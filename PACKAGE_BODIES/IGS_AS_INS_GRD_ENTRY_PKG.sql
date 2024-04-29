--------------------------------------------------------
--  DDL for Package Body IGS_AS_INS_GRD_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_INS_GRD_ENTRY_PKG" AS
/* $Header: IGSDI22B.pls 115.3 2002/11/28 23:16:14 nsidana ship $ */
l_rowid VARCHAR2(25);
  old_references IGS_AS_INS_GRD_ENTRY%RowType;
  new_references IGS_AS_INS_GRD_ENTRY%RowType;
PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_keying_who IN VARCHAR2 DEFAULT NULL,
    x_keying_time IN DATE DEFAULT NULL,
    x_student_sequence IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_name IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_mark IN NUMBER DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_gs_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_specified_grade_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_INS_GRD_ENTRY
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action  NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	        Close cur_old_ref_values;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.keying_who := x_keying_who;
    new_references.keying_time := x_keying_time;
    new_references.student_sequence := x_student_sequence;
    new_references.person_id := x_person_id;
    new_references.name := x_name;
    new_references.course_cd := x_course_cd;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.unit_class := x_unit_class;
    new_references.unit_attempt_status := x_unit_attempt_status;
    new_references.mark := x_mark;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.gs_version_number := x_gs_version_number;
    new_references.grade := x_grade;
    new_references.specified_grade_ind := x_specified_grade_ind;
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
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.gs_version_number = new_references.gs_version_number) AND
         (old_references.grade = new_references.grade)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.gs_version_number IS NULL) OR
         (new_references.grade IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_GRD_SCH_GRADE_PKG.Get_PK_For_Validation (
        new_references.grading_schema_cd,
        new_references.gs_version_number,
        new_references.grade
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Parent_Existance;
  FUNCTION Get_PK_For_Validation (
    x_keying_who IN VARCHAR2,
    x_keying_time IN DATE,
    x_student_sequence IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_INS_GRD_ENTRY
      WHERE    keying_who = x_keying_who
      AND      keying_time = x_keying_time
      AND      student_sequence = x_student_sequence
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
  PROCEDURE GET_FK_IGS_AS_GRD_SCH_GRADE (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_INS_GRD_ENTRY
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      gs_version_number = x_version_number
      AND      grade = x_grade ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
    Fnd_Message.Set_Name ('IGS', 'IGS_AS_GET_GSG_FK');
    IGS_GE_MSG_STACK.ADD;
       Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_GRD_SCH_GRADE;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_keying_who IN VARCHAR2 DEFAULT NULL,
    x_keying_time IN DATE DEFAULT NULL,
    x_student_sequence IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_name IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_mark IN NUMBER DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_gs_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_specified_grade_ind IN VARCHAR2 DEFAULT NULL,
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
      x_keying_who,
      x_keying_time,
      x_student_sequence,
      x_person_id,
      x_name,
      x_course_cd,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_location_cd,
      x_unit_class,
      x_unit_attempt_status,
      x_mark,
      x_grading_schema_cd,
      x_gs_version_number,
      x_grade,
      x_specified_grade_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      	IF  Get_PK_For_Validation (
	         NEW_REFERENCES.keying_who ,
    NEW_REFERENCES.keying_time ,
    NEW_REFERENCES.student_sequence) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;

      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

      Check_Constraints;
      Check_Parent_Existance;


	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation (
	          NEW_REFERENCES.keying_who ,
    NEW_REFERENCES.keying_time ,
    NEW_REFERENCES.student_sequence) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	      Check_Constraints;

    END IF;
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_KEYING_WHO in VARCHAR2,
  X_KEYING_TIME in DATE,
  X_STUDENT_SEQUENCE in NUMBER,
  X_PERSON_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_MARK in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_SPECIFIED_GRADE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_INS_GRD_ENTRY
      where KEYING_WHO = X_KEYING_WHO
      and KEYING_TIME = X_KEYING_TIME
      and STUDENT_SEQUENCE = X_STUDENT_SEQUENCE;
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
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_cal_type=>X_CAL_TYPE,
 x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
 x_course_cd=>X_COURSE_CD,
 x_grade=>X_GRADE,
 x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
 x_gs_version_number=>X_GS_VERSION_NUMBER,
 x_keying_time=>X_KEYING_TIME,
 x_keying_who=>X_KEYING_WHO,
 x_location_cd=>X_LOCATION_CD,
 x_mark=>X_MARK,
 x_name=>X_NAME,
 x_person_id=>X_PERSON_ID,
 x_specified_grade_ind=> NVL(X_SPECIFIED_GRADE_IND,'N'),
 x_student_sequence=>X_STUDENT_SEQUENCE,
 x_unit_attempt_status=>X_UNIT_ATTEMPT_STATUS,
 x_unit_cd=>X_UNIT_CD,
 x_unit_class=>X_UNIT_CLASS,
 x_version_number=>X_VERSION_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_AS_INS_GRD_ENTRY (
    KEYING_WHO,
    KEYING_TIME,
    STUDENT_SEQUENCE,
    PERSON_ID,
    NAME,
    COURSE_CD,
    UNIT_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    LOCATION_CD,
    UNIT_CLASS,
    UNIT_ATTEMPT_STATUS,
    MARK,
    GRADING_SCHEMA_CD,
    GS_VERSION_NUMBER,
    GRADE,
    SPECIFIED_GRADE_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.KEYING_WHO,
    NEW_REFERENCES.KEYING_TIME,
    NEW_REFERENCES.STUDENT_SEQUENCE,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.NAME,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.UNIT_ATTEMPT_STATUS,
    NEW_REFERENCES.MARK,
    NEW_REFERENCES.GRADING_SCHEMA_CD,
    NEW_REFERENCES.GS_VERSION_NUMBER,
    NEW_REFERENCES.GRADE,
    NEW_REFERENCES.SPECIFIED_GRADE_IND,
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
  X_ROWID in  VARCHAR2,
  X_KEYING_WHO in VARCHAR2,
  X_KEYING_TIME in DATE,
  X_STUDENT_SEQUENCE in NUMBER,
  X_PERSON_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_MARK in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_SPECIFIED_GRADE_IND in VARCHAR2
) AS
  cursor c1 is select
      PERSON_ID,
      NAME,
      COURSE_CD,
      UNIT_CD,
      VERSION_NUMBER,
      CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      LOCATION_CD,
      UNIT_CLASS,
      UNIT_ATTEMPT_STATUS,
      MARK,
      GRADING_SCHEMA_CD,
      GS_VERSION_NUMBER,
      GRADE,
      SPECIFIED_GRADE_IND
    from IGS_AS_INS_GRD_ENTRY
    where ROWID = X_ROWID  for update  nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    close c1;
    return;
  end if;
  close c1;
  if ( (tlinfo.PERSON_ID = X_PERSON_ID)
      AND (tlinfo.NAME = X_NAME)
      AND (tlinfo.COURSE_CD = X_COURSE_CD)
      AND (tlinfo.UNIT_CD = X_UNIT_CD)
      AND (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND (tlinfo.CAL_TYPE = X_CAL_TYPE)
      AND (tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)
      AND (tlinfo.LOCATION_CD = X_LOCATION_CD)
      AND (tlinfo.UNIT_CLASS = X_UNIT_CLASS)
      AND ((tlinfo.UNIT_ATTEMPT_STATUS = X_UNIT_ATTEMPT_STATUS)
           OR ((tlinfo.UNIT_ATTEMPT_STATUS is null)
               AND (X_UNIT_ATTEMPT_STATUS is null)))
      AND ((tlinfo.MARK = X_MARK)
           OR ((tlinfo.MARK is null)
               AND (X_MARK is null)))
      AND ((tlinfo.GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD)
           OR ((tlinfo.GRADING_SCHEMA_CD is null)
               AND (X_GRADING_SCHEMA_CD is null)))
      AND ((tlinfo.GS_VERSION_NUMBER = X_GS_VERSION_NUMBER)
           OR ((tlinfo.GS_VERSION_NUMBER is null)
               AND (X_GS_VERSION_NUMBER is null)))
      AND ((tlinfo.GRADE = X_GRADE)
           OR ((tlinfo.GRADE is null)
               AND (X_GRADE is null)))
      AND (tlinfo.SPECIFIED_GRADE_IND = X_SPECIFIED_GRADE_IND)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_ROWID in  VARCHAR2,
  X_KEYING_WHO in VARCHAR2,
  X_KEYING_TIME in DATE,
  X_STUDENT_SEQUENCE in NUMBER,
  X_PERSON_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_MARK in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_SPECIFIED_GRADE_IND in VARCHAR2,
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
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_cal_type=>X_CAL_TYPE,
 x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
 x_course_cd=>X_COURSE_CD,
 x_grade=>X_GRADE,
 x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
 x_gs_version_number=>X_GS_VERSION_NUMBER,
 x_keying_time=>X_KEYING_TIME,
 x_keying_who=>X_KEYING_WHO,
 x_location_cd=>X_LOCATION_CD,
 x_mark=>X_MARK,
 x_name=>X_NAME,
 x_person_id=>X_PERSON_ID,
 x_specified_grade_ind=>X_SPECIFIED_GRADE_IND,
 x_student_sequence=>X_STUDENT_SEQUENCE,
 x_unit_attempt_status=>X_UNIT_ATTEMPT_STATUS,
 x_unit_cd=>X_UNIT_CD,
 x_unit_class=>X_UNIT_CLASS,
 x_version_number=>X_VERSION_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_AS_INS_GRD_ENTRY set
    PERSON_ID = NEW_REFERENCES.PERSON_ID,
    NAME = NEW_REFERENCES.NAME,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    UNIT_CD = NEW_REFERENCES.UNIT_CD,
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
    CI_SEQUENCE_NUMBER = NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    UNIT_CLASS = NEW_REFERENCES.UNIT_CLASS,
    UNIT_ATTEMPT_STATUS = NEW_REFERENCES.UNIT_ATTEMPT_STATUS,
    MARK = NEW_REFERENCES.MARK,
    GRADING_SCHEMA_CD = NEW_REFERENCES.GRADING_SCHEMA_CD,
    GS_VERSION_NUMBER = NEW_REFERENCES.GS_VERSION_NUMBER,
    GRADE = NEW_REFERENCES.GRADE,
    SPECIFIED_GRADE_IND = NEW_REFERENCES.SPECIFIED_GRADE_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_KEYING_WHO in VARCHAR2,
  X_KEYING_TIME in DATE,
  X_STUDENT_SEQUENCE in NUMBER,
  X_PERSON_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_MARK in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_SPECIFIED_GRADE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_INS_GRD_ENTRY
     where KEYING_WHO = X_KEYING_WHO
     and KEYING_TIME = X_KEYING_TIME
     and STUDENT_SEQUENCE = X_STUDENT_SEQUENCE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_KEYING_WHO,
     X_KEYING_TIME,
     X_STUDENT_SEQUENCE,
     X_PERSON_ID,
     X_NAME,
     X_COURSE_CD,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_LOCATION_CD,
     X_UNIT_CLASS,
     X_UNIT_ATTEMPT_STATUS,
     X_MARK,
     X_GRADING_SCHEMA_CD,
     X_GS_VERSION_NUMBER,
     X_GRADE,
     X_SPECIFIED_GRADE_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_KEYING_WHO,
   X_KEYING_TIME,
   X_STUDENT_SEQUENCE,
   X_PERSON_ID,
   X_NAME,
   X_COURSE_CD,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_LOCATION_CD,
   X_UNIT_CLASS,
   X_UNIT_ATTEMPT_STATUS,
   X_MARK,
   X_GRADING_SCHEMA_CD,
   X_GS_VERSION_NUMBER,
   X_GRADE,
   X_SPECIFIED_GRADE_IND,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_INS_GRD_ENTRY
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)
	AS
	BEGIN
	IF  column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'CAL_TYPE' then
	    new_references.CAL_TYPE := column_value;
      	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.COURSE_CD := column_value;
	ELSIF upper(Column_name) = 'GRADE' then
	    new_references.GRADE := column_value;
	ELSIF upper(Column_name) = 'GRADING_SCHEMA_CD' then
	    new_references.GRADING_SCHEMA_CD := column_value;
	ELSIF upper(Column_name) = 'KEYING_WHO' then
	    new_references.KEYING_WHO := column_value;
	ELSIF upper(Column_name) = 'LOCATION_CD' then
	    new_references.LOCATION_CD := column_value;
	ELSIF upper(Column_name) = 'SPECIFIED_GRADE_IND' then
	    new_references.SPECIFIED_GRADE_IND := column_value;
	ELSIF upper(Column_name) = 'UNIT_ATTEMPT_STATUS' then
	    new_references.UNIT_ATTEMPT_STATUS := column_value;
	ELSIF upper(Column_name) = 'UNIT_CD' then
	    new_references.UNIT_CD := column_value;
	ELSIF upper(Column_name) = 'UNIT_CLASS' then
	    new_references.UNIT_CLASS := column_value;
	ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
	    new_references.CI_SEQUENCE_NUMBER := igs_ge_number.to_num(column_value);

      END IF ;

     IF upper(column_name) = 'CAL_TYPE' OR
     column_name is null Then
     IF new_references.CAL_TYPE <> UPPER(new_references.CAL_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.COURSE_CD <> UPPER(new_references.COURSE_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'GRADE' OR
     column_name is null Then
     IF new_references.GRADE <> UPPER(new_references.GRADE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'GRADING_SCHEMA_CD' OR
     column_name is null Then
     IF new_references.GRADING_SCHEMA_CD <> UPPER(new_references.GRADING_SCHEMA_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'KEYING_WHO' OR
     column_name is null Then
     IF new_references.KEYING_WHO <> UPPER(new_references.KEYING_WHO) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'LOCATION_CD' OR
     column_name is null Then
     IF new_references.LOCATION_CD <> UPPER(new_references.LOCATION_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'SPECIFIED_GRADE_IND' OR
     column_name is null Then
     IF new_references.SPECIFIED_GRADE_IND <> UPPER(new_references.SPECIFIED_GRADE_IND) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'UNIT_ATTEMPT_STATUS' OR
     column_name is null Then
     IF new_references.UNIT_ATTEMPT_STATUS <> UPPER(new_references.UNIT_ATTEMPT_STATUS) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.UNIT_CD <> UPPER(new_references.UNIT_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'UNIT_CLASS' OR
     column_name is null Then
     IF new_references.UNIT_CLASS <> UPPER(new_references.UNIT_CLASS) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.CI_SEQUENCE_NUMBER < 1 OR new_references.CI_SEQUENCE_NUMBER > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

	END Check_Constraints;
end IGS_AS_INS_GRD_ENTRY_PKG;

/
