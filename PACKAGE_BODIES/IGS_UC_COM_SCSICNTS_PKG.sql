--------------------------------------------------------
--  DDL for Package Body IGS_UC_COM_SCSICNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_COM_SCSICNTS_PKG" AS
/* $Header: IGSXI12B.pls 115.7 2003/06/11 10:34:42 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_com_scsicnts%ROWTYPE;
  new_references igs_uc_com_scsicnts%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER  ,
    x_sitecode                          IN     VARCHAR2,
    x_contact_code                      IN     NUMBER  ,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
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
      FROM     IGS_UC_COM_SCSICNTS
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
    new_references.contact_code                      := x_contact_code;
    new_references.contact_post                      := x_contact_post;
    new_references.contact_name                      := x_contact_name;
    new_references.telephone                         := x_telephone;
    new_references.fax                               := x_fax;
    new_references.email                             := x_email;
    new_references.principal                         := x_principal;
    new_references.lists                             := x_lists;
    new_references.orders                            := x_orders;
    new_references.forms                             := x_forms;
    new_references.referee                           := x_referee;
    new_references.careers                           := x_careers;
    new_references.eas_contact                       := x_eas_contact;
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

    IF (((old_references.school = new_references.school) AND
         (old_references.sitecode = new_references.sitecode)) OR
        ((new_references.school IS NULL) OR
         (new_references.sitecode IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_com_schsites_pkg.get_pk_for_validation (
                new_references.school,
                new_references.sitecode
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_contact_code                      IN     NUMBER
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
      FROM     igs_uc_com_scsicnts
      WHERE    school = x_school
      AND      sitecode = x_sitecode
      AND      contact_code = x_contact_code ;

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


  PROCEDURE get_fk_igs_uc_com_schsites (
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2
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
      FROM     igs_uc_com_scsicnts
      WHERE   ((school = x_school) AND
               (sitecode = x_sitecode));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCCOSC_UCCOSS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_com_schsites;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER  ,
    x_sitecode                          IN     VARCHAR2,
    x_contact_code                      IN     NUMBER  ,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
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
      x_contact_code,
      x_contact_post,
      x_contact_name,
      x_telephone,
      x_fax,
      x_email,
      x_principal,
      x_lists,
      x_orders,
      x_forms,
      x_referee,
      x_careers,
      x_eas_contact,
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
             new_references.sitecode,
             new_references.contact_code
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
             new_references.school,
             new_references.sitecode,
             new_references.contact_code
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
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_contact_code                      IN     NUMBER,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
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
      FROM     igs_uc_com_scsicnts
      WHERE    school                            = x_school
      AND      sitecode                          = x_sitecode
      AND      contact_code                      = x_contact_code;

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
      x_contact_code                      => x_contact_code,
      x_contact_post                      => x_contact_post,
      x_contact_name                      => x_contact_name,
      x_telephone                         => x_telephone,
      x_fax                               => x_fax,
      x_email                             => x_email,
      x_principal                         => x_principal,
      x_lists                             => x_lists,
      x_orders                            => x_orders,
      x_forms                             => x_forms,
      x_referee                           => x_referee,
      x_careers                           => x_careers,
      x_eas_contact                       => x_eas_contact,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_com_scsicnts (
      school,
      sitecode,
      contact_code,
      contact_post,
      contact_name,
      telephone,
      fax,
      email,
      principal,
      lists,
      orders,
      forms,
      referee,
      careers,
      eas_contact,
      imported,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.school,
      new_references.sitecode,
      new_references.contact_code,
      new_references.contact_post,
      new_references.contact_name,
      new_references.telephone,
      new_references.fax,
      new_references.email,
      new_references.principal,
      new_references.lists,
      new_references.orders,
      new_references.forms,
      new_references.referee,
      new_references.careers,
      new_references.eas_contact,
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
    x_contact_code                      IN     NUMBER,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
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
        contact_post,
        contact_name,
        telephone,
        fax,
        email,
        principal,
        lists,
        orders,
        forms,
        referee,
        careers,
        eas_contact,
        imported
      FROM  igs_uc_com_scsicnts
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
        ((tlinfo.contact_post = x_contact_post) OR ((tlinfo.contact_post IS NULL) AND (X_contact_post IS NULL)))
        AND ((tlinfo.contact_name = x_contact_name) OR ((tlinfo.contact_name IS NULL) AND (X_contact_name IS NULL)))
        AND ((tlinfo.telephone = x_telephone) OR ((tlinfo.telephone IS NULL) AND (X_telephone IS NULL)))
        AND ((tlinfo.fax = x_fax) OR ((tlinfo.fax IS NULL) AND (X_fax IS NULL)))
        AND ((tlinfo.email = x_email) OR ((tlinfo.email IS NULL) AND (X_email IS NULL)))
        AND (tlinfo.principal = x_principal)
        AND (tlinfo.lists = x_lists)
        AND (tlinfo.orders = x_orders)
        AND (tlinfo.forms = x_forms)
        AND (tlinfo.referee = x_referee)
        AND (tlinfo.careers = x_careers)
        AND (tlinfo.eas_contact = x_eas_contact)
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
    x_contact_code                      IN     NUMBER,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
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
      x_contact_code                      => x_contact_code,
      x_contact_post                      => x_contact_post,
      x_contact_name                      => x_contact_name,
      x_telephone                         => x_telephone,
      x_fax                               => x_fax,
      x_email                             => x_email,
      x_principal                         => x_principal,
      x_lists                             => x_lists,
      x_orders                            => x_orders,
      x_forms                             => x_forms,
      x_referee                           => x_referee,
      x_careers                           => x_careers,
      x_eas_contact                       => x_eas_contact,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_com_scsicnts
      SET
        contact_post                      = new_references.contact_post,
        contact_name                      = new_references.contact_name,
        telephone                         = new_references.telephone,
        fax                               = new_references.fax,
        email                             = new_references.email,
        principal                         = new_references.principal,
        lists                             = new_references.lists,
        orders                            = new_references.orders,
        forms                             = new_references.forms,
        referee                           = new_references.referee,
        careers                           = new_references.careers,
        eas_contact                       = new_references.eas_contact,
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
    x_contact_code                      IN     NUMBER,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
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
      FROM     igs_uc_com_scsicnts
      WHERE    school                            = x_school
      AND      sitecode                          = x_sitecode
      AND      contact_code                      = x_contact_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_school,
        x_sitecode,
        x_contact_code,
        x_contact_post,
        x_contact_name,
        x_telephone,
        x_fax,
        x_email,
        x_principal,
        x_lists,
        x_orders,
        x_forms,
        x_referee,
        x_careers,
        x_eas_contact,
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
      x_contact_code,
      x_contact_post,
      x_contact_name,
      x_telephone,
      x_fax,
      x_email,
      x_principal,
      x_lists,
      x_orders,
      x_forms,
      x_referee,
      x_careers,
      x_eas_contact,
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

    DELETE FROM igs_uc_com_scsicnts
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_com_scsicnts_pkg;

/
