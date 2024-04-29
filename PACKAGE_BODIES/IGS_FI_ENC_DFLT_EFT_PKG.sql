--------------------------------------------------------
--  DDL for Package Body IGS_FI_ENC_DFLT_EFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_ENC_DFLT_EFT_PKG" AS
/* $Header: IGSSI16B.pls 115.6 2003/10/15 09:38:50 ssaleem ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_FI_ENC_DFLT_EFT%RowType;
  new_references IGS_FI_ENC_DFLT_EFT%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_encumbrance_type IN VARCHAR2 DEFAULT NULL,
    x_s_encmb_effect_type IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_ENC_DFLT_EFT
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
    new_references.encumbrance_type := x_encumbrance_type;
    new_references.s_encmb_effect_type := x_s_encmb_effect_type;
    new_references.comments := x_comments;
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
  -- Trigger description :-
  -- "OSS_TST".trg_etde_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_FI_ENC_DFLT_EFT
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate ENCUMBRANCE TYPE.
	IF p_inserting OR p_updating THEN
		IF IGS_EN_VAL_ETDE.enrp_val_et_closed (
				new_references.encumbrance_type,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate SYSTEM ENCUMBRANCE EFFECT TYPE.
	IF p_inserting OR
	    (p_updating AND (old_references.s_encmb_effect_type <> new_references.s_encmb_effect_type)) THEN
		IF IGS_EN_VAL_ETDE.enrp_val_seet_closed (
				new_references.s_encmb_effect_type,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;
PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
  IF  column_name is null then
     NULL;
  ELSIF upper(Column_name) = 'ENCUMBRANCE_TYPE' then
     new_references.encumbrance_type := column_value;
  ELSIF upper(Column_name) = 'S_ENCMB_EFFECT_TYPE' then
     new_references.s_encmb_effect_type := column_value;
  End if;

  IF upper(column_name) = 'ENCUMBRANCE_TYPE' OR
       column_name is null Then
       IF new_references.ENCUMBRANCE_TYPE <>
  	UPPER(new_references.ENCUMBRANCE_TYPE) Then
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
  END IF;

IF upper(column_name) = 'S_ENCMB_EFFECT_TYPE' OR
     column_name is null Then
     IF new_references.S_ENCMB_EFFECT_TYPE <>
	UPPER(new_references.S_ENCMB_EFFECT_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END Check_Constraints;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.encumbrance_type = new_references.encumbrance_type)) OR
        ((new_references.encumbrance_type IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_FI_ENCMB_TYPE_PKG.Get_PK_For_Validation (
        new_references.encumbrance_type
        )
		THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                     IGS_GE_MSG_STACK.ADD;
		     App_Exception.Raise_Exception;
		END IF;
    END IF;
    IF (((old_references.s_encmb_effect_type = new_references.s_encmb_effect_type)) OR
        ((new_references.s_encmb_effect_type IS NULL))) THEN
      NULL;

    ELSE
	  IF  NOT IGS_EN_ENCMB_EFCTTYP_Pkg.Get_PK_For_Validation (
        new_references.s_encmb_effect_type
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
             IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
  END Check_Parent_Existance;

  PROCEDURE GET_FK_IGS_FI_ENCMB_TYPE (
    x_encumbrance_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ENC_DFLT_EFT
      WHERE    encumbrance_type = x_encumbrance_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_ETDE_ET_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_ENCMB_TYPE;

  Function Get_PK_For_Validation (
    x_encumbrance_type IN VARCHAR2,
    x_s_encmb_effect_type IN VARCHAR2
    ) Return Boolean
	AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ENC_DFLT_EFT
      WHERE    encumbrance_type = x_encumbrance_type
      AND      s_encmb_effect_type = x_s_encmb_effect_type
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


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_encumbrance_type IN VARCHAR2 DEFAULT NULL,
    x_s_encmb_effect_type IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
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
      x_encumbrance_type,
      x_s_encmb_effect_type,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	  	IF  Get_PK_For_Validation (
			new_references.encumbrance_type ,
			new_references.s_encmb_effect_type
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
	      IF  Get_PK_For_Validation (
			new_references.encumbrance_type ,
			new_references.s_encmb_effect_type
	        ) THEN
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                 IGS_GE_MSG_STACK.ADD;
	          App_Exception.Raise_Exception;
	      END IF;
	      Check_Constraints;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	       Check_Constraints;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN
	      Null;
    END IF;
  END Before_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_ENC_DFLT_EFT
      where ENCUMBRANCE_TYPE = X_ENCUMBRANCE_TYPE
      and S_ENCMB_EFFECT_TYPE = X_S_ENCMB_EFFECT_TYPE;
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
Before_DML (
    p_action => 'INSERT',
    x_rowid => x_rowid,
    x_encumbrance_type => x_encumbrance_type,
    x_s_encmb_effect_type => x_s_encmb_effect_type,
    x_comments => x_comments,
	x_creation_date => X_LAST_UPDATE_DATE,
	x_created_by => X_LAST_UPDATED_BY,
	x_last_update_date => X_LAST_UPDATE_DATE,
	x_last_updated_by => X_LAST_UPDATED_BY,
	x_last_update_login => X_LAST_UPDATE_LOGIN
);
  insert into IGS_FI_ENC_DFLT_EFT (
    ENCUMBRANCE_TYPE,
    S_ENCMB_EFFECT_TYPE,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ENCUMBRANCE_TYPE,
    NEW_REFERENCES.S_ENCMB_EFFECT_TYPE,
    NEW_REFERENCES.COMMENTS,
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
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      COMMENTS
    from IGS_FI_ENC_DFLT_EFT
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
      if ( ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
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
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
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
	Before_DML (
	    p_action => 'UPDATE',
	    x_rowid => x_rowid,
	    x_encumbrance_type => x_encumbrance_type,
	    x_s_encmb_effect_type => x_s_encmb_effect_type,
	    x_comments => x_comments,
		x_creation_date => X_LAST_UPDATE_DATE,
		x_created_by => X_LAST_UPDATED_BY,
		x_last_update_date => X_LAST_UPDATE_DATE,
		x_last_updated_by => X_LAST_UPDATED_BY,
		x_last_update_login => X_LAST_UPDATE_LOGIN
	);
  update IGS_FI_ENC_DFLT_EFT set
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_ENC_DFLT_EFT
     where ENCUMBRANCE_TYPE = X_ENCUMBRANCE_TYPE
     and S_ENCMB_EFFECT_TYPE = X_S_ENCMB_EFFECT_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ENCUMBRANCE_TYPE,
     X_S_ENCMB_EFFECT_TYPE,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
X_ROWID,
   X_ENCUMBRANCE_TYPE,
   X_S_ENCMB_EFFECT_TYPE,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML(
 p_action => 'DELETE',
 x_rowid  => X_ROWID
);
  delete from IGS_FI_ENC_DFLT_EFT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_ENC_DFLT_EFT_PKG;

/
