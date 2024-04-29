--------------------------------------------------------
--  DDL for Package Body IGS_UC_INST_CONTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_INST_CONTS_PKG" AS
/* $Header: IGSXI21B.pls 115.7 2003/06/11 10:11:00 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_inst_conts%ROWTYPE;
  new_references igs_uc_inst_conts%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_contact_code                      IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_post                              IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
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
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_INST_CONTS
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
    new_references.contact_code                      := x_contact_code;
    new_references.updater                           := x_updater;
    new_references.name                              := x_name;
    new_references.post                              := x_post;
    new_references.address1                          := x_address1;
    new_references.address2                          := x_address2;
    new_references.address3                          := x_address3;
    new_references.address4                          := x_address4;
    new_references.telephone                         := x_telephone;
    new_references.fax                               := x_fax;
    new_references.email                             := x_email;
    new_references.sent_to_ucas                      := x_sent_to_ucas;

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

    igs_uc_inst_cnt_grp_pkg.get_fk_igs_uc_inst_conts (
      old_references.contact_code
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_contact_code                      IN     VARCHAR2
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
      FROM     igs_uc_inst_conts
      WHERE    contact_code = x_contact_code ;

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
    x_contact_code                      IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_post                              IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
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
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_contact_code,
      x_updater,
      x_name,
      x_post,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_telephone,
      x_fax,
      x_email,
      x_sent_to_ucas,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.contact_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.contact_code
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
    x_contact_code                      IN OUT NOCOPY VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_post                              IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_inst_conts
      WHERE    contact_code                      = x_contact_code;

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

/*    SELECT    igs_uc_inst_conts_s.NEXTVAL
    INTO      x_contact_code
    FROM      dual;
*/
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_contact_code                      => x_contact_code,
      x_updater                           => x_updater,
      x_name                              => x_name,
      x_post                              => x_post,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_telephone                         => x_telephone,
      x_fax                               => x_fax,
      x_email                             => x_email,
      x_sent_to_ucas                      => x_sent_to_ucas,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_inst_conts (
      contact_code,
      updater,
      name,
      post,
      address1,
      address2,
      address3,
      address4,
      telephone,
      fax,
      email,
      sent_to_ucas,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.contact_code,
      new_references.updater,
      new_references.name,
      new_references.post,
      new_references.address1,
      new_references.address2,
      new_references.address3,
      new_references.address4,
      new_references.telephone,
      new_references.fax,
      new_references.email,
      new_references.sent_to_ucas,
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
    x_contact_code                      IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_post                              IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        updater,
        name,
        post,
        address1,
        address2,
        address3,
        address4,
        telephone,
        fax,
        email,
        sent_to_ucas
      FROM  igs_uc_inst_conts
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
        ((tlinfo.updater = x_updater) OR ((tlinfo.updater IS NULL) AND (X_updater IS NULL)))
        AND (tlinfo.name = x_name)
        AND (tlinfo.post = x_post)
        AND (tlinfo.address1 = x_address1)
        AND ((tlinfo.address2 = x_address2) OR ((tlinfo.address2 IS NULL) AND (X_address2 IS NULL)))
        AND ((tlinfo.address3 = x_address3) OR ((tlinfo.address3 IS NULL) AND (X_address3 IS NULL)))
        AND ((tlinfo.address4 = x_address4) OR ((tlinfo.address4 IS NULL) AND (X_address4 IS NULL)))
        AND ((tlinfo.telephone = x_telephone) OR ((tlinfo.telephone IS NULL) AND (X_telephone IS NULL)))
        AND ((tlinfo.fax = x_fax) OR ((tlinfo.fax IS NULL) AND (X_fax IS NULL)))
        AND ((tlinfo.email = x_email) OR ((tlinfo.email IS NULL) AND (X_email IS NULL)))
        AND (tlinfo.sent_to_ucas = x_sent_to_ucas)
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
    x_contact_code                      IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_post                              IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
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
      x_contact_code                      => x_contact_code,
      x_updater                           => x_updater,
      x_name                              => x_name,
      x_post                              => x_post,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_telephone                         => x_telephone,
      x_fax                               => x_fax,
      x_email                             => x_email,
      x_sent_to_ucas                      => x_sent_to_ucas,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_inst_conts
      SET
        updater                           = new_references.updater,
        name                              = new_references.name,
        post                              = new_references.post,
        address1                          = new_references.address1,
        address2                          = new_references.address2,
        address3                          = new_references.address3,
        address4                          = new_references.address4,
        telephone                         = new_references.telephone,
        fax                               = new_references.fax,
        email                             = new_references.email,
        sent_to_ucas                      = new_references.sent_to_ucas,
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
    x_contact_code                      IN OUT NOCOPY VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_name                              IN     VARCHAR2,
    x_post                              IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_inst_conts
      WHERE    contact_code                      = x_contact_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_contact_code,
        x_updater,
        x_name,
        x_post,
        x_address1,
        x_address2,
        x_address3,
        x_address4,
        x_telephone,
        x_fax,
        x_email,
        x_sent_to_ucas,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_contact_code,
      x_updater,
      x_name,
      x_post,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_telephone,
      x_fax,
      x_email,
      x_sent_to_ucas,
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

    DELETE FROM igs_uc_inst_conts
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_inst_conts_pkg;

/
