--------------------------------------------------------
--  DDL for Package Body IGS_OR_LOC_REGION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_LOC_REGION_PKG" AS
/* $Header: IGSOI34B.pls 115.1 2003/10/30 13:30:15 rghosh noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_or_loc_region%ROWTYPE;
  new_references igs_or_loc_region%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_region_cd                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kpadiyar@oracle.com
  ||  Created On : 18-APR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_or_loc_region
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
    new_references.location_cd                       := x_location_cd;
    new_references.region_cd                         := x_region_cd;

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
  ||  Created By : kpadiyar@oracle.com
  ||  Created On : 18-APR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_location_pkg.get_pk_for_validation (
                new_references.location_cd ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  FUNCTION get_rg_for_validation (
    x_location_cd                       IN     VARCHAR2,
    x_region_cd                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kpadiyar@oracle.com
  ||  Created On : 18-APR-2003
  ||  Purpose : Validates the region_code references .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_prcd IS
	SELECT 1
	FROM   igs_ps_unit_ofr_opt_all uooa,
	       igs_ps_usec_occurs_all uoa
	WHERE  uoa.preferred_region_code = x_region_cd
	AND    uoa.uoo_id = uooa.uoo_id
	AND    uooa.location_cd = x_location_cd;


    lv_prcd NUMBER;

  BEGIN

    OPEN cur_prcd;
    FETCH cur_prcd INTO lv_prcd;
    IF (cur_prcd%FOUND) THEN
      CLOSE cur_prcd;
      RETURN(TRUE);
    ELSE
      CLOSE cur_prcd;
      RETURN(FALSE);
    END IF;

  END get_rg_for_validation;

  FUNCTION get_pk_for_validation (
    x_location_cd                       IN     VARCHAR2,
    x_region_cd                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kpadiyar@oracle.com
  ||  Created On : 18-APR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_loc_region
      WHERE    location_cd = x_location_cd
      AND      region_cd = x_region_cd
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


  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kpadiyar@oracle.com
  ||  Created On : 18-APR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_loc_region
      WHERE   ((location_cd = x_location_cd));

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

  END get_fk_igs_ad_location;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_region_cd                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kpadiyar@oracle.com
  ||  Created On : 18-APR-2003
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
      x_location_cd,
      x_region_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.location_cd,
             new_references.region_cd
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
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      IF ( get_rg_for_validation(
             old_references.location_cd,
             old_references.region_cd
           )) THEN
        fnd_message.set_name('IGS','IGS_OR_PREF_REGION_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.location_cd,
             new_references.region_cd
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
    x_location_cd                       IN     VARCHAR2,
    x_region_cd                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kpadiyar@oracle.com
  ||  Created On : 18-APR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_OR_LOC_REGION_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_location_cd                       => x_location_cd,
      x_region_cd                         => x_region_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_or_loc_region (
      location_cd,
      region_cd,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.location_cd,
      new_references.region_cd,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_region_cd                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kpadiyar@oracle.com
  ||  Created On : 18-APR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        rowid
      FROM  igs_or_loc_region
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


    RETURN;

  END lock_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kpadiyar@oracle.com
  ||  Created On : 18-APR-2003
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

    DELETE FROM igs_or_loc_region
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_or_loc_region_pkg;

/
