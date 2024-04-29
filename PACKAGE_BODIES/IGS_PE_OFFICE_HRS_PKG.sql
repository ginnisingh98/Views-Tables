--------------------------------------------------------
--  DDL for Package Body IGS_PE_OFFICE_HRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_OFFICE_HRS_PKG" AS
/* $Header: IGSNIB3B.pls 120.1 2005/06/28 06:07:07 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_office_hrs%ROWTYPE;
  new_references igs_pe_office_hrs%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_office_hrs_id                     IN     NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                       IN     VARCHAR2,
    x_start_tm_date                          IN     DATE,
    x_end_tm_date                            IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_office_hrs
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
    new_references.office_hrs_id                     := x_office_hrs_id;
    new_references.contact_preference_id             := x_contact_preference_id;
    new_references.day_of_week_code                       := x_day_of_week_code;
    new_references.start_tm_date                          := x_start_tm_date;
    new_references.end_tm_date                            := x_end_tm_date;

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



PROCEDURE validate_overlap (
p_contact_preference_id IN igs_pe_office_hrs.CONTACT_PREFERENCE_ID%type,
p_day_of_week_code IN igs_pe_office_hrs.day_of_week_code%TYPE,
p_start_tm_date IN DATE,
p_end_tm_date IN DATE,
P_OFFID NUMBER)   AS
/*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : overlap check.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pkpatel         18-JUL-2003     Bug 3026057
  ||                                  Consider only the time component in the overlap check
  */

  CURSOR c_overlap (cp_contact_preference_id igs_pe_office_hrs.CONTACT_PREFERENCE_ID%type,
  cp_day_of_week_code igs_pe_office_hrs.day_of_week_code%TYPE,
  cp_start_tm_date DATE,
  cp_end_tm_date DATE,
  cp_offid NUMBER) IS
  SELECT count(1)
  FROM igs_pe_office_hrs
  WHERE contact_preference_id = cp_contact_preference_id AND
        (CP_OFFID <> OFFICE_HRS_ID OR CP_OFFID IS NULL) AND
    	day_of_week_code = cp_day_of_week_code AND
       ( TO_DATE(TO_CHAR(end_tm_date,'HH24:MI'),'HH24:MI') > cp_start_tm_date OR TO_DATE(TO_CHAR(end_tm_date,'HH24:MI'),'HH24:MI') >= cp_end_tm_date) AND
       (TO_DATE(TO_CHAR(start_tm_date,'HH24:MI'),'HH24:MI') <= cp_start_tm_date OR TO_DATE(TO_CHAR(start_tm_date,'HH24:MI'),'HH24:MI') < cp_end_tm_date);


  l_count NUMBER(2) :=0;
  l_start_time   DATE := TO_DATE(TO_CHAR(p_start_tm_date,'HH24:MI'),'HH24:MI');
  l_end_time     DATE := TO_DATE(TO_CHAR(p_end_tm_date,'HH24:MI'),'HH24:MI');
  BEGIN

  OPEN c_overlap(p_contact_preference_id,p_day_of_week_code,l_start_time,l_end_time,p_offid);

  FETCH c_overlap INTO l_count;

    IF l_count > 0 THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_TIME_OVERLAP');
    	IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

  CLOSE c_overlap;

  END validate_overlap;




  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
