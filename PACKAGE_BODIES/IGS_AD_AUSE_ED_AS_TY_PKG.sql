--------------------------------------------------------
--  DDL for Package Body IGS_AD_AUSE_ED_AS_TY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_AUSE_ED_AS_TY_PKG" as
/* $Header: IGSAI49B.pls 115.5 2003/10/30 13:13:25 akadam ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_AUSE_ED_AS_TY%RowType;
  new_references IGS_AD_AUSE_ED_AS_TY%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_aus_scndry_edu_ass_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_tac_aus_scndry_edu_ass_type IN VARCHAR2 DEFAULT NULL,
    x_state_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_reported_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_AUSE_ED_AS_TY
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.aus_scndry_edu_ass_type := x_aus_scndry_edu_ass_type;
    new_references.description := x_description;
    new_references.tac_aus_scndry_edu_ass_type := x_tac_aus_scndry_edu_ass_type;
    new_references.state_cd := x_state_cd;
    new_references.govt_reported_ind := x_govt_reported_ind;
    new_references.closed_ind := x_closed_ind;
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
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate that the tac_aus_scndry_edu_ass_type is not closed.
	IF p_inserting
	OR (old_references.tac_aus_scndry_edu_ass_type <> new_references.tac_aus_scndry_edu_ass_type)
	OR (old_references.tac_aus_scndry_edu_ass_type IS NULL AND
		new_references.tac_aus_scndry_edu_ass_type IS NOT NULL) THEN
		IF IGS_AD_VAL_ASEAT.admp_val_taseatclose(
					new_references.tac_aus_scndry_edu_ass_type,
					v_message_name) = FALSE THEN
		         Fnd_Message.Set_Name('IGS',v_message_name);
		         IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;

		END IF;
	END IF;

  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
  )
  AS
  BEGIN
	IF Column_Name is null then
		NULL;
	ELSIF upper(Column_Name) = 'GOVT_REPORTED_IND' then
		new_references.govt_reported_ind := column_value;
	ELSIF upper(Column_Name) = 'CLOSED_IND' then
		new_references.closed_ind := column_value;
	ELSIF upper(Column_Name) = 'STATE_CD' then
		new_references.state_cd := column_value;
	ELSIF upper(Column_Name) = 'AUS_SCNDRY_EDU_ASS_TYPE' then
		new_references.aus_scndry_edu_ass_type := column_value;
	ELSIF upper(Column_Name) = 'TAC_AUS_SCNDRY_EDU_ASS_TYPE' then
		new_references.tac_aus_scndry_edu_ass_type := column_value;
	END IF;

	IF upper(Column_Name) = 'GOVT_REPORTED_IND' OR Column_Name IS NULL THEN
		IF new_references.govt_reported_ind NOT IN ('Y','N') THEN
  		 Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
  		 IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'CLOSED_IND' OR Column_Name IS NULL THEN
		IF new_references.closed_ind NOT IN ('Y','N') THEN
    		 Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    		 IGS_GE_MSG_STACK.ADD;
 	        App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'STATE_CD' OR Column_Name IS NULL THEN
		IF new_references.state_cd <> UPPER(new_references.state_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'AUS_SCNDRY_EDU_ASS_TYPE' OR Column_Name IS NULL THEN
		IF new_references.aus_scndry_edu_ass_type <> UPPER(new_references.aus_scndry_edu_ass_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'TAC_AUS_SCNDRY_EDU_ASS_TYPE' OR Column_Name IS NULL THEN
		IF new_references.tac_aus_scndry_edu_ass_type <> UPPER(new_references.tac_aus_scndry_edu_ass_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
   	      	App_Exception.Raise_Exception;
		END IF;

END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.tac_aus_scndry_edu_ass_type = new_references.tac_aus_scndry_edu_ass_type)) OR
        ((new_references.tac_aus_scndry_edu_ass_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_TAC_AUSCED_AS_PKG.Get_PK_For_Validation (
        new_references.tac_aus_scndry_edu_ass_type ,
         'N') THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AS_TYPGOV_SCORMP_PKG.get_fk_igs_ad_ause_ed_as_ty (
      old_references.aus_scndry_edu_ass_type
      );

    IGS_AD_AUS_SEC_EDU_PKG.get_fk_igs_ad_ause_ed_as_ty (
      old_references.aus_scndry_edu_ass_type
      );

    IGS_AD_AUS_SEC_ED_SU_PKG.get_fk_igs_ad_ause_ed_as_ty (
      old_references.aus_scndry_edu_ass_type
      );

  END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
    x_aus_scndry_edu_ass_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2
)return BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUSE_ED_AS_TY
      WHERE    aus_scndry_edu_ass_type = x_aus_scndry_edu_ass_type AND
               closed_ind = NVL(x_closed_ind,closed_ind)
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;

  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_AD_TAC_AUSCED_AS (
    x_tac_aus_scndry_edu_ass_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUSE_ED_AS_TY
      WHERE    tac_aus_scndry_edu_ass_type = x_tac_aus_scndry_edu_ass_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ASAET_TASAET_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_TAC_AUSCED_AS;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_aus_scndry_edu_ass_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_tac_aus_scndry_edu_ass_type IN VARCHAR2 DEFAULT NULL,
    x_state_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_reported_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_aus_scndry_edu_ass_type,
      x_description,
      x_tac_aus_scndry_edu_ass_type,
      x_state_cd,
      x_govt_reported_ind,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
		new_references.aus_scndry_edu_ass_type
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
	  Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.aus_scndry_edu_ass_type
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	  Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAC_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_GOVT_REPORTED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_AUSE_ED_AS_TY
      where AUS_SCNDRY_EDU_ASS_TYPE = X_AUS_SCNDRY_EDU_ASS_TYPE;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
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
   x_aus_scndry_edu_ass_type=>X_AUS_SCNDRY_EDU_ASS_TYPE,
   x_closed_ind=>Nvl(X_CLOSED_IND, 'N'),
   x_description=>X_DESCRIPTION,
   x_govt_reported_ind=>Nvl(X_GOVT_REPORTED_IND, 'N'),
   x_state_cd=>X_STATE_CD,
   x_tac_aus_scndry_edu_ass_type=>X_TAC_AUS_SCNDRY_EDU_ASS_TYPE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_AD_AUSE_ED_AS_TY (
    AUS_SCNDRY_EDU_ASS_TYPE,
    DESCRIPTION,
    TAC_AUS_SCNDRY_EDU_ASS_TYPE,
    STATE_CD,
    GOVT_REPORTED_IND,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.AUS_SCNDRY_EDU_ASS_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.TAC_AUS_SCNDRY_EDU_ASS_TYPE,
    NEW_REFERENCES.STATE_CD,
    NEW_REFERENCES.GOVT_REPORTED_IND,
    NEW_REFERENCES.CLOSED_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  After_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAC_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_GOVT_REPORTED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      TAC_AUS_SCNDRY_EDU_ASS_TYPE,
      STATE_CD,
      GOVT_REPORTED_IND,
      CLOSED_IND
    from IGS_AD_AUSE_ED_AS_TY
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.TAC_AUS_SCNDRY_EDU_ASS_TYPE = X_TAC_AUS_SCNDRY_EDU_ASS_TYPE)
           OR ((tlinfo.TAC_AUS_SCNDRY_EDU_ASS_TYPE is null)
               AND (X_TAC_AUS_SCNDRY_EDU_ASS_TYPE is null)))
      AND ((tlinfo.STATE_CD = X_STATE_CD)
           OR ((tlinfo.STATE_CD is null)
               AND (X_STATE_CD is null)))
      AND (tlinfo.GOVT_REPORTED_IND = X_GOVT_REPORTED_IND)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAC_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_GOVT_REPORTED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
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
   x_aus_scndry_edu_ass_type=>X_AUS_SCNDRY_EDU_ASS_TYPE,
   x_closed_ind=>X_CLOSED_IND,
   x_description=>X_DESCRIPTION,
   x_govt_reported_ind=>X_GOVT_REPORTED_IND,
   x_state_cd=>X_STATE_CD,
   x_tac_aus_scndry_edu_ass_type=>X_TAC_AUS_SCNDRY_EDU_ASS_TYPE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_AD_AUSE_ED_AS_TY set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    TAC_AUS_SCNDRY_EDU_ASS_TYPE = NEW_REFERENCES.TAC_AUS_SCNDRY_EDU_ASS_TYPE,
    STATE_CD = NEW_REFERENCES.STATE_CD,
    GOVT_REPORTED_IND = NEW_REFERENCES.GOVT_REPORTED_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID);

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAC_AUS_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_GOVT_REPORTED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_AUSE_ED_AS_TY
     where AUS_SCNDRY_EDU_ASS_TYPE = X_AUS_SCNDRY_EDU_ASS_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_AUS_SCNDRY_EDU_ASS_TYPE,
     X_DESCRIPTION,
     X_TAC_AUS_SCNDRY_EDU_ASS_TYPE,
     X_STATE_CD,
     X_GOVT_REPORTED_IND,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_AUS_SCNDRY_EDU_ASS_TYPE,
   X_DESCRIPTION,
   X_TAC_AUS_SCNDRY_EDU_ASS_TYPE,
   X_STATE_CD,
   X_GOVT_REPORTED_IND,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_AD_AUSE_ED_AS_TY
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_AD_AUSE_ED_AS_TY_PKG;

/
