--------------------------------------------------------
--  DDL for Package Body IGS_PS_OFR_OPT_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_OFR_OPT_NOTE_PKG" AS
/* $Header: IGSPI22B.pls 115.4 2002/11/29 02:12:21 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_OFR_OPT_NOTE%RowType;
  new_references IGS_PS_OFR_OPT_NOTE%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_coo_id IN NUMBER DEFAULT NULL,
    x_crs_note_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_OFR_OPT_NOTE
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
    new_references.cal_type := x_cal_type;
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.reference_number := x_reference_number;
    new_references.coo_id := x_coo_id;
    new_references.crs_note_type := x_crs_note_type;
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
  -- "OSS_TST".trg_coon_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_PS_OFR_OPT_NOTE
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_course_cd		IGS_PS_OFR_OPT_NOTE.course_cd%TYPE;
	v_version_number		IGS_PS_OFR_OPT_NOTE.version_number%TYPE;
	v_message_name          VARCHAR2(30);
  BEGIN

	-- Set IGS_PS_OFR_OPT key.
	IF p_inserting THEN
		IGS_PS_GEN_003.CRSP_GET_COO_KEY (
			new_references.coo_id,
			new_references.course_cd,
			new_references.version_number,
			new_references.cal_type,
			new_references.location_cd,
			new_references.attendance_mode,
			new_references.attendance_type);
	END IF;
	-- Set variables.
	IF p_deleting THEN
		v_course_cd := old_references.course_cd;
		v_version_number := old_references.version_number;
	ELSE -- p_inserting or p_updating
		v_course_cd := new_references.course_cd;
		v_version_number := new_references.version_number;
	END IF;
	-- Validate the insert/update/delete.
	IF IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl (
			v_course_cd,
			v_version_number,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;


  END BeforeRowInsertUpdateDelete1;

 PROCEDURE Check_Constraints (
 Column_Name	IN VARCHAR2	DEFAULT NULL,
 Column_Value 	IN VARCHAR2	DEFAULT NULL
 )
 AS
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
	ELSIF upper(Column_name) = 'LOCATION_CD' then
	    new_references.location_cd := column_value;
	ELSIF upper(Column_name) = 'CRS_NOTE_TYPE' then
	    new_references.crs_note_type := column_value;
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

    IF upper(column_name) = 'LOCATION_CD' OR
    column_name is null Then
	   IF ( new_references.location_cd <> UPPER(new_references.location_cd) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF upper(column_name) = 'CRS_NOTE_TYPE' OR
    column_name is null Then
	   IF ( new_references.crs_note_type <> UPPER(new_references.crs_note_type) ) Then
      	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      	 IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.crs_note_type = new_references.crs_note_type)) OR
        ((new_references.crs_note_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_NOTE_TYPE_PKG.Get_PK_For_Validation (
        new_references.crs_note_type
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.location_cd = new_references.location_cd) AND
         (old_references.attendance_mode = new_references.attendance_mode) AND
         (old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.location_cd IS NULL) OR
         (new_references.attendance_mode IS NULL) OR
         (new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_OPT_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.location_cd,
        new_references.attendance_mode,
        new_references.attendance_type
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.coo_id = new_references.coo_id)) OR
        ((new_references.coo_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_OPT_PKG.Get_UK_For_Validation (
        new_references.coo_id
        ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.reference_number = new_references.reference_number)) OR
        ((new_references.reference_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GE_NOTE_PKG.Get_PK_For_Validation (
        new_references.reference_number
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
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2,
    x_reference_number IN NUMBER
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_NOTE
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      location_cd = x_location_cd
      AND      attendance_mode = x_attendance_mode
      AND      attendance_type = x_attendance_type
      AND      reference_number = x_reference_number
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

  PROCEDURE GET_FK_IGS_PS_NOTE_TYPE (
    x_crs_note_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_NOTE
      WHERE    crs_note_type = x_crs_note_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COON_CNT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_NOTE_TYPE;

  PROCEDURE GET_FK_IGS_PS_OFR_OPT (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_NOTE
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      location_cd = x_location_cd
      AND      attendance_mode = x_attendance_mode
      AND      attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COON_COO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR_OPT;

  PROCEDURE GET_UFK_IGS_PS_OFR_OPT (
    x_coo_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_NOTE
      WHERE    coo_id = x_coo_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COON_COO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_PS_OFR_OPT;

  PROCEDURE GET_FK_IGS_GE_NOTE (
    x_reference_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_OPT_NOTE
      WHERE    reference_number = x_reference_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COON_NOTE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GE_NOTE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_coo_id IN NUMBER DEFAULT NULL,
    x_crs_note_type IN VARCHAR2 DEFAULT NULL,
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
      x_cal_type,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_reference_number,
      x_coo_id,
      x_crs_note_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
      new_references.course_cd,
      new_references.version_number,
      new_references.cal_type,
      new_references.location_cd,
      new_references.attendance_mode,
      new_references.attendance_type,
      new_references.reference_number ) THEN
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF  Get_PK_For_Validation (
      new_references.course_cd,
      new_references.version_number,
      new_references.cal_type,
      new_references.location_cd,
      new_references.attendance_mode,
      new_references.attendance_type,
      new_references.reference_number ) THEN
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
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_COO_ID in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_OFR_OPT_NOTE
      where COURSE_CD = X_COURSE_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and CAL_TYPE = X_CAL_TYPE
      and ATTENDANCE_MODE = X_ATTENDANCE_MODE
      and REFERENCE_NUMBER = X_REFERENCE_NUMBER
      and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
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
Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_reference_number => X_REFERENCE_NUMBER,
    x_coo_id => X_COO_ID,
    x_crs_note_type => X_CRS_NOTE_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  insert into IGS_PS_OFR_OPT_NOTE (
    COURSE_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    REFERENCE_NUMBER,
    COO_ID,
    CRS_NOTE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.REFERENCE_NUMBER,
    NEW_REFERENCES.COO_ID,
    NEW_REFERENCES.CRS_NOTE_TYPE,
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
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_COO_ID in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2
) AS
  cursor c1 is select
      COO_ID,
      CRS_NOTE_TYPE
    from IGS_PS_OFR_OPT_NOTE
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

  if ( (tlinfo.COO_ID = X_COO_ID)
      AND (tlinfo.CRS_NOTE_TYPE = X_CRS_NOTE_TYPE)
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
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_COO_ID in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2,
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
    x_cal_type => X_CAL_TYPE,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_reference_number => X_REFERENCE_NUMBER,
    x_coo_id => X_COO_ID,
    x_crs_note_type => X_CRS_NOTE_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  update IGS_PS_OFR_OPT_NOTE set
    COO_ID = NEW_REFERENCES.COO_ID,
    CRS_NOTE_TYPE = NEW_REFERENCES.CRS_NOTE_TYPE,
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
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_COO_ID in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_OFR_OPT_NOTE
     where COURSE_CD = X_COURSE_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and CAL_TYPE = X_CAL_TYPE
     and ATTENDANCE_MODE = X_ATTENDANCE_MODE
     and REFERENCE_NUMBER = X_REFERENCE_NUMBER
     and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
     and LOCATION_CD = X_LOCATION_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_ATTENDANCE_MODE,
     X_REFERENCE_NUMBER,
     X_ATTENDANCE_TYPE,
     X_LOCATION_CD,
     X_COO_ID,
     X_CRS_NOTE_TYPE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_ATTENDANCE_MODE,
   X_REFERENCE_NUMBER,
   X_ATTENDANCE_TYPE,
   X_LOCATION_CD,
   X_COO_ID,
   X_CRS_NOTE_TYPE,
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
  delete from IGS_PS_OFR_OPT_NOTE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_PS_OFR_OPT_NOTE_PKG;

/
