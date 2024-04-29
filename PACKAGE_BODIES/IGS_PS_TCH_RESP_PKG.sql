--------------------------------------------------------
--  DDL for Package Body IGS_PS_TCH_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_TCH_RESP_PKG" as
/* $Header: IGSPI69B.pls 120.0 2005/06/01 21:45:01 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PS_TCH_RESP%RowType;
  new_references IGS_PS_TCH_RESP%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE,
    x_percentage IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_TCH_RESP
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.org_unit_cd := x_org_unit_cd;
    new_references.ou_start_dt := x_ou_start_dt;
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

  PROCEDURE Check_Child_Existance AS
  /*
  ||  Created By : jonathan.baber@oracle.com
  ||  Created On : 12-JAN-2005
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IGS_HE_UNT_OU_CC_PKG.get_fk_igs_ps_tch_resp (
	old_references.unit_cd,
	old_references.version_number,
	old_references.org_unit_cd
    );

  END check_child_existance;

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
	v_unit_cd		IGS_PS_TCH_RESP.unit_cd%TYPE;
	v_version_number	IGS_PS_TCH_RESP.version_number%TYPE;
	v_percentage	IGS_PS_TCH_RESP.percentage%TYPE;
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Set variables.
	IF p_deleting THEN
		v_unit_cd := old_references.unit_cd;
		v_version_number := old_references.version_number;
	ELSE -- p_inserting or p_updating
		v_unit_cd := new_references.unit_cd;
		v_version_number := new_references.version_number;
	END IF;
	-- Validate the insert/update/delete.
	IF IGS_PS_VAL_UNIT.crsp_val_iud_uv_dtl (
			v_unit_cd,
			v_version_number,
			v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
	END IF;
	-- Validate the org IGS_PS_UNIT.  Org IGS_PS_UNIT is not updateable.
	IF p_inserting THEN
	-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_TR.crsp_val_ou_sys_sts
		IF IGS_PS_VAL_CRV.crsp_val_ou_sys_sts (
				new_references.org_unit_cd,
				new_references.ou_start_dt,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Create history record.
	IF p_updating THEN
		IF old_references.percentage <> new_references.percentage THEN
			SELECT	DECODE (old_references.percentage,new_references.percentage,NULL,old_references.percentage)
			INTO	v_percentage
			FROM	dual;
			IGS_PS_GEN_005.CRSP_INS_TR_HIST(
				old_references.unit_cd,
				old_references.version_number,
				old_references.org_unit_cd,
				old_references.ou_start_dt,
				old_references.last_update_date,
				new_references.last_update_date,
				old_references.last_updated_by,
				v_percentage);
		END IF;
	END IF;
	-- Create history record on delete
	IF p_deleting THEN

		-- Added for HE355 - Org Unit Cost Center Link to check for child existance before deleting record
		Check_Child_Existance;

		IGS_PS_GEN_005.CRSP_INS_TR_HIST(
			old_references.unit_cd,
			old_references.version_number,
			old_references.org_unit_cd,
			old_references.ou_start_dt,
			old_references.last_update_date,
			SYSDATE,
			old_references.last_updated_by,
			old_references.percentage);

	END IF;


  END BeforeRowInsertUpdateDelete1;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2,
 Column_Value 	IN	VARCHAR2
 )
 AS
 BEGIN

 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'UNIT_CD' then
     new_references.unit_cd:= column_value;
 ELSIF upper(Column_name) = 'PERCENTAGE' then
     new_references.percentage :=IGS_GE_NUMBER.TO_NUM(column_value);
 END IF;

IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.unit_cd <> UPPER(new_references.unit_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'PERCENTAGE' OR
     column_name is null Then
     IF new_references.percentage <= 0 OR new_references.percentage > 100 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END check_constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.org_unit_cd = new_references.org_unit_cd) AND
         (old_references.ou_start_dt = new_references.ou_start_dt)) OR
        ((new_references.org_unit_cd IS NULL) OR
         (new_references.ou_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.org_unit_cd,
        new_references.ou_start_dt
       ) THEN
		  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_VER_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number
        ) THEN
		  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
	END IF;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TCH_RESP
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_ou_start_dt
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

  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_org_unit_cd IN VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : jonathan.baber@oracle.com
  ||  Created On : 26-JAN-2005
  ||  Purpose : Validates the Primary Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TCH_RESP
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      org_unit_cd = x_org_unit_cd
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

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TCH_RESP
      WHERE    org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_TR_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TCH_RESP
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_TR_UV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_VER;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_org_unit_cd IN VARCHAR2 ,
    x_ou_start_dt IN DATE ,
    x_percentage IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_cd,
      x_version_number,
      x_org_unit_cd,
      x_ou_start_dt,
      x_percentage,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE, p_updating => FALSE, p_deleting => FALSE);
      IF  Get_PK_For_Validation (
				    new_references.unit_cd,
				    new_references.version_number,
				    new_references.org_unit_cd,
				    new_references.ou_start_dt
				         ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE, p_updating => TRUE, p_deleting => FALSE );
       Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE, p_updating => FALSE, p_deleting => TRUE );
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
				    new_references.unit_cd,
				    new_references.version_number,
				    new_references.org_unit_cd,
				    new_references.ou_start_dt
				         ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
 ELSIF (p_action = 'VALIDATE_DELETE') THEN
       -- Added for HE355 - Org Unit Cost Center Link to check for child existance before deleting record
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
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_PS_TCH_RESP
      where UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and OU_START_DT = X_OU_START_DT
      and ORG_UNIT_CD = X_ORG_UNIT_CD;
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
    x_rowid =>   X_ROWID,
    x_unit_cd =>   X_UNIT_CD,
    x_version_number =>   X_VERSION_NUMBER,
    x_org_unit_cd =>    X_ORG_UNIT_CD,
    x_ou_start_dt =>   X_OU_START_DT,
    x_percentage =>   X_PERCENTAGE,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
   );

  insert into IGS_PS_TCH_RESP (
    UNIT_CD,
    VERSION_NUMBER,
    ORG_UNIT_CD,
    OU_START_DT,
    PERCENTAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.ORG_UNIT_CD,
    NEW_REFERENCES.OU_START_DT,
    NEW_REFERENCES.PERCENTAGE,
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
  X_ROWID IN VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_PERCENTAGE in NUMBER
) as
  cursor c1 is select
      PERCENTAGE
    from IGS_PS_TCH_RESP
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

  if ( (tlinfo.PERCENTAGE = X_PERCENTAGE)
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
  X_ROWID IN VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2
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
  Before_DML (
    p_action => 'UPDATE',
    x_rowid =>   X_ROWID,
    x_unit_cd =>   X_UNIT_CD,
    x_version_number =>   X_VERSION_NUMBER,
    x_org_unit_cd =>    X_ORG_UNIT_CD,
    x_ou_start_dt =>   X_OU_START_DT,
    x_percentage =>   X_PERCENTAGE,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
   );

  update IGS_PS_TCH_RESP set
    PERCENTAGE = NEW_REFERENCES.PERCENTAGE,
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
     x_rowid => X_ROWID
    );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_PS_TCH_RESP
     where UNIT_CD = X_UNIT_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and OU_START_DT = X_OU_START_DT
     and ORG_UNIT_CD = X_ORG_UNIT_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_OU_START_DT,
     X_ORG_UNIT_CD,
     X_PERCENTAGE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_OU_START_DT,
   X_ORG_UNIT_CD,
   X_PERCENTAGE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
  Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_PS_TCH_RESP
    where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_PS_TCH_RESP_PKG;

/
