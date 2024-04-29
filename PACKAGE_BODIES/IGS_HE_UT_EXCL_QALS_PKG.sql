--------------------------------------------------------
--  DDL for Package Body IGS_HE_UT_EXCL_QALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_UT_EXCL_QALS_PKG" AS
/* $Header: IGSWI41B.pls 115.0 2003/09/02 13:20:29 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_ut_excl_qals%ROWTYPE;
  new_references igs_he_ut_excl_qals%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_excl_qual_id                      IN     NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-AUG-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_he_ut_excl_qals
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
    new_references.excl_qual_id                      := x_excl_qual_id;
    new_references.tariff_calc_type_cd               := x_tariff_calc_type_cd;
    new_references.award_cd                          := x_award_cd;
    new_references.field_of_study                    := x_field_of_study;

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
  ||  Created On : 28-AUG-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.tariff_calc_type_cd = new_references.tariff_calc_type_cd)) OR
        ((new_references.tariff_calc_type_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_ut_calc_type_pkg.get_pk_for_validation (
                new_references.tariff_calc_type_cd,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_excl_qual_id                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 28-AUG-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ut_excl_qals
      WHERE    excl_qual_id = x_excl_qual_id
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


  PROCEDURE get_fk_igs_he_ut_calc_type (
    x_tariff_calc_type_cd               IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-AUG-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ut_excl_qals
      WHERE   ((tariff_calc_type_cd = x_tariff_calc_type_cd));

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

  END get_fk_igs_he_ut_calc_type;


  FUNCTION get_uk_for_validation (
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2
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
      FROM     igs_he_ut_excl_qals
      WHERE    tariff_calc_type_cd = x_tariff_calc_type_cd
        AND ((award_cd = x_award_cd) OR ((award_cd IS NULL) AND (X_award_cd IS NULL)))
        AND ((field_of_study = x_field_of_study) OR ((field_of_study IS NULL) AND (X_field_of_study IS NULL)))
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
  ||  Purpose : tariff_calc_type_cd, award_cd  and field_of_study should be unique
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF ( get_uk_for_validation (
           x_tariff_calc_type_cd        => new_references.tariff_calc_type_cd,
           x_award_cd                   => new_references.award_cd,
           x_field_of_study             => new_references.field_of_study )
       ) THEN
       fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_excl_qual_id                      IN     NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-AUG-2003
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
      x_excl_qual_id,
      x_tariff_calc_type_cd,
      x_award_cd,
      x_field_of_study,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.excl_qual_id
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
             new_references.excl_qual_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    END IF;

    IF (p_action IN ('VALIDATE_INSERT', 'VALIDATE_UPDATE', 'VALIDATE_DELETE')) THEN
      l_rowid := NULL;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_excl_qual_id                      IN OUT NOCOPY NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-AUG-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_UT_EXCL_QALS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_excl_qual_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_excl_qual_id                      => x_excl_qual_id,
      x_tariff_calc_type_cd               => x_tariff_calc_type_cd,
      x_award_cd                          => x_award_cd,
      x_field_of_study                    => x_field_of_study,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_ut_excl_qals (
      excl_qual_id,
      tariff_calc_type_cd,
      award_cd,
      field_of_study,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_he_ut_excl_qals_s.NEXTVAL,
      new_references.tariff_calc_type_cd,
      new_references.award_cd,
      new_references.field_of_study,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, excl_qual_id INTO x_rowid, x_excl_qual_id;

    l_rowid := NULL;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_excl_qual_id                      IN     NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-AUG-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        tariff_calc_type_cd,
        award_cd,
        field_of_study
      FROM  igs_he_ut_excl_qals
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
        (tlinfo.tariff_calc_type_cd = x_tariff_calc_type_cd)
        AND ((tlinfo.award_cd = x_award_cd) OR ((tlinfo.award_cd IS NULL) AND (X_award_cd IS NULL)))
        AND ((tlinfo.field_of_study = x_field_of_study) OR ((tlinfo.field_of_study IS NULL) AND (X_field_of_study IS NULL)))
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
    x_excl_qual_id                      IN     NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-AUG-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_UT_EXCL_QALS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_excl_qual_id                      => x_excl_qual_id,
      x_tariff_calc_type_cd               => x_tariff_calc_type_cd,
      x_award_cd                          => x_award_cd,
      x_field_of_study                    => x_field_of_study,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_ut_excl_qals
      SET
        tariff_calc_type_cd               = new_references.tariff_calc_type_cd,
        award_cd                          = new_references.award_cd,
        field_of_study                    = new_references.field_of_study,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_excl_qual_id                      IN OUT NOCOPY NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-AUG-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_ut_excl_qals
      WHERE    excl_qual_id                      = x_excl_qual_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_excl_qual_id,
        x_tariff_calc_type_cd,
        x_award_cd,
        x_field_of_study,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_excl_qual_id,
      x_tariff_calc_type_cd,
      x_award_cd,
      x_field_of_study,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-AUG-2003
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

    DELETE FROM igs_he_ut_excl_qals
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_he_ut_excl_qals_pkg;

/
