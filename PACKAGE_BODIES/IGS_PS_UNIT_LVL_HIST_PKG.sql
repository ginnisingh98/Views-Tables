--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_LVL_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_LVL_HIST_PKG" AS
 /* $Header: IGSPI41B.pls 115.7 2003/11/05 18:39:40 ijeddy ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_UNIT_LVL_HIST_ALL%RowType;
  new_references IGS_PS_UNIT_LVL_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_unit_level IN VARCHAR2 DEFAULT NULL,
    x_wam_weighting IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL  ,
    x_course_cd VARCHAR2 DEFAULT NULL,
    x_course_version_number NUMBER DEFAULT NULL

  )  AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_LVL_HIST_ALL
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
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.unit_level := x_unit_level;
    new_references.wam_weighting := x_wam_weighting;
    new_references.course_cd := x_course_cd;
    new_references.course_version_number := x_course_version_number;

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
    new_references.org_id := x_org_id;

  END Set_Column_Values;

  PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
  ) IS
  BEGIN
	IF column_name is null THEN
	   NULL;
	ELSIF upper(column_name) = 'UNIT_CD' THEN
	   new_references.unit_cd := column_value;
	ELSIF upper(column_name) = 'UNIT_LEVEL' THEN
	   new_references.unit_level:= column_value;
	END IF;

	IF upper(column_name)= 'UNIT_CD' OR
		column_name is null THEN
		IF new_references.unit_cd <> UPPER(new_references.unit_cd)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'UNIT_LEVEL' OR
		column_name is null THEN
		IF new_references.unit_level <> UPPER(new_references.unit_level)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
  END Check_Constraints;


  PROCEDURE Check_Parent_Existance  AS
  BEGIN

    IF (((old_references.unit_level = new_references.unit_level)) OR
        ((new_references.unit_level IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_LEVEL_PKG.Get_PK_For_Validation (
        new_references.unit_level
      )THEN
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
              )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
    END IF;

     IF (((old_references.course_cd = new_references.course_cd) AND
                (old_references.course_version_number = new_references.course_version_number)) OR
               ((new_references.course_cd IS NULL) OR
                (new_references.course_version_number IS NULL))) THEN
             NULL;
           ELSE
             IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
               new_references.course_cd,
               new_references.course_version_number
       	) THEN
       	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
       	IGS_GE_MSG_STACK.ADD;
       	App_Exception.Raise_Exception;
       	END IF;
     END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_hist_start_dt IN DATE,
    x_course_cd             IN VARCHAR2,
    x_course_version_number IN NUMBER

    ) RETURN BOOLEAN  AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_LVL_HIST_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      hist_start_dt = x_hist_start_dt
      AND      course_cd      = x_course_cd
      AND      course_version_number = x_course_version_number
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


  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    )  AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_LVL_HIST_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CULH_UV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_VER;

  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd             IN VARCHAR2,
    x_course_version_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_lvl_all
      WHERE    course_cd = x_course_cd
      AND      course_version_number = x_course_version_number;
    lv_rowid cur_rowid%RowType;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF cur_rowid%FOUND THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PRA_CRV_FK');
      IGS_GE_MSG_STACK.ADD;
      CLOSE CUR_ROWID;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_ps_ver;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_unit_level IN VARCHAR2 DEFAULT NULL,
    x_wam_weighting IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_course_version_number IN NUMBER DEFAULT NULL

  )  AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_cd,
      x_version_number,
      x_course_type,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_unit_level,
      x_wam_weighting,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id ,
      x_course_cd,
      x_course_version_number
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

	IF Get_PK_For_Validation(
		new_references.unit_cd,
		new_references.version_number,
		new_references.hist_start_dt,
                new_references.course_cd,
                new_references.course_version_number
    	) THEN
 	Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Parent_Existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation(
		new_references.unit_cd,
		new_references.version_number,
		new_references.hist_start_dt,
                new_references.course_cd,
                new_references.course_version_number
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
  )  AS
  BEGIN

    l_rowid := x_rowid;


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2 DEFAULT NULL,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UNIT_LEVEL in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_COURSE_VERSION_NUMBER IN NUMBER

  ) AS
    cursor C is select ROWID from IGS_PS_UNIT_LVL_HIST_ALL
      where UNIT_CD = X_UNIT_CD
      AND VERSION_NUMBER = X_VERSION_NUMBER
      AND HIST_START_DT = X_HIST_START_DT
      AND course_cd   = x_course_cd
      AND course_version_number = x_course_version_number;

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

 Before_DML( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_unit_cd => X_UNIT_CD,
    x_version_number => X_VERSION_NUMBER,
    x_course_type => X_COURSE_TYPE,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_unit_level => X_UNIT_LEVEL,
    x_wam_weighting => X_WAM_WEIGHTING,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_course_cd => X_COURSE_CD,
    x_course_version_number => X_COURSE_VERSION_NUMBER

  );
  insert into IGS_PS_UNIT_LVL_HIST_ALL (
    UNIT_CD,
    VERSION_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    UNIT_LEVEL,
    WAM_WEIGHTING,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    COURSE_CD ,
    COURSE_VERSION_NUMBER
  ) values (
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.UNIT_LEVEL,
    NEW_REFERENCES.WAM_WEIGHTING,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.COURSE_VERSION_NUMBER
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2 DEFAULT NULL,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UNIT_LEVEL in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_COURSE_VERSION_NUMBER IN NUMBER
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      UNIT_LEVEL,
      WAM_WEIGHTING
    from IGS_PS_UNIT_LVL_HIST_ALL
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.UNIT_LEVEL = X_UNIT_LEVEL)
           OR ((tlinfo.UNIT_LEVEL is null)
               AND (X_UNIT_LEVEL is null)))
      AND ((tlinfo.WAM_WEIGHTING = X_WAM_WEIGHTING)
           OR ((tlinfo.WAM_WEIGHTING is null)
               AND (X_WAM_WEIGHTING is null)))
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
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2 DEFAULT NULL,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UNIT_LEVEL in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_COURSE_CD VARCHAR2,
  X_COURSE_VERSION_NUMBER NUMBER
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

 Before_DML( p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_unit_cd => X_UNIT_CD,
    x_version_number => X_VERSION_NUMBER,
    x_course_type => X_COURSE_TYPE,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_unit_level => X_UNIT_LEVEL,
    x_wam_weighting => X_WAM_WEIGHTING,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_course_cd =>   X_COURSE_CD,
    x_course_version_number => X_COURSE_VERSION_NUMBER

  );
  update IGS_PS_UNIT_LVL_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    UNIT_LEVEL = NEW_REFERENCES.UNIT_LEVEL,
    WAM_WEIGHTING = NEW_REFERENCES.WAM_WEIGHTING,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2 DEFAULT NULL,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UNIT_LEVEL in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_COURSE_CD VARCHAR2,
  X_COURSE_VERSION_NUMBER NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PS_UNIT_LVL_HIST_ALL
     where UNIT_CD = X_UNIT_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and HIST_START_DT = X_HIST_START_DT
     AND course_cd   = x_course_cd
     AND course_version_number = x_course_version_number;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_COURSE_TYPE,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_UNIT_LEVEL,
     X_WAM_WEIGHTING,
     X_MODE,
     X_ORG_ID,
     X_COURSE_CD,
     X_COURSE_VERSION_NUMBER);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_COURSE_TYPE,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_UNIT_LEVEL,
   X_WAM_WEIGHTING,
   X_MODE,
   X_COURSE_CD,
   X_COURSE_VERSION_NUMBER);

end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2
) AS
begin
 Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
  );
 delete from IGS_PS_UNIT_LVL_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_PS_UNIT_LVL_HIST_PKG;

/
