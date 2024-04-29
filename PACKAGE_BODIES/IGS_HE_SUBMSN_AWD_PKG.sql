--------------------------------------------------------
--  DDL for Package Body IGS_HE_SUBMSN_AWD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_SUBMSN_AWD_PKG" AS
/* $Header: IGSWI49B.pls 120.0 2006/02/06 19:23:14 jtmathew noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_submsn_awd%ROWTYPE;
  new_references igs_he_submsn_awd%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sub_awd_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_he_submsn_awd
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
    new_references.sub_awd_id                        := x_sub_awd_id;
    new_references.submission_name                   := x_submission_name;
    new_references.type                              := x_type;
    new_references.key1                              := x_key1;
    new_references.key2                              := x_key2;
    new_references.key3                              := x_key3;
    new_references.award_start_date                  := x_award_start_date;
    new_references.award_end_date                    := x_award_end_date;

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
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.submission_name,
           new_references.type,
           new_references.key1,
           new_references.key2,
           new_references.key3
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.submission_name = new_references.submission_name)) OR
        ((new_references.submission_name IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_submsn_header_pkg.get_pk_for_validation (
                new_references.submission_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_sub_awd_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_submsn_awd
      WHERE    sub_awd_id = x_sub_awd_id
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
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_submsn_awd
      WHERE    submission_name = x_submission_name
      AND      type = x_type
      AND      key1 = x_key1
      AND      ((key2 = x_key2) OR (key2 IS NULL AND x_key2 IS NULL))
      AND      ((key3 = x_key3) OR (key3 IS NULL AND x_key3 IS NULL))
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


  PROCEDURE get_fk_igs_he_submsn_header (
    x_submission_name                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_submsn_awd
      WHERE   ((submission_name = x_submission_name));

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

  END get_fk_igs_he_submsn_header;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sub_awd_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
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
      x_sub_awd_id,
      x_submission_name,
      x_type,
      x_key1,
      x_key2,
      x_key3,
      x_award_start_date,
      x_award_end_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.sub_awd_id
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
             new_references.sub_awd_id
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
    x_sub_awd_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_SUBMSN_AWD_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_sub_awd_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sub_awd_id                        => x_sub_awd_id,
      x_submission_name                   => x_submission_name,
      x_type                              => x_type,
      x_key1                              => x_key1,
      x_key2                              => x_key2,
      x_key3                              => x_key3,
      x_award_start_date                  => x_award_start_date,
      x_award_end_date                    => x_award_end_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_submsn_awd (
      sub_awd_id,
      submission_name,
      type,
      key1,
      key2,
      key3,
      award_start_date,
      award_end_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_he_submsn_awd_s.NEXTVAL,
      new_references.submission_name,
      new_references.type,
      new_references.key1,
      new_references.key2,
      new_references.key3,
      new_references.award_start_date,
      new_references.award_end_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, sub_awd_id INTO x_rowid, x_sub_awd_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_awd_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE
  ) AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        submission_name,
        type,
        key1,
        key2,
        key3,
        award_start_date,
        award_end_date
      FROM  igs_he_submsn_awd
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
        (tlinfo.submission_name = x_submission_name)
        AND (tlinfo.type = x_type)
        AND (tlinfo.key1 = x_key1)
        AND ((tlinfo.key2 = x_key2) OR ((tlinfo.key2 IS NULL) AND (X_key2 IS NULL)))
        AND ((tlinfo.key3 = x_key3) OR ((tlinfo.key3 IS NULL) AND (X_key3 IS NULL)))
        AND (tlinfo.award_start_date = x_award_start_date)
        AND (tlinfo.award_end_date = x_award_end_date)
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
    x_sub_awd_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_SUBMSN_AWD_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_sub_awd_id                        => x_sub_awd_id,
      x_submission_name                   => x_submission_name,
      x_type                              => x_type,
      x_key1                              => x_key1,
      x_key2                              => x_key2,
      x_key3                              => x_key3,
      x_award_start_date                  => x_award_start_date,
      x_award_end_date                    => x_award_end_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_submsn_awd
      SET
        submission_name                   = new_references.submission_name,
        type                              = new_references.type,
        key1                              = new_references.key1,
        key2                              = new_references.key2,
        key3                              = new_references.key3,
        award_start_date                  = new_references.award_start_date,
        award_end_date                    = new_references.award_end_date,
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
    x_sub_awd_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_submsn_awd
      WHERE    sub_awd_id                        = x_sub_awd_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sub_awd_id,
        x_submission_name,
        x_type,
        x_key1,
        x_key2,
        x_key3,
        x_award_start_date,
        x_award_end_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sub_awd_id,
      x_submission_name,
      x_type,
      x_key1,
      x_key2,
      x_key3,
      x_award_start_date,
      x_award_end_date,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : jay.mathew@oracle.com
  ||  Created On : 04-DEC-2005
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

    DELETE FROM igs_he_submsn_awd
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_submsn_awd_pkg;

/