/*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : date validations.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

  -- start time should be less than end time, while inserts and updates.
  IF (p_inserting OR p_updating) THEN


     -- check that start time less than end time
     IF (new_references.start_tm_date <> NVL(old_references.start_tm_date,IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
        (new_references.end_tm_date <> NVL(old_references.end_tm_date,IGS_GE_DATE.IGSDATE('1900/01/01')))  THEN

         IF to_char(new_references.start_tm_date,'HH24:MI') >= to_char(new_references.end_tm_date,'HH24:MI') THEN
	    FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_ST_TIME_LT_END_TIME');
	    IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
	 END IF;

      END IF;



   END IF;


  END BeforeRowInsertUpdate1;


  FUNCTION Get_PK_For_Validation (
    x_office_hrs_id IN NUMBER
    ) RETURN BOOLEAN AS
/*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : PK checks
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_OFFICE_HRS
      WHERE    office_hrs_id = x_office_hrs_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
       Close cur_rowid;
       Return (TRUE);
	 ELSE
       Close cur_rowid;
       Return (FALSE);
 END IF;

 END Get_PK_For_Validation;

 PROCEDURE Check_Parent_Existance AS

     CURSOR check_cont_pref_cur IS
	  SELECT 'X'
	  FROM   hz_contact_preferences
	  WHERE  contact_preference_id = new_references.contact_preference_id;

     l_var  VARCHAR2(1);

 BEGIN

     IF (((old_references.contact_preference_id  = new_references.contact_preference_id )) OR
          ((new_references.contact_preference_id  IS NULL))) THEN
          NULL;
     ELSE

         OPEN check_cont_pref_cur;
	 FETCH  check_cont_pref_cur into l_var;
	 IF check_cont_pref_cur%NOTFOUND THEN
               CLOSE check_cont_pref_cur;
               FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
               IGS_GE_MSG_STACK.ADD;
               APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
	  CLOSE check_cont_pref_cur;
     END IF;

 END Check_Parent_Existance;



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_office_hrs_id                     IN     NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                       IN     VARCHAR2,
    x_start_tm_date                          IN     DATE,
    x_end_tm_date                            IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vrathi          10-JUN-2003     Added calls to procedures for locla validation of duplicate records
  ||  pkpatel         26-JUN-2003     Bug 3026139 (Reversed the call of BeforeRowInsertUpdate1 and validate_overlap procedures)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_office_hrs_id,
      x_contact_preference_id,
      x_day_of_week_code,
      x_start_tm_date,
      x_end_tm_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN

      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 (
	  p_inserting => TRUE,
      p_updating  => FALSE,
	  p_deleting  => FALSE);

       -- validate the overlap check.(this should be done after the insert/update)
       validate_overlap(x_contact_preference_id,x_day_of_week_code, x_start_tm_date, x_end_tm_date,X_OFFICE_HRS_ID);

      IF ( get_pk_for_validation( new_references.office_hrs_id  )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      -- check valid cont pref
      Check_Parent_Existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN

      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 (
	  p_inserting => TRUE,
      p_updating  => FALSE,
	  p_deleting  => FALSE);

	  -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.office_hrs_id  )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    ELSIF (p_action = 'UPDATE') THEN

       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate1 (
     	  p_inserting => FALSE,
          p_updating  => TRUE,
	      p_deleting  => FALSE );

       -- validate the overlap check.(this should be done after the insert/update)
       validate_overlap(x_contact_preference_id,x_day_of_week_code, x_start_tm_date, x_end_tm_date,X_OFFICE_HRS_ID);

       -- check valid cont pref
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
       null;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
       -- Call all the procedures related to Before Delete.
       null;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       -- Call all the procedures related to Before Delete.
       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate1 (
     	  p_inserting => FALSE,
          p_updating  => TRUE,
	      p_deleting  => FALSE );

    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_office_hrs_id                     IN OUT NOCOPY NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                       IN     VARCHAR2,
    x_start_tm_date                          IN     DATE,
    x_end_tm_date                            IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_PE_OFFICE_HRS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_office_hrs_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_office_hrs_id                     => x_office_hrs_id,
      x_contact_preference_id             => x_contact_preference_id,
      x_day_of_week_code                       => x_day_of_week_code,
      x_start_tm_date                          => x_start_tm_date,
      x_end_tm_date                            => x_end_tm_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_office_hrs (
      office_hrs_id,
      contact_preference_id,
      day_of_week_code,
      start_tm_date,
      end_tm_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_pe_office_hrs_s.NEXTVAL,
      new_references.contact_preference_id,
      new_references.day_of_week_code,
      new_references.start_tm_date,
      new_references.end_tm_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, office_hrs_id INTO x_rowid, x_office_hrs_id;
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
    x_rowid                                  IN     VARCHAR2,
    x_office_hrs_id                          IN     NUMBER,
    x_contact_preference_id                  IN     NUMBER,
    x_day_of_week_code                       IN     VARCHAR2,
    x_start_tm_date                          IN     DATE,
    x_end_tm_date                            IN     DATE
  ) AS
  /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        office_hrs_id,
        contact_preference_id,
        day_of_week_code,
        start_tm_date,
        end_tm_date
      FROM  igs_pe_office_hrs
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
        (tlinfo.office_hrs_id = x_office_hrs_id)
        AND (tlinfo.contact_preference_id = x_contact_preference_id)
        AND (tlinfo.day_of_week_code = x_day_of_week_code)
        AND (tlinfo.start_tm_date = x_start_tm_date)
        AND (tlinfo.end_tm_date = x_end_tm_date)
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
    x_office_hrs_id                     IN     NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                  IN     VARCHAR2,
    x_start_tm_date                     IN     DATE,
    x_end_tm_date                       IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_PE_OFFICE_HRS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- x_office_hrs_id := NULL;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_office_hrs_id                     => x_office_hrs_id,
      x_contact_preference_id             => x_contact_preference_id,
      x_day_of_week_code                       => x_day_of_week_code,
      x_start_tm_date                          => x_start_tm_date,
      x_end_tm_date                            => x_end_tm_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_office_hrs
      SET
        office_hrs_id                     = new_references.office_hrs_id,
        contact_preference_id             = new_references.contact_preference_id,
        day_of_week_code                       = new_references.day_of_week_code,
        start_tm_date                          = new_references.start_tm_date,
        end_tm_date                            = new_references.end_tm_date,
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
    x_office_hrs_id                     IN OUT NOCOPY NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                       IN     VARCHAR2,
    x_start_tm_date                          IN     DATE,
    x_end_tm_date                            IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_office_hrs
      WHERE    office_hrs_id= x_office_hrs_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_office_hrs_id,
        x_contact_preference_id,
        x_day_of_week_code,
        x_start_tm_date,
        x_end_tm_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_office_hrs_id,
      x_contact_preference_id,
      x_day_of_week_code,
      x_start_tm_date,
      x_end_tm_date,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
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
 DELETE FROM igs_pe_office_hrs
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



  PROCEDURE insert_row_ss (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_office_hrs_id                     IN OUT NOCOPY NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                  IN     VARCHAR2,
    x_start_tm                          IN     VARCHAR2,
    x_end_tm                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
    ) AS
  /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Handles the INSERT DML logic for the table when called from SS.
  ||            The time component alone is passed here and not the complete date string.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  l_start_tm_date DATE;
  l_end_tm_date  DATE;
  BEGIN

  l_start_tm_date := TO_DATE(x_start_tm,'HH24:MI');
  l_end_tm_date := TO_DATE(x_end_tm,'HH24:MI');

  -- call the insert row passing the correct formatted date.
  insert_row
  (
   x_rowid                   =>   x_rowid,
   x_office_hrs_id           =>   x_office_hrs_id,
   x_contact_preference_id   =>   x_contact_preference_id,
   x_day_of_week_code        =>   x_day_of_week_code,
   x_start_tm_date           =>   l_start_tm_date,
   x_end_tm_date             =>   l_end_tm_date,
   x_mode                    =>   'R');

  END insert_row_ss;


   PROCEDURE update_row_ss (
    x_rowid                             IN     VARCHAR2,
    x_office_hrs_id                     IN     NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                  IN     VARCHAR2,
    x_start_tm                          IN     VARCHAR2,
    x_end_tm                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2)
    AS
     /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Handles the UPDATE DML logic for the table when called from SS.
  ||            The time component alone is passed here and not the complete date string.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

   l_start_tm_date DATE;
   l_end_tm_date  DATE;
  BEGIN

  l_start_tm_date := TO_DATE(x_start_tm,'HH24:MI');
  l_end_tm_date := TO_DATE(x_end_tm,'HH24:MI');

  -- call the insert row passing the correct formatted date.
  update_row
  (
   x_rowid                   =>   x_rowid,
   x_office_hrs_id           =>   x_office_hrs_id,
   x_contact_preference_id   =>   x_contact_preference_id,
   x_day_of_week_code        =>   x_day_of_week_code,
   x_start_tm_date           =>   l_start_tm_date,
   x_end_tm_date             =>   l_end_tm_date,
   x_mode                    =>   'R');

   END update_row_ss;



  PROCEDURE lock_row_ss (
    x_rowid                                  IN     VARCHAR2,
    x_office_hrs_id                          IN     NUMBER,
    x_contact_preference_id                  IN     NUMBER,
    x_day_of_week_code                       IN     VARCHAR2,
    x_start_tm                               IN     VARCHAR2,
    x_end_tm                                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        office_hrs_id,
        contact_preference_id,
        day_of_week_code,
        to_char(start_tm_date,'HH24:MI') start_tm_date,
        to_char(end_tm_date,'HH24:MI') end_tm_date
      FROM  igs_pe_office_hrs
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
        (tlinfo.office_hrs_id = x_office_hrs_id)
        AND (tlinfo.contact_preference_id = x_contact_preference_id)
        AND (tlinfo.day_of_week_code = x_day_of_week_code)
        --AND (tlinfo.start_tm_date = x_start_tm_date)
        --AND (tlinfo.end_tm_date = x_end_tm_date)
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row_ss;

END igs_pe_office_hrs_pkg;

/
