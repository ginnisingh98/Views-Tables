--------------------------------------------------------
--  DDL for Package Body IGS_HE_CODE_MAP_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_CODE_MAP_VAL_PKG" AS
/* $Header: IGSWI03B.pls 115.7 2003/01/07 06:21:34 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_code_map_val%ROWTYPE;
  new_references igs_he_code_map_val%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_association_code                  IN     VARCHAR2    ,
    x_sequence                          IN     NUMBER      ,
    x_map_description                   IN     VARCHAR2    ,
    x_map1                              IN     VARCHAR2    ,
    x_map2                              IN     VARCHAR2    ,
    x_map3                              IN     VARCHAR2    ,
    x_map4                              IN     VARCHAR2    ,
    x_map5                              IN     VARCHAR2    ,
    x_map6                              IN     VARCHAR2    ,
    x_map7                              IN     VARCHAR2    ,
    x_map8                              IN     VARCHAR2    ,
    x_map9                              IN     VARCHAR2    ,
    x_map10                             IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
) AS
  /*
  ||  Created By :
  ||  Created On : 23-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_CODE_MAP_VAL
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
    new_references.map_description                   := x_map_description;
    new_references.map1                              := x_map1;
    new_references.map2                              := x_map2;
    new_references.map3                              := x_map3;
    new_references.map4                              := x_map4;
    new_references.map5                              := x_map5;
    new_references.map6                              := x_map6;
    new_references.map7                              := x_map7;
    new_references.map8                              := x_map8;
    new_references.map9                              := x_map9;
    new_references.map10                             := x_map10;

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
  ||  Created By :
  ||  Created On : 23-JUL-2001
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
    x_sequence                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_code_map_val
      WHERE    sequence = x_sequence
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
  ||  Created By :
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_code_map_val
      WHERE   ((association_code = x_association_code));

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

  END get_fk_igs_he_code_assoc;

  FUNCTION get_uk_for_validation (
    x_association_code                  IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smaddali
  ||  Created On : 13-jun-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali modified cursor cur_rowid to add check for rowid as it was missing
  */
      CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_code_map_val
      WHERE    association_code = x_association_code
      AND      map1 = x_map1
      AND      map2 = x_map2
      AND      ((map3 = x_map3) OR (map3 IS NULL AND x_map3 IS NULL))
      AND      ((map4 = x_map4) OR (map4 IS NULL AND x_map4 IS NULL))
      AND      ((map5 = x_map5) OR (map5 IS NULL AND x_map5 IS NULL))
      AND      ((map6 = x_map6) OR (map6 IS NULL AND x_map6 IS NULL))
      AND      ((map7 = x_map7) OR (map7 IS NULL AND x_map7 IS NULL))
      AND      ((map8 = x_map8) OR (map8 IS NULL AND x_map8 IS NULL))
      AND      ((map9 = x_map9) OR (map9 IS NULL AND x_map9 IS NULL))
      AND      ((map10 = x_map10) OR (map10 IS NULL AND x_map10 IS NULL))
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid)) ;

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

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : smaddali
  ||  Created On : 13-jun-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF ( get_uk_for_validation (x_association_code => new_references.association_code,
           x_map1 => new_references.map1,
           x_map2 => new_references.map2,
           x_map3 => new_references.map3,
           x_map4 => new_references.map4,
           x_map5 =>  new_references.map5,
           x_map6 => new_references.map6,
           x_map7 => new_references.map7,
           x_map8 => new_references.map8,
           x_map9 => new_references.map9,
           x_map10 => new_references.map10 )
       ) THEN
       fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_association_code                  IN     VARCHAR2    ,
    x_sequence                          IN     NUMBER      ,
    x_map_description                   IN     VARCHAR2    ,
    x_map1                              IN     VARCHAR2    ,
    x_map2                              IN     VARCHAR2    ,
    x_map3                              IN     VARCHAR2    ,
    x_map4                              IN     VARCHAR2    ,
    x_map5                              IN     VARCHAR2    ,
    x_map6                              IN     VARCHAR2    ,
    x_map7                              IN     VARCHAR2    ,
    x_map8                              IN     VARCHAR2    ,
    x_map9                              IN     VARCHAR2    ,
    x_map10                             IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
) AS
  /*
  ||  Created By :
  ||  Created On : 23-JUL-2001
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
      x_map_description,
      x_map1,
      x_map2,
      x_map3,
      x_map4,
      x_map5,
      x_map6,
      x_map7,
      x_map8,
      x_map9,
      x_map10,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.sequence
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.sequence
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN OUT NOCOPY NUMBER,
    x_map_description                   IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
) AS
  /*
  ||  Created By :
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_code_map_val
      WHERE    sequence                          = x_sequence;

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

    SELECT    igs_he_code_map_val_s.NEXTVAL
    INTO      x_sequence
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_association_code                  => x_association_code,
      x_sequence                          => x_sequence,
      x_map_description                   => x_map_description,
      x_map1                              => x_map1,
      x_map2                              => x_map2,
      x_map3                              => x_map3,
      x_map4                              => x_map4,
      x_map5                              => x_map5,
      x_map6                              => x_map6,
      x_map7                              => x_map7,
      x_map8                              => x_map8,
      x_map9                              => x_map9,
      x_map10                             => x_map10,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_code_map_val (
      association_code,
      sequence,
      map_description,
      map1,
      map2,
      map3,
      map4,
      map5,
      map6,
      map7,
      map8,
      map9,
      map10,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.association_code,
      new_references.sequence,
      new_references.map_description,
      new_references.map1,
      new_references.map2,
      new_references.map3,
      new_references.map4,
      new_references.map5,
      new_references.map6,
      new_references.map7,
      new_references.map8,
      new_references.map9,
      new_references.map10,
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
    x_map_description                   IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        association_code,
        map_description,
        map1,
        map2,
        map3,
        map4,
        map5,
        map6,
        map7,
        map8,
        map9,
        map10
      FROM  igs_he_code_map_val
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
        (tlinfo.association_code = x_association_code)
        AND (tlinfo.map_description = x_map_description)
        AND (tlinfo.map1 = x_map1)
        AND (tlinfo.map2 = x_map2)
        AND ((tlinfo.map3 = x_map3) OR ((tlinfo.map3 IS NULL) AND (X_map3 IS NULL)))
        AND ((tlinfo.map4 = x_map4) OR ((tlinfo.map4 IS NULL) AND (X_map4 IS NULL)))
        AND ((tlinfo.map5 = x_map5) OR ((tlinfo.map5 IS NULL) AND (X_map5 IS NULL)))
        AND ((tlinfo.map6 = x_map6) OR ((tlinfo.map6 IS NULL) AND (X_map6 IS NULL)))
        AND ((tlinfo.map7 = x_map7) OR ((tlinfo.map7 IS NULL) AND (X_map7 IS NULL)))
        AND ((tlinfo.map8 = x_map8) OR ((tlinfo.map8 IS NULL) AND (X_map8 IS NULL)))
        AND ((tlinfo.map9 = x_map9) OR ((tlinfo.map9 IS NULL) AND (X_map9 IS NULL)))
        AND ((tlinfo.map10 = x_map10) OR ((tlinfo.map10 IS NULL) AND (X_map10 IS NULL)))
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
    x_map_description                   IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
) AS
  /*
  ||  Created By :
  ||  Created On : 23-JUL-2001
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
      x_map_description                   => x_map_description,
      x_map1                              => x_map1,
      x_map2                              => x_map2,
      x_map3                              => x_map3,
      x_map4                              => x_map4,
      x_map5                              => x_map5,
      x_map6                              => x_map6,
      x_map7                              => x_map7,
      x_map8                              => x_map8,
      x_map9                              => x_map9,
      x_map10                             => x_map10,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_code_map_val
      SET
        association_code                  = new_references.association_code,
        map_description                   = new_references.map_description,
        map1                              = new_references.map1,
        map2                              = new_references.map2,
        map3                              = new_references.map3,
        map4                              = new_references.map4,
        map5                              = new_references.map5,
        map6                              = new_references.map6,
        map7                              = new_references.map7,
        map8                              = new_references.map8,
        map9                              = new_references.map9,
        map10                             = new_references.map10,
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
    x_sequence                          IN OUT NOCOPY NUMBER,
    x_map_description                   IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
) AS
  /*
  ||  Created By :
  ||  Created On : 23-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_code_map_val
      WHERE    sequence                          = x_sequence;


  BEGIN
      OPEN c1;
      FETCH c1 INTO x_rowid;
      IF (c1%NOTFOUND)  AND NOT ( get_uk_for_validation (
           x_association_code,
           x_map1,
           x_map2,
           x_map3,
           x_map4,
           x_map5,
           x_map6,
           x_map7,
           x_map8,
           x_map9,
           x_map10 )
       ) THEN

        CLOSE c1;

        insert_row (
          x_rowid,
          x_association_code,
          x_sequence,
          x_map_description,
          x_map1,
          x_map2,
          x_map3,
          x_map4,
          x_map5,
          x_map6,
          x_map7,
          x_map8,
          x_map9,
          x_map10,
          x_mode
         );
         RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_association_code,
      x_sequence,
      x_map_description,
      x_map1,
      x_map2,
      x_map3,
      x_map4,
      x_map5,
      x_map6,
      x_map7,
      x_map8,
      x_map9,
      x_map10,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 23-JUL-2001
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

    DELETE FROM igs_he_code_map_val
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_code_map_val_pkg;

/
