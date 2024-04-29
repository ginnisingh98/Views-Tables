--------------------------------------------------------
--  DDL for Package Body IGS_PE_ACAD_INTENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_ACAD_INTENTS_PKG" AS
/* $Header: IGSNIB6B.pls 120.0 2006/05/23 12:32:39 vskumar noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_acad_intents%ROWTYPE;
  new_references igs_pe_acad_intents%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_acad_intent_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : vskumar
  ||  Created On : 25-APR-2006
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_acad_intents
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
    new_references.acad_intent_id                    := x_acad_intent_id;
    new_references.person_id                         := x_person_id;
    new_references.cal_type                          := x_cal_type;
    new_references.sequence_number                   := x_sequence_number;
    new_references.acad_intent_code                  := x_acad_intent_code;
    new_references.active_flag                       := x_active_flag;

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


 PROCEDURE AfterRowInsertUpdate(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : vskumar
  --Date created: 26-APR-2006
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------
  lv_rowid		varchar2(25);
  lv_acad_intent_code	IGS_PE_ACAD_INTENTS.acad_intent_code%TYPE;
  ln_acad_intent_id     NUMBER;

  CURSOR	c_act (cp_person_id IGS_PE_ACAD_INTENTS.person_id%TYPE,
		       cp_cal_type IGS_PE_ACAD_INTENTS.cal_type%TYPE,
		       cp_sequence_number IGS_PE_ACAD_INTENTS.sequence_number%TYPE,
		       cp_active_flag IGS_PE_ACAD_INTENTS.active_flag%TYPE,
		       cp_l_rowid varchar2) IS
		SELECT rowid, acad_intent_code
		FROM IGS_PE_ACAD_INTENTS
		WHERE person_id = cp_person_id
		AND cal_type = cp_cal_type
		AND sequence_number = cp_sequence_number
		AND active_flag = cp_active_flag
		AND ROWID <> cp_l_rowid;


  BEGIN
   IF p_inserting THEN
	OPEN c_act (new_references.person_id,
		    new_references.cal_type,
		    new_references.sequence_number,
		    'Y',
		    l_rowid);

	FETCH c_act INTO lv_rowid, lv_acad_intent_code;
  	IF (c_act%FOUND) THEN
		UPDATE igs_pe_acad_intents
		SET active_flag = 'N'
		WHERE rowid=  lv_rowid;
	END IF;

	CLOSE c_act;

	IGS_PE_WF_GEN.raise_acad_intent_event(P_ACAD_INTENT_ID => new_references.acad_intent_id,
	                                      P_PERSON_ID=> new_references.person_id,
					      P_CAL_TYPE=>new_references.cal_type,
					      P_CAL_SEQ_NUMBER=>new_references.sequence_number,
					      P_ACAD_INTENT_CODE=>new_references.acad_intent_code,
					      P_OLD_ACAD_INTENT_CODE=>lv_acad_intent_code);

   ELSIF p_updating THEN
	INSERT INTO igs_pe_acad_intents (
					acad_intent_id,
					person_id,
					cal_type,
					sequence_number,
					acad_intent_code,
					active_flag,
					creation_date,
					created_by,
					last_update_date,
					last_updated_by,
					last_update_login
					) VALUES (
						 igs_pe_acad_intents_s.NEXTVAL,
						 new_references.person_id,
						 new_references.cal_type,
						 new_references.sequence_number,
						 new_references.acad_intent_code,
						 'Y',
						 SYSDATE,
						 fnd_global.user_id,
						 SYSDATE,
						 fnd_global.user_id,
						 fnd_global.login_id ) RETURNING acad_intent_id INTO ln_acad_intent_id;

	IGS_PE_WF_GEN.raise_acad_intent_event(P_ACAD_INTENT_ID => ln_acad_intent_id,
	                                      P_PERSON_ID=> new_references.person_id,
					      P_CAL_TYPE=>new_references.cal_type,
					      P_CAL_SEQ_NUMBER=>new_references.sequence_number,
					      P_ACAD_INTENT_CODE=>new_references.acad_intent_code,
					      P_OLD_ACAD_INTENT_CODE=>old_references.acad_intent_code);


   END IF;
END AfterRowInsertUpdate;

PROCEDURE Check_Parent_Existance as
  BEGIN
   IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
   ELSE
	IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
		new_references.person_id ) THEN
		Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;
  END Check_Parent_Existance;

  FUNCTION get_pk_for_validation (
    x_acad_intent_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : vskumar
  ||  Created On : 25-APR-2006
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_acad_intents
      WHERE    acad_intent_id = x_acad_intent_id
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_acad_intent_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : vskumar
  ||  Created On : 25-APR-2006
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
      x_acad_intent_id,
      x_person_id,
      x_cal_type,
      x_sequence_number,
      x_acad_intent_code,
      x_active_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      IF ( get_pk_for_validation(
             new_references.acad_intent_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

      Check_Parent_Existance; -- if procedure present
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.acad_intent_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) as
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
	AfterRowInsertUpdate(p_inserting => TRUE,
          p_updating  => FALSE,
          p_deleting  => FALSE);

    ELSIF (p_action = 'UPDATE') THEN
      AfterRowInsertUpdate(p_inserting => FALSE,
          p_updating  => TRUE,
          p_deleting  => FALSE);

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      NULL;
    END IF;
  END After_DML;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acad_intent_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vskumar
  ||  Created On : 25-APR-2006
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
    ELSIF (x_mode IN ('R','S')) THEN
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
      fnd_message.set_token ('ROUTINE', 'igs_pe_acad_intents_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_acad_intent_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_acad_intent_id                    => x_acad_intent_id,
      x_person_id                         => x_person_id,
      x_cal_type                          => x_cal_type,
      x_sequence_number                   => x_sequence_number,
      x_acad_intent_code                  => x_acad_intent_code,
      x_active_flag                       => x_active_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
   END IF;

    INSERT INTO igs_pe_acad_intents (
      acad_intent_id,
      person_id,
      cal_type,
      sequence_number,
      acad_intent_code,
      active_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_pe_acad_intents_s.NEXTVAL,
      new_references.person_id,
      new_references.cal_type,
      new_references.sequence_number,
      new_references.acad_intent_code,
      'Y',
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, acad_intent_id INTO x_rowid, x_acad_intent_id;

  new_references.acad_intent_id := x_acad_intent_id;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
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
    x_acad_intent_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vskumar
  ||  Created On : 25-APR-2006
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        cal_type,
        sequence_number,
        acad_intent_code,
        active_flag
      FROM  igs_pe_acad_intents
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.cal_type = x_cal_type)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND (tlinfo.acad_intent_code = x_acad_intent_code)
        AND (tlinfo.active_flag = x_active_flag)
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
    x_acad_intent_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vskumar
  ||  Created On : 25-APR-2006
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
    ELSIF (x_mode IN ('R','S')) THEN
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
      fnd_message.set_token ('ROUTINE', 'igs_pe_acad_intents_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_acad_intent_id                    => x_acad_intent_id,
      x_person_id                         => x_person_id,
      x_cal_type                          => x_cal_type,
      x_sequence_number                   => x_sequence_number,
      x_acad_intent_code                  => x_acad_intent_code,
      x_active_flag                       => x_active_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'S') THEN
      igs_sc_gen_001.set_ctx('R');
    END IF;

    UPDATE igs_pe_acad_intents
      SET
        person_id                         = new_references.person_id,
        cal_type                          = new_references.cal_type,
        sequence_number                   = new_references.sequence_number,
        acad_intent_code                  = old_references.acad_intent_code,
        active_flag                       = 'N',
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;

 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );

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
    x_acad_intent_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vskumar
  ||  Created On : 25-APR-2006
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_acad_intents
      WHERE    acad_intent_id                    = x_acad_intent_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_acad_intent_id,
        x_person_id,
        x_cal_type,
        x_sequence_number,
        x_acad_intent_code,
        x_active_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_acad_intent_id,
      x_person_id,
      x_cal_type,
      x_sequence_number,
      x_acad_intent_code,
      x_active_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
    x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : vskumar
  ||  Created On : 25-APR-2006
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
    DELETE FROM igs_pe_acad_intents
    WHERE rowid = x_rowid;

  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  END delete_row;


END igs_pe_acad_intents_pkg;

/
