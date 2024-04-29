--------------------------------------------------------
--  DDL for Package Body IGS_PR_INST_STA_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_INST_STA_REF_PKG" AS
/* $Header: IGSQI35B.pls 120.1 2005/11/21 02:01:00 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pr_inst_sta_ref%ROWTYPE;
  new_references igs_pr_inst_sta_ref%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_stat_type                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_ref_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_include_or_exclude                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_reference_cd_type                 IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pr_inst_sta_ref
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
    new_references.stat_type                         := x_stat_type;
    new_references.unit_ref_cd                       := x_unit_ref_cd;
    new_references.include_or_exclude                := x_include_or_exclude;

    new_references.reference_cd_type                 := x_reference_cd_type;

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
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.stat_type = new_references.stat_type)) OR
        ((new_references.stat_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pr_inst_stat_pkg.get_pk_for_validation (
                new_references.stat_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_stat_type                         IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2,
    x_reference_cd_type                 IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_inst_sta_ref
      WHERE    stat_type = x_stat_type
      AND      unit_ref_cd = x_unit_ref_cd
      AND      reference_cd_type = x_reference_cd_type
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


  PROCEDURE get_fk_igs_pr_inst_stat (
    x_stat_type                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_inst_sta_ref
      WHERE   ((stat_type = x_stat_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_INSTR_STTY_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pr_inst_stat;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_stat_type                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_ref_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_include_or_exclude                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_reference_cd_type                 IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
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
      x_stat_type,
      x_unit_ref_cd,
      x_include_or_exclude,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_reference_cd_type
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.stat_type,
             new_references.unit_ref_cd,
             new_references.reference_cd_type
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
             new_references.stat_type,
             new_references.unit_ref_cd,
             new_references.reference_cd_type
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
    x_stat_type                         IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2,
    x_include_or_exclude                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_reference_cd_type                 IN     VARCHAR2

  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pr_inst_sta_ref
      WHERE    stat_type                         = x_stat_type
      AND      unit_ref_cd                       = x_unit_ref_cd;

    CURSOR c1 IS
      SELECT include_or_exclude
      FROM igs_pr_inst_sta_ref
      WHERE     stat_type                       = x_stat_type;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_include_or_exclude         igs_pr_inst_sta_ref.include_or_exclude%TYPE;
    l_c1 c1%ROWTYPE;

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
      x_stat_type                         => x_stat_type,
      x_unit_ref_cd                       => x_unit_ref_cd,
      x_include_or_exclude                => x_include_or_exclude,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_reference_cd_type                 => x_reference_cd_type
    );
    -- The code written in the For Loop checks whether the current
    -- Unit Reference Code is having same value for the field Include
    -- or Exclude as existing Unit Reference Codes. If not it raises
    -- an Error indicating there exist Unit ReferenceCodes with differnt
    -- Include or Exclude value.
    FOR l_c1 IN c1 LOOP
        l_include_or_exclude := l_c1.include_or_exclude;
        IF l_include_or_exclude <> x_include_or_exclude THEN
                fnd_message.set_name ('IGS', 'IGS_PR_INCLUDE_OR_EXCLUDE');
		fnd_message.set_token('Include_or_Exclude1',x_include_or_exclude);
                fnd_message.set_token('Include_or_Exclude2',l_include_or_exclude);
                igs_ge_msg_stack.add;
                app_exception.raise_exception;
        END IF;
    END LOOP;

    INSERT INTO igs_pr_inst_sta_ref (
      stat_type,
      unit_ref_cd,
      include_or_exclude,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      reference_cd_type
    ) VALUES (
      new_references.stat_type,
      new_references.unit_ref_cd,
      new_references.include_or_exclude,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_reference_cd_type
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
    x_stat_type                         IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2,
    x_include_or_exclude                IN     VARCHAR2,
    x_reference_cd_type                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        include_or_exclude
      FROM  igs_pr_inst_sta_ref
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
        (tlinfo.include_or_exclude = x_include_or_exclude)
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
    x_stat_type                         IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2,
    x_include_or_exclude                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_reference_cd_type                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
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
      x_stat_type                         => x_stat_type,
      x_unit_ref_cd                       => x_unit_ref_cd,
      x_include_or_exclude                => x_include_or_exclude,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_reference_cd_type                 => x_reference_cd_type
    );

    UPDATE igs_pr_inst_sta_ref
      SET
        include_or_exclude                = new_references.include_or_exclude,
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
    x_stat_type                         IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2,
    x_include_or_exclude                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_reference_cd_type                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pr_inst_sta_ref
      WHERE    stat_type                         = x_stat_type
      AND      unit_ref_cd                       = x_unit_ref_cd;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_stat_type,
        x_unit_ref_cd,
        x_include_or_exclude,
        x_mode,
        x_reference_cd_type
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_stat_type,
      x_unit_ref_cd,
      x_include_or_exclude,
      x_mode,
      x_reference_cd_type
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : nbehera
  ||  Created On : 02-NOV-2001
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

    DELETE FROM igs_pr_inst_sta_ref
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pr_inst_sta_ref_pkg;

/
