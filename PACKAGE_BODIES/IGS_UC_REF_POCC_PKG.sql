--------------------------------------------------------
--  DDL for Package Body IGS_UC_REF_POCC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_REF_POCC_PKG" AS
/* $Header: IGSXI31B.pls 120.1 2005/09/27 19:34:46 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_ref_pocc%ROWTYPE;
  new_references igs_uc_ref_pocc%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_pocc                              IN     NUMBER  ,
    x_social_class                      IN     NUMBER  ,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternative_class1                IN     NUMBER  ,
    x_alternative_class2                IN     NUMBER  ,
    x_imported                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    -- Added socio_economic Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_socio_economic                      IN   VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_REF_POCC
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
    new_references.pocc                              := x_pocc;
    new_references.social_class                      := x_social_class;
    new_references.occupation_text                   := x_occupation_text;
    new_references.alternative_text                  := x_alternative_text;
    new_references.alternative_class1                := x_alternative_class1;
    new_references.alternative_class2                := x_alternative_class2;
    new_references.imported                          := x_imported;
    new_references.socio_economic                    := x_socio_economic;

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
    x_pocc                              IN     NUMBER
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
      FROM     igs_uc_ref_pocc
      WHERE    pocc = x_pocc ;

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
    x_pocc                              IN     NUMBER  ,
    x_social_class                      IN     NUMBER  ,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternative_class1                IN     NUMBER  ,
    x_alternative_class2                IN     NUMBER  ,
    x_imported                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    -- Added socio_economic Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_socio_economic                      IN   VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      x_pocc,
      x_social_class,
      x_occupation_text,
      x_alternative_text,
      x_alternative_class1,
      x_alternative_class2,
      x_imported,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_socio_economic
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.pocc
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.pocc
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
    x_pocc                              IN OUT NOCOPY NUMBER,
    x_social_class                      IN     NUMBER,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternative_class1                IN     NUMBER,
    x_alternative_class2                IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    -- Added socio_economic Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_socio_economic                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_ref_pocc
      WHERE    pocc                              = x_pocc;

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

/*    SELECT    igs_uc_ref_pocc_s.NEXTVAL
    INTO      x_pocc
    FROM      dual;
*/
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_pocc                              => x_pocc,
      x_social_class                      => x_social_class,
      x_occupation_text                   => x_occupation_text,
      x_alternative_text                  => x_alternative_text,
      x_alternative_class1                => x_alternative_class1,
      x_alternative_class2                => x_alternative_class2,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_socio_economic                    => x_socio_economic
    );

    INSERT INTO igs_uc_ref_pocc (
      pocc,
      social_class,
      occupation_text,
      alternative_text,
      alternative_class1,
      alternative_class2,
      imported,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      socio_economic
    ) VALUES (
      new_references.pocc,
      new_references.social_class,
      new_references.occupation_text,
      new_references.alternative_text,
      new_references.alternative_class1,
      new_references.alternative_class2,
      new_references.imported,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.socio_economic
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
    x_pocc                              IN     NUMBER,
    x_social_class                      IN     NUMBER,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternative_class1                IN     NUMBER,
    x_alternative_class2                IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    -- Added socio_economic Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_socio_economic                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who       When        What
  ||  jbaber    15-Sep-05   Added NULL checks for social_class and socio_economic for bug 4589994
  */
    CURSOR c1 IS
      SELECT
        social_class,
        occupation_text,
        alternative_text,
        alternative_class1,
        alternative_class2,
        imported,
        socio_economic
      FROM  igs_uc_ref_pocc
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
        ((tlinfo.social_class = x_social_class) OR ((tlinfo.social_class IS NULL) AND (x_social_class IS NULL)))
        AND ((tlinfo.occupation_text = x_occupation_text) OR ((tlinfo.occupation_text IS NULL) AND (X_occupation_text IS NULL)))
        AND ((tlinfo.alternative_text = x_alternative_text) OR ((tlinfo.alternative_text IS NULL) AND (X_alternative_text IS NULL)))
        AND ((tlinfo.alternative_class1 = x_alternative_class1) OR ((tlinfo.alternative_class1 IS NULL) AND (X_alternative_class1 IS NULL)))
        AND ((tlinfo.alternative_class2 = x_alternative_class2) OR ((tlinfo.alternative_class2 IS NULL) AND (X_alternative_class2 IS NULL)))
        AND (tlinfo.imported = x_imported)
        AND ((tlinfo.socio_economic = x_socio_economic) OR ((tlinfo.socio_economic IS NULL) AND (x_socio_economic IS NULL)))
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
    x_pocc                              IN     NUMBER,
    x_social_class                      IN     NUMBER,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternative_class1                IN     NUMBER,
    x_alternative_class2                IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    -- Added socio_economic Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_socio_economic                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      x_pocc                              => x_pocc,
      x_social_class                      => x_social_class,
      x_occupation_text                   => x_occupation_text,
      x_alternative_text                  => x_alternative_text,
      x_alternative_class1                => x_alternative_class1,
      x_alternative_class2                => x_alternative_class2,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_socio_economic                    => x_socio_economic
    );

    UPDATE igs_uc_ref_pocc
      SET
        social_class                      = new_references.social_class,
        occupation_text                   = new_references.occupation_text,
        alternative_text                  = new_references.alternative_text,
        alternative_class1                = new_references.alternative_class1,
        alternative_class2                = new_references.alternative_class2,
        imported                          = new_references.imported,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        socio_economic                    = new_references.socio_economic
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pocc                              IN OUT NOCOPY NUMBER,
    x_social_class                      IN     NUMBER,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternative_class1                IN     NUMBER,
    x_alternative_class2                IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    -- Added socio_economic Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_socio_economic                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_ref_pocc
      WHERE    pocc                              = x_pocc;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_pocc,
        x_social_class,
        x_occupation_text,
        x_alternative_text,
        x_alternative_class1,
        x_alternative_class2,
        x_imported,
        x_mode,
        x_socio_economic
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_pocc,
      x_social_class,
      x_occupation_text,
      x_alternative_text,
      x_alternative_class1,
      x_alternative_class2,
      x_imported,
      x_mode,
      x_socio_economic
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

    DELETE FROM igs_uc_ref_pocc
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_ref_pocc_pkg;

/
