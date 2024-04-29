--------------------------------------------------------
--  DDL for Package Body IGS_RE_CDT_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_CDT_HIST_PKG" as
/* $Header: IGSRI05B.pls 115.5 2002/11/29 03:32:20 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_RE_CDT_HIST_ALL%RowType;
  new_references IGS_RE_CDT_HIST_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_sca_course_cd IN VARCHAR2 DEFAULT NULL,
    x_acai_admission_appl_number IN NUMBER DEFAULT NULL,
    x_acai_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_acai_sequence_number IN NUMBER DEFAULT NULL,
    x_attendance_percentage IN NUMBER DEFAULT NULL,
    x_govt_type_of_activity_cd IN VARCHAR2 DEFAULT NULL,
    x_max_submission_dt IN DATE DEFAULT NULL,
    x_min_submission_dt IN DATE DEFAULT NULL,
    x_research_topic IN VARCHAR2 DEFAULT NULL,
    x_industry_links IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id in NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_CDT_HIST_ALL
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
    new_references.person_id := x_person_id;
    new_references.sequence_number := x_sequence_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.sca_course_cd := x_sca_course_cd;
    new_references.acai_admission_appl_number := x_acai_admission_appl_number;
    new_references.acai_nominated_course_cd := x_acai_nominated_course_cd;
    new_references.acai_sequence_number := x_acai_sequence_number;
    new_references.attendance_percentage := x_attendance_percentage;
    new_references.govt_type_of_activity_cd := x_govt_type_of_activity_cd;
    new_references.max_submission_dt := x_max_submission_dt;
    new_references.min_submission_dt := x_min_submission_dt;
    new_references.research_topic := x_research_topic;
    new_references.industry_links := x_industry_links;
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
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) AS
 BEGIN
 IF Column_Name is null then
   NULL;
 ELSIF upper(Column_name) = 'ACAI_NOMINATED_COURSE_CD' THEN
   new_references.ACAI_NOMINATED_COURSE_CD := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'GOVT_TYPE_OF_ACTIVITY_CD' THEN
   new_references.GOVT_TYPE_OF_ACTIVITY_CD := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'SCA_COURSE_CD' THEN
   new_references.SCA_COURSE_CD := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' THEN
   new_references.SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'ACAI_SEQUENCE_NUMBER' THEN
   new_references.ACAI_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'ATTENDANCE_PERCENTAGE' THEN
   new_references.ATTENDANCE_PERCENTAGE := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 END IF;
  IF upper(column_name) = 'ACAI_NOMINATED_COURSE_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.ACAI_NOMINATED_COURSE_CD <> upper(NEW_REFERENCES.ACAI_NOMINATED_COURSE_CD) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'GOVT_TYPE_OF_ACTIVITY_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.GOVT_TYPE_OF_ACTIVITY_CD <> upper(NEW_REFERENCES.GOVT_TYPE_OF_ACTIVITY_CD) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'SCA_COURSE_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.SCA_COURSE_CD <> upper(NEW_REFERENCES.SCA_COURSE_CD) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.SEQUENCE_NUMBER < 1 OR  new_references.SEQUENCE_NUMBER > 999999 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'ACAI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.ACAI_SEQUENCE_NUMBER < 1  OR new_references.ACAI_SEQUENCE_NUMBER > 999999 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'ATTENDANCE_PERCENTAGE' OR COLUMN_NAME IS NULL THEN
    IF new_references.ATTENDANCE_PERCENTAGE < 1 OR new_references.ATTENDANCE_PERCENTAGE > 100 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
 END Check_Constraints ;
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN
  AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_CDT_HIST_ALL
      WHERE    person_id = x_person_id
      AND      sequence_number = x_sequence_number
      AND      hist_start_dt = x_hist_start_dt
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
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_sca_course_cd IN VARCHAR2 DEFAULT NULL,
    x_acai_admission_appl_number IN NUMBER DEFAULT NULL,
    x_acai_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_acai_sequence_number IN NUMBER DEFAULT NULL,
    x_attendance_percentage IN NUMBER DEFAULT NULL,
    x_govt_type_of_activity_cd IN VARCHAR2 DEFAULT NULL,
    x_max_submission_dt IN DATE DEFAULT NULL,
    x_min_submission_dt IN DATE DEFAULT NULL,
    x_research_topic IN VARCHAR2 DEFAULT NULL,
    x_industry_links IN VARCHAR2 DEFAULT NULL,
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
      x_person_id,
      x_sequence_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_sca_course_cd,
      x_acai_admission_appl_number,
      x_acai_nominated_course_cd,
      x_acai_sequence_number,
      x_attendance_percentage,
      x_govt_type_of_activity_cd,
      x_max_submission_dt,
      x_min_submission_dt,
      x_research_topic,
      x_industry_links,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      IF Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.sequence_number,
	    new_references.hist_start_dt
      ) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	 IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.sequence_number,
	    new_references.hist_start_dt
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
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_ACAI_ADMISSION_APPL_NUMBER in NUMBER,
  X_ACAI_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_PERCENTAGE in NUMBER,
  X_GOVT_TYPE_OF_ACTIVITY_CD in VARCHAR2,
  X_MAX_SUBMISSION_DT in DATE,
  X_MIN_SUBMISSION_DT in DATE,
  X_RESEARCH_TOPIC in VARCHAR2,
  X_INDUSTRY_LINKS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) as
    cursor C is select ROWID from IGS_RE_CDT_HIST_ALL
      where PERSON_ID = X_PERSON_ID
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
      and HIST_START_DT = X_HIST_START_DT;
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
    x_person_id => X_PERSON_ID,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_sca_course_cd => X_SCA_COURSE_CD,
    x_acai_admission_appl_number => X_ACAI_ADMISSION_APPL_NUMBER,
    x_acai_nominated_course_cd => X_ACAI_NOMINATED_COURSE_CD,
    x_acai_sequence_number => X_ACAI_SEQUENCE_NUMBER,
    x_attendance_percentage => X_ATTENDANCE_PERCENTAGE,
    x_govt_type_of_activity_cd => X_GOVT_TYPE_OF_ACTIVITY_CD,
    x_max_submission_dt => X_MAX_SUBMISSION_DT,
    x_min_submission_dt => X_MIN_SUBMISSION_DT,
    x_research_topic => X_RESEARCH_TOPIC,
    x_industry_links => X_INDUSTRY_LINKS,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
  );
  insert into IGS_RE_CDT_HIST_ALL (
    PERSON_ID,
    SEQUENCE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    SCA_COURSE_CD,
    ACAI_ADMISSION_APPL_NUMBER,
    ACAI_NOMINATED_COURSE_CD,
    ACAI_SEQUENCE_NUMBER,
    ATTENDANCE_PERCENTAGE,
    GOVT_TYPE_OF_ACTIVITY_CD,
    MAX_SUBMISSION_DT,
    MIN_SUBMISSION_DT,
    RESEARCH_TOPIC,
    INDUSTRY_LINKS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.SCA_COURSE_CD,
    NEW_REFERENCES.ACAI_ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.ACAI_NOMINATED_COURSE_CD,
    NEW_REFERENCES.ACAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ATTENDANCE_PERCENTAGE,
    NEW_REFERENCES.GOVT_TYPE_OF_ACTIVITY_CD,
    NEW_REFERENCES.MAX_SUBMISSION_DT,
    NEW_REFERENCES.MIN_SUBMISSION_DT,
    NEW_REFERENCES.RESEARCH_TOPIC,
    NEW_REFERENCES.INDUSTRY_LINKS,
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
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_ACAI_ADMISSION_APPL_NUMBER in NUMBER,
  X_ACAI_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_PERCENTAGE in NUMBER,
  X_GOVT_TYPE_OF_ACTIVITY_CD in VARCHAR2,
  X_MAX_SUBMISSION_DT in DATE,
  X_MIN_SUBMISSION_DT in DATE,
  X_RESEARCH_TOPIC in VARCHAR2,
  X_INDUSTRY_LINKS in VARCHAR2
) as
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      SCA_COURSE_CD,
      ACAI_ADMISSION_APPL_NUMBER,
      ACAI_NOMINATED_COURSE_CD,
      ACAI_SEQUENCE_NUMBER,
      ATTENDANCE_PERCENTAGE,
      GOVT_TYPE_OF_ACTIVITY_CD,
      MAX_SUBMISSION_DT,
      MIN_SUBMISSION_DT,
      RESEARCH_TOPIC,
      INDUSTRY_LINKS
    from IGS_RE_CDT_HIST_ALL
    where ROWID = X_ROWID
    for update nowait;
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
      AND ((tlinfo.SCA_COURSE_CD = X_SCA_COURSE_CD)
           OR ((tlinfo.SCA_COURSE_CD is null)
               AND (X_SCA_COURSE_CD is null)))
      AND ((tlinfo.ACAI_ADMISSION_APPL_NUMBER = X_ACAI_ADMISSION_APPL_NUMBER)
           OR ((tlinfo.ACAI_ADMISSION_APPL_NUMBER is null)
               AND (X_ACAI_ADMISSION_APPL_NUMBER is null)))
      AND ((tlinfo.ACAI_NOMINATED_COURSE_CD = X_ACAI_NOMINATED_COURSE_CD)
           OR ((tlinfo.ACAI_NOMINATED_COURSE_CD is null)
               AND (X_ACAI_NOMINATED_COURSE_CD is null)))
      AND ((tlinfo.ACAI_SEQUENCE_NUMBER = X_ACAI_SEQUENCE_NUMBER)
           OR ((tlinfo.ACAI_SEQUENCE_NUMBER is null)
               AND (X_ACAI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ATTENDANCE_PERCENTAGE = X_ATTENDANCE_PERCENTAGE)
           OR ((tlinfo.ATTENDANCE_PERCENTAGE is null)
               AND (X_ATTENDANCE_PERCENTAGE is null)))
      AND ((tlinfo.GOVT_TYPE_OF_ACTIVITY_CD = X_GOVT_TYPE_OF_ACTIVITY_CD)
           OR ((tlinfo.GOVT_TYPE_OF_ACTIVITY_CD is null)
               AND (X_GOVT_TYPE_OF_ACTIVITY_CD is null)))
      AND ((tlinfo.MAX_SUBMISSION_DT = X_MAX_SUBMISSION_DT)
           OR ((tlinfo.MAX_SUBMISSION_DT is null)
               AND (X_MAX_SUBMISSION_DT is null)))
      AND ((tlinfo.MIN_SUBMISSION_DT = X_MIN_SUBMISSION_DT)
           OR ((tlinfo.MIN_SUBMISSION_DT is null)
               AND (X_MIN_SUBMISSION_DT is null)))
      AND ((tlinfo.RESEARCH_TOPIC = X_RESEARCH_TOPIC)
           OR ((tlinfo.RESEARCH_TOPIC is null)
               AND (X_RESEARCH_TOPIC is null)))
      AND ((tlinfo.INDUSTRY_LINKS = X_INDUSTRY_LINKS)
           OR ((tlinfo.INDUSTRY_LINKS is null)
               AND (X_INDUSTRY_LINKS is null)))
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
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_ACAI_ADMISSION_APPL_NUMBER in NUMBER,
  X_ACAI_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_PERCENTAGE in NUMBER,
  X_GOVT_TYPE_OF_ACTIVITY_CD in VARCHAR2,
  X_MAX_SUBMISSION_DT in DATE,
  X_MIN_SUBMISSION_DT in DATE,
  X_RESEARCH_TOPIC in VARCHAR2,
  X_INDUSTRY_LINKS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
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
    x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_sca_course_cd => X_SCA_COURSE_CD,
    x_acai_admission_appl_number => X_ACAI_ADMISSION_APPL_NUMBER,
    x_acai_nominated_course_cd => X_ACAI_NOMINATED_COURSE_CD,
    x_acai_sequence_number => X_ACAI_SEQUENCE_NUMBER,
    x_attendance_percentage => X_ATTENDANCE_PERCENTAGE,
    x_govt_type_of_activity_cd => X_GOVT_TYPE_OF_ACTIVITY_CD,
    x_max_submission_dt => X_MAX_SUBMISSION_DT,
    x_min_submission_dt => X_MIN_SUBMISSION_DT,
    x_research_topic => X_RESEARCH_TOPIC,
    x_industry_links => X_INDUSTRY_LINKS,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_RE_CDT_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    SCA_COURSE_CD = NEW_REFERENCES.SCA_COURSE_CD,
    ACAI_ADMISSION_APPL_NUMBER = NEW_REFERENCES.ACAI_ADMISSION_APPL_NUMBER,
    ACAI_NOMINATED_COURSE_CD = NEW_REFERENCES.ACAI_NOMINATED_COURSE_CD,
    ACAI_SEQUENCE_NUMBER = NEW_REFERENCES.ACAI_SEQUENCE_NUMBER,
    ATTENDANCE_PERCENTAGE = NEW_REFERENCES.ATTENDANCE_PERCENTAGE,
    GOVT_TYPE_OF_ACTIVITY_CD = NEW_REFERENCES.GOVT_TYPE_OF_ACTIVITY_CD,
    MAX_SUBMISSION_DT = NEW_REFERENCES.MAX_SUBMISSION_DT,
    MIN_SUBMISSION_DT = NEW_REFERENCES.MIN_SUBMISSION_DT,
    RESEARCH_TOPIC = NEW_REFERENCES.RESEARCH_TOPIC,
    INDUSTRY_LINKS = NEW_REFERENCES.INDUSTRY_LINKS,
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
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_ACAI_ADMISSION_APPL_NUMBER in NUMBER,
  X_ACAI_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_PERCENTAGE in NUMBER,
  X_GOVT_TYPE_OF_ACTIVITY_CD in VARCHAR2,
  X_MAX_SUBMISSION_DT in DATE,
  X_MIN_SUBMISSION_DT in DATE,
  X_RESEARCH_TOPIC in VARCHAR2,
  X_INDUSTRY_LINKS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_CDT_HIST_ALL
     where PERSON_ID = X_PERSON_ID
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_SEQUENCE_NUMBER,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_SCA_COURSE_CD,
     X_ACAI_ADMISSION_APPL_NUMBER,
     X_ACAI_NOMINATED_COURSE_CD,
     X_ACAI_SEQUENCE_NUMBER,
     X_ATTENDANCE_PERCENTAGE,
     X_GOVT_TYPE_OF_ACTIVITY_CD,
     X_MAX_SUBMISSION_DT,
     X_MIN_SUBMISSION_DT,
     X_RESEARCH_TOPIC,
     X_INDUSTRY_LINKS,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_SEQUENCE_NUMBER,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_SCA_COURSE_CD,
   X_ACAI_ADMISSION_APPL_NUMBER,
   X_ACAI_NOMINATED_COURSE_CD,
   X_ACAI_SEQUENCE_NUMBER,
   X_ATTENDANCE_PERCENTAGE,
   X_GOVT_TYPE_OF_ACTIVITY_CD,
   X_MAX_SUBMISSION_DT,
   X_MIN_SUBMISSION_DT,
   X_RESEARCH_TOPIC,
   X_INDUSTRY_LINKS,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  ) as
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
   );
  delete from IGS_RE_CDT_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_RE_CDT_HIST_PKG;

/
