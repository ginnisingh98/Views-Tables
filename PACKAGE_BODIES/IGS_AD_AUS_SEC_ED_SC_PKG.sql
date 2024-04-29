--------------------------------------------------------
--  DDL for Package Body IGS_AD_AUS_SEC_ED_SC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_AUS_SEC_ED_SC_PKG" as
/* $Header: IGSAI66B.pls 115.5 2003/10/30 13:13:49 akadam ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_AUS_SEC_ED_SC%RowType;
  new_references IGS_AD_AUS_SEC_ED_SC%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_secondary_school_cd IN VARCHAR2 DEFAULT NULL,
    x_secondary_school_name IN VARCHAR2 DEFAULT NULL,
    x_state_cd IN VARCHAR2 DEFAULT NULL,
    x_s_scndry_school_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_AUS_SEC_ED_SC
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
    new_references.secondary_school_cd := x_secondary_school_cd;
    new_references.secondary_school_name := x_secondary_school_name;
    new_references.state_cd := x_state_cd;
    new_references.s_scndry_school_type := x_s_scndry_school_type;
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
    ) as
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate System Secondary School Type.
	IF p_inserting OR ((old_references.s_scndry_school_type <> new_references.s_scndry_school_type) OR
			(old_references.closed_ind = 'Y' AND new_references.closed_ind = 'N')) THEN
		IF IGS_AD_VAL_ASES.admp_val_ssst_closed(
					new_references.s_scndry_school_type,
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
  as
  BEGIN
	IF Column_Name is null then
		NULL;
	ELSIF upper(Column_Name) = 'SECONDARY_SCHOOL_CD' then
		new_references.secondary_school_cd := column_value;
	ELSIF upper(Column_Name) = 'STATE_CD' then
		new_references.state_cd := column_value;
	ELSIF upper(Column_Name) = 'S_SCNDRY_SCHOOL_TYPE' then
		new_references.s_scndry_school_type := column_value;
	ELSIF upper(Column_Name) = 'CLOSED_IND' then
		new_references.closed_ind := column_value;
	END IF;

	IF upper(Column_Name) = 'STATE_CD' OR Column_Name IS NULL THEN
		IF new_references.state_cd <> UPPER(new_references.state_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'S_SCNDRY_SCHOOL_TYPE' OR Column_Name IS NULL THEN
		IF new_references.s_scndry_school_type <> UPPER(new_references.s_scndry_school_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'CLOSED_IND' OR Column_Name IS NULL THEN
		IF new_references.closed_ind NOT IN ('Y','N') THEN
			Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.s_scndry_school_type = new_references.s_scndry_school_type)) OR
        ((new_references.s_scndry_school_type IS NULL))) THEN
      NULL;
    ELSE
	IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
		'SCNDRY_SCHOOL_TYPE',
		new_references.s_scndry_school_type
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_AD_AUS_SEC_EDU_PKG.get_fk_igs_ad_aus_sec_ed_sc (
      old_references.secondary_school_cd
      );

  END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
    x_secondary_school_cd IN VARCHAR2,
    x_closed_ind IN VARCHAR2
)return BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUS_SEC_ED_SC
      WHERE    secondary_school_cd = x_secondary_school_cd AND
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


  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_scndry_school_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_AUS_SEC_ED_SC
      WHERE    s_scndry_school_type = x_s_scndry_school_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ASES_SLV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_secondary_school_cd IN VARCHAR2 DEFAULT NULL,
    x_secondary_school_name IN VARCHAR2 DEFAULT NULL,
    x_state_cd IN VARCHAR2 DEFAULT NULL,
    x_s_scndry_school_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_secondary_school_cd,
      x_secondary_school_name,
      x_state_cd,
      x_s_scndry_school_type,
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
		new_references.secondary_school_cd
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
		new_references.secondary_school_cd
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
  ) as
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SECONDARY_SCHOOL_CD in VARCHAR2,
  X_SECONDARY_SCHOOL_NAME in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_S_SCNDRY_SCHOOL_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_AD_AUS_SEC_ED_SC
      where SECONDARY_SCHOOL_CD = X_SECONDARY_SCHOOL_CD;
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
   x_closed_ind=>Nvl(X_CLOSED_IND, 'N'),
   x_s_scndry_school_type=>X_S_SCNDRY_SCHOOL_TYPE,
   x_secondary_school_cd=>X_SECONDARY_SCHOOL_CD,
   x_secondary_school_name=>X_SECONDARY_SCHOOL_NAME,
   x_state_cd=>X_STATE_CD,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_AD_AUS_SEC_ED_SC (
    SECONDARY_SCHOOL_CD,
    SECONDARY_SCHOOL_NAME,
    STATE_CD,
    S_SCNDRY_SCHOOL_TYPE,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SECONDARY_SCHOOL_CD,
    NEW_REFERENCES.SECONDARY_SCHOOL_NAME,
    NEW_REFERENCES.STATE_CD,
    NEW_REFERENCES.S_SCNDRY_SCHOOL_TYPE,
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
  X_SECONDARY_SCHOOL_CD in VARCHAR2,
  X_SECONDARY_SCHOOL_NAME in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_S_SCNDRY_SCHOOL_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) as
  cursor c1 is select
      SECONDARY_SCHOOL_NAME,
      STATE_CD,
      S_SCNDRY_SCHOOL_TYPE,
      CLOSED_IND
    from IGS_AD_AUS_SEC_ED_SC
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

  if ( (tlinfo.SECONDARY_SCHOOL_NAME = X_SECONDARY_SCHOOL_NAME)
      AND (tlinfo.STATE_CD = X_STATE_CD)
      AND ((tlinfo.S_SCNDRY_SCHOOL_TYPE = X_S_SCNDRY_SCHOOL_TYPE)
           OR ((tlinfo.S_SCNDRY_SCHOOL_TYPE is null)
               AND (X_S_SCNDRY_SCHOOL_TYPE is null)))
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
  X_SECONDARY_SCHOOL_CD in VARCHAR2,
  X_SECONDARY_SCHOOL_NAME in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_S_SCNDRY_SCHOOL_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
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
   x_closed_ind=>X_CLOSED_IND,
   x_s_scndry_school_type=>X_S_SCNDRY_SCHOOL_TYPE,
   x_secondary_school_cd=>X_SECONDARY_SCHOOL_CD,
   x_secondary_school_name=>X_SECONDARY_SCHOOL_NAME,
   x_state_cd=>X_STATE_CD,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  update IGS_AD_AUS_SEC_ED_SC set
    SECONDARY_SCHOOL_NAME = NEW_REFERENCES.SECONDARY_SCHOOL_NAME,
    STATE_CD = NEW_REFERENCES.STATE_CD,
    S_SCNDRY_SCHOOL_TYPE = NEW_REFERENCES.S_SCNDRY_SCHOOL_TYPE,
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
  X_SECONDARY_SCHOOL_CD in VARCHAR2,
  X_SECONDARY_SCHOOL_NAME in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_S_SCNDRY_SCHOOL_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_AD_AUS_SEC_ED_SC
     where SECONDARY_SCHOOL_CD = X_SECONDARY_SCHOOL_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SECONDARY_SCHOOL_CD,
     X_SECONDARY_SCHOOL_NAME,
     X_STATE_CD,
     X_S_SCNDRY_SCHOOL_TYPE,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SECONDARY_SCHOOL_CD,
   X_SECONDARY_SCHOOL_NAME,
   X_STATE_CD,
   X_S_SCNDRY_SCHOOL_TYPE,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_AD_AUS_SEC_ED_SC
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_AD_AUS_SEC_ED_SC_PKG;

/
