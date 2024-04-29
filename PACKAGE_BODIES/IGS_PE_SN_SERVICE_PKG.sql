--------------------------------------------------------
--  DDL for Package Body IGS_PE_SN_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_SN_SERVICE_PKG" AS
/* $Header: IGSNI89B.pls 120.1 2005/06/28 06:15:54 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_sn_service%ROWTYPE;
  new_references igs_pe_sn_service%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2 ,--    DEFAULT NULL,
    x_sn_service_id                     IN     NUMBER   ,--   DEFAULT NULL,
    x_disability_id                     IN     NUMBER   ,--   DEFAULT NULL,
    x_special_service_cd                IN     VARCHAR2    ,-- DEFAULT NULL,
    x_documented_ind                    IN     VARCHAR2 ,--   DEFAULT NULL,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE,
    x_creation_date                     IN     DATE     ,--   DEFAULT NULL,
    x_created_by                        IN     NUMBER   ,--   DEFAULT NULL,
    x_last_update_date                  IN     DATE     ,--   DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER   ,--   DEFAULT NULL,
    x_last_update_login                 IN     NUMBER   --   DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_sn_service
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
    new_references.sn_service_id                     := x_sn_service_id;
    new_references.disability_id                     := x_disability_id;
    new_references.special_service_cd              := x_special_service_cd;
    new_references.documented_ind                    := x_documented_ind;

    new_references.start_dt			     := x_start_dt;
    new_references.end_dt			     := x_end_dt;


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
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kumma           21-OCT-2002     Added a parameter of start_dt to the get_uk_for_validation., 2608360
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.disability_id,
           new_references.special_service_cd,
	   new_references.start_dt
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.special_service_code = new_references.special_service_code)) OR
        ((new_references.special_service_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation (
                'PE_SN_SERVICE',new_references.special_service_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.disability_id = new_references.disability_id)) OR
        ((new_references.disability_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_pers_disablty_pkg.get_pk_for_validation (
                new_references.disability_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_sn_service_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_sn_service
      WHERE    sn_service_id = x_sn_service_id
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


  FUNCTION get_uk_for_validation (
    x_disability_id                   IN     NUMBER,
    x_special_service_cd              IN     VARCHAR2,
    x_start_dt			      IN     DATE

  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kumma          21-OCT-2002     Added a new condition for start_dt, 2608360
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_sn_service
      WHERE    disability_id = x_disability_id
      AND      special_service_cd = x_special_service_cd
      AND      ( (trunc(start_dt) = trunc(x_start_dt)) OR (start_dt IS NULL and x_start_dt IS NULL ))
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

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

  PROCEDURE get_fk_igs_pe_pers_disablty (
    x_igs_pe_pers_disablty_id           IN     NUMBER
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_sn_service
      WHERE   ((disability_id = x_igs_pe_pers_disablty_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_SNSV_PD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_pers_disablty;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2 ,--   DEFAULT NULL,
    x_sn_service_id                     IN     NUMBER   ,--   DEFAULT NULL,
    x_disability_id                     IN     NUMBER   ,--   DEFAULT NULL,
    x_special_service_cd                IN     VARCHAR2 ,--     DEFAULT NULL,
    x_documented_ind                    IN     VARCHAR2 ,--   DEFAULT NULL,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE,
    x_creation_date                     IN     DATE     ,--   DEFAULT NULL,
    x_created_by                        IN     NUMBER   ,--   DEFAULT NULL,
    x_last_update_date                  IN     DATE     ,--   DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER   ,--   DEFAULT NULL,
    x_last_update_login                 IN     NUMBER   --   DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || kumma            21-OCT-2002     Commented out NOCOPY the call to cheque_uniqueness as there can be many special need services
  ||				       each having its own start and end date
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_sn_service_id,
      x_disability_id,
      x_special_service_cd,
      x_documented_ind,
      x_start_dt,
      x_end_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.sn_service_id
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
             new_references.sn_service_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
         check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sn_service_id                     IN OUT NOCOPY NUMBER,
    x_disability_id                     IN     NUMBER,
    x_special_service_cd                IN     VARCHAR2,
    x_documented_ind                    IN     VARCHAR2,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE,
    x_mode                              IN     VARCHAR2 -- DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pe_sn_service
      WHERE    sn_service_id                     = x_sn_service_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
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

    SELECT    igs_pe_sn_service_s.NEXTVAL
    INTO      x_sn_service_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sn_service_id                     => x_sn_service_id,
      x_disability_id                     => x_disability_id,
      x_special_service_cd              => x_special_service_cd,
      x_documented_ind                    => x_documented_ind,
      x_start_dt			 => x_start_dt,
      x_end_dt				 => x_end_dt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_sn_service (
      sn_service_id,
      disability_id,
      special_service_cd,
      documented_ind,
      start_dt,
      end_dt,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.sn_service_id,
      new_references.disability_id,
      new_references.special_service_cd,
      new_references.documented_ind,
      new_references.start_dt,
      new_references.end_dt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sn_service_id                     IN     NUMBER,
    x_disability_id                     IN     NUMBER,
    x_special_service_cd              IN     VARCHAR2,
    x_documented_ind                    IN     VARCHAR2,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE

  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        disability_id,
        special_service_cd,
        documented_ind,
	start_dt,
	end_dt
      FROM  igs_pe_sn_service
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
        (tlinfo.disability_id = x_disability_id)
        AND ((tlinfo.special_service_cd = x_special_service_cd)
 	    OR ((tlinfo.special_service_cd is null)
		AND (x_special_service_cd is null)))
        AND (tlinfo.documented_ind = x_documented_ind)

	AND ((tlinfo.start_dt = x_start_dt)
 	    OR ((tlinfo.start_dt is null)
		AND (x_start_dt is null)))


       	AND ((tlinfo.end_dt = x_end_dt)
 	    OR ((tlinfo.end_dt is null)
		AND (x_end_dt is null)))
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
    x_sn_service_id                     IN     NUMBER,
    x_disability_id                     IN     NUMBER,
    x_special_service_cd              IN     VARCHAR2,
    x_documented_ind                    IN     VARCHAR2,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE,
    x_mode                              IN     VARCHAR2 --DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      x_sn_service_id                     => x_sn_service_id,
      x_disability_id                     => x_disability_id,
      x_special_service_cd              => x_special_service_cd,
      x_documented_ind                    => x_documented_ind,
      x_start_dt			  => x_start_dt,
      x_end_dt				  => x_end_dt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_sn_service
      SET
        disability_id                     = new_references.disability_id,
        special_service_cd              = new_references.special_service_cd,
        documented_ind                    = new_references.documented_ind,
	start_dt			 = new_references.start_dt,
	end_dt				 = new_references.end_dt,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;



EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sn_service_id                     IN OUT NOCOPY NUMBER,
    x_disability_id                     IN     NUMBER,
    x_special_service_cd                IN     VARCHAR2,
    x_documented_ind                    IN     VARCHAR2,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE,
    x_mode                              IN     VARCHAR2 --DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_sn_service
      WHERE    sn_service_id                     = x_sn_service_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sn_service_id,
        x_disability_id,
        x_special_service_cd,
        x_documented_ind,
	x_start_dt,
	x_end_dt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sn_service_id,
      x_disability_id,
      x_special_service_cd,
      x_documented_ind,
      x_start_dt,
      x_end_dt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_pe_sn_service
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  END delete_row;


END igs_pe_sn_service_pkg;

/
