--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERSON_ALIAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERSON_ALIAS_PKG" AS
 /* $Header: IGSNI11B.pls 120.2 2005/07/31 23:35:56 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374. The Call to igs_as_val_pal.genp_val_strt_end_dt
  --                            is replaced by igs_ad_val_edtl.genp_val_strt_end_dt
  --smadathi    24-AUG-2001     Bug No. 1956374. The call to igs_en_val_pal.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  --skpandey	01-JUL-2005	Bug No. 4327807
  --				Added an additional condition in "BeforeRowInsertUpdate1" prodecure
  --				to check that the Effective start date must not be earlier than the person's year of birth.
  -------------------------------------------------------------------------------------------
/***********************************************************************

  CHANGE HISTORY		   : 1219551 FIXED BY - ahemmige 04-MAR-2000
  PROCEDURE/PROGRAM UNIT/FORM object affected	   : check_constraints
  PURPOSE/RATIONALE	 	  : There is no need to check the alias_comments
                             	    field for upper case restrictions.
  KNOWN LIMITATIONS/ENHANCEMENTS and REMARKS 	   :

***********************************************************************/

  l_rowid VARCHAR2(25);
  old_references IGS_PE_PERSON_ALIAS%RowType;
  new_references IGS_PE_PERSON_ALIAS%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    X_alias_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_surname IN VARCHAR2 DEFAULT NULL,
    x_given_names IN VARCHAR2 DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_alias_comment IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PERSON_ALIAS
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.alias_type := x_alias_type;
    new_references.sequence_number := x_sequence_number;
    new_references.start_dt := x_start_dt;
    new_references.end_dt := x_end_dt;
    new_references.surname := x_surname;
    new_references.given_names := x_given_names;
    new_references.title := x_title;
    new_references.alias_comment := x_alias_comment;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END Set_Column_Values;
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS

  CURSOR get_dob_dt_cur(cp_person_id igs_pe_passport.person_id%TYPE)
  IS
  SELECT birth_date
  FROM  igs_pe_person_base_v
  WHERE person_id = cp_person_id;
  l_birth_dt igs_pe_person_base_v.birth_date%TYPE;
  v_message_name  varchar2(30);
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_PE_PERSON_ALIAS') THEN
		-- Validate START DATE AND END DATE.
		-- Validate that if end date is specified, then start date is also specified.
		IF (new_references.end_dt IS NOT NULL) AND
			((p_inserting OR p_updating) OR
			(NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <> new_references.end_dt))
			THEN
			IF IGS_EN_VAL_PAL.enrp_val_api_end_dt (
			 		new_references.start_dt,
				 	new_references.end_dt,
				 	v_message_name) = FALSE THEN
				 Fnd_Message.Set_Name('IGS', v_message_name);
				 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate that if both are specified, then end is not greater than start.
		IF (new_references.end_dt IS NOT NULL) AND
			((p_inserting OR p_updating) OR
			(NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <> new_references.end_dt)) THEN
			IF igs_ad_val_edtl.genp_val_strt_end_dt (
				 	new_references.start_dt,
				 	new_references.end_dt,
				 	v_message_name) = FALSE THEN
				 Fnd_Message.Set_Name('IGS', v_message_name);
				 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Prevent the start date being set to null if the end date is specified.
		IF p_updating AND (new_references.start_dt IS NULL AND new_references.end_dt IS NOT NULL) THEN
			Fnd_Message.Set_Name('IGS', 'IGS_EN_CANT_REMOVE_ST_DATE');
			IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
		-- Validate Surname and Given Names.
		IF (p_inserting OR p_updating) THEN
			IF IGS_EN_VAL_PAL.enrp_val_pal_names (
			 		new_references.surname,
				 	new_references.given_names,
				 	v_message_name) = FALSE THEN
				 Fnd_Message.Set_Name('IGS', v_message_name);
				 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
			END IF;
		-- Validate that if both are specified, then the Effective start date must not be earlier than the person's year of birth.
			OPEN get_dob_dt_cur(new_references.person_id);
			FETCH get_dob_dt_cur INTO l_birth_dt;
			CLOSE get_dob_dt_cur;
			IF l_birth_dt IS NOT NULL AND new_references.start_dt IS NOT NULL THEN
				IF l_birth_dt > new_references.start_dt THEN
					FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_STDT_NOTLESS_BIRTHDT');
					IGS_GE_MSG_STACK.ADD;
					APP_EXCEPTION.RAISE_EXCEPTION;
				END IF;
			END IF;
		END IF;

-- This following IF block is removed as a fix for bug number 2045753
/*		IF (p_inserting OR p_updating) THEN
			IF IGS_EN_VAL_PAL.enrp_val_pal_alias (
					new_references.person_id,
			 		new_references.surname,
				 	new_references.given_names,
					new_references.title,
			 		v_message_name) = FALSE THEN
				 Fnd_Message.Set_Name('IGS', v_message_name);
				 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
			END IF;
		END IF;
*/
	END IF;

  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Constraints (
 Column_Name    IN      VARCHAR2        DEFAULT NULL,
 Column_Value   IN      VARCHAR2        DEFAULT NULL
 )
  AS
 BEGIN
    IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'GIVEN_NAMES' then
     new_references.given_names:= column_value;
  ELSIF upper(Column_name) = 'SURNAME' then
     new_references.surname:= column_value;
END IF;

IF upper(column_name) = 'GIVEN_NAMES' OR
     column_name is null Then
     IF new_references.given_names <>
