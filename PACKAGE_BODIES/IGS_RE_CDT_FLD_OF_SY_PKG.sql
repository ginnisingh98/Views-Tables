--------------------------------------------------------
--  DDL for Package Body IGS_RE_CDT_FLD_OF_SY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_CDT_FLD_OF_SY_PKG" as
/* $Header: IGSRI04B.pls 120.1 2005/07/04 00:41:28 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_re_val_cafos.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_RE_CDT_FLD_OF_SY%RowType;
  new_references IGS_RE_CDT_FLD_OF_SY%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_CDT_FLD_OF_SY
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN  ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.ca_sequence_number := x_ca_sequence_number;
    new_references.field_of_study := x_field_of_study;
    new_references.percentage := x_percentage;
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Turn off trigger validation when performing insert of IGS_RE_CANDIDATURE details
	-- as a result of IGS_PS_COURSE transfer
	IF igs_as_val_suaap.genp_val_sdtt_sess('ENRP_INS_CA_TRNSFR') THEN
		IF p_inserting  THEN
			-- Validate field of study.
			IF IGS_RE_VAL_CAFOS.resp_val_cafos_fos (
				new_references.person_id,
				new_references.ca_sequence_number,
				new_references.FIELD_OF_STUDY,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name ('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF p_inserting OR
			p_updating OR
			p_deleting THEN
			-- Validate updates are allowed
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Changed the reference of "IGS_RE_VAL_CAFOS.RESP_VAL_CA_CHILDUPD" to program unit "IGS_RE_VAL_CAH.RESP_VAL_CA_CHILDUPD". -- kdande
*/
			IF IGS_RE_VAL_CAH.resp_val_ca_childupd (
				new_references.person_id,
				new_references.ca_sequence_number,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name ('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;

 PROCEDURE Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) AS
 BEGIN

 if Column_Name is null then
   NULL;
 ELSIF upper(Column_name) = 'FIELD_OF_STUDY' THEN
   new_references.FIELD_OF_STUDY := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'PERCENTAGE' THEN
   new_references.PERCENTAGE := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'CA_SEQUENCE_NUMBER' THEN
   new_references.CA_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 end if;

  IF upper(column_name) = 'FIELD_OF_STUDY' OR COLUMN_NAME IS NULL THEN
    IF new_references.FIELD_OF_STUDY <> upper(new_references.FIELD_OF_STUDY) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;

  IF upper(column_name) = 'PERCENTAGE' OR COLUMN_NAME IS NULL THEN
    IF new_references.PERCENTAGE < 1 OR new_references.PERCENTAGE > 100 THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;

  IF upper(column_name) = 'CA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.CA_SEQUENCE_NUMBER < 1 OR new_references.CA_SEQUENCE_NUMBER > 999999 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;

 END Check_Constraints ;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.ca_sequence_number = new_references.ca_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.ca_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_CANDIDATURE_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.ca_sequence_number
        ) THEN
     	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF (((old_references.field_of_study = new_references.field_of_study)) OR
        ((new_references.field_of_study IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_FLD_OF_STUDY_PKG.Get_PK_For_Validation (
        new_references.field_of_study
        ) THEN
     	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_field_of_study IN VARCHAR2
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_CDT_FLD_OF_SY
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      field_of_study = x_field_of_study
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
 	RETURN(TRUE);
    ELSE
        Close cur_rowid;
        RETURN(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_RE_CANDIDATURE (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_CDT_FLD_OF_SY
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_CAFOS_CA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_CANDIDATURE;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
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
      x_ca_sequence_number,
      x_field_of_study,
      x_percentage,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.ca_sequence_number,
	    new_references.field_of_study
      ) THEN

	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	 IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.ca_sequence_number,
	    new_references.field_of_study
      ) THEN

	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	 IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    END IF;
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_RE_CDT_FLD_OF_SY
      where PERSON_ID = X_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
      and FIELD_OF_STUDY = X_FIELD_OF_STUDY;
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

  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_field_of_study => X_FIELD_OF_STUDY,
    x_percentage => X_PERCENTAGE,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_RE_CDT_FLD_OF_SY (
    PERSON_ID,
    CA_SEQUENCE_NUMBER,
    FIELD_OF_STUDY,
    PERCENTAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.CA_SEQUENCE_NUMBER,
    NEW_REFERENCES.FIELD_OF_STUDY,
    NEW_REFERENCES.PERCENTAGE,
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
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_PERCENTAGE in NUMBER
) as
  cursor c1 is select
      PERCENTAGE
    from IGS_RE_CDT_FLD_OF_SY
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.PERCENTAGE = X_PERCENTAGE)
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
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
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

  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_field_of_study => X_FIELD_OF_STUDY,
    x_percentage => X_PERCENTAGE,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_RE_CDT_FLD_OF_SY set
    PERCENTAGE = NEW_REFERENCES.PERCENTAGE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
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
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_RE_CDT_FLD_OF_SY
     where PERSON_ID = X_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
     and FIELD_OF_STUDY = X_FIELD_OF_STUDY
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_CA_SEQUENCE_NUMBER,
     X_FIELD_OF_STUDY,
     X_PERCENTAGE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_CA_SEQUENCE_NUMBER,
   X_FIELD_OF_STUDY,
   X_PERCENTAGE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
  ) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
   );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_RE_CDT_FLD_OF_SY
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


end DELETE_ROW;

end IGS_RE_CDT_FLD_OF_SY_PKG;

/
