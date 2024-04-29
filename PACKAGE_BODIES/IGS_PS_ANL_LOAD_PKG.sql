--------------------------------------------------------
--  DDL for Package Body IGS_PS_ANL_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_ANL_LOAD_PKG" AS
  /* $Header: IGSPI04B.pls 115.5 2003/02/05 10:24:07 sarakshi ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_PS_ANL_LOAD%RowType;
  new_references IGS_PS_ANL_LOAD%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_yr_num IN NUMBER DEFAULT NULL,
    x_effective_start_dt IN DATE DEFAULT NULL,
    x_effective_end_dt IN DATE DEFAULT NULL,
    x_annual_load_val IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_ANL_LOAD
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
    new_references.yr_num := x_yr_num;
    new_references.effective_start_dt := x_effective_start_dt;
    new_references.effective_end_dt := x_effective_end_dt;
    new_references.annual_load_val := x_annual_load_val;
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
  -- "OSS_TST".trg_cal_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_PS_ANL_LOAD
  -- FOR EACH ROW


  FUNCTION validate_overlapping(p_course_cd      igs_ps_anl_load.course_cd%TYPE,
                                p_version_number igs_ps_anl_load.version_number%TYPE,
				p_yr_num         igs_ps_anl_load.yr_num%TYPE,
                                p_start_dt       igs_ps_anl_load.effective_start_dt%TYPE,
                                p_end_dt         igs_ps_anl_load.effective_end_dt%TYPE,
                                p_row_id         VARCHAR2)
  RETURN BOOLEAN AS
  /*
  ||  Created By : sarakshi
  ||  Created On : 04-Feb-2002
  ||  Purpose : Validates the overlapping of the effective dates.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR cur_overlapping_u(cp_course_cd      igs_ps_anl_load.course_cd%TYPE ,
                           cp_version_number igs_ps_anl_load.version_number%TYPE ,
                           cp_yr_num         igs_ps_anl_load.yr_num%TYPE,
                           cp_start_dt       igs_ps_anl_load.effective_start_dt%TYPE,
                           cp_row_id         VARCHAR2 ) IS
  SELECT 'X'
  FROM   igs_ps_anl_load
  WHERE  course_cd=cp_course_cd
  AND    version_number=cp_version_number
  AND    yr_num = cp_yr_num
  AND    cp_start_dt >= effective_start_dt AND cp_start_dt <= NVL(effective_end_dt,cp_start_dt)
  AND    (rowid <> cp_row_id  OR (cp_row_id IS NULL));

  CURSOR cur_overlapping_u1(cp_course_cd      igs_ps_anl_load.course_cd%TYPE ,
                           cp_version_number  igs_ps_anl_load.version_number%TYPE ,
                           cp_yr_num          igs_ps_anl_load.yr_num%TYPE,
                           cp_start_dt        igs_ps_anl_load.effective_start_dt%TYPE,
                           cp_end_dt          igs_ps_anl_load.effective_end_dt%TYPE,
                           cp_row_id          VARCHAR2 ) IS
  SELECT 'X'
  FROM   igs_ps_anl_load
  WHERE  course_cd=cp_course_cd
  AND    version_number=cp_version_number
  AND    yr_num = cp_yr_num
  AND    (cp_end_dt >= effective_start_dt OR (cp_end_dt IS NULL)) AND cp_start_dt <= effective_start_dt
  AND    (rowid <> cp_row_id OR (cp_row_id IS NULL));

  l_temp  VARCHAR2(1);

  BEGIN
    --Validating if effective dates  are not overlapping

    -- start date overlapping
    OPEN cur_overlapping_u(p_course_cd,p_version_number,p_yr_num,p_start_dt,p_row_id);
    FETCH cur_overlapping_u INTO l_temp;
    IF cur_overlapping_u%FOUND THEN
      CLOSE cur_overlapping_u;
      RETURN FALSE;
    END IF;
    CLOSE cur_overlapping_u;

    --end date overlapping
    OPEN cur_overlapping_u1(p_course_cd,p_version_number,p_yr_num,p_start_dt,p_end_dt,p_row_id);
    FETCH cur_overlapping_u1 INTO l_temp;
    IF cur_overlapping_u1%FOUND THEN
      CLOSE cur_overlapping_u1;
      RETURN FALSE;
    END IF;
    CLOSE cur_overlapping_u1;

    RETURN TRUE;

  END validate_overlapping;


  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
	v_course_cd	IGS_PS_ANL_LOAD.course_cd%TYPE;
	v_version_number	IGS_PS_ANL_LOAD.version_number%TYPE;
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
	-- Validate effective start date and effective end date.
	IF p_inserting OR p_updating THEN
		-- Because start date is part of the key it will be set and
		-- is not updateable, so only need to check the end date.
		IF ( new_references.effective_end_dt IS NOT NULL AND
			(NVL(substr(new_references.effective_end_dt,1,10),'1990/01/01') <>
			 NVL(substr(old_references.effective_end_dt,1,10),'1900/01/01'))) THEN
			IF igs_ad_val_edtl.genp_val_strt_end_dt (
					new_references.effective_start_dt,
					new_references.effective_end_dt,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_cal_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_PS_ANL_LOAD
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate IGS_PS_COURSE annual load end date.
	IF new_references.effective_end_dt IS NULL THEN
		-- Cannot call crsp_val_cal_end_dt because trigger will be mutating.
		 -- Save the rowid of the current row.
		IF IGS_PS_VAL_CAL.crsp_val_cal_end_dt (
  				NEW_REFERENCES.course_cd,
  				NEW_REFERENCES.version_number,
  				NEW_REFERENCES.yr_num,
  				NEW_REFERENCES.effective_start_dt,
  				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS',v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
	END IF;


  END AfterRowInsertUpdate2;

	 PROCEDURE Check_Constraints (
	 Column_Name	IN VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN VARCHAR2	DEFAULT NULL
	 )
	 AS
	 BEGIN

	IF column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.course_cd := column_value;
	ELSIF upper(Column_name) = 'YR_NUM' then
	    new_references.yr_num := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'ANNUAL_LOAD_VAL' then
	    new_references.annual_load_val := igs_ge_number.to_num(column_value);
     END IF;

    IF upper(column_name) = 'COURSE_CD' OR
    column_name is null Then
   IF ( new_references.course_cd <> UPPER(new_references.course_cd) ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'YR_NUM' OR
    column_name is null Then
   IF ( new_references.yr_num < 0 OR new_references.yr_num > 999 ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'ANNUAL_LOAD_VAL' OR
    column_name is null Then
   IF ( new_references.annual_load_val < 0 OR new_references.annual_load_val > 9999.999 ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;
  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PS_ANL_LOAD_U_LN_PKG.GET_FK_IGS_PS_ANL_LOAD (
      old_references.course_cd,
      old_references.version_number,
      old_references.yr_num,
      old_references.effective_start_dt
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_yr_num IN NUMBER,
    x_effective_start_dt IN DATE
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_ANL_LOAD
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      yr_num = x_yr_num
      AND      effective_start_dt = x_effective_start_dt
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

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_ANL_LOAD
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CAL_CRV_FK');
       IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_VER;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_yr_num IN NUMBER DEFAULT NULL,
    x_effective_start_dt IN DATE DEFAULT NULL,
    x_effective_end_dt IN DATE DEFAULT NULL,
    x_annual_load_val IN NUMBER DEFAULT NULL,
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
      x_yr_num,
      x_effective_start_dt,
      x_effective_end_dt,
      x_annual_load_val,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    --Added by sarakshi bug#2473015, to validate the logic of dates overlap
    IF p_action IN ( 'INSERT', 'VALIDATE_INSERT','UPDATE','VALIDATE_UPDATE') THEN
      IF NOT validate_overlapping(x_course_cd , x_version_number,x_yr_num ,
                                 x_effective_start_dt  , x_effective_end_dt,x_rowid  )   THEN
        fnd_message.set_name('IGS','IGS_PS_OVERLAP_PERIODS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;


    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
      new_references.course_cd,
      new_references.version_number,
      new_references.yr_num,
      new_references.effective_start_dt) THEN
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
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF  Get_PK_For_Validation (
      new_references.course_cd,
      new_references.version_number,
      new_references.yr_num,
      new_references.effective_start_dt) THEN
	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_YR_NUM in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_EFFECTIVE_END_DT in DATE,
  X_ANNUAL_LOAD_VAL in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_ANL_LOAD
      where VERSION_NUMBER = X_VERSION_NUMBER
      and COURSE_CD = X_COURSE_CD
      and YR_NUM = X_YR_NUM
      and EFFECTIVE_START_DT = X_EFFECTIVE_START_DT;
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
    x_yr_num => X_YR_NUM,
    x_effective_start_dt => X_EFFECTIVE_START_DT,
    x_effective_end_dt => X_EFFECTIVE_END_DT ,
    x_annual_load_val => X_ANNUAL_LOAD_VAL ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  insert into IGS_PS_ANL_LOAD (
    VERSION_NUMBER,
    COURSE_CD,
    YR_NUM,
    EFFECTIVE_START_DT,
    EFFECTIVE_END_DT,
    ANNUAL_LOAD_VAL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.YR_NUM,
    NEW_REFERENCES.EFFECTIVE_START_DT,
    NEW_REFERENCES.EFFECTIVE_END_DT,
    NEW_REFERENCES.ANNUAL_LOAD_VAL,
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
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_YR_NUM in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_EFFECTIVE_END_DT in DATE,
  X_ANNUAL_LOAD_VAL in NUMBER
) AS
  cursor c1 is select
      EFFECTIVE_END_DT,
      ANNUAL_LOAD_VAL
    from IGS_PS_ANL_LOAD
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

      if ( ((tlinfo.EFFECTIVE_END_DT = X_EFFECTIVE_END_DT)
           OR ((tlinfo.EFFECTIVE_END_DT is null)
               AND (X_EFFECTIVE_END_DT is null)))
      AND (tlinfo.ANNUAL_LOAD_VAL = X_ANNUAL_LOAD_VAL)
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
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_YR_NUM in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_EFFECTIVE_END_DT in DATE,
  X_ANNUAL_LOAD_VAL in NUMBER,
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
    x_yr_num => X_YR_NUM,
    x_effective_start_dt => X_EFFECTIVE_START_DT,
    x_effective_end_dt => X_EFFECTIVE_END_DT ,
    x_annual_load_val => X_ANNUAL_LOAD_VAL ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  update IGS_PS_ANL_LOAD set
    EFFECTIVE_END_DT = NEW_REFERENCES.EFFECTIVE_END_DT,
    ANNUAL_LOAD_VAL = NEW_REFERENCES.ANNUAL_LOAD_VAL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;

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
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_YR_NUM in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_EFFECTIVE_END_DT in DATE,
  X_ANNUAL_LOAD_VAL in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_ANL_LOAD
     where VERSION_NUMBER = X_VERSION_NUMBER
     and COURSE_CD = X_COURSE_CD
     and YR_NUM = X_YR_NUM
     and EFFECTIVE_START_DT = X_EFFECTIVE_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_VERSION_NUMBER,
     X_COURSE_CD,
     X_YR_NUM,
     X_EFFECTIVE_START_DT,
     X_EFFECTIVE_END_DT,
     X_ANNUAL_LOAD_VAL,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_VERSION_NUMBER,
   X_COURSE_CD,
   X_YR_NUM,
   X_EFFECTIVE_START_DT,
   X_EFFECTIVE_END_DT,
   X_ANNUAL_LOAD_VAL,
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

  delete from IGS_PS_ANL_LOAD
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_PS_ANL_LOAD_PKG;

/
