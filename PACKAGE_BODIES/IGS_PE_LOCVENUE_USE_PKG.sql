--------------------------------------------------------
--  DDL for Package Body IGS_PE_LOCVENUE_USE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_LOCVENUE_USE_PKG" AS
/* $Header: IGSNI76B.pls 115.4 2002/11/29 01:31:17 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_locvenue_use%ROWTYPE;
  new_references igs_pe_locvenue_use%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_locvenue_use_id                   IN     NUMBER      DEFAULT NULL,
    x_loc_venue_addr_id                 IN     NUMBER      DEFAULT NULL,
    x_site_use_code                     IN     VARCHAR2    DEFAULT NULL,
    x_active_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_location                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_LOCVENUE_USE
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
    new_references.locvenue_use_id                   := x_locvenue_use_id;
    new_references.loc_venue_addr_id                 := x_loc_venue_addr_id;
    new_references.site_use_code                     := x_site_use_code;
    new_references.active_ind                        := x_active_ind;
    new_references.location                          := x_location;

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

PROCEDURE check_uniqueness AS
  /*************************************************************
  Created By : pkpatel
  Date Created By : 13-SEP-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   BEGIN
              IF get_uk_for_validation (
                                new_references.loc_venue_addr_id,
                                new_references.site_use_code
                ) THEN
                FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
             END IF;
 END Check_Uniqueness ;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.loc_venue_addr_id = new_references.loc_venue_addr_id)) OR
        ((new_references.loc_venue_addr_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_locvenue_addr_pkg.get_pk_for_validation (
                new_references.loc_venue_addr_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_uk_for_validation(
    x_loc_venue_addr_id  IN NUMBER,
    x_site_use_code      IN VARCHAR2
    ) RETURN BOOLEAN AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

   CURSOR cur_rowid IS
   SELECT   rowid
   FROM     igs_pe_locvenue_use
   WHERE   loc_venue_addr_id = x_loc_venue_addr_id  AND
       ((site_use_code =  x_site_use_code) OR (site_use_code IS NULL AND x_site_use_code IS NULL))  AND
	   ((l_rowid is null) or (rowid <> l_rowid))    ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(false);
    END IF;


  END get_uk_for_validation;

  FUNCTION get_pk_for_validation (
    x_locvenue_use_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_locvenue_use
      WHERE    locvenue_use_id = x_locvenue_use_id
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


  PROCEDURE get_fk_igs_ad_locvenue_addr (
    x_location_venue_addr_id            IN     NUMBER
  ) AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_locvenue_use
      WHERE   ((loc_venue_addr_id = x_location_venue_addr_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_locvenue_addr;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_locvenue_use_id                   IN     NUMBER      DEFAULT NULL,
    x_loc_venue_addr_id                 IN     NUMBER      DEFAULT NULL,
    x_site_use_code                     IN     VARCHAR2    DEFAULT NULL,
    x_active_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_location                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
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
      x_locvenue_use_id,
      x_loc_venue_addr_id,
      x_site_use_code,
      x_active_ind,
      x_location,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.locvenue_use_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
	  check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	  check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.locvenue_use_id
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
    x_locvenue_use_id                   IN OUT NOCOPY NUMBER,
    x_loc_venue_addr_id                 IN     NUMBER,
    x_site_use_code                     IN     VARCHAR2,
    x_active_ind                        IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pe_locvenue_use
      WHERE    locvenue_use_id                   = x_locvenue_use_id;

    l_locvenue_use_id		 NUMBER;
    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN
    SELECT IGS_PE_LOCVENUE_USE_S.NEXTVAL INTO L_LOCVENUE_USE_ID FROM DUAL;
    x_locvenue_use_id := l_locvenue_use_id;
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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_locvenue_use_id                   => x_locvenue_use_id,
      x_loc_venue_addr_id                 => x_loc_venue_addr_id,
      x_site_use_code                     => x_site_use_code,
      x_active_ind                        => x_active_ind,
      x_location                          => x_location,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_pe_locvenue_use (
      locvenue_use_id,
      loc_venue_addr_id,
      site_use_code,
      active_ind,
      location,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.locvenue_use_id,
      new_references.loc_venue_addr_id,
      new_references.site_use_code,
      new_references.active_ind,
      new_references.location,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
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
    x_locvenue_use_id                   IN     NUMBER,
    x_loc_venue_addr_id                 IN     NUMBER,
    x_site_use_code                     IN     VARCHAR2,
    x_active_ind                        IN     VARCHAR2,
    x_location                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        loc_venue_addr_id,
        site_use_code,
        active_ind,
        location
      FROM  igs_pe_locvenue_use
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
        (tlinfo.loc_venue_addr_id = x_loc_venue_addr_id)
        AND ((tlinfo.site_use_code = x_site_use_code) OR ((tlinfo.site_use_code IS NULL) AND (X_site_use_code IS NULL)))
        AND (tlinfo.active_ind = x_active_ind)
        AND ((tlinfo.location = x_location) OR ((tlinfo.location IS NULL) AND (X_location IS NULL)))
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
    x_locvenue_use_id                   IN     NUMBER,
    x_loc_venue_addr_id                 IN     NUMBER,
    x_site_use_code                     IN     VARCHAR2,
    x_active_ind                        IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_locvenue_use_id                   => x_locvenue_use_id,
      x_loc_venue_addr_id                 => x_loc_venue_addr_id,
      x_site_use_code                     => x_site_use_code,
      x_active_ind                        => x_active_ind,
      x_location                          => x_location,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igs_pe_locvenue_use
      SET
        loc_venue_addr_id                 = new_references.loc_venue_addr_id,
        site_use_code                     = new_references.site_use_code,
        active_ind                        = new_references.active_ind,
        location                          = new_references.location,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_locvenue_use_id                   IN OUT NOCOPY NUMBER,
    x_loc_venue_addr_id                 IN     NUMBER,
    x_site_use_code                     IN     VARCHAR2,
    x_active_ind                        IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_locvenue_use
      WHERE    locvenue_use_id                   = x_locvenue_use_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_locvenue_use_id,
        x_loc_venue_addr_id,
        x_site_use_code,
        x_active_ind,
        x_location,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_locvenue_use_id,
      x_loc_venue_addr_id,
      x_site_use_code,
      x_active_ind,
      x_location,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sitaram.rachakonda
  ||  Created On : 31-AUG-2000
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

    DELETE FROM igs_pe_locvenue_use
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pe_locvenue_use_pkg;

/
