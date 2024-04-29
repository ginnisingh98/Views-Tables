--------------------------------------------------------
--  DDL for Package Body IGS_PS_AWD_OWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_AWD_OWN_PKG" AS
  /* $Header: IGSPI07B.pls 115.9 2003/06/10 08:14:30 smvk ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_PS_AWD_OWN%RowType;
  new_references IGS_PS_AWD_OWN%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_AWD_OWN
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
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.award_cd := x_award_cd;
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

  -- Trigger description :-
  -- "OSS_TST".TRG_CAO_BR_IUD
  -- BEFORE  INSERT  OR UPDATE  OR DELETE  ON IGS_PS_AWD_OWN
  -- REFERENCING
  --  NEW AS NEW
  --  OLD AS OLD
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		varchar2(30);
	v_course_cd		IGS_PS_AWD_OWN.course_cd%TYPE;
	v_version_number		IGS_PS_AWD_OWN.version_number%TYPE;
  BEGIN

	-- Set variables.
	IF p_deleting THEN
		v_course_cd := old_references.course_cd;
		v_version_number := old_references.version_number;
	ELSE -- p_inserting or p_updating
		v_course_cd := new_references.course_cd;
		v_version_number := new_references.version_number;
	END IF;
	-- Validate the insert/update/delete.
	IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl (
			v_course_cd,
			v_version_number,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	-- Validate the org IGS_PS_UNIT.  Org IGS_PS_UNIT is not updateable.
	IF p_inserting THEN
	-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_CAO.crsp_val_ou_sys_sts
		IF IGS_PS_VAL_CRV.crsp_val_ou_sys_sts (
				new_references.org_unit_cd,
				new_references.ou_start_dt,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE before_insert_update(p_inserting IN BOOLEAN DEFAULT FALSE,
                                p_updating  IN BOOLEAN DEFAULT FALSE ) AS
     CURSOR c_closed_ind (cp_c_award_cd IN IGS_PS_AWARD.AWARD_CD%TYPE,
                          cp_c_course_cd IN IGS_PS_AWARD.COURSE_CD%TYPE,
                          cp_n_version_num IN IGS_PS_AWARD.VERSION_NUMBER%TYPE) IS
       SELECT CLOSED_IND
       FROM IGS_PS_AWARD
       WHERE AWARD_CD = cp_c_award_cd
       AND   COURSE_CD = cp_c_course_cd
       AND   VERSION_NUMBER = cp_n_version_num;
       l_c_closed_ind VARCHAR2(1);
  BEGIN
     IF p_inserting OR ( p_updating AND new_references.award_cd <> old_references.award_cd ) THEN
        OPEN c_closed_ind(new_references.award_cd, new_references.course_cd, new_references.version_number);
        FETCH c_closed_ind INTO l_c_closed_ind;
        CLOSE c_closed_ind;
        IF l_c_closed_ind = 'Y' THEN
           fnd_message.set_name('IGS','IGS_PS_AWD_CD_CLOSED');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;
     END IF;
  END before_insert_update;

 PROCEDURE Check_Constraints (
 Column_Name	IN VARCHAR2	DEFAULT NULL,
 Column_Value 	IN VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN

	IF column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'PERCENTAGE' then
	    new_references.percentage := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'AWARD_CD' then
	    new_references.award_cd := column_value;
	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.course_cd := column_value;
        END IF;

    IF upper(column_name) = 'PERCENTAGE' OR
    column_name is null Then
	   IF ( new_references.percentage < 0 OR new_references.percentage > 100 ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
    END IF;

    IF upper(column_name) = 'AWARD_CD' OR
    column_name is null Then
	   IF ( new_references.award_cd <> UPPER(new_references.award_cd) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
    END IF;

    IF upper(column_name) = 'COURSE_CD' OR
    column_name is null Then
	   IF ( new_references.course_cd <> UPPER(new_references.course_cd) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
    END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.award_cd = new_references.award_cd)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.award_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_AWARD_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.award_cd
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

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

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_award_cd IN VARCHAR2,
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_AWD_OWN
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      award_cd = x_award_cd
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

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_AWD_OWN
      WHERE    org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CAO_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
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
      x_course_cd,
      x_version_number,
      x_award_cd,
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
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      before_insert_update( p_inserting => TRUE , p_updating => FALSE);
	IF Get_PK_For_Validation (
      new_references.course_cd,
      new_references.version_number,
      new_references.award_cd ,
      new_references.org_unit_cd ,
      new_references.ou_start_dt) THEN
	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	   IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      before_insert_update(p_inserting => FALSE, p_updating => TRUE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF  Get_PK_For_Validation (
      new_references.course_cd,
      new_references.version_number,
      new_references.award_cd ,
      new_references.org_unit_cd ,
      new_references.ou_start_dt) THEN
	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_AWARD_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_AWD_OWN
      where COURSE_CD = X_COURSE_CD
      and ORG_UNIT_CD = X_ORG_UNIT_CD
      and OU_START_DT = X_OU_START_DT
      and AWARD_CD = X_AWARD_CD
      and VERSION_NUMBER = X_VERSION_NUMBER;
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
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_org_unit_cd => X_ORG_UNIT_CD,
    x_ou_start_dt => X_OU_START_DT,
    x_percentage => X_PERCENTAGE ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  insert into IGS_PS_AWD_OWN (
    COURSE_CD,
    VERSION_NUMBER,
    AWARD_CD,
    ORG_UNIT_CD,
    OU_START_DT,
    PERCENTAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.AWARD_CD,
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
  X_COURSE_CD in VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_AWARD_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PERCENTAGE in NUMBER
) AS
  cursor c1 is select
      PERCENTAGE
    from IGS_PS_AWD_OWN
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
  X_COURSE_CD in VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_AWARD_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PERCENTAGE in NUMBER,
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
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_org_unit_cd => X_ORG_UNIT_CD,
    x_ou_start_dt => X_OU_START_DT,
    x_percentage => X_PERCENTAGE ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  update IGS_PS_AWD_OWN set
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
  X_COURSE_CD in VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_AWARD_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_AWD_OWN
     where COURSE_CD = X_COURSE_CD
     and ORG_UNIT_CD = X_ORG_UNIT_CD
     and OU_START_DT = X_OU_START_DT
     and AWARD_CD = X_AWARD_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_ORG_UNIT_CD,
     X_OU_START_DT,
     X_AWARD_CD,
     X_VERSION_NUMBER,
     X_PERCENTAGE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_ORG_UNIT_CD,
   X_OU_START_DT,
   X_AWARD_CD,
   X_VERSION_NUMBER,
   X_PERCENTAGE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

Before_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);

  delete from IGS_PS_AWD_OWN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_PS_AWD_OWN_PKG;

/
