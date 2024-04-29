--------------------------------------------------------
--  DDL for Package Body IGS_HE_CODE_ASS_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_CODE_ASS_VAL_PKG" AS
/* $Header: IGSWI02B.pls 115.4 2002/11/29 04:34:22 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_code_ass_val%ROWTYPE;
  new_references igs_he_code_ass_val%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_association_code                  IN     VARCHAR2    ,
    x_sequence                          IN     NUMBER      ,
    x_association_type                  IN     VARCHAR2    ,
    x_main_source                       IN     VARCHAR2    ,
    x_secondary_source                  IN     VARCHAR2    ,
    x_condition                         IN     VARCHAR2    ,
    x_display_title                     IN     VARCHAR2    ,
    x_system_defined                    IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_CODE_ASS_VAL
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
    new_references.association_code                  := x_association_code;
    new_references.sequence                          := x_sequence;
    new_references.association_type                  := x_association_type;
    new_references.main_source                       := x_main_source;
    new_references.secondary_source                  := x_secondary_source;
    new_references.condition                         := x_condition;
    new_references.display_title                     := x_display_title;
    new_references.system_defined                    := x_system_defined;

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
  ||  Created On : 15-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.association_code = new_references.association_code)) OR
        ((new_references.association_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_code_assoc_pkg.get_pk_for_validation (
                new_references.association_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_code_ass_val
      WHERE    association_code = x_association_code
      AND      sequence = x_sequence
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


  PROCEDURE get_fk_igs_he_code_assoc (
    x_association_code                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_code_ass_val
      WHERE   ((association_code = x_association_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HECDAVAL_HECDASCH_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_he_code_assoc;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_association_code                  IN     VARCHAR2    ,
    x_sequence                          IN     NUMBER      ,
    x_association_type                  IN     VARCHAR2    ,
    x_main_source                       IN     VARCHAR2    ,
    x_secondary_source                  IN     VARCHAR2    ,
    x_condition                         IN     VARCHAR2    ,
    x_display_title                     IN     VARCHAR2    ,
    x_system_defined                    IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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
      x_association_code,
      x_sequence,
      x_association_type,
      x_main_source,
      x_secondary_source,
      x_condition,
      x_display_title,
      x_system_defined,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.association_code,
             new_references.sequence
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
             new_references.association_code,
             new_references.sequence
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
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_association_type                  IN     VARCHAR2,
    x_main_source                       IN     VARCHAR2,
    x_secondary_source                  IN     VARCHAR2,
    x_condition                         IN     VARCHAR2,
    x_display_title                     IN     VARCHAR2,
    x_system_defined                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_code_ass_val
      WHERE    association_code                  = x_association_code
      AND      sequence                          = x_sequence;

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
      x_association_code                  => x_association_code,
      x_sequence                          => x_sequence,
      x_association_type                  => x_association_type,
      x_main_source                       => x_main_source,
      x_secondary_source                  => x_secondary_source,
      x_condition                         => x_condition,
      x_display_title                     => x_display_title,
      x_system_defined                    => x_system_defined,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_code_ass_val (
      association_code,
      sequence,
      association_type,
      main_source,
      secondary_source,
      condition,
      display_title,
      system_defined,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.association_code,
      new_references.sequence,
      new_references.association_type,
      new_references.main_source,
      new_references.secondary_source,
      new_references.condition,
      new_references.display_title,
      new_references.system_defined,
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
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_association_type                  IN     VARCHAR2,
    x_main_source                       IN     VARCHAR2,
    x_secondary_source                  IN     VARCHAR2,
    x_condition                         IN     VARCHAR2,
    x_display_title                     IN     VARCHAR2,
    x_system_defined                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        association_type,
        main_source,
        secondary_source,
        condition,
        display_title,
        system_defined
      FROM  igs_he_code_ass_val
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
        (tlinfo.association_type = x_association_type)
        AND (tlinfo.main_source = x_main_source)
        AND ((tlinfo.secondary_source = x_secondary_source) OR ((tlinfo.secondary_source IS NULL) AND (X_secondary_source IS NULL)))
        AND ((tlinfo.condition = x_condition) OR ((tlinfo.condition IS NULL) AND (X_condition IS NULL)))
        AND (tlinfo.display_title = x_display_title)
        AND (tlinfo.system_defined = x_system_defined)
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
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_association_type                  IN     VARCHAR2,
    x_main_source                       IN     VARCHAR2,
    x_secondary_source                  IN     VARCHAR2,
    x_condition                         IN     VARCHAR2,
    x_display_title                     IN     VARCHAR2,
    x_system_defined                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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
      x_association_code                  => x_association_code,
      x_sequence                          => x_sequence,
      x_association_type                  => x_association_type,
      x_main_source                       => x_main_source,
      x_secondary_source                  => x_secondary_source,
      x_condition                         => x_condition,
      x_display_title                     => x_display_title,
      x_system_defined                    => x_system_defined,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_code_ass_val
      SET
        association_type                  = new_references.association_type,
        main_source                       = new_references.main_source,
        secondary_source                  = new_references.secondary_source,
        condition                         = new_references.condition,
        display_title                     = new_references.display_title,
        system_defined                    = new_references.system_defined,
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
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_association_type                  IN     VARCHAR2,
    x_main_source                       IN     VARCHAR2,
    x_secondary_source                  IN     VARCHAR2,
    x_condition                         IN     VARCHAR2,
    x_display_title                     IN     VARCHAR2,
    x_system_defined                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_code_ass_val
      WHERE    association_code                  = x_association_code
      AND      sequence                          = x_sequence;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_association_code,
        x_sequence,
        x_association_type,
        x_main_source,
        x_secondary_source,
        x_condition,
        x_display_title,
        x_system_defined,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_association_code,
      x_sequence,
      x_association_type,
      x_main_source,
      x_secondary_source,
      x_condition,
      x_display_title,
      x_system_defined,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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

    DELETE FROM igs_he_code_ass_val
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_code_ass_val_pkg;

/
