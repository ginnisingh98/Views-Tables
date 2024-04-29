--------------------------------------------------------
--  DDL for Package Body IGS_PS_FEE_TRG_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_FEE_TRG_HIST_PKG" AS
  /* $Header: IGSPI12B.pls 115.9 2003/02/12 09:49:00 shtatiko ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_PS_FEE_TRG_HIST_ALL%RowType;
  new_references IGS_PS_FEE_TRG_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_fee_trigger_group_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_FEE_TRG_HIST_ALL
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
    new_references.fee_cat := x_fee_cat;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.fee_type := x_fee_type;
    new_references.course_cd := x_course_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.create_dt := x_create_dt;
    new_references.fee_trigger_group_number := x_fee_trigger_group_number;
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

 PROCEDURE Check_Constraints (
 Column_Name	IN VARCHAR2	DEFAULT NULL,
 Column_Value 	IN VARCHAR2	DEFAULT NULL
 ) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     19-May-2002   removed upper check constraint on fee_cat,fee_type columns.bug#2344826.
  ----------------------------------------------------------------------------*/

 BEGIN

	IF column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'ATTENDANCE_MODE' then
	    new_references.attendance_mode := column_value;
	ELSIF upper(Column_name) = 'ATTENDANCE_TYPE' then
	    new_references.attendance_type := column_value;
	ELSIF upper(Column_name) = 'CAL_TYPE' then
	    new_references.cal_type := column_value;
	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.course_cd := column_value;
	ELSIF upper(Column_name) = 'FEE_CAL_TYPE' then
	    new_references.fee_cal_type := column_value;
	ELSIF upper(Column_name) = 'LOCATION_CD' then
	    new_references.location_cd := column_value;
	ELSIF upper(Column_name) = 'FEE_TRIGGER_GROUP_NUMBER' then
	    new_references.fee_trigger_group_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' then
	    new_references.sequence_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'VERSION_NUMBER' then
	    new_references.version_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'FEE_CI_SEQUENCE_NUMBER' then
	    new_references.fee_ci_sequence_number := igs_ge_number.to_num(column_value);
     END IF;

    IF upper(column_name) = 'ATTENDANCE_MODE' OR
    column_name is null Then
	   IF ( new_references.attendance_mode <> UPPER(new_references.attendance_mode) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'ATTENDANCE_TYPE' OR
    column_name is null Then
	   IF ( new_references.attendance_type <> UPPER(new_references.attendance_type) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'CAL_TYPE' OR
    column_name is null Then
	   IF ( new_references.cal_type <> UPPER(new_references.cal_type) ) Then
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

    IF upper(column_name) = 'FEE_CAL_TYPE' OR
    column_name is null Then
	   IF ( new_references.fee_cal_type <> UPPER(new_references.fee_cal_type) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'LOCATION_CD' OR
    column_name is null Then
	   IF ( new_references.location_cd <> UPPER(new_references.location_cd) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'FEE_CI_SEQUENCE_NUMBER' OR
    column_name is null Then
	   IF ( new_references.fee_ci_sequence_number < 1 OR new_references.fee_ci_sequence_number > 999999 ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'SEQUENCE_NUMBER' OR
    column_name is null Then
	   IF ( new_references.sequence_number < 1 OR new_references.sequence_number > 999999 ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'VERSION_NUMBER' OR
    column_name is null Then
	   IF ( new_references.version_number < 1 OR new_references.version_number > 999 ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'FEE_TRIGGER_GROUP_NUMBER' OR
    column_name is null Then
	   IF ( new_references.fee_trigger_group_number < 1 OR new_references.fee_trigger_group_number > 999999 ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

  END Check_Constraints;

  PROCEDURE Check_Uniqueness AS
  BEGIN

      IF Get_UK_For_Validation (
      new_references.fee_cat ,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.fee_type,
      new_references.course_cd,
      new_references.VERSION_NUMBER,
      new_references.CAL_TYPE,
      new_references.LOCATION_CD,
      new_references.ATTENDANCE_MODE,
      new_references.ATTENDANCE_TYPE,
      new_references.CREATE_DT,
      new_references.hist_start_dt) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
  END Check_Uniqueness ;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
        new_references.fee_cat,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number,
        new_references.fee_type ) THEN
     	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    )
RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_FEE_TRG_HIST_ALL
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      course_cd = x_course_cd
      AND      sequence_number = x_sequence_number
      AND      hist_start_dt = x_hist_start_dt
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

  FUNCTION Get_UK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_course_cd IN VARCHAR2,
    X_VERSION_NUMBER in NUMBER,
    X_CAL_TYPE in VARCHAR2,
    X_LOCATION_CD in VARCHAR2,
    X_ATTENDANCE_MODE in VARCHAR2,
    X_ATTENDANCE_TYPE in VARCHAR2,
    X_CREATE_DT in DATE,
    x_hist_start_dt IN DATE )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_FEE_TRG_HIST_ALL
         WHERE    fee_cat = new_references.fee_cat
         AND      fee_cal_type = new_references.fee_cal_type
         AND      fee_ci_sequence_number = new_references.fee_ci_sequence_number
         AND      fee_type = new_references.fee_type
         AND      course_cd = new_references.course_cd
         AND      version_number = new_references.version_number
         AND      cal_type = new_references.cal_type
         AND      location_cd = new_references.location_cd
         AND      attendance_mode = new_references.attendance_mode
         AND      attendance_type = new_references.attendance_type
         AND      create_dt = new_references.create_dt
         AND      hist_start_dt = new_references.hist_start_dt
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

 END Get_UK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_fee_trigger_group_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_cat,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_type,
      x_course_cd,
      x_sequence_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_version_number,
      x_cal_type,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_create_dt,
      x_fee_trigger_group_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
     	IF Get_PK_For_Validation (
      new_references.fee_cat,
      new_references.fee_cal_type ,
      new_references.fee_ci_sequence_number,
      new_references.fee_type,
      new_references.course_cd,
      new_references.sequence_number,
      new_references.hist_start_dt) THEN
	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	   IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
	Check_Uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Parent_Existance;
	Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF  Get_PK_For_Validation (
      new_references.fee_cat,
      new_references.fee_cal_type ,
      new_references.fee_ci_sequence_number,
      new_references.fee_type,
      new_references.course_cd,
      new_references.sequence_number,
      new_references.hist_start_dt) THEN
	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
	Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
	Check_Uniqueness;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := null;


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in number
  ) AS
    cursor C is select ROWID from IGS_PS_FEE_TRG_HIST_ALL
      where FEE_CAT = X_FEE_CAT
      and FEE_TYPE = X_FEE_TYPE
      and COURSE_CD = X_COURSE_CD
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
      and HIST_START_DT = X_HIST_START_DT
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE;
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
    x_fee_cat => X_FEE_CAT,
    x_fee_cal_type => X_FEE_CAL_TYPE,
    x_fee_ci_sequence_number => X_FEE_CI_SEQUENCE_NUMBER,
    x_fee_type => X_FEE_TYPE,
    x_course_cd => X_COURSE_CD,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_create_dt => NVL(X_CREATE_DT,SYSDATE),
    x_fee_trigger_group_number => X_FEE_TRIGGER_GROUP_NUMBER ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
 );

  insert into IGS_PS_FEE_TRG_HIST_ALL (
    FEE_CAT,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    FEE_TYPE,
    COURSE_CD,
    SEQUENCE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    VERSION_NUMBER,
    CAL_TYPE,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    CREATE_DT,
    FEE_TRIGGER_GROUP_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.FEE_TRIGGER_GROUP_NUMBER,
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
After_DML (
	p_action => 'INSERT',
	x_rowid => X_ROWID
);
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER

) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      VERSION_NUMBER,
      CAL_TYPE,
      LOCATION_CD,
      ATTENDANCE_MODE,
      ATTENDANCE_TYPE,
      CREATE_DT,
      FEE_TRIGGER_GROUP_NUMBER

    from IGS_PS_FEE_TRG_HIST_ALL
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
           OR ((tlinfo.VERSION_NUMBER is null)
               AND (X_VERSION_NUMBER is null)))
      AND ((tlinfo.CAL_TYPE = X_CAL_TYPE)
           OR ((tlinfo.CAL_TYPE is null)
               AND (X_CAL_TYPE is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
           OR ((tlinfo.ATTENDANCE_MODE is null)
               AND (X_ATTENDANCE_MODE is null)))
      AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
           OR ((tlinfo.ATTENDANCE_TYPE is null)
               AND (X_ATTENDANCE_TYPE is null)))
      AND ((tlinfo.CREATE_DT = X_CREATE_DT)
           OR ((tlinfo.CREATE_DT is null)
               AND (X_CREATE_DT is null)))
      AND ((tlinfo.FEE_TRIGGER_GROUP_NUMBER = X_FEE_TRIGGER_GROUP_NUMBER)
           OR ((tlinfo.FEE_TRIGGER_GROUP_NUMBER is null)
               AND (X_FEE_TRIGGER_GROUP_NUMBER is null)))

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
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
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
    x_fee_cat => X_FEE_CAT,
    x_fee_cal_type => X_FEE_CAL_TYPE,
    x_fee_ci_sequence_number => X_FEE_CI_SEQUENCE_NUMBER,
    x_fee_type => X_FEE_TYPE,
    x_course_cd => X_COURSE_CD,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_create_dt => X_CREATE_DT,
    x_fee_trigger_group_number => X_FEE_TRIGGER_GROUP_NUMBER ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN

 );

  update IGS_PS_FEE_TRG_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    CREATE_DT = NEW_REFERENCES.CREATE_DT,
    FEE_TRIGGER_GROUP_NUMBER = NEW_REFERENCES.FEE_TRIGGER_GROUP_NUMBER,
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
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PS_FEE_TRG_HIST_ALL
     where FEE_CAT = X_FEE_CAT
     and FEE_TYPE = X_FEE_TYPE
     and COURSE_CD = X_COURSE_CD
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and HIST_START_DT = X_HIST_START_DT
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAT,
     X_FEE_TYPE,
     X_COURSE_CD,
     X_SEQUENCE_NUMBER,
     X_HIST_START_DT,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_FEE_CAL_TYPE,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_LOCATION_CD,
     X_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_CREATE_DT,
     X_FEE_TRIGGER_GROUP_NUMBER,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_CAT,
   X_FEE_TYPE,
   X_COURSE_CD,
   X_SEQUENCE_NUMBER,
   X_HIST_START_DT,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_FEE_CAL_TYPE,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_LOCATION_CD,
   X_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_CREATE_DT,
   X_FEE_TRIGGER_GROUP_NUMBER,
   X_MODE
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
  delete from IGS_PS_FEE_TRG_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_PS_FEE_TRG_HIST_PKG;

/
