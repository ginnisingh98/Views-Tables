--------------------------------------------------------
--  DDL for Package Body IGS_UC_COM_SCHSITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_COM_SCHSITES_PKG" AS
/* $Header: IGSXI11B.pls 115.7 2003/06/11 10:34:08 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_com_schsites%ROWTYPE;
  new_references igs_uc_com_schsites%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER  ,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
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
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_COM_SCHSITES
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
    new_references.school                            := x_school;
    new_references.sitecode                          := x_sitecode;
    new_references.address1                          := x_address1;
    new_references.address2                          := x_address2;
    new_references.address3                          := x_address3;
    new_references.address4                          := x_address4;
    new_references.postcode                          := x_postcode;
    new_references.mailsort                          := x_mailsort;
    new_references.town_key                          := x_town_key;
    new_references.county_key                        := x_county_key;
    new_references.country_code                      := x_country_code;
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

    IF (((old_references.school = new_references.school)) OR
        ((new_references.school IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_com_sch_pkg.get_pk_for_validation (
                new_references.school
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

    igs_uc_com_scsicnts_pkg.get_fk_igs_uc_com_schsites (
      old_references.school,
      old_references.sitecode
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2
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
      FROM     igs_uc_com_schsites
      WHERE    school = x_school
      AND      sitecode = x_sitecode ;

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


  PROCEDURE get_fk_igs_uc_com_sch (
    x_school                            IN     NUMBER
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
      FROM     igs_uc_com_schsites
      WHERE   ((school = x_school));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCCOSS_UCCOSH_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_com_sch;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER  ,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
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
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_school,
      x_sitecode,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_postcode,
      x_mailsort,
      x_town_key,
      x_county_key,
      x_country_code,
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
             new_references.school,
             new_references.sitecode
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
             new_references.school,
             new_references.sitecode
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
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
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
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_com_schsites
      WHERE    school                            = x_school
      AND      sitecode                          = x_sitecode;

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
      x_school                            => x_school,
      x_sitecode                          => x_sitecode,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_postcode                          => x_postcode,
      x_mailsort                          => x_mailsort,
      x_town_key                          => x_town_key,
      x_county_key                        => x_county_key,
      x_country_code                      => x_country_code,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_com_schsites (
      school,
      sitecode,
      address1,
      address2,
      address3,
      address4,
      postcode,
      mailsort,
      town_key,
      county_key,
      country_code,
      imported,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.school,
      new_references.sitecode,
      new_references.address1,
      new_references.address2,
      new_references.address3,
      new_references.address4,
      new_references.postcode,
      new_references.mailsort,
      new_references.town_key,
      new_references.county_key,
      new_references.country_code,
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
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        address1,
        address2,
        address3,
        address4,
        postcode,
        mailsort,
        town_key,
        county_key,
        country_code,
        imported
      FROM  igs_uc_com_schsites
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
        ((tlinfo.address1 = x_address1) OR ((tlinfo.address1 IS NULL) AND (X_address1 IS NULL)))
        AND ((tlinfo.address2 = x_address2) OR ((tlinfo.address2 IS NULL) AND (X_address2 IS NULL)))
        AND ((tlinfo.address3 = x_address3) OR ((tlinfo.address3 IS NULL) AND (X_address3 IS NULL)))
        AND ((tlinfo.address4 = x_address4) OR ((tlinfo.address4 IS NULL) AND (X_address4 IS NULL)))
        AND ((tlinfo.postcode = x_postcode) OR ((tlinfo.postcode IS NULL) AND (X_postcode IS NULL)))
        AND ((tlinfo.mailsort = x_mailsort) OR ((tlinfo.mailsort IS NULL) AND (X_mailsort IS NULL)))
        AND ((tlinfo.town_key = x_town_key) OR ((tlinfo.town_key IS NULL) AND (X_town_key IS NULL)))
        AND ((tlinfo.county_key = x_county_key) OR ((tlinfo.county_key IS NULL) AND (X_county_key IS NULL)))
        AND ((tlinfo.country_code = x_country_code) OR ((tlinfo.country_code IS NULL) AND (X_country_code IS NULL)))
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
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
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
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
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
      x_school                            => x_school,
      x_sitecode                          => x_sitecode,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_postcode                          => x_postcode,
      x_mailsort                          => x_mailsort,
      x_town_key                          => x_town_key,
      x_county_key                        => x_county_key,
      x_country_code                      => x_country_code,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_com_schsites
      SET
        address1                          = new_references.address1,
        address2                          = new_references.address2,
        address3                          = new_references.address3,
        address4                          = new_references.address4,
        postcode                          = new_references.postcode,
        mailsort                          = new_references.mailsort,
        town_key                          = new_references.town_key,
        county_key                        = new_references.county_key,
        country_code                      = new_references.country_code,
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
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
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
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_com_schsites
      WHERE    school                            = x_school
      AND      sitecode                          = x_sitecode;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_school,
        x_sitecode,
        x_address1,
        x_address2,
        x_address3,
        x_address4,
        x_postcode,
        x_mailsort,
        x_town_key,
        x_county_key,
        x_country_code,
        x_imported,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_school,
      x_sitecode,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_postcode,
      x_mailsort,
      x_town_key,
      x_county_key,
      x_country_code,
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

    DELETE FROM igs_uc_com_schsites
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_com_schsites_pkg;

/
