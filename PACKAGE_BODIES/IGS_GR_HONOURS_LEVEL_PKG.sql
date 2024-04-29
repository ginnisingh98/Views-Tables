--------------------------------------------------------
--  DDL for Package Body IGS_GR_HONOURS_LEVEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_HONOURS_LEVEL_PKG" as
/* $Header: IGSGI14B.pls 115.9 2003/02/24 12:08:53 anilk ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_HONOURS_LEVEL_ALL%RowType;
  new_references IGS_GR_HONOURS_LEVEL_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_honours_level IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_govt_honours_level IN VARCHAR2 ,
    x_rank IN NUMBER ,
    x_closed_ind IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_HONOURS_LEVEL_ALL
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
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.honours_level := x_honours_level;
    new_references.description := x_description;
    new_references.govt_honours_level := x_govt_honours_level;
    new_references.rank := x_rank;
    new_references.closed_ind := x_closed_ind;
    new_references.org_id := x_org_id;
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
  -- "OSS_TST".trg_hl_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_GR_HONOURS_LEVEL_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate  Govt. Honours Level.
	IF p_inserting OR ((old_references.govt_honours_level <>
				 new_references.govt_honours_level) OR
			(old_references.closed_ind = 'Y' AND new_references.closed_ind = 'N')) THEN
		IF IGS_GR_VAL_GHL.grdp_val_ghl_closed(
					new_references.govt_honours_level,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
  				App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.govt_honours_level = new_references.govt_honours_level)) OR
        ((new_references.govt_honours_level IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_GOVT_HNS_LVL_PKG.Get_PK_For_Validation (
        new_references.govt_honours_level
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE CHECK_CONSTRAINTS(
	Column_Name IN VARCHAR2  ,
	Column_Value IN VARCHAR2
	) AS
  BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'CLOSED_IND' THEN
  new_references.CLOSED_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GOVT_HONOURS_LEVEL' THEN
  new_references.GOVT_HONOURS_LEVEL:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'HONOURS_LEVEL' THEN
  new_references.HONOURS_LEVEL:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'CLOSED_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CLOSED_IND<> upper(new_references.CLOSED_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GOVT_HONOURS_LEVEL' OR COLUMN_NAME IS NULL THEN
  IF new_references.GOVT_HONOURS_LEVEL<> upper(new_references.GOVT_HONOURS_LEVEL) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'HONOURS_LEVEL' OR COLUMN_NAME IS NULL THEN
  IF new_references.HONOURS_LEVEL<> upper(new_references.HONOURS_LEVEL) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
  END CHECK_CONSTRAINTS;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_GR_GRADUAND_PKG.GET_FK_IGS_GR_HONOURS_LEVEL(
      old_references.honours_level
      );

    IGS_AD_TER_EDU_PKG.GET_FK_IGS_GR_HONOURS_LEVEL (
      old_references.honours_level
      );

    IGS_EN_SPA_AWD_AIM_PKG.GET_FK_IGS_GR_HONOURS_LEVEL (
      old_references.honours_level
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_honours_level IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_HONOURS_LEVEL_ALL
      WHERE    honours_level = x_honours_level;

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

  PROCEDURE GET_FK_IGS_GR_GOVT_HNS_LVL (
    x_govt_honours_level IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_HONOURS_LEVEL_ALL
      WHERE    govt_honours_level = x_govt_honours_level ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_HL_GHL_FK');
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_GOVT_HNS_LVL;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_honours_level IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_govt_honours_level IN VARCHAR2 ,
    x_rank IN NUMBER ,
    x_closed_ind IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_honours_level,
      x_description,
      x_govt_honours_level,
      x_rank,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE,
			       p_updating  => FALSE,
			       p_deleting  => FALSE );


	IF GET_PK_FOR_VALIDATION(
			NEW_REFERENCES.honours_level
			) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_inserting => FALSE,
			       p_updating  => TRUE,
			       p_deleting  => FALSE);

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
			NEW_REFERENCES.honours_level
			) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
	check_child_existance;

    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_HONOURS_LEVEL in VARCHAR2,
  X_RANK in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_GR_HONOURS_LEVEL_ALL
      where HONOURS_LEVEL = X_HONOURS_LEVEL;
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID,
    x_honours_level => X_HONOURS_LEVEL,
    x_description => X_DESCRIPTION,
    x_govt_honours_level => X_GOVT_HONOURS_LEVEL,
    x_rank => X_RANK,
    x_closed_ind => NVL(X_CLOSED_IND, 'N'),
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
  );

  insert into IGS_GR_HONOURS_LEVEL_ALL (
    HONOURS_LEVEL,
    DESCRIPTION,
    GOVT_HONOURS_LEVEL,
    RANK,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.HONOURS_LEVEL,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.GOVT_HONOURS_LEVEL,
    NEW_REFERENCES.RANK,
    NEW_REFERENCES.CLOSED_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
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
  X_HONOURS_LEVEL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_HONOURS_LEVEL in VARCHAR2,
  X_RANK in NUMBER,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      GOVT_HONOURS_LEVEL,
      RANK,
      CLOSED_IND
    from IGS_GR_HONOURS_LEVEL_ALL
    where ROWID = X_ROWID for update nowait;
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.GOVT_HONOURS_LEVEL = X_GOVT_HONOURS_LEVEL)
           OR ((tlinfo.GOVT_HONOURS_LEVEL is null)
               AND (X_GOVT_HONOURS_LEVEL is null)))
      AND (tlinfo.RANK = X_RANK)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)

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
  X_HONOURS_LEVEL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_HONOURS_LEVEL in VARCHAR2,
  X_RANK in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
    x_honours_level => X_HONOURS_LEVEL,
    x_description => X_DESCRIPTION,
    x_govt_honours_level => X_GOVT_HONOURS_LEVEL,
    x_rank => X_RANK,
    x_closed_ind => X_CLOSED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_GR_HONOURS_LEVEL_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    GOVT_HONOURS_LEVEL = NEW_REFERENCES.GOVT_HONOURS_LEVEL,
    RANK = NEW_REFERENCES.RANK,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_HONOURS_LEVEL in VARCHAR2,
  X_RANK in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_GR_HONOURS_LEVEL_ALL
     where HONOURS_LEVEL = X_HONOURS_LEVEL
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_HONOURS_LEVEL,
     X_DESCRIPTION,
     X_GOVT_HONOURS_LEVEL,
     X_RANK,
     X_CLOSED_IND,
     X_MODE,
      x_org_id
);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_HONOURS_LEVEL,
   X_DESCRIPTION,
   X_GOVT_HONOURS_LEVEL,
   X_RANK,
   X_CLOSED_IND,
   X_MODE
);
end ADD_ROW;

end IGS_GR_HONOURS_LEVEL_PKG;

/
