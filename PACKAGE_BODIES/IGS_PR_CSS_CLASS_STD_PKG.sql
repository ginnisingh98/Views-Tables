--------------------------------------------------------
--  DDL for Package Body IGS_PR_CSS_CLASS_STD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_CSS_CLASS_STD_PKG" AS
/* $Header: IGSQI31B.pls 115.5 2002/11/29 03:22:16 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pr_css_class_std%ROWTYPE;
  new_references igs_pr_css_class_std%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_pr_css_class_std_id           IN     NUMBER      DEFAULT NULL,
    x_igs_pr_cs_schdl_id                IN     NUMBER      DEFAULT NULL,
    x_igs_pr_class_std_id               IN     NUMBER      DEFAULT NULL,
    x_min_cp                            IN     NUMBER      DEFAULT NULL,
    x_max_cp                            IN     NUMBER      DEFAULT NULL,
    x_acad_year                         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_CSS_CLASS_STD
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
    new_references.igs_pr_css_class_std_id           := x_igs_pr_css_class_std_id;
    new_references.igs_pr_cs_schdl_id                := x_igs_pr_cs_schdl_id;
    new_references.igs_pr_class_std_id               := x_igs_pr_class_std_id;
    new_references.min_cp                            := x_min_cp;
    new_references.max_cp                            := x_max_cp;
    new_references.acad_year                         := x_acad_year;

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
  ||  Created By : avenkatr
  ||  Created On : 18-JUL-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.igs_pr_class_std_id,
           new_references.igs_pr_cs_schdl_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.igs_pr_cs_schdl_id = new_references.igs_pr_cs_schdl_id)) OR
        ((new_references.igs_pr_cs_schdl_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pr_cs_schdl_pkg.get_pk_for_validation (
                new_references.igs_pr_cs_schdl_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.igs_pr_class_std_id = new_references.igs_pr_class_std_id)) OR
        ((new_references.igs_pr_class_std_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pr_class_std_pkg.get_pk_for_validation (
                new_references.igs_pr_class_std_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_igs_pr_css_class_std_id           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_css_class_std
      WHERE    igs_pr_css_class_std_id = x_igs_pr_css_class_std_id
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
    x_igs_pr_class_std_id               IN     NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 18-JUL-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_css_class_std
      WHERE    igs_pr_class_std_id = x_igs_pr_class_std_id
      AND      igs_pr_cs_schdl_id = x_igs_pr_cs_schdl_id
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


  PROCEDURE get_fk_igs_pr_cs_schdl (
    x_igs_pr_cs_schdl_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_css_class_std
      WHERE   ((igs_pr_cs_schdl_id = x_igs_pr_cs_schdl_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_PCCS_PCSC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pr_cs_schdl;


  PROCEDURE get_fk_igs_pr_class_std (
    x_igs_pr_class_std_id               IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_css_class_std
      WHERE   ((igs_pr_class_std_id = x_igs_pr_class_std_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_PCCS_PCS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pr_class_std;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_pr_css_class_std_id           IN     NUMBER      DEFAULT NULL,
    x_igs_pr_cs_schdl_id                IN     NUMBER      DEFAULT NULL,
    x_igs_pr_class_std_id               IN     NUMBER      DEFAULT NULL,
    x_min_cp                            IN     NUMBER      DEFAULT NULL,
    x_max_cp                            IN     NUMBER      DEFAULT NULL,
    x_acad_year                         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
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
      x_igs_pr_css_class_std_id,
      x_igs_pr_cs_schdl_id,
      x_igs_pr_class_std_id,
      x_min_cp,
      x_max_cp,
      x_acad_year,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.igs_pr_css_class_std_id
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
             new_references.igs_pr_css_class_std_id
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
    x_igs_pr_css_class_std_id           IN OUT NOCOPY NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_igs_pr_class_std_id               IN     NUMBER,
    x_min_cp                            IN     NUMBER,
    x_max_cp                            IN     NUMBER,
    x_acad_year                         IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pr_css_class_std
      WHERE    igs_pr_css_class_std_id           = x_igs_pr_css_class_std_id;

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

    SELECT    igs_pr_css_class_std_s.NEXTVAL
    INTO      x_igs_pr_css_class_std_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_igs_pr_css_class_std_id           => x_igs_pr_css_class_std_id,
      x_igs_pr_cs_schdl_id                => x_igs_pr_cs_schdl_id,
      x_igs_pr_class_std_id               => x_igs_pr_class_std_id,
      x_min_cp                            => x_min_cp,
      x_max_cp                            => x_max_cp,
      x_acad_year                         => x_acad_year,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_pr_css_class_std (
      igs_pr_css_class_std_id,
      igs_pr_cs_schdl_id,
      igs_pr_class_std_id,
      min_cp,
      max_cp,
      acad_year,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.igs_pr_css_class_std_id,
      new_references.igs_pr_cs_schdl_id,
      new_references.igs_pr_class_std_id,
      new_references.min_cp,
      new_references.max_cp,
      new_references.acad_year,
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
    x_igs_pr_css_class_std_id           IN     NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_igs_pr_class_std_id               IN     NUMBER,
    x_min_cp                            IN     NUMBER,
    x_max_cp                            IN     NUMBER,
    x_acad_year                         IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        igs_pr_cs_schdl_id,
        igs_pr_class_std_id,
        min_cp,
        max_cp,
        acad_year
      FROM  igs_pr_css_class_std
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
        (tlinfo.igs_pr_cs_schdl_id = x_igs_pr_cs_schdl_id)
        AND (tlinfo.igs_pr_class_std_id = x_igs_pr_class_std_id)
        AND ((tlinfo.min_cp = x_min_cp) OR ((tlinfo.min_cp IS NULL) AND (X_min_cp IS NULL)))
        AND ((tlinfo.max_cp = x_max_cp) OR ((tlinfo.max_cp IS NULL) AND (X_max_cp IS NULL)))
        AND ((tlinfo.acad_year = x_acad_year) OR ((tlinfo.acad_year IS NULL) AND (X_acad_year IS NULL)))
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
    x_igs_pr_css_class_std_id           IN     NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_igs_pr_class_std_id               IN     NUMBER,
    x_min_cp                            IN     NUMBER,
    x_max_cp                            IN     NUMBER,
    x_acad_year                         IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
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
      x_igs_pr_css_class_std_id           => x_igs_pr_css_class_std_id,
      x_igs_pr_cs_schdl_id                => x_igs_pr_cs_schdl_id,
      x_igs_pr_class_std_id               => x_igs_pr_class_std_id,
      x_min_cp                            => x_min_cp,
      x_max_cp                            => x_max_cp,
      x_acad_year                         => x_acad_year,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_pr_css_class_std
      SET
        igs_pr_cs_schdl_id                = new_references.igs_pr_cs_schdl_id,
        igs_pr_class_std_id               = new_references.igs_pr_class_std_id,
        min_cp                            = new_references.min_cp,
        max_cp                            = new_references.max_cp,
        acad_year                         = new_references.acad_year,
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
    x_igs_pr_css_class_std_id           IN OUT NOCOPY NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_igs_pr_class_std_id               IN     NUMBER,
    x_min_cp                            IN     NUMBER,
    x_max_cp                            IN     NUMBER,
    x_acad_year                         IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pr_css_class_std
      WHERE    igs_pr_css_class_std_id           = x_igs_pr_css_class_std_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_igs_pr_css_class_std_id,
        x_igs_pr_cs_schdl_id,
        x_igs_pr_class_std_id,
        x_min_cp,
        x_max_cp,
        x_acad_year,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_igs_pr_css_class_std_id,
      x_igs_pr_cs_schdl_id,
      x_igs_pr_class_std_id,
      x_min_cp,
      x_max_cp,
      x_acad_year,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JUL-2001
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

    DELETE FROM igs_pr_css_class_std
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pr_css_class_std_pkg;

/
