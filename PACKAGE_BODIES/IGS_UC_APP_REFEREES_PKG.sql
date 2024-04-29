--------------------------------------------------------
--  DDL for Package Body IGS_UC_APP_REFEREES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_APP_REFEREES_PKG" AS
/* $Header: IGSXI52B.pls 120.1 2005/07/31 17:57:12 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_app_referees%ROWTYPE;
  new_references igs_uc_app_referees%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2,
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
      FROM     igs_uc_app_referees
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
    new_references.referee_name                      := x_referee_name;
    new_references.referee_post                      := x_referee_post;
    new_references.estab_name                        := x_estab_name;
    new_references.address1                          := x_address1;
    new_references.address2                          := x_address2;
    new_references.address3                          := x_address3;
    new_references.address4                          := x_address4;
    new_references.telephone                         := x_telephone;
    new_references.fax                               := x_fax;
    new_references.email                             := x_email;
    new_references.statement                         := x_statement;
    new_references.predicted_grades                  := x_predicted_grades;

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
           new_references.referee_name
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
    x_referee_name                      IN     VARCHAR2
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
      FROM     igs_uc_app_referees
      WHERE    app_no = x_app_no
      AND      referee_name = x_referee_name
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
      FROM     igs_uc_app_referees
      WHERE   ((app_no = x_app_no));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UAPREF_UCAP_FK');
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
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2,
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
      x_referee_name,
      x_referee_post,
      x_estab_name,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_telephone,
      x_fax,
      x_email,
      x_statement,
      x_predicted_grades,
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
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2,
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_APP_REFEREES_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_app_no                            => x_app_no,
      x_referee_name                      => x_referee_name,
      x_referee_post                      => x_referee_post,
      x_estab_name                        => x_estab_name,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_telephone                         => x_telephone,
      x_fax                               => x_fax,
      x_email                             => x_email,
      x_statement                         => x_statement,
      x_predicted_grades                  => x_predicted_grades,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_app_referees (
      app_no,
      referee_name,
      referee_post,
      estab_name,
      address1,
      address2,
      address3,
      address4,
      telephone,
      fax,
      email,
      statement,
      predicted_grades,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.app_no,
      new_references.referee_name,
      new_references.referee_post,
      new_references.estab_name,
      new_references.address1,
      new_references.address2,
      new_references.address3,
      new_references.address4,
      new_references.telephone,
      new_references.fax,
      new_references.email,
      new_references.statement,
      new_references.predicted_grades,
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
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2
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
        referee_name,
        referee_post,
        estab_name,
        address1,
        address2,
        address3,
        address4,
        telephone,
        fax,
        email,
        statement,
        predicted_grades
      FROM  igs_uc_app_referees
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
        AND (tlinfo.referee_name = x_referee_name)
        AND ((tlinfo.referee_post = x_referee_post) OR ((tlinfo.referee_post IS NULL) AND (X_referee_post IS NULL)))
        AND ((tlinfo.estab_name = x_estab_name) OR ((tlinfo.estab_name IS NULL) AND (X_estab_name IS NULL)))
        AND ((tlinfo.address1 = x_address1) OR ((tlinfo.address1 IS NULL) AND (X_address1 IS NULL)))
        AND ((tlinfo.address2 = x_address2) OR ((tlinfo.address2 IS NULL) AND (X_address2 IS NULL)))
        AND ((tlinfo.address3 = x_address3) OR ((tlinfo.address3 IS NULL) AND (X_address3 IS NULL)))
        AND ((tlinfo.address4 = x_address4) OR ((tlinfo.address4 IS NULL) AND (X_address4 IS NULL)))
        AND ((tlinfo.telephone = x_telephone) OR ((tlinfo.telephone IS NULL) AND (X_telephone IS NULL)))
        AND ((tlinfo.fax = x_fax) OR ((tlinfo.fax IS NULL) AND (X_fax IS NULL)))
        AND ((tlinfo.email = x_email) OR ((tlinfo.email IS NULL) AND (X_email IS NULL)))
--        AND ((tlinfo.statement = x_statement) OR ((tlinfo.statement IS NULL) AND (X_statement IS NULL)))
        AND ((tlinfo.predicted_grades = x_predicted_grades) OR ((tlinfo.predicted_grades IS NULL) AND (X_predicted_grades IS NULL)))
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
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2,
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_APP_REFEREES_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_app_no                            => x_app_no,
      x_referee_name                      => x_referee_name,
      x_referee_post                      => x_referee_post,
      x_estab_name                        => x_estab_name,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_telephone                         => x_telephone,
      x_fax                               => x_fax,
      x_email                             => x_email,
      x_statement                         => x_statement,
      x_predicted_grades                  => x_predicted_grades,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_app_referees
      SET
        app_no                            = new_references.app_no,
        referee_name                      = new_references.referee_name,
        referee_post                      = new_references.referee_post,
        estab_name                        = new_references.estab_name,
        address1                          = new_references.address1,
        address2                          = new_references.address2,
        address3                          = new_references.address3,
        address4                          = new_references.address4,
        telephone                         = new_references.telephone,
        fax                               = new_references.fax,
        email                             = new_references.email,
        statement                         = new_references.statement,
        predicted_grades                  = new_references.predicted_grades,
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
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2,
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
      FROM     igs_uc_app_referees
      WHERE    app_no = x_app_no;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_app_no,
        x_referee_name,
        x_referee_post,
        x_estab_name,
        x_address1,
        x_address2,
        x_address3,
        x_address4,
        x_telephone,
        x_fax,
        x_email,
        x_statement,
        x_predicted_grades,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_app_no,
      x_referee_name,
      x_referee_post,
      x_estab_name,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_telephone,
      x_fax,
      x_email,
      x_statement,
      x_predicted_grades,
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

    DELETE FROM igs_uc_app_referees
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_app_referees_pkg;


/
