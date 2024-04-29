--------------------------------------------------------
--  DDL for Package Body IGS_CA_DA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_DA_PKG" AS
/* $Header: IGSCI02B.pls 120.2 2006/06/19 09:58:29 sapanigr noship $ */
   l_rowid VARCHAR2(25);
  old_references IGS_CA_DA%RowType;
  new_references IGS_CA_DA%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_dt_alias IN VARCHAR2,
    x_description IN VARCHAR2,
    x_dt_cat IN VARCHAR2,
    x_abbreviation IN VARCHAR2,
    x_s_cal_cat IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_notes IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_DA
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
    new_references.dt_alias := x_dt_alias;
    new_references.description := x_description;
    new_references.dt_cat := x_dt_cat;
    new_references.abbreviation := x_abbreviation;
    new_references.s_cal_cat := x_s_cal_cat;
    new_references.closed_ind :=x_closed_ind;
    new_references.notes := x_notes;
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

   PROCEDURE Check_Constraints (
	Column_Name 	IN	VARCHAR2,
	Column_Value 	IN	VARCHAR2
	) AS
	BEGIN
        IF  column_name is null then
                        NULL;
         ELSIF UPPER(column_name) = 'CLOSED_IND' then
                new_references.closed_ind := column_value;
         Elsif UPPER(column_name) = 'ABBREVIATION' Then
				new_references.abbreviation := column_value;
         Elsif UPPER(column_name) = 'DT_ALIAS' Then
				new_references.dt_alias := column_value;
         Elsif UPPER(column_name) = 'DT_CAT' Then
				new_references.dt_cat:= column_value;
        Elsif UPPER(column_name) = 'S_CAL_CAT' Then
				new_references.s_cal_cat:= column_value;
     END IF;
                  if upper(column_name) = 'CLOSED_IND' or column_name is null Then
				if new_references.closed_ind NOT IN ('Y', 'N') Then
                  	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  	   IGS_GE_MSG_STACK.ADD;
                   	   App_Exception.Raise_Exception;
				end if;
			end if;
                  if upper(column_name) = 'ABBREVIATION' or column_name is null Then
				if new_references.abbreviation <> UPPER( new_references.abbreviation) then
                  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  		IGS_GE_MSG_STACK.ADD;
                  		App_Exception.Raise_Exception;
				end if;
			end if;
                  if upper(column_name) = 'DT_ALIAS' or column_name is null Then
				if new_references.dt_alias <> UPPER( new_references.dt_alias) then
                  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  		IGS_GE_MSG_STACK.ADD;
                  		App_Exception.Raise_Exception;
				end if;
			end if;
			if upper(column_name) = 'DT_CAT' or column_name is null Then
				if new_references.dt_cat <> UPPER( new_references.dt_cat) then
                  	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  	   IGS_GE_MSG_STACK.ADD;
                   	   App_Exception.Raise_Exception;
				end if;
			end if;
			if upper(column_name) = 'S_CAL_CAT' or column_name is null Then
				if new_references.s_cal_cat <> UPPER( new_references.s_cal_cat) then
                  	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  	   IGS_GE_MSG_STACK.ADD;
                   	   App_Exception.Raise_Exception;
				end if;
			end if;

   END Check_Constraints ;
  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.dt_cat = new_references.dt_cat)) OR
        ((new_references.dt_cat IS NULL))) THEN
      NULL;
    ELSE
       IF NOT IGS_CA_DA_CAT_PKG.Get_PK_For_Validation (
        new_references.dt_cat
         ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.s_cal_cat = new_references.s_cal_cat)) OR
        ((new_references.s_cal_cat IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
	 'CAL_CAT',
        new_references.s_cal_cat
        )THEN
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_CA_DA_INST_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_CA_DA_OFST_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_CA_DA_PAIR_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_AD_CAL_CONF_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_AS_CAL_CONF_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_PR_S_CRV_PRG_CON_Pkg.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_EN_CAL_CONF_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_GE_S_GEN_CAL_CON_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_PR_S_OU_PRG_CONF_Pkg.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_PR_S_PRG_CONF_Pkg.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_RE_S_RES_CAL_CON_Pkg.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_PS_UNIT_DISC_CRT_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_EN_CAT_PRC_DTL_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

    IGS_FI_CONTROL_PKG.GET_FK_IGS_CA_DA (
      old_references.dt_alias
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_dt_alias IN VARCHAR2
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA
      WHERE    dt_alias = x_dt_alias
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
    Close cur_rowid;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_CA_DA_CAT (
    x_dt_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA
      WHERE    dt_cat = x_dt_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_DA_DAC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA_CAT;

--skpandey; Bug#3686538: Stubbed as a part of query optimization
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_cal_cat IN VARCHAR2
    ) AS
  BEGIN
	NULL;
  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_dt_alias IN VARCHAR2,
    x_description IN VARCHAR2,
    x_dt_cat IN VARCHAR2,
    x_abbreviation IN VARCHAR2,
    x_s_cal_cat IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_notes IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_dt_alias,
      x_description,
      x_dt_cat,
      x_abbreviation,
      x_s_cal_cat,
      x_closed_ind,
      x_notes,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
      	new_references.dt_alias )THEN
      	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      	IGS_GE_MSG_STACK.ADD;
      	App_Exception.Raise_Exception;
       END IF;
      Check_Constraints;
      Check_Parent_Existance;
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
                	new_references.dt_alias )THEN
      	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      	IGS_GE_MSG_STACK.ADD;
      	App_Exception.Raise_Exception;
       END IF;
      Check_Constraints;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Parent_Existance;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
   ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
   ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
   END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DT_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_CA_DA
      where DT_ALIAS = X_DT_ALIAS;
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
    p_action =>'INSERT',
    x_rowid =>X_ROWID,
    x_dt_alias =>X_DT_ALIAS,
    x_description =>X_DESCRIPTION,
    x_dt_cat =>X_DT_CAT,
    x_abbreviation =>X_ABBREVIATION,
    x_s_cal_cat =>X_S_CAL_CAT,
    x_closed_ind =>NVL(X_CLOSED_IND,'N'),
    x_notes =>X_NOTES,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

  insert into IGS_CA_DA (
    DT_ALIAS,
    DESCRIPTION,
    DT_CAT,
    ABBREVIATION,
    S_CAL_CAT,
    CLOSED_IND,
    NOTES,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.DT_CAT,
    NEW_REFERENCES.ABBREVIATION,
    NEW_REFERENCES.S_CAL_CAT,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.NOTES,
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
  X_DT_ALIAS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DT_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      DT_CAT,
      ABBREVIATION,
      S_CAL_CAT,
      CLOSED_IND,
      NOTES
    from IGS_CA_DA
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.DT_CAT = X_DT_CAT)
      AND ((tlinfo.ABBREVIATION = X_ABBREVIATION)
           OR ((tlinfo.ABBREVIATION is null)
               AND (X_ABBREVIATION is null)))
      AND ((tlinfo.S_CAL_CAT = X_S_CAL_CAT)
           OR ((tlinfo.S_CAL_CAT is null)
               AND (X_S_CAL_CAT is null)))
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.NOTES = X_NOTES)
           OR ((tlinfo.NOTES is null)
               AND (X_NOTES is null)))
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
  X_DT_ALIAS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DT_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
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
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

