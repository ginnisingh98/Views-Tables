--------------------------------------------------------
--  DDL for Package Body IGF_DB_PAYS_PRG_T_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_PAYS_PRG_T_PKG" AS
/* $Header: IGFDI08B.pls 115.2 2002/11/28 14:14:50 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_db_pays_prg_t%ROWTYPE;
  new_references igf_db_pays_prg_t%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_dbpays_id                         IN     NUMBER  ,
    x_base_id                           IN     NUMBER  ,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER  ,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 10-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_db_pays_prg_t
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
    new_references.dbpays_id                         := x_dbpays_id;
    new_references.base_id                           := x_base_id;
    new_references.program_cd                        := x_program_cd;
    new_references.prg_ver_num                       := x_prg_ver_num;
    new_references.unit_cd                           := x_unit_cd;
    new_references.unit_ver_num                      := x_unit_ver_num;

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


  FUNCTION get_pk_for_validation (
    x_dbpays_id                         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasingh
  ||  Created On : 10-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_pays_prg_t
      WHERE    dbpays_id = x_dbpays_id
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_dbpays_id                         IN     NUMBER  ,
    x_base_id                           IN     NUMBER  ,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER  ,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 10-JAN-2002
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
      x_dbpays_id,
      x_base_id,
      x_program_cd,
      x_prg_ver_num,
      x_unit_cd,
      x_unit_ver_num,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.dbpays_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.dbpays_id
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
    x_dbpays_id                         IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 10-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_db_pays_prg_t
      WHERE    dbpays_id                         = x_dbpays_id;

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

    SELECT    igf_db_pays_prg_t_s.NEXTVAL
    INTO      x_dbpays_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_dbpays_id                         => x_dbpays_id,
      x_base_id                           => x_base_id,
      x_program_cd                        => x_program_cd,
      x_prg_ver_num                       => x_prg_ver_num,
      x_unit_cd                           => x_unit_cd,
      x_unit_ver_num                      => x_unit_ver_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_db_pays_prg_t (
      dbpays_id,
      base_id,
      program_cd,
      prg_ver_num,
      unit_cd,
      unit_ver_num,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.dbpays_id,
      new_references.base_id,
      new_references.program_cd,
      new_references.prg_ver_num,
      new_references.unit_cd,
      new_references.unit_ver_num,
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
    x_dbpays_id                         IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 10-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        base_id,
        program_cd,
        prg_ver_num,
        unit_cd,
        unit_ver_num
      FROM  igf_db_pays_prg_t
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
        (tlinfo.base_id = x_base_id)
        AND ((tlinfo.program_cd = x_program_cd) OR ((tlinfo.program_cd IS NULL) AND (X_program_cd IS NULL)))
        AND ((tlinfo.prg_ver_num = x_prg_ver_num) OR ((tlinfo.prg_ver_num IS NULL) AND (X_prg_ver_num IS NULL)))
        AND ((tlinfo.unit_cd = x_unit_cd) OR ((tlinfo.unit_cd IS NULL) AND (X_unit_cd IS NULL)))
        AND ((tlinfo.unit_ver_num = x_unit_ver_num) OR ((tlinfo.unit_ver_num IS NULL) AND (X_unit_ver_num IS NULL)))
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
    x_dbpays_id                         IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 10-JAN-2002
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
      x_dbpays_id                         => x_dbpays_id,
      x_base_id                           => x_base_id,
      x_program_cd                        => x_program_cd,
      x_prg_ver_num                       => x_prg_ver_num,
      x_unit_cd                           => x_unit_cd,
      x_unit_ver_num                      => x_unit_ver_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_db_pays_prg_t
      SET
        base_id                           = new_references.base_id,
        program_cd                        = new_references.program_cd,
        prg_ver_num                       = new_references.prg_ver_num,
        unit_cd                           = new_references.unit_cd,
        unit_ver_num                      = new_references.unit_ver_num,
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
    x_dbpays_id                         IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 10-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_db_pays_prg_t
      WHERE    dbpays_id                         = x_dbpays_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_dbpays_id,
        x_base_id,
        x_program_cd,
        x_prg_ver_num,
        x_unit_cd,
        x_unit_ver_num,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_dbpays_id,
      x_base_id,
      x_program_cd,
      x_prg_ver_num,
      x_unit_cd,
      x_unit_ver_num,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 10-JAN-2002
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

    DELETE FROM igf_db_pays_prg_t
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_db_pays_prg_t_pkg;

/