UPPER(new_references.given_names) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'SURNAME' OR
     column_name is null Then
     IF new_references.surname<>
UPPER(new_references.surname) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

 END Check_Constraints;


 PROCEDURE Check_Parent_Existance AS
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

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    )  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERSON_ALIAS
      WHERE    person_id = x_person_id
      AND      sequence_number = x_sequence_number
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

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERSON_ALIAS
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PAL_PE_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_alias_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_surname IN VARCHAR2 DEFAULT NULL,
    x_given_names IN VARCHAR2 DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_alias_comment IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_alias_type,
      x_sequence_number,
      x_start_dt,
      x_end_dt,
      x_surname,
      x_given_names,
      x_title,
      x_alias_comment,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
     BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
          new_references.person_id ,
    	     new_references.sequence_number) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate1 ( p_updating => TRUE );

       Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.

      NULL;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.person_id ,
    	     new_references.sequence_number) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

 END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ALIAS_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TITLE in VARCHAR2,
  X_ALIAS_COMMENT in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_SURNAME in VARCHAR2,
  X_GIVEN_NAMES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
    cursor C is select ROWID from IGS_PE_PERSON_ALIAS
      where PERSON_ID = X_PERSON_ID
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_alias_comment=>X_ALIAS_COMMENT,
  x_end_dt=>X_END_DT,
  x_given_names=>X_GIVEN_NAMES,
  x_person_id=>X_PERSON_ID,
  x_alias_type=>X_ALIAS_TYPE,
  x_sequence_number=>X_SEQUENCE_NUMBER,
  x_start_dt=>X_START_DT,
  x_surname=>X_SURNAME,
  x_title=>X_TITLE,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PE_PERSON_ALIAS (
    TITLE,
    ALIAS_COMMENT,
    PERSON_ID,
    ALIAS_TYPE,
    SEQUENCE_NUMBER,
    START_DT,
    END_DT,
    SURNAME,
    GIVEN_NAMES,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.TITLE,
    NEW_REFERENCES.ALIAS_COMMENT,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ALIAS_TYPE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.SURNAME,
    NEW_REFERENCES.GIVEN_NAMES,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
  close c;

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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ALIAS_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TITLE in VARCHAR2,
  X_ALIAS_COMMENT in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_SURNAME in VARCHAR2,
  X_GIVEN_NAMES in VARCHAR2
) is
  cursor c1 is select
      TITLE,
      ALIAS_COMMENT,
      START_DT,
      END_DT,
      SURNAME,
      GIVEN_NAMES
    from IGS_PE_PERSON_ALIAS
    where  ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');

    close c1;
    App_Exception.Raise_Exception;
    return;
  end if;
  close c1;

      if ( ((tlinfo.TITLE = X_TITLE)
           OR ((tlinfo.TITLE is null)
               AND (X_TITLE is null)))
      AND ((tlinfo.ALIAS_COMMENT = X_ALIAS_COMMENT)
           OR ((tlinfo.ALIAS_COMMENT is null)
               AND (X_ALIAS_COMMENT is null)))
      AND ((tlinfo.START_DT = X_START_DT)
           OR ((tlinfo.START_DT is null)
               AND (X_START_DT is null)))
      AND ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND ((tlinfo.SURNAME = X_SURNAME)
           OR ((tlinfo.SURNAME is null)
               AND (X_SURNAME is null)))
      AND ((tlinfo.GIVEN_NAMES = X_GIVEN_NAMES)
           OR ((tlinfo.GIVEN_NAMES is null)
               AND (X_GIVEN_NAMES is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ALIAS_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TITLE in VARCHAR2,
  X_ALIAS_COMMENT in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_SURNAME in VARCHAR2,
  X_GIVEN_NAMES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) is
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_alias_comment=>X_ALIAS_COMMENT,
  x_end_dt=>X_END_DT,
  x_given_names=>X_GIVEN_NAMES,
  x_person_id=>X_PERSON_ID,
  x_alias_type=>X_ALIAS_TYPE,
  x_sequence_number=>X_SEQUENCE_NUMBER,
  x_start_dt=>X_START_DT,
  x_surname=>X_SURNAME,
  x_title=>X_TITLE,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PE_PERSON_ALIAS set
    TITLE = NEW_REFERENCES.TITLE,
    ALIAS_COMMENT = NEW_REFERENCES.ALIAS_COMMENT,
    START_DT = NEW_REFERENCES.START_DT,
    END_DT = NEW_REFERENCES.END_DT,
    SURNAME = NEW_REFERENCES.SURNAME,
    GIVEN_NAMES = NEW_REFERENCES.GIVEN_NAMES,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
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

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ALIAS_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TITLE in VARCHAR2,
  X_ALIAS_COMMENT in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_SURNAME in VARCHAR2,
  X_GIVEN_NAMES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PE_PERSON_ALIAS
     where PERSON_ID = X_PERSON_ID
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ALIAS_TYPE,
     X_SEQUENCE_NUMBER,
     X_TITLE,
     X_ALIAS_COMMENT,
     X_START_DT,
     X_END_DT,
     X_SURNAME,
     X_GIVEN_NAMES,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ALIAS_TYPE,
   X_SEQUENCE_NUMBER,
   X_TITLE,
   X_ALIAS_COMMENT,
   X_START_DT,
   X_END_DT,
   X_SURNAME,
   X_GIVEN_NAMES,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_PE_PERSON_ALIAS
  where ROWID = X_ROWID;
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
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;
end IGS_PE_PERSON_ALIAS_PKG;

/
