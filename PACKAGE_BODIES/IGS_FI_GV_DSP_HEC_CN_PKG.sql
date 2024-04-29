--------------------------------------------------------
--  DDL for Package Body IGS_FI_GV_DSP_HEC_CN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GV_DSP_HEC_CN_PKG" AS
/* $Header: IGSSI53B.pls 115.3 2002/11/29 03:50:36 nsidana ship $*/
  l_rowid VARCHAR2(25);
  old_references IGS_FI_GV_DSP_HEC_CN%RowType;
  new_references IGS_FI_GV_DSP_HEC_CN%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_hecs_cntrbtn_band IN NUMBER DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_GV_DSP_HEC_CN
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
    new_references.govt_discipline_group_cd := x_govt_discipline_group_cd;
    new_references.govt_hecs_cntrbtn_band := x_govt_hecs_cntrbtn_band;
    new_references.start_dt := x_start_dt;
    new_references.end_dt := x_end_dt;
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
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_FI_GV_DSP_HEC_CN
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate govt discipline hecs contribution
	IF p_inserting OR p_updating THEN
		IF new_references.end_dt IS NOT NULL THEN
			IF IGS_ST_VAL_GDHC.stap_val_gdhc_end_dt(
						new_references.start_dt,
						new_references.end_dt,
						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
      				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF IGS_ST_VAL_GDHC.stap_val_gdhc_gd(
					new_references.govt_discipline_group_cd,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
      				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;
  -- Trigger description :-
  -- AFTER INSERT OR UPDATE
  -- ON IGS_FI_GV_DSP_HEC_CN
  PROCEDURE AfterStmtInsertUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
  	-- Validate the start and end dates
  	IF p_inserting OR p_updating THEN
  		IF IGS_ST_VAL_GDHC.stap_val_gdhc_ovrlp (
  			              new_references.govt_discipline_group_cd,
  		    	              new_references.start_dt,
  			              new_references.end_dt,
  			              v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      		        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  		END IF;
  		IF  new_references.end_dt IS NULL THEN
  			IF IGS_ST_VAL_GDHC.stap_val_gdhc_open (
  				              new_references.govt_discipline_group_cd,
  			    	              new_references.start_dt,
  				              v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
      		                IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
  			END IF;
  		END IF;
  	END IF;
  END AfterStmtInsertUpdate3;
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'GOVT_DISCIPLINE_GROUP_CD') THEN
      new_references.govt_discipline_group_cd := column_value;
    END IF;
    IF ((UPPER (column_name) = 'GOVT_DISCIPLINE_GROUP_CD') OR (column_name IS NULL)) THEN
      IF (new_references.govt_discipline_group_cd <> UPPER (new_references.govt_discipline_group_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;
  PROCEDURE Check_Uniqueness AS
  BEGIN
    IF (Get_UK1_For_Validation (
          new_references.govt_discipline_group_cd,
          new_references.start_dt
        )) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
  END Check_Uniqueness;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.govt_discipline_group_cd = new_references.govt_discipline_group_cd)) OR
        ((new_references.govt_discipline_group_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_GOVT_DSCP_PKG.Get_PK_For_Validation (
               new_references.govt_discipline_group_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.govt_hecs_cntrbtn_band = new_references.govt_hecs_cntrbtn_band)) OR
        ((new_references.govt_hecs_cntrbtn_band IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_GOVT_HEC_CNTB_PKG.Get_PK_For_Validation (
               new_references.govt_hecs_cntrbtn_band
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;
  FUNCTION Get_PK_For_Validation (
    x_govt_discipline_group_cd IN VARCHAR2,
    x_govt_hecs_cntrbtn_band IN NUMBER,
    x_start_dt IN DATE
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_GV_DSP_HEC_CN
      WHERE    govt_discipline_group_cd = x_govt_discipline_group_cd
      AND      govt_hecs_cntrbtn_band = x_govt_hecs_cntrbtn_band
      AND      start_dt = x_start_dt
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
  FUNCTION Get_UK1_For_Validation (
    x_govt_discipline_group_cd IN VARCHAR2,
    x_start_dt IN DATE
  ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_GV_DSP_HEC_CN
      WHERE    govt_discipline_group_cd = x_govt_discipline_group_cd
      AND      start_dt = x_start_dt
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
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
  END Get_UK1_For_Validation;
  PROCEDURE GET_FK_IGS_PS_GOVT_DSCP (
    x_govt_discipline_group_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_GV_DSP_HEC_CN
      WHERE    govt_discipline_group_cd = x_govt_discipline_group_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_GDHC_GD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_GOVT_DSCP;
  PROCEDURE GET_FK_IGS_FI_GOVT_HEC_CNTB (
    x_govt_hecs_cntrbtn_band IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_GV_DSP_HEC_CN
      WHERE    govt_hecs_cntrbtn_band = x_govt_hecs_cntrbtn_band ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_GDHC_GHC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_GOVT_HEC_CNTB;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_hecs_cntrbtn_band IN NUMBER DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
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
      x_govt_discipline_group_cd,
      x_govt_hecs_cntrbtn_band,
      x_start_dt,
      x_end_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      IF (Get_PK_For_Validation (
            new_references.govt_discipline_group_cd,
            new_references.govt_hecs_cntrbtn_band,
            new_references.start_dt
            )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            new_references.govt_discipline_group_cd,
            new_references.govt_hecs_cntrbtn_band,
            new_references.start_dt
          )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
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
      AfterStmtInsertUpdate3 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterStmtInsertUpdate3 ( p_updating => TRUE );
    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_GV_DSP_HEC_CN
      where GOVT_DISCIPLINE_GROUP_CD = X_GOVT_DISCIPLINE_GROUP_CD
      and GOVT_HECS_CNTRBTN_BAND = X_GOVT_HECS_CNTRBTN_BAND
      and START_DT = X_START_DT;
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
 x_end_dt=>X_END_DT,
 x_govt_discipline_group_cd=>X_GOVT_DISCIPLINE_GROUP_CD,
 x_govt_hecs_cntrbtn_band=>X_GOVT_HECS_CNTRBTN_BAND,
 x_start_dt=>X_START_DT,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  insert into IGS_FI_GV_DSP_HEC_CN (
    GOVT_DISCIPLINE_GROUP_CD,
    GOVT_HECS_CNTRBTN_BAND,
    START_DT,
    END_DT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.GOVT_DISCIPLINE_GROUP_CD,
    NEW_REFERENCES.GOVT_HECS_CNTRBTN_BAND,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.END_DT,
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
 x_rowid => X_ROWID
);
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE
) AS
  cursor c1 is select
      END_DT
    from IGS_FI_GV_DSP_HEC_CN
    where ROWID=X_ROWID
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
      if ( ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
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
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
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
 x_end_dt=>X_END_DT,
 x_govt_discipline_group_cd=>X_GOVT_DISCIPLINE_GROUP_CD,
 x_govt_hecs_cntrbtn_band=>X_GOVT_HECS_CNTRBTN_BAND,
 x_start_dt=>X_START_DT,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  update IGS_FI_GV_DSP_HEC_CN set
    END_DT = NEW_REFERENCES.END_DT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'UPDATE',
 x_rowid => X_ROWID
);
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_GV_DSP_HEC_CN
     where GOVT_DISCIPLINE_GROUP_CD = X_GOVT_DISCIPLINE_GROUP_CD
     and GOVT_HECS_CNTRBTN_BAND = X_GOVT_HECS_CNTRBTN_BAND
     and START_DT = X_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GOVT_DISCIPLINE_GROUP_CD,
     X_GOVT_HECS_CNTRBTN_BAND,
     X_START_DT,
     X_END_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_GOVT_DISCIPLINE_GROUP_CD,
   X_GOVT_HECS_CNTRBTN_BAND,
   X_START_DT,
   X_END_DT,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
BEFORE_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_FI_GV_DSP_HEC_CN
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_GV_DSP_HEC_CN_PKG;

/
