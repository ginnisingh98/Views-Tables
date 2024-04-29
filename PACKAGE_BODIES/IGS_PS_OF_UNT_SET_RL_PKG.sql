--------------------------------------------------------
--  DDL for Package Body IGS_PS_OF_UNT_SET_RL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_OF_UNT_SET_RL_PKG" as
 /* $Header: IGSPI51B.pls 115.3 2002/11/29 02:30:09 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_OF_UNT_SET_RL%RowType;
  new_references IGS_PS_OF_UNT_SET_RL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sup_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_sup_us_version_number IN NUMBER DEFAULT NULL,
    x_sub_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_sub_us_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_OF_UNT_SET_RL
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
    new_references.course_cd := x_course_cd;
    new_references.crv_version_number := x_crv_version_number;
    new_references.cal_type := x_cal_type;
    new_references.sup_unit_set_cd := x_sup_unit_set_cd;
    new_references.sup_us_version_number := x_sup_us_version_number;
    new_references.sub_unit_set_cd := x_sub_unit_set_cd;
    new_references.sub_us_version_number := x_sub_us_version_number;
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

  PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts
	IF  p_inserting THEN
		-- <cousr1>
		-- Can only create superior against ACTIVE or PLANNED IGS_PS_UNIT sets
		IF  IGS_PS_VAL_COusr.crsp_val_iud_us_dtl (
						new_references.sup_unit_set_cd,
						new_references.sup_us_version_number,
						v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		-- <cousr2>
		-- Can only create subordinate against ACTIVE or PLANNED IGS_PS_UNIT sets
		IF  IGS_PS_VAL_COusr.crsp_val_iud_us_dtl (
						new_references.sub_unit_set_cd,
						new_references.sub_us_version_number,
						v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		-- <cousr4>
		-- Can only create as superior if 'only as subordinate' indicator is
		-- set appropriately
		IF  IGS_PS_VAL_COusr.crsp_val_cousr_sub (
						new_references.course_cd,
						new_references.crv_version_number,
						new_references.cal_type,
						new_references.sup_unit_set_cd,
						new_references.sup_us_version_number,
						v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		-- <cousr5>
		-- Can only create as subordinate if IGS_PS_UNIT set has not been used to
		-- restrict and admission category (ie; cacus record exists)
		IF  IGS_PS_VAL_COusr.crsp_val_cousr_cacus (
						new_references.course_cd,
						new_references.crv_version_number,
						new_references.cal_type,
						new_references.sub_unit_set_cd,
						new_references.sub_us_version_number,
						v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;

  END BeforeRowInsert1;

  PROCEDURE AfterRowInsert2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
  		-- Validate attendance type load range.
  		IF  IGS_PS_VAL_COusr.crsp_val_cousr_tree (
  				new_references.course_cd,
  				new_references.crv_version_number,
  				new_references.cal_type,
  				new_references.sup_unit_set_cd,
  				new_references.sup_us_version_number,
  				new_references.sub_unit_set_cd,
  				new_references.sub_us_version_number,
  				v_message_name) = FALSE THEN
			   FND_MESSAGE.SET_NAME('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			   APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;

  END AfterRowInsert2;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'CAL_TYPE' then
     new_references.cal_type := column_value;
 ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
 ELSIF upper(Column_name) = 'SUB_UNIT_SET_CD ' then
     new_references.sub_unit_set_cd := column_value;
 ELSIF upper(Column_name) = 'SUP_UNIT_SET_CD ' then
     new_references.sup_unit_set_cd := column_value;
END IF;

IF upper(column_name) = 'CAL_TYPE' OR
     column_name is null Then
     IF new_references.cal_type <> UPPER(new_references.cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd <> UPPER(new_references.course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'SUB_UNIT_SET_CD' OR
     column_name is null Then
     IF new_references.sub_unit_set_cd <> UPPER(new_references.sub_unit_set_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'SUP_UNIT_SET_CD' OR
     column_name is null Then
     IF new_references.sup_unit_set_cd <> UPPER(new_references.sup_unit_set_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

END Check_Constraints;



PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.crv_version_number = new_references.crv_version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.sub_unit_set_cd = new_references.sub_unit_set_cd) AND
         (old_references.sub_us_version_number = new_references.sub_us_version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.crv_version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.sub_unit_set_cd IS NULL) OR
         (new_references.sub_us_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.crv_version_number,
        new_references.cal_type,
        new_references.sub_unit_set_cd,
        new_references.sub_us_version_number
        ) THEN
		 Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	 END IF;

    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.crv_version_number = new_references.crv_version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.sup_unit_set_cd = new_references.sup_unit_set_cd) AND
         (old_references.sup_us_version_number = new_references.sup_us_version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.crv_version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.sup_unit_set_cd IS NULL) OR
         (new_references.sup_us_version_number IS NULL))) THEN
      NULL;
    ELSE
       IF NOT IGS_PS_OFR_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.crv_version_number,
        new_references.cal_type,
        new_references.sup_unit_set_cd,
        new_references.sup_us_version_number
        ) THEN
		 Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		 App_Exception.Raise_Exception;
	 END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_sup_unit_set_cd IN VARCHAR2,
    x_sup_us_version_number IN NUMBER,
    x_sub_unit_set_cd IN VARCHAR2,
    x_sub_us_version_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OF_UNT_SET_RL
      WHERE    course_cd = x_course_cd
      AND      crv_version_number = x_crv_version_number
      AND      cal_type = x_cal_type
      AND      sup_unit_set_cd = x_sup_unit_set_cd
      AND      sup_us_version_number = x_sup_us_version_number
      AND      sub_unit_set_cd = x_sub_unit_set_cd
      AND      sub_us_version_number = x_sub_us_version_number
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

  PROCEDURE GET_FK_IGS_PS_OFR_UNIT_SET (
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OF_UNT_SET_RL
      WHERE    (course_cd = x_course_cd
      AND      crv_version_number = x_crv_version_number
      AND      cal_type = x_cal_type
      AND      sub_unit_set_cd = x_unit_set_cd
      AND      sub_us_version_number = x_us_version_number)
	OR       (course_cd = x_course_cd
      AND      crv_version_number = x_crv_version_number
      AND      cal_type = x_cal_type
      AND      sup_unit_set_cd = x_unit_set_cd
      AND      sup_us_version_number = x_us_version_number);
      lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COUSR_COUS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR_UNIT_SET;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sup_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_sup_us_version_number IN NUMBER DEFAULT NULL,
    x_sub_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_sub_us_version_number IN NUMBER DEFAULT NULL,
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
      x_crv_version_number,
      x_cal_type,
      x_sup_unit_set_cd,
      x_sup_us_version_number,
      x_sub_unit_set_cd,
      x_sub_us_version_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsert1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
	    new_references.course_cd,
	    new_references.crv_version_number,
    	    new_references.cal_type,
    	    new_references.sup_unit_set_cd,
 	    new_references.sup_us_version_number,
    	    new_references.sub_unit_set_cd,
    	    new_references.sub_us_version_number
           ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
      IF  Get_PK_For_Validation (
	    new_references.course_cd,
	    new_references.crv_version_number,
    	    new_references.cal_type,
    	    new_references.sup_unit_set_cd,
 	    new_references.sup_us_version_number,
    	    new_references.sub_unit_set_cd,
    	    new_references.sub_us_version_number
           ) THEN
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

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsert2 ( p_inserting => TRUE );

    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_SUP_US_VERSION_NUMBER in NUMBER,
  X_SUB_UNIT_SET_CD in VARCHAR2,
  X_SUP_UNIT_SET_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_SUB_US_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_OF_UNT_SET_RL
      where COURSE_CD = X_COURSE_CD
      and CRV_VERSION_NUMBER = X_CRV_VERSION_NUMBER
      and SUP_US_VERSION_NUMBER = X_SUP_US_VERSION_NUMBER
      and SUB_UNIT_SET_CD = X_SUB_UNIT_SET_CD
      and SUP_UNIT_SET_CD = X_SUP_UNIT_SET_CD
      and CAL_TYPE = X_CAL_TYPE
      and SUB_US_VERSION_NUMBER = X_SUB_US_VERSION_NUMBER;
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
    x_course_cd => X_COURSE_CD,
    x_crv_version_number => X_CRV_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_sup_unit_set_cd => X_SUP_UNIT_SET_CD,
    x_sup_us_version_number => X_SUP_US_VERSION_NUMBER,
    x_sub_unit_set_cd => X_SUB_UNIT_SET_CD,
    x_sub_us_version_number => X_SUB_US_VERSION_NUMBER,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_PS_OF_UNT_SET_RL (
    COURSE_CD,
    CRV_VERSION_NUMBER,
    CAL_TYPE,
    SUP_UNIT_SET_CD,
    SUP_US_VERSION_NUMBER,
    SUB_UNIT_SET_CD,
    SUB_US_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.CRV_VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.SUP_UNIT_SET_CD,
    NEW_REFERENCES.SUP_US_VERSION_NUMBER,
    NEW_REFERENCES.SUB_UNIT_SET_CD,
    NEW_REFERENCES.SUB_US_VERSION_NUMBER,
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
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );


end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_SUP_US_VERSION_NUMBER in NUMBER,
  X_SUB_UNIT_SET_CD in VARCHAR2,
  X_SUP_UNIT_SET_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_SUB_US_VERSION_NUMBER in NUMBER
) AS
  cursor c1 is select ROWID
    from IGS_PS_OF_UNT_SET_RL
    where ROWID = X_ROWID for update nowait;
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
  return;
end LOCK_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
   Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_PS_OF_UNT_SET_RL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_PS_OF_UNT_SET_RL_PKG;

/
