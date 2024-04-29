--------------------------------------------------------
--  DDL for Package Body IGS_RE_SCHOLARSHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_SCHOLARSHIP_PKG" as
/* $Header: IGSRI11B.pls 120.1 2005/07/04 00:41:46 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The call to igs_re_val_sch.genp_val_strt_end_dt
  --                            is changed to igs_ad_val_edtl.genp_val_strt_end_dt
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_re_val_sch.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_RE_SCHOLARSHIP_ALL%RowType;
  new_references IGS_RE_SCHOLARSHIP_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_scholarship_type IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_dollar_value IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_other_benefits IN VARCHAR2 DEFAULT NULL,
    x_conditions IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_SCHOLARSHIP_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
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
    new_references.scholarship_type := x_scholarship_type;
    new_references.start_dt := x_start_dt;
    new_references.end_dt := x_end_dt;
    new_references.dollar_value := x_dollar_value;
    new_references.description := x_description;
    new_references.other_benefits := x_other_benefits;
    new_references.conditions := x_conditions;
    new_references.org_id := x_org_id ;
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
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Turn off trigger validation when performing insert of IGS_RE_CANDIDATURE details
	-- as a result of IGS_PS_COURSE transfer
	IF igs_as_val_suaap.genp_val_sdtt_sess('ENRP_INS_CA_TRNSFR') THEN
		-- Validate that inserts are allowed
		IF  p_inserting THEN
			-- Validate if IGS_RE_SCHOLARSHIP type is closed
			IF  IGS_RE_VAL_SCH.resp_val_scht_closed (	new_references.scholarship_type,
							v_message_name) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate that inserts/updates are allowed
		IF  p_inserting OR p_updating THEN
			-- Validate if start date is before end date
			IF  igs_ad_val_edtl.genp_val_strt_end_dt (	new_references.start_dt,
							new_references.end_dt,
							v_message_name) = FALSE THEN
								Fnd_Message.Set_Name ('IGS', v_message_name);
								IGS_GE_MSG_STACK.ADD;
								App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
      v_message_name	VARCHAR2(30);

  BEGIN
	IF  p_inserting OR p_updating THEN
	    -- Save the rowid of the current row.
	      		-- Validate dates do not overlap
  		IF IGS_RE_VAL_SCH.resp_val_sch_ovrlp (
  					new_references.person_id,
  					new_references.ca_sequence_number,
  					new_references.scholarship_type,
  					new_references.start_dt,
  					new_references.end_dt,
  					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name ('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
  		END IF;
	END IF;
  END AfterRowInsertUpdate2;

  PROCEDURE Check_Constraints (
    Column_Name in VARCHAR2 DEFAULT NULL ,
    Column_Value in VARCHAR2 DEFAULT NULL
  ) AS
 BEGIN

 IF Column_Name is null then
   NULL;
 ELSIF upper(Column_name) = 'SCHOLARSHIP_TYPE' THEN
   new_references.SCHOLARSHIP_TYPE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'CA_SEQUENCE_NUMBER' THEN
   new_references.CA_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'DOLLAR_VALUE' THEN
   new_references.DOLLAR_VALUE := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 END IF;

  IF upper(column_name) = 'SCHOLARSHIP_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.SCHOLARSHIP_TYPE <> upper(NEW_REFERENCES.SCHOLARSHIP_TYPE) then
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
  IF upper(column_name) = 'DOLLAR_VALUE' OR COLUMN_NAME IS NULL THEN
    IF new_references.DOLLAR_VALUE < 0 OR new_references.DOLLAR_VALUE > 999999.99  then
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

    IF (((old_references.scholarship_type = new_references.scholarship_type)) OR
        ((new_references.scholarship_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_SCHL_TYPE_PKG.Get_PK_For_Validation (
        new_references.scholarship_type
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
    x_scholarship_type IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN
   AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SCHOLARSHIP_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      scholarship_type = x_scholarship_type
      AND      start_dt = x_start_dt
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
      FROM     IGS_RE_SCHOLARSHIP_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_SCH_CA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_CANDIDATURE;

  PROCEDURE GET_FK_IGS_RE_SCHL_TYPE (
    x_scholarship_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SCHOLARSHIP_ALL
      WHERE    scholarship_type = x_scholarship_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_SCH_SCHT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_SCHL_TYPE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_scholarship_type IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_dollar_value IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_other_benefits IN VARCHAR2 DEFAULT NULL,
    x_conditions IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_ca_sequence_number,
      x_scholarship_type,
      x_start_dt,
      x_end_dt,
      x_dollar_value,
      x_description,
      x_other_benefits,
      x_conditions,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      IF Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.ca_sequence_number,
	    new_references.scholarship_type,
	    new_references.start_dt
      ) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	 IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.ca_sequence_number,
	    new_references.scholarship_type,
	    new_references.start_dt
      ) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	 IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
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
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    END IF;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_DOLLAR_VALUE in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_OTHER_BENEFITS in VARCHAR2,
  X_CONDITIONS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
    cursor C is select ROWID from IGS_RE_SCHOLARSHIP_ALL
      where PERSON_ID = X_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
      and SCHOLARSHIP_TYPE = X_SCHOLARSHIP_TYPE
      and START_DT = X_START_DT;
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
    x_scholarship_type => X_SCHOLARSHIP_TYPE,
    x_start_dt => X_START_DT,
    x_end_dt => X_END_DT,
    x_dollar_value => X_DOLLAR_VALUE,
    x_description => X_DESCRIPTION,
    x_other_benefits => X_OTHER_BENEFITS,
    x_conditions => X_CONDITIONS,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
 );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_RE_SCHOLARSHIP_ALL (
    PERSON_ID,
    CA_SEQUENCE_NUMBER,
    SCHOLARSHIP_TYPE,
    START_DT,
    END_DT,
    DOLLAR_VALUE,
    DESCRIPTION,
    OTHER_BENEFITS,
    CONDITIONS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.CA_SEQUENCE_NUMBER,
    NEW_REFERENCES.SCHOLARSHIP_TYPE,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.DOLLAR_VALUE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.OTHER_BENEFITS,
    NEW_REFERENCES.CONDITIONS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
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

 After_DML (
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_DOLLAR_VALUE in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_OTHER_BENEFITS in VARCHAR2,
  X_CONDITIONS in VARCHAR2
) as
  cursor c1 is select
      END_DT,
      DOLLAR_VALUE,
      DESCRIPTION,
      OTHER_BENEFITS,
      CONDITIONS
    from IGS_RE_SCHOLARSHIP_ALL
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

      if ( ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND ((tlinfo.DOLLAR_VALUE = X_DOLLAR_VALUE)
           OR ((tlinfo.DOLLAR_VALUE is null)
               AND (X_DOLLAR_VALUE is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.OTHER_BENEFITS = X_OTHER_BENEFITS)
           OR ((tlinfo.OTHER_BENEFITS is null)
               AND (X_OTHER_BENEFITS is null)))
      AND ((tlinfo.CONDITIONS = X_CONDITIONS)
           OR ((tlinfo.CONDITIONS is null)
               AND (X_CONDITIONS is null)))

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
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_DOLLAR_VALUE in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_OTHER_BENEFITS in VARCHAR2,
  X_CONDITIONS in VARCHAR2,
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
    x_scholarship_type => X_SCHOLARSHIP_TYPE,
    x_start_dt => X_START_DT,
    x_end_dt => X_END_DT,
    x_dollar_value => X_DOLLAR_VALUE,
    x_description => X_DESCRIPTION,
    x_other_benefits => X_OTHER_BENEFITS,
    x_conditions => X_CONDITIONS,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_RE_SCHOLARSHIP_ALL set
    END_DT = NEW_REFERENCES.END_DT,
    DOLLAR_VALUE = NEW_REFERENCES.DOLLAR_VALUE,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    OTHER_BENEFITS = NEW_REFERENCES.OTHER_BENEFITS,
    CONDITIONS = NEW_REFERENCES.CONDITIONS,
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
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_DOLLAR_VALUE in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_OTHER_BENEFITS in VARCHAR2,
  X_CONDITIONS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_SCHOLARSHIP_ALL
     where PERSON_ID = X_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
     and SCHOLARSHIP_TYPE = X_SCHOLARSHIP_TYPE
     and START_DT = X_START_DT
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
     X_SCHOLARSHIP_TYPE,
     X_START_DT,
     X_END_DT,
     X_DOLLAR_VALUE,
     X_DESCRIPTION,
     X_OTHER_BENEFITS,
     X_CONDITIONS,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_CA_SEQUENCE_NUMBER,
   X_SCHOLARSHIP_TYPE,
   X_START_DT,
   X_END_DT,
   X_DOLLAR_VALUE,
   X_DESCRIPTION,
   X_OTHER_BENEFITS,
   X_CONDITIONS,
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
  delete from IGS_RE_SCHOLARSHIP_ALL
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

end IGS_RE_SCHOLARSHIP_PKG;

/
