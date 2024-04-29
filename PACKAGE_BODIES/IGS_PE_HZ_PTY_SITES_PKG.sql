--------------------------------------------------------
--  DDL for Package Body IGS_PE_HZ_PTY_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_HZ_PTY_SITES_PKG" AS
/* $Header: IGSNIB5B.pls 120.3 2005/09/22 02:31:33 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pe_hz_pty_sites%ROWTYPE;
  new_references igs_pe_hz_pty_sites%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_party_site_id                     IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : asbala
  ||  Created On : 10-NOV-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_hz_pty_sites
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
    new_references.party_site_id                     := x_party_site_id;
    new_references.start_date                        := trunc(x_start_date);
    new_references.end_date                          := trunc(x_end_date);

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

PROCEDURE BeforeRowInsertUpdate(
    p_party_site_id  IN NUMBER,
    p_start_dt IN Date ,
    p_end_dt   IN Date
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : vredkar
  --Date created: 29-AUG-2005
  --
  --Purpose:
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------
  CURSOR validate_brth_dt(cp_party_site_id NUMBER ) IS
	SELECT PE.BIRTH_DATE
	FROM
	IGS_PE_PERSON_BASE_V PE,
	HZ_PARTY_SITES PTY
	WHERE
	PE.PERSON_ID=PTY.PARTY_ID
	AND
	PTY.PARTY_SITE_ID =  cp_party_site_id ;

  l_bth_dt IGS_PE_PERSON_BASE_V.birth_date%TYPE;

  BEGIN

          OPEN validate_brth_dt(p_party_site_id);
          FETCH validate_brth_dt INTO  l_bth_dt;
          CLOSE validate_brth_dt;

          IF p_start_dt IS NULL AND p_end_dt IS NOT NULL  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_EN_CANT_SPECIFY_END_DATE');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;

	  ELSIF p_end_dt IS NOT NULL AND p_start_dt > p_end_dt  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_FI_ST_DT_LE_END_DT');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;

	 ELSIF  l_bth_dt IS NOT NULL AND l_bth_dt >  p_start_dt  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_AD_STRT_DT_LESS_BIRTH_DT');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
END BeforeRowInsertUpdate;


PROCEDURE BeforeRowInsertUpdate_ss(
    p_party_id  IN NUMBER,
    p_start_dt IN Date ,
    p_end_dt   IN Date
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : gmaheswa
  --Date created: 29-AUG-2005
  --
  --Purpose:
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------
  CURSOR validate_brth_dt(cp_party_id NUMBER ) IS
	SELECT PE.BIRTH_DATE
	FROM
	IGS_PE_PERSON_BASE_V PE
	WHERE
	PE.PERSON_ID= cp_party_id;

    l_bth_dt IGS_PE_PERSON_BASE_V.birth_date%TYPE;

  BEGIN

          OPEN validate_brth_dt(p_party_id);
          FETCH validate_brth_dt INTO  l_bth_dt;
          CLOSE validate_brth_dt;

          IF p_start_dt IS NULL AND p_end_dt IS NOT NULL  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_EN_CANT_SPECIFY_END_DATE');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;

	  ELSIF p_end_dt IS NOT NULL AND p_start_dt > p_end_dt  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_FI_ST_DT_LE_END_DT');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;

	 ELSIF  l_bth_dt IS NOT NULL AND l_bth_dt >  p_start_dt  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_AD_STRT_DT_LESS_BIRTH_DT');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
 END BeforeRowInsertUpdate_ss;


  FUNCTION get_pk_for_validation (
    x_party_site_id              IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :asbala
  ||  Created On : 27-AUG-2003
  ||  Purpose : Validates the primary Keys of the table., not generated through tool. uniqueness confirmed during build
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pe_hz_pty_sites
      WHERE    party_site_id = x_party_site_id
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (TRUE);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;
  END get_pk_for_validation;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_party_site_id                     IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : asbala
  ||  Created On : 10-NOV-2003
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
      x_party_site_id,
      x_start_date,
      x_end_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate(new_references.party_site_id , new_references.start_date , new_references.end_date );
      IF (get_pk_for_validation( new_references.party_site_id)) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate(new_references.party_site_id , new_references.start_date , new_references.end_date );
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      BeforeRowInsertUpdate(new_references.party_site_id , new_references.start_date , new_references.end_date );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate(new_references.party_site_id , new_references.start_date , new_references.end_date );
      IF ( get_pk_for_validation ( new_references.party_site_id)) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_party_site_id                     IN OUT NOCOPY NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : asbala
  ||  Created On : 10-NOV-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_PE_HZ_PTY_SITES_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;


    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_party_site_id                     => x_party_site_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_hz_pty_sites (
      party_site_id,
      start_date,
      end_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      x_party_site_id,
      new_references.start_date,
      new_references.end_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID/*, party_site_id */INTO x_rowid/*, x_party_site_id*/;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;



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
    x_party_site_id                     IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE
  ) AS
  /*
  ||  Created By : asbala
  ||  Created On : 10-NOV-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        party_site_id,
        start_date,
        end_date
      FROM  igs_pe_hz_pty_sites
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
        (tlinfo.party_site_id = x_party_site_id)
        AND ((tlinfo.start_date = x_start_date) OR ((tlinfo.start_date IS NULL) AND (X_start_date IS NULL)))
        AND ((tlinfo.end_date = x_end_date) OR ((tlinfo.end_date IS NULL) AND (X_end_date IS NULL)))
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
    x_party_site_id                     IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : asbala
  ||  Created On : 10-NOV-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_PE_HZ_PTY_SITES_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_party_site_id                     => x_party_site_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_hz_pty_sites
      SET
        party_site_id                     = new_references.party_site_id,
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
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
    x_party_site_id                     IN OUT NOCOPY NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : asbala
  ||  Created On : 10-NOV-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_hz_pty_sites
      WHERE    party_site_id = x_party_site_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_party_site_id,
        x_start_date,
        x_end_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_party_site_id,
      x_start_date,
      x_end_date,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : asbala
  ||  Created On : 10-NOV-2003
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
 DELETE FROM igs_pe_hz_pty_sites
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


END igs_pe_hz_pty_sites_pkg;

/
