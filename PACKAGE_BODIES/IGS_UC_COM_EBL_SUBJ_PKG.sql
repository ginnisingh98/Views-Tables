--------------------------------------------------------
--  DDL for Package Body IGS_UC_COM_EBL_SUBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_COM_EBL_SUBJ_PKG" AS
/* $Header: IGSXI08B.pls 115.8 2003/06/11 10:30:19 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_com_ebl_subj%ROWTYPE;
  new_references igs_uc_com_ebl_subj%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_subject_id                        IN     NUMBER  ,
    x_year                              IN     NUMBER  ,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_COM_EBL_SUBJ
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
    new_references.subject_id                        := x_subject_id;
    new_references.year                              := x_year;
    new_references.sitting                           := x_sitting;
    new_references.awarding_body                     := x_awarding_body;
    new_references.external_ref                      := x_external_ref;
    new_references.exam_level                        := x_exam_level;
    new_references.title                             := x_title;
    new_references.subject_code                      := x_subject_code;
    new_references.imported                          := x_imported;

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

    IF (((old_references.awarding_body = new_references.awarding_body) AND
         (old_references.sitting = new_references.sitting) AND
         (old_references.year = new_references.year)) OR
        ((new_references.awarding_body IS NULL) OR
         (new_references.sitting IS NULL) OR
         (new_references.year IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_ref_awrdbdy_pkg.get_pk_for_validation (
                new_references.awarding_body,
                new_references.sitting,
                new_references.year
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_uc_app_results_pkg.get_fk_igs_uc_com_ebl_subj (
      old_references.subject_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_subject_id                        IN     NUMBER
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
      FROM     igs_uc_com_ebl_subj
      WHERE    subject_id = x_subject_id ;

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


  PROCEDURE get_fk_igs_uc_ref_awrdbdy (
    x_awarding_body                     IN     VARCHAR2,
    x_sitting                           IN     VARCHAR2,
    x_year                              IN     NUMBER
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
      FROM     igs_uc_com_ebl_subj
      WHERE   ((awarding_body = x_awarding_body) AND
               (sitting = x_sitting) AND
               (year = x_year));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCCOES_UCREAB_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_ref_awrdbdy;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_subject_id                        IN     NUMBER  ,
    x_year                              IN     NUMBER  ,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
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
  ||  smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_subject_id,
      x_year,
      x_sitting,
      x_awarding_body,
      x_external_ref,
      x_exam_level,
      x_title,
      x_subject_code,
      x_imported,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.subject_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.subject_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_subject_id                        IN OUT NOCOPY NUMBER,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_com_ebl_subj
      WHERE    subject_id                        = x_subject_id;

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
      x_subject_id                        => x_subject_id,
      x_year                              => x_year,
      x_sitting                           => x_sitting,
      x_awarding_body                     => x_awarding_body,
      x_external_ref                      => x_external_ref,
      x_exam_level                        => x_exam_level,
      x_title                             => x_title,
      x_subject_code                      => x_subject_code,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_com_ebl_subj (
      subject_id,
      year,
      sitting,
      awarding_body,
      external_ref,
      exam_level,
      title,
      subject_code,
      imported,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.subject_id,
      new_references.year,
      new_references.sitting,
      new_references.awarding_body,
      new_references.external_ref,
      new_references.exam_level,
      new_references.title,
      new_references.subject_code,
      new_references.imported,
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
    x_subject_id                        IN     NUMBER,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        year,
        sitting,
        awarding_body,
        external_ref,
        exam_level,
        title,
        subject_code,
        imported
      FROM  igs_uc_com_ebl_subj
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
        (tlinfo.year = x_year)
        AND (tlinfo.sitting = x_sitting)
        AND (tlinfo.awarding_body = x_awarding_body)
        AND ((tlinfo.external_ref = x_external_ref) OR ((tlinfo.external_ref IS NULL) AND (X_external_ref IS NULL)))
        AND (tlinfo.exam_level = x_exam_level)
        AND ((tlinfo.title = x_title) OR ((tlinfo.title IS NULL) AND (X_title IS NULL)))
        AND (tlinfo.subject_code = x_subject_code)
        AND (tlinfo.imported = x_imported)
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
    x_subject_id                        IN     NUMBER,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208 |
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
      x_subject_id                        => x_subject_id,
      x_year                              => x_year,
      x_sitting                           => x_sitting,
      x_awarding_body                     => x_awarding_body,
      x_external_ref                      => x_external_ref,
      x_exam_level                        => x_exam_level,
      x_title                             => x_title,
      x_subject_code                      => x_subject_code,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_com_ebl_subj
      SET
        year                              = new_references.year,
        sitting                           = new_references.sitting,
        awarding_body                     = new_references.awarding_body,
        external_ref                      = new_references.external_ref,
        exam_level                        = new_references.exam_level,
        title                             = new_references.title,
        subject_code                      = new_references.subject_code,
        imported                          = new_references.imported,
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
    x_subject_id                        IN OUT NOCOPY NUMBER,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_external_ref                      IN     VARCHAR2,
    x_exam_level                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208 |
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_com_ebl_subj
      WHERE    subject_id                        = x_subject_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_subject_id,
        x_year,
        x_sitting,
        x_awarding_body,
        x_external_ref,
        x_exam_level,
        x_title,
        x_subject_code,
        x_imported,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_subject_id,
      x_year,
      x_sitting,
      x_awarding_body,
      x_external_ref,
      x_exam_level,
      x_title,
      x_subject_code,
      x_imported,
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

    DELETE FROM igs_uc_com_ebl_subj
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_com_ebl_subj_pkg;

/
