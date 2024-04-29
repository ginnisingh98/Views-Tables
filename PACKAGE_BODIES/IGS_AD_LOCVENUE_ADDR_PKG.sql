--------------------------------------------------------
--  DDL for Package Body IGS_AD_LOCVENUE_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_LOCVENUE_ADDR_PKG" AS
/* $Header: IGSAIC0B.pls 115.7 2003/01/23 04:41:58 knag ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_locvenue_addr%ROWTYPE;
  new_references igs_ad_locvenue_addr%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_location_venue_addr_id            IN     NUMBER      DEFAULT NULL,
    x_location_id                       IN     NUMBER      DEFAULT NULL,
    x_location_venue_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_source_type                       IN     VARCHAR2    DEFAULT NULL,
    x_identifying_address_flag          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_LOCVENUE_ADDR
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
    new_references.location_venue_addr_id            := x_location_venue_addr_id;
    new_references.location_id                       := x_location_id;
    new_references.location_venue_cd                 := x_location_venue_cd;
    new_references.source_type                       := x_source_type;
    new_references.identifying_address_flag          := x_identifying_address_flag;

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


  PROCEDURE check_constraints (
    column_name    IN     VARCHAR2    DEFAULT NULL,
    column_value   IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Handles the Check Constraint logic for the the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER(column_name) = 'SOURCE_TYPE') THEN
      new_references.source_type := column_value;
    ELSIF (UPPER(column_name) = 'IDENTIFYING_ADDRESS_FLAG') THEN
      new_references.identifying_address_flag := column_value;
    END IF;

    IF (UPPER(column_name) = 'SOURCE_TYPE' OR column_name IS NULL) THEN
      IF NOT (new_references.source_type IN ('L','V'))  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'IDENTIFYING_ADDRESS_FLAG' OR column_name IS NULL) THEN
      IF NOT (new_references.identifying_address_flag IN ('Y','N'))  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;


  PROCEDURE check_parent_existance
  AS
  CURSOR cur_rowid IS
         SELECT   rowid
         FROM     HZ_LOCATIONS
         WHERE    LOCATION_ID = new_references.LOCATION_ID ;
       lv_rowid cur_rowid%RowType;
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN

    IF (((old_references.location_id = new_references.location_id)) OR
        ((new_references.location_id IS NULL))) THEN
      NULL;
    ELSE
    Open cur_rowid;
       Fetch cur_rowid INTO lv_rowid;
       IF (cur_rowid%NOTFOUND) THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
       END IF;
     Close cur_rowid;

    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
    /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN

    igs_pe_contact_dtls_pkg.get_fk_igs_ad_locvenue_addr (
      old_references.location_venue_addr_id
    );
    igs_pe_locvenue_use_pkg.get_fk_igs_ad_locvenue_addr (
      old_references.location_venue_addr_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_location_venue_addr_id            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_locvenue_addr
      WHERE    location_venue_addr_id = x_location_venue_addr_id
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


  PROCEDURE get_fk_igs_pe_hz_locations (
    x_location_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_locvenue_addr
      WHERE   ((location_id = x_location_id));

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

  END get_fk_igs_pe_hz_locations;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_location_venue_addr_id            IN     NUMBER      DEFAULT NULL,
    x_location_id                       IN     NUMBER      DEFAULT NULL,
    x_location_venue_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_source_type                       IN     VARCHAR2    DEFAULT NULL,
    x_identifying_address_flag          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel         3-APR-2002      Bug NO: 2329883
  ||                                  Added the Check while update that whenever more than one record comes with
  ||                                  identfying_address_flag = 'Y', the previous records should be updated with
  ||                                  identfying_address_flag = 'N'
  ||  (reverse chronological order - newest change first)
  */

     CURSOR c_address(cp_location_venue_cd  igs_ad_locvenue_addr.location_venue_cd%TYPE,
                      cp_source_type        igs_ad_locvenue_addr.source_type%TYPE) IS
     SELECT rowid
     FROM   igs_ad_locvenue_addr
     WHERE  location_venue_cd = cp_location_venue_cd
     AND    source_type       = cp_source_type
     AND    identifying_address_flag = 'Y';

	 l_rowid   ROWID;

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_location_venue_addr_id,
      x_location_id,
      x_location_venue_cd,
      x_source_type,
      x_identifying_address_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.location_venue_addr_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      OPEN   c_address(x_location_venue_cd, x_source_type);
	  FETCH  c_address INTO l_rowid;
  	      IF c_address%FOUND THEN
		      IF x_identifying_address_flag = 'Y' THEN
			      UPDATE   igs_ad_locvenue_addr
				  SET      identifying_address_flag = 'N'
				  WHERE    rowid = l_rowid;
			  END IF;
		  END IF;
	  CLOSE c_address;

      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.location_venue_addr_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_location_venue_addr_id            IN OUT NOCOPY NUMBER,
    x_location_id                       IN     NUMBER,
    x_location_venue_cd                 IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_identifying_address_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_locvenue_addr
      WHERE    location_venue_addr_id            = x_location_venue_addr_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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

    X_LOCATION_VENUE_ADDR_ID := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_location_venue_addr_id            => x_location_venue_addr_id,
      x_location_id                       => x_location_id,
      x_location_venue_cd                 => x_location_venue_cd,
      x_source_type                       => x_source_type,
      x_identifying_address_flag          => x_identifying_address_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_locvenue_addr (
      location_venue_addr_id,
      location_id,
      location_venue_cd,
      source_type,
      identifying_address_flag,
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
      IGS_AD_LOCVENUE_ADDR_S.NEXTVAL,
      new_references.location_id,
      new_references.location_venue_cd,
      new_references.source_type,
      new_references.identifying_address_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    )RETURNING LOCATION_VENUE_ADDR_ID INTO X_LOCATION_VENUE_ADDR_ID;

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
    x_location_venue_addr_id            IN     NUMBER,
    x_location_id                       IN     NUMBER,
    x_location_venue_cd                 IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_identifying_address_flag          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        location_id,
        location_venue_cd,
        source_type,
        identifying_address_flag
      FROM  igs_ad_locvenue_addr
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
        ((tlinfo.location_id = x_location_id) OR ((tlinfo.location_id IS NULL) AND (X_location_id IS NULL)))
        AND ((tlinfo.location_venue_cd = x_location_venue_cd) OR ((tlinfo.location_venue_cd IS NULL) AND (X_location_venue_cd IS NULL)))
        AND ((tlinfo.source_type = x_source_type) OR ((tlinfo.source_type IS NULL) AND (X_source_type IS NULL)))
        AND ((tlinfo.identifying_address_flag = x_identifying_address_flag) OR ((tlinfo.identifying_address_flag IS NULL) AND (X_identifying_address_flag IS NULL)))
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
    x_location_venue_addr_id            IN     NUMBER,
    x_location_id                       IN     NUMBER,
    x_location_venue_cd                 IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_identifying_address_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
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
      x_location_venue_addr_id            => x_location_venue_addr_id,
      x_location_id                       => x_location_id,
      x_location_venue_cd                 => x_location_venue_cd,
      x_source_type                       => x_source_type,
      x_identifying_address_flag          => x_identifying_address_flag,
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

    UPDATE igs_ad_locvenue_addr
      SET
        location_id                       = new_references.location_id,
        location_venue_cd                 = new_references.location_venue_cd,
        source_type                       = new_references.source_type,
        identifying_address_flag          = new_references.identifying_address_flag,
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
    x_location_venue_addr_id            IN OUT NOCOPY NUMBER,
    x_location_id                       IN     NUMBER,
    x_location_venue_cd                 IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_identifying_address_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_locvenue_addr
      WHERE    location_venue_addr_id            = x_location_venue_addr_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_location_venue_addr_id,
        x_location_id,
        x_location_venue_cd,
        x_source_type,
        x_identifying_address_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_location_venue_addr_id,
      x_location_id,
      x_location_venue_cd,
      x_source_type,
      x_identifying_address_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
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

    DELETE FROM igs_ad_locvenue_addr
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_locvenue_addr_pkg;

/
