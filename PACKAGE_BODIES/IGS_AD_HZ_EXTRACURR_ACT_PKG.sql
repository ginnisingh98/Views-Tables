--------------------------------------------------------
--  DDL for Package Body IGS_AD_HZ_EXTRACURR_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_HZ_EXTRACURR_ACT_PKG" AS
/* $Header: IGSAIB9B.pls 120.1 2005/06/28 04:33:16 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_hz_extracurr_act%ROWTYPE;
  new_references igs_ad_hz_extracurr_act%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hz_extracurr_act_id               IN     NUMBER      DEFAULT NULL,
    x_person_interest_id                IN     NUMBER      DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_hours_per_week                    IN     NUMBER      DEFAULT NULL,
    x_weeks_per_year                    IN     NUMBER      DEFAULT NULL,
    x_activity_source_cd                IN     VARCHAR2    DEFAULT NULL,
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
      FROM     IGS_AD_HZ_EXTRACURR_ACT
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.hz_extracurr_act_id               := x_hz_extracurr_act_id;
    new_references.person_interest_id                := x_person_interest_id;
    new_references.end_date                          := TRUNC(x_end_date);
    new_references.hours_per_week                    := x_hours_per_week;
    new_references.weeks_per_year                    := x_weeks_per_year;
    new_references.activity_source_cd                := x_activity_source_cd;


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
  CURSOR cur_rowid IS
         SELECT   ROWID
         FROM     hz_person_interest
         WHERE    person_interest_id = new_references.person_interest_id ;
       lv_rowid cur_rowid%ROWTYPE;
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

    IF (((old_references.person_interest_id = new_references.person_interest_id)) OR
        ((new_references.person_interest_id IS NULL))) THEN
      NULL;
    ELSE
    OPEN cur_rowid;
       FETCH cur_rowid INTO lv_rowid;
       IF (cur_rowid%NOTFOUND) THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
       END IF;
     CLOSE cur_rowid;

    END IF;

    IF (((old_references.activity_source_cd = new_references.activity_source_cd)) OR
        ((new_references.activity_source_cd IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'ACTIVITY_SOURCE',
          new_references.activity_source_cd
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
     END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_hz_extracurr_act_id            IN     NUMBER
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
      SELECT   ROWID
      FROM     igs_ad_hz_extracurr_act
      WHERE    hz_extracurr_act_id = x_hz_extracurr_act_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

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

  PROCEDURE get_fk_hz_person_interest (
    x_person_interest_id                        IN     NUMBER
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
      SELECT   ROWID
      FROM     igs_ad_hz_extracurr_act
      WHERE   ((person_interest_id  = x_person_interest_id ));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_person_interest;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hz_extracurr_act_id               IN     NUMBER      DEFAULT NULL,
    x_person_interest_id                IN     NUMBER      DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_hours_per_week                    IN     NUMBER      DEFAULT NULL,
    x_weeks_per_year                    IN     NUMBER      DEFAULT NULL,
    x_activity_source_cd                IN     VARCHAR2    DEFAULT NULL,
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
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_hz_extracurr_act_id,
      x_person_interest_id,
      x_end_date,
      x_hours_per_week,
      x_weeks_per_year,
      x_activity_source_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
		new_references.hz_extracurr_act_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
	  check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_constraints;
	  check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
	NULL;
      -- Call all the procedures related to Before Delete.
     -- check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
		new_references.hz_extracurr_act_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hz_extracurr_act_id               IN OUT NOCOPY NUMBER,
    x_person_interest_id                IN     NUMBER,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
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
      SELECT   ROWID
      FROM     igs_ad_hz_extracurr_act
      WHERE    hz_extracurr_act_id	= x_hz_extracurr_act_id;

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
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id:=FND_GLOBAL.CONC_REQUEST_ID;
      x_program_id:=FND_GLOBAL.CONC_PROGRAM_ID;
      x_program_application_id:=FND_GLOBAL.PROG_APPL_ID;
      IF (x_request_id = -1 ) THEN
        x_request_id:=NULL;
        x_program_id:=NULL;
        x_program_application_id:=NULL;
        x_program_update_date:=NULL;
      ELSE
        x_program_update_date:=SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    X_HZ_EXTRACURR_ACT_ID := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hz_extracurr_act_id               => x_hz_extracurr_act_id,
      x_person_interest_id                => x_person_interest_id,
      x_end_date                          => x_end_date,
      x_hours_per_week                    => x_hours_per_week,
      x_weeks_per_year                    => x_weeks_per_year,
      x_activity_source_cd                => x_activity_source_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_ad_hz_extracurr_act (
      hz_extracurr_act_id,
      person_interest_id,
      end_date,
      hours_per_week,
      weeks_per_year,
      activity_source_cd,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_application_id,
      program_update_date,
      program_id
    ) VALUES (
      IGS_AD_HZ_EXTRACURR_ACT_S.NEXTVAL,
      new_references.person_interest_id,
      new_references.end_date,
      new_references.hours_per_week,
      new_references.weeks_per_year,
      new_references.activity_source_cd,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_request_id,
      x_program_application_id,
      x_program_update_date,
      x_program_id
    )RETURNING HZ_EXTRACURR_ACT_ID INTO X_HZ_EXTRACURR_ACT_ID;
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
    x_hz_extracurr_act_id               IN     NUMBER,
    x_person_interest_id                IN     NUMBER,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL
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
        hz_extracurr_act_id,
        person_interest_id,
        end_date,
        hours_per_week,
        weeks_per_year,
        activity_source_cd
      FROM  igs_ad_hz_extracurr_act
      WHERE ROWID = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.hz_extracurr_act_id = x_hz_extracurr_act_id)
        AND (tlinfo.person_interest_id = x_person_interest_id)
        AND ((TRUNC(tlinfo.end_date) = TRUNC(x_end_date)) OR ((tlinfo.end_date IS NULL) AND (X_end_date IS NULL)))
        AND ((tlinfo.hours_per_week = x_hours_per_week) OR ((tlinfo.hours_per_week IS NULL) AND (X_hours_per_week IS NULL)))
        AND ((tlinfo.weeks_per_year = x_weeks_per_year) OR ((tlinfo.weeks_per_year IS NULL) AND (X_weeks_per_year IS NULL)))
        AND ((tlinfo.activity_source_cd = x_activity_source_cd) OR ((tlinfo.activity_source_cd IS NULL) AND (x_activity_source_cd IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hz_extracurr_act_id               IN     NUMBER,
    x_person_interest_id                IN     NUMBER,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
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
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id:=FND_GLOBAL.CONC_REQUEST_ID;
      x_program_id:=FND_GLOBAL.CONC_PROGRAM_ID;
      x_program_application_id:=FND_GLOBAL.PROG_APPL_ID;
      IF (x_request_id = -1 ) THEN
        x_request_id:=NULL;
        x_program_id:=NULL;
        x_program_application_id:=NULL;
        x_program_update_date:=NULL;
      ELSE
        x_program_update_date:=SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_hz_extracurr_act_id               => x_hz_extracurr_act_id,
      x_person_interest_id                => x_person_interest_id,
      x_end_date                          => x_end_date,
      x_hours_per_week                    => x_hours_per_week,
      x_weeks_per_year                    => x_weeks_per_year,
      x_activity_source_cd                => x_activity_source_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_ad_hz_extracurr_act
      SET
        hz_extracurr_act_id               = new_references.hz_extracurr_act_id,
        person_interest_id                = new_references.person_interest_id,
        end_date                          = new_references.end_date,
        hours_per_week                    = new_references.hours_per_week,
        weeks_per_year                    = new_references.weeks_per_year,
        activity_source_cd                = new_references.activity_source_cd,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        request_id                        = x_request_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        program_id                        = x_program_id
      WHERE ROWID = x_rowid;

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
    x_hz_extracurr_act_id               IN OUT NOCOPY NUMBER,
    x_person_interest_id                IN     NUMBER,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
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
      SELECT   ROWID
      FROM     igs_ad_hz_extracurr_act
      WHERE    hz_extracurr_act_id	= x_hz_extracurr_act_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hz_extracurr_act_id,
        x_person_interest_id,
        x_end_date,
        x_hours_per_week,
        x_weeks_per_year,
        x_activity_source_cd ,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hz_extracurr_act_id,
      x_person_interest_id,
      x_end_date,
      x_hours_per_week,
      x_weeks_per_year,
      x_activity_source_cd,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_ad_hz_extracurr_act
    WHERE ROWID = x_rowid;

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

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :amuthu
  Date Created By :03-Jul-2001
  Purpose : This has been added during the ID prospective applicant
  part 2 of build. This peice of code was missing and has been
  copied from an older version of the TBH and slighlty modidifed
  to remove the reference to the item that do not exist in the table
  anymore (start_date removed but present in HZ_PERSON_INTEREST)
  The validation for end_date with out NOCOPY the start_date is not possible
  hence removed that too.

  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'HOURS_PER_WEEK'  THEN
        new_references.hours_per_week := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'WEEKS_PER_YEAR'  THEN
        new_references.weeks_per_year := IGS_GE_NUMBER.TO_NUM(column_value);
      END IF;


    -- The following code checks for check constraints on the Columns.
      IF UPPER(Column_Name) = 'HOURS_PER_WEEK' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.hours_per_week >= 0
              AND new_references.hours_per_week <= 168 )  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_HRS_PER_WEEK');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

   -- The following code checks for check constraints on the Columns.
      IF UPPER(Column_Name) = 'WEEKS_PER_YEAR' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.weeks_per_year >= 0
              AND new_references.weeks_per_year <= 52 )  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_WKS_PER_YEAR');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

  END Check_Constraints;


END igs_ad_hz_extracurr_act_pkg;

/
