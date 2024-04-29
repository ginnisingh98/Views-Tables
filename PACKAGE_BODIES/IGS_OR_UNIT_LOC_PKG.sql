--------------------------------------------------------
--  DDL for Package Body IGS_OR_UNIT_LOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_UNIT_LOC_PKG" AS
 /* $Header: IGSOI13B.pls 115.7 2003/10/30 13:29:48 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_OR_UNIT_LOC%RowType;
  new_references IGS_OR_UNIT_LOC%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_OR_UNIT_LOC
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
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.org_unit_cd := x_org_unit_cd;
    new_references.start_dt := x_start_dt;
    new_references.location_cd := x_location_cd;
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
  -- "OSS_TST".trg_oul_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_OR_UNIT_LOC
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name   VARCHAR2(30);
  BEGIN
	IF p_inserting THEN
	-- As part of the bug# 1956374 changed to the below call from IGS_OR_VAL_OUL.crsp_val_loc_cd
		IF IGS_PS_VAL_UOO.crsp_val_loc_cd (
				new_references.location_cd,
  						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception ;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd ,
        'N' )THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

	  END IF;
    END IF;
    IF (((old_references.org_unit_cd = new_references.org_unit_cd) AND
         (old_references.start_dt = new_references.start_dt)) OR
        ((new_references.org_unit_cd IS NULL) OR
         (new_references.start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.org_unit_cd,
        new_references.start_dt
        )THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

	  END IF;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE,
    x_location_cd IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_UNIT_LOC
      WHERE    org_unit_cd = x_org_unit_cd
      AND      start_dt = x_start_dt
      AND      location_cd = x_location_cd
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

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_UNIT_LOC
      WHERE    location_cd = x_location_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OUL_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_UNIT_LOC
      WHERE    org_unit_cd = x_org_unit_cd
      AND      start_dt = x_start_dt ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OUL_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_OR_UNIT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
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
      x_org_unit_cd,
      x_start_dt,
      x_location_cd,
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
    new_references.org_unit_cd ,
    new_references.start_dt ,
    new_references.location_cd
    	)THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

   END IF;
      Check_Parent_Existance;
	  Check_Constraints ;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints ;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN

   IF  Get_PK_For_Validation (
    new_references.org_unit_cd ,
    new_references.start_dt ,
    new_references.location_cd
    	)THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

   END IF;
	  Check_Constraints ;

	ELSIF (p_action = 'VALIDATE_UPDATE') THEN

     Check_Constraints ;

	ELSIF (p_action = 'VALIDATE_DELETE') THEN

     NULL;

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
  X_ORG_UNIT_CD in VARCHAR2,
  X_START_DT in DATE,
  X_LOCATION_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_OR_UNIT_LOC
      where ORG_UNIT_CD = X_ORG_UNIT_CD
      and START_DT = X_START_DT
      and LOCATION_CD = X_LOCATION_CD;
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
    x_location_cd=>X_LOCATION_CD,
    x_org_unit_cd=>X_ORG_UNIT_CD,
    x_start_dt=>X_START_DT,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
  insert into IGS_OR_UNIT_LOC (
    ORG_UNIT_CD,
    START_DT,
    LOCATION_CD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_UNIT_CD,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.LOCATION_CD,
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
  After_DML(
    p_action=>'INSERT',
    x_rowid=>X_ROWID
    );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_START_DT in DATE,
  X_LOCATION_CD in VARCHAR2
) AS
  cursor c1 is select rowid
    from IGS_OR_UNIT_LOC
    where ROWID = X_ROWID
    for update nowait ;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  return;
end LOCK_ROW;

procedure DELETE_ROW (
    X_ROWID in VARCHAR2
    ) AS
begin
  Before_DML(
   p_action=>'DELETE',
   x_rowid=>X_ROWID
   );
  delete from IGS_OR_UNIT_LOC
  where ROWID = X_ROWID ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
    p_action=>'DELETE',
    x_rowid=>X_ROWID
    );
end DELETE_ROW;

procedure Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By : pkpatel
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pkpatel    29-JUL-2002   Bug No: 2461744
  ||                           Removed the upper check constraint on org_unit_cd
  ----------------------------------------------------------------------------*/

 begin

IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'LOCATION_CD' THEN
  new_references.LOCATION_CD:= COLUMN_VALUE ;
END IF ;

IF upper(Column_name) = 'LOCATION_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.LOCATION_CD <> upper(new_references.LOCATION_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

end Check_Constraints ;

end IGS_OR_UNIT_LOC_PKG;

/