Before_DML (
    p_action =>'UPDATE',
    x_rowid =>X_ROWID,
    x_dt_alias =>X_DT_ALIAS,
    x_description =>X_DESCRIPTION,
    x_dt_cat =>X_DT_CAT,
    x_abbreviation =>X_ABBREVIATION,
    x_s_cal_cat =>X_S_CAL_CAT,
    x_closed_ind =>X_CLOSED_IND,
    x_notes =>X_NOTES,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

  update IGS_CA_DA set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    DT_CAT = NEW_REFERENCES.DT_CAT,
    ABBREVIATION = NEW_REFERENCES.ABBREVIATION,
    S_CAL_CAT = NEW_REFERENCES.S_CAL_CAT,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    NOTES = NEW_REFERENCES.NOTES,
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
  X_DT_ALIAS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DT_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_CA_DA
     where ROWID = X_ROWID
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_DT_ALIAS,
     X_DESCRIPTION,
     X_DT_CAT,
     X_ABBREVIATION,
     X_S_CAL_CAT,
     X_CLOSED_IND,
     X_NOTES,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_DT_ALIAS,
   X_DESCRIPTION,
   X_DT_CAT,
   X_ABBREVIATION,
   X_S_CAL_CAT,
   X_CLOSED_IND,
   X_NOTES,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  delete from IGS_CA_DA
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_CA_DA_PKG;

/
