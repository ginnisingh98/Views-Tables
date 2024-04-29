--------------------------------------------------------
--  DDL for Package Body IGS_AD_PESTAT_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PESTAT_GROUP_PKG" AS
/* $Header: IGSAIG4B.pls 120.1 2005/08/03 06:46:46 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_pestat_group%ROWTYPE;
  new_references igs_ad_pestat_group%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_group_number                      IN     NUMBER      DEFAULT NULL,
    x_admission_application_type        IN     VARCHAR2    DEFAULT NULL,
    x_group_min                         IN     NUMBER      DEFAULT NULL,
    x_self_message                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_group_name                        IN     VARCHAR2    DEFAULT NULL,
    x_group_required_flag               IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ad_pestat_group
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
    new_references.group_number                      := x_group_number;
    new_references.admission_application_type        := x_admission_application_type;
    new_references.group_min                         := x_group_min;
    new_references.self_message                      := x_self_message;

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

    new_references.group_name                        := x_group_name;
    new_references.group_required_flag               := x_group_required_flag;


  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.admission_application_type = new_references.admission_application_type)) OR
        ((new_references.admission_application_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_ss_appl_typ_pkg.get_pk_for_validation (
                new_references.admission_application_type ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pestat_group
      WHERE    group_number = x_group_number
      AND      admission_application_type = x_admission_application_type
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


  PROCEDURE get_fk_igs_ad_ss_appl_typ (
    x_admission_appl_type               IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pestat_group
      WHERE   ((admission_application_type = x_admission_appl_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_PSG_AT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_ss_appl_typ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_group_number                      IN     NUMBER      DEFAULT NULL,
    x_admission_application_type        IN     VARCHAR2    DEFAULT NULL,
    x_group_min                         IN     NUMBER      DEFAULT NULL,
    x_self_message                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_group_name                        IN     VARCHAR2    DEFAULT NULL,
    x_group_required_flag               IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
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
      x_group_number,
      x_admission_application_type,
      x_group_min,
      x_self_message,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_group_name,
      x_group_required_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.group_number,
             new_references.admission_application_type
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
             new_references.group_number,
             new_references.admission_application_type
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
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2,
    x_group_min                         IN     NUMBER,
    x_self_message                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_group_name                        IN     VARCHAR2,
    x_group_required_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_pestat_group
      WHERE    group_number                      = x_group_number
      AND      admission_application_type        = x_admission_application_type;

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
      x_group_number                      => x_group_number,
      x_admission_application_type        => x_admission_application_type,
      x_group_min                         => x_group_min,
      x_self_message                      => x_self_message,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_group_name                        => x_group_name,
      x_group_required_flag		  => x_group_required_flag
    );

    INSERT INTO igs_ad_pestat_group (
      group_number,
      admission_application_type,
      group_min,
      self_message,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      group_name,
      group_required_flag
    ) VALUES (
      new_references.group_number,
      new_references.admission_application_type,
      new_references.group_min,
      new_references.self_message,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.group_name,
      new_references.group_required_flag
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
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2,
    x_group_min                         IN     NUMBER,
    x_self_message                      IN     VARCHAR2,
    x_group_name                        IN     VARCHAR2,
    x_group_required_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT *
      FROM  igs_ad_pestat_group
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
        (tlinfo.group_min = x_group_min)
        AND ((tlinfo.self_message = x_self_message) OR ((tlinfo.self_message IS NULL) AND (X_self_message IS NULL)))
	AND ((tlinfo.group_name = x_group_name) OR ((tlinfo.group_name IS NULL) AND (X_group_name IS NULL)))
	AND ((tlinfo.group_required_flag = x_group_required_flag) OR ((tlinfo.group_required_flag IS NULL) AND (x_group_required_flag IS NULL)))
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
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2,
    x_group_min                         IN     NUMBER,
    x_self_message                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_group_name                        IN     VARCHAR2,
    x_group_required_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
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
      x_group_number                      => x_group_number,
      x_admission_application_type        => x_admission_application_type,
      x_group_min                         => x_group_min,
      x_self_message                      => x_self_message,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_group_name                        => x_group_name,
      x_group_required_flag		  => x_group_required_flag
    );

    UPDATE igs_ad_pestat_group
      SET
        group_min                         = new_references.group_min,
        self_message                      = new_references.self_message,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        group_name                        = x_group_name,
        group_required_flag		  = x_group_required_flag
     WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_number                      IN     NUMBER,
    x_admission_application_type        IN     VARCHAR2,
    x_group_min                         IN     NUMBER,
    x_self_message                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_group_name                        IN     VARCHAR2,
    x_group_required_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_pestat_group
      WHERE    group_number                      = x_group_number
      AND      admission_application_type        = x_admission_application_type;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_group_number,
        x_admission_application_type,
        x_group_min,
        x_self_message,
        x_mode,
	x_group_name,
        x_group_required_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_group_number,
      x_admission_application_type,
      x_group_min,
      x_self_message,
      x_mode,
      x_group_name,
      x_group_required_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
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

    DELETE FROM igs_ad_pestat_group
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_pestat_group_pkg;

/
