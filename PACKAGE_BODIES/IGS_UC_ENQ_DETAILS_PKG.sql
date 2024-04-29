--------------------------------------------------------
--  DDL for Package Body IGS_UC_ENQ_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_ENQ_DETAILS_PKG" AS
/* $Header: IGSXI42B.pls 115.5 2003/02/28 07:51:45 bayadav noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_enq_details%ROWTYPE;
  new_references igs_uc_enq_details%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_uc_enq_details
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
    new_references.app_no                            := x_app_no;
    new_references.surname                           := x_surname;
    new_references.given_names                       := x_given_names;
    new_references.sex                               := x_sex;
    new_references.birth_dt                          := x_birth_dt;
    new_references.prefix                            := x_prefix;
    new_references.address_line1                     := x_address_line1;
    new_references.address_line2                     := x_address_line2;
    new_references.address_line3                     := x_address_line3;
    new_references.address_line4                     := x_address_line4;
    new_references.country                           := x_country;
    new_references.postcode                          := x_postcode;
    new_references.email                             := x_email;
    new_references.telephone                         := x_telephone;

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
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_enq_details
      WHERE    app_no = x_app_no ;

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
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
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
      x_app_no,
      x_surname,
      x_given_names,
      x_sex,
      x_birth_dt,
      x_prefix,
      x_address_line1,
      x_address_line2,
      x_address_line3,
      x_address_line4,
      x_country,
      x_postcode,
      x_email,
      x_telephone,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.app_no
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.app_no
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
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_app_no                            => x_app_no,
      x_surname                           => x_surname,
      x_given_names                       => x_given_names,
      x_sex                               => x_sex,
      x_birth_dt                          => x_birth_dt,
      x_prefix                            => x_prefix,
      x_address_line1                     => x_address_line1,
      x_address_line2                     => x_address_line2,
      x_address_line3                     => x_address_line3,
      x_address_line4                     => x_address_line4,
      x_country                           => x_country,
      x_postcode                          => x_postcode,
      x_email                             => x_email,
      x_telephone                         => x_telephone,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_enq_details (
      app_no,
      surname,
      given_names,
      sex,
      birth_dt,
      prefix,
      address_line1,
      address_line2,
      address_line3,
      address_line4,
      country,
      postcode,
      email,
      telephone,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.app_no,
      new_references.surname,
      new_references.given_names,
      new_references.sex,
      new_references.birth_dt,
      new_references.prefix,
      new_references.address_line1,
      new_references.address_line2,
      new_references.address_line3,
      new_references.address_line4,
      new_references.country,
      new_references.postcode,
      new_references.email,
      new_references.telephone,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        surname,
        given_names,
        sex,
        birth_dt,
        prefix,
        address_line1,
        address_line2,
        address_line3,
        address_line4,
        country,
        postcode,
        email,
        telephone
      FROM  igs_uc_enq_details
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
        ((tlinfo.surname = x_surname) OR ((tlinfo.surname IS NULL) AND (X_surname IS NULL)))
        AND ((tlinfo.given_names = x_given_names) OR ((tlinfo.given_names IS NULL) AND (X_given_names IS NULL)))
        AND ((tlinfo.sex = x_sex) OR ((tlinfo.sex IS NULL) AND (X_sex IS NULL)))
        AND ((tlinfo.birth_dt = x_birth_dt) OR ((tlinfo.birth_dt IS NULL) AND (X_birth_dt IS NULL)))
        AND ((tlinfo.prefix = x_prefix) OR ((tlinfo.prefix IS NULL) AND (X_prefix IS NULL)))
        AND ((tlinfo.address_line1 = x_address_line1) OR ((tlinfo.address_line1 IS NULL) AND (X_address_line1 IS NULL)))
        AND ((tlinfo.address_line2 = x_address_line2) OR ((tlinfo.address_line2 IS NULL) AND (X_address_line2 IS NULL)))
        AND ((tlinfo.address_line3 = x_address_line3) OR ((tlinfo.address_line3 IS NULL) AND (X_address_line3 IS NULL)))
        AND ((tlinfo.address_line4 = x_address_line4) OR ((tlinfo.address_line4 IS NULL) AND (X_address_line4 IS NULL)))
        AND ((tlinfo.country = x_country) OR ((tlinfo.country IS NULL) AND (X_country IS NULL)))
        AND ((tlinfo.postcode = x_postcode) OR ((tlinfo.postcode IS NULL) AND (X_postcode IS NULL)))
        AND ((tlinfo.email = x_email) OR ((tlinfo.email IS NULL) AND (X_email IS NULL)))
        AND ((tlinfo.telephone = x_telephone) OR ((tlinfo.telephone IS NULL) AND (X_telephone IS NULL)))
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
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
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
      x_app_no                            => x_app_no,
      x_surname                           => x_surname,
      x_given_names                       => x_given_names,
      x_sex                               => x_sex,
      x_birth_dt                          => x_birth_dt,
      x_prefix                            => x_prefix,
      x_address_line1                     => x_address_line1,
      x_address_line2                     => x_address_line2,
      x_address_line3                     => x_address_line3,
      x_address_line4                     => x_address_line4,
      x_country                           => x_country,
      x_postcode                          => x_postcode,
      x_email                             => x_email,
      x_telephone                         => x_telephone,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_enq_details
      SET
        surname                           = new_references.surname,
        given_names                       = new_references.given_names,
        sex                               = new_references.sex,
        birth_dt                          = new_references.birth_dt,
        prefix                            = new_references.prefix,
        address_line1                     = new_references.address_line1,
        address_line2                     = new_references.address_line2,
        address_line3                     = new_references.address_line3,
        address_line4                     = new_references.address_line4,
        country                           = new_references.country,
        postcode                          = new_references.postcode,
        email                             = new_references.email,
        telephone                         = new_references.telephone,
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
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_enq_details
      WHERE    app_no                            = x_app_no;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_app_no,
        x_surname,
        x_given_names,
        x_sex,
        x_birth_dt,
        x_prefix,
        x_address_line1,
        x_address_line2,
        x_address_line3,
        x_address_line4,
        x_country,
        x_postcode,
        x_email,
        x_telephone,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_app_no,
      x_surname,
      x_given_names,
      x_sex,
      x_birth_dt,
      x_prefix,
      x_address_line1,
      x_address_line2,
      x_address_line3,
      x_address_line4,
      x_country,
      x_postcode,
      x_email,
      x_telephone,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
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

    DELETE FROM igs_uc_enq_details
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_enq_details_pkg;

/
