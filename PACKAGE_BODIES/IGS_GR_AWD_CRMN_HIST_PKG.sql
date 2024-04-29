--------------------------------------------------------
--  DDL for Package Body IGS_GR_AWD_CRMN_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_AWD_CRMN_HIST_PKG" as
/* $Header: IGSGI04B.pls 115.4 2002/11/29 00:34:27 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_AWD_CRMN_HIST%RowType;
  new_references IGS_GR_AWD_CRMN_HIST%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_GACH_ID in NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_us_group_number IN NUMBER DEFAULT NULL,
    x_order_in_presentation IN NUMBER DEFAULT NULL,
    x_graduand_seat_number IN VARCHAR2 DEFAULT NULL,
    x_name_pronunciation IN VARCHAR2 DEFAULT NULL,
    x_name_announced IN VARCHAR2 DEFAULT NULL,
    x_academic_dress_rqrd_ind IN VARCHAR2 DEFAULT NULL,
    x_academic_gown_size IN VARCHAR2 DEFAULT NULL,
    x_academic_hat_size IN VARCHAR2 DEFAULT NULL,
    x_guest_tickets_requested IN NUMBER DEFAULT NULL,
    x_guest_tickets_allocated IN NUMBER DEFAULT NULL,
    x_guest_seats IN VARCHAR2 DEFAULT NULL,
    x_fees_paid_ind IN VARCHAR2 DEFAULT NULL,
    x_special_requirements IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_AWD_CRMN_HIST
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
    new_references.GACH_ID := x_GACH_ID;
    new_references.person_id := x_person_id;
    new_references.create_dt := x_create_dt;
    new_references.grd_cal_type := x_grd_cal_type;
    new_references.grd_ci_sequence_number := x_grd_ci_sequence_number;
    new_references.ceremony_number := x_ceremony_number;
    new_references.award_course_cd := x_award_course_cd;
    new_references.award_crs_version_number := x_award_crs_version_number;
    new_references.award_cd := x_award_cd;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.us_group_number := x_us_group_number;
    new_references.order_in_presentation := x_order_in_presentation;
    new_references.graduand_seat_number := x_graduand_seat_number;
    new_references.name_pronunciation := x_name_pronunciation;
    new_references.name_announced := x_name_announced;
    new_references.academic_dress_rqrd_ind := x_academic_dress_rqrd_ind;
    new_references.academic_gown_size := x_academic_gown_size;
    new_references.academic_hat_size := x_academic_hat_size;
    new_references.guest_tickets_requested := x_guest_tickets_requested;
    new_references.guest_tickets_allocated := x_guest_tickets_allocated;
    new_references.guest_seats := x_guest_seats;
    new_references.fees_paid_ind := x_fees_paid_ind;
    new_references.special_requirements := x_special_requirements;
    new_references.comments := x_comments;
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

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.create_dt = new_references.create_dt)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.create_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_GRADUAND_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.create_dt
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Uniqueness AS
  BEGIN
	IF Get_UK_For_Validation (
         new_references.person_id,
         new_references.create_dt,
         new_references.grd_cal_type,
         new_references.grd_ci_sequence_number,
         new_references.ceremony_number,
         new_references.award_course_cd,
         new_references.award_crs_version_number,
         new_references.award_cd,
         new_references.hist_start_dt
    ) THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
  END Check_Uniqueness;

  PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
  BEGIN
IF Column_Name is null THEN
  NULL;

ELSIF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' THEN
  new_references.GRD_CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'ORDER_IN_PRESENTATION' THEN
  new_references.ORDER_IN_PRESENTATION:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'CEREMONY_NUMBER' THEN
  new_references.CEREMONY_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'GUEST_TICKETS_ALLOCATED' THEN
  new_references.GUEST_TICKETS_ALLOCATED:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'GUEST_TICKETS_REQUESTED' THEN
  new_references.GUEST_TICKETS_REQUESTED := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'FEES_PAID_IND' THEN
  new_references.FEES_PAID_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'ACADEMIC_DRESS_RQRD_IND' THEN
  new_references.ACADEMIC_DRESS_RQRD_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'ACADEMIC_DRESS_RQRD_IND' THEN
  new_references.ACADEMIC_DRESS_RQRD_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'ACADEMIC_GOWN_SIZE' THEN
  new_references.ACADEMIC_GOWN_SIZE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'ACADEMIC_HAT_SIZE' THEN
  new_references.ACADEMIC_HAT_SIZE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'AWARD_CD' THEN
  new_references.AWARD_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'AWARD_COURSE_CD' THEN
  new_references.AWARD_COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GRADUAND_SEAT_NUMBER' THEN
  new_references.GRADUAND_SEAT_NUMBER:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GRD_CAL_TYPE' THEN
  new_references.GRD_CAL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GUEST_SEATS' THEN
  new_references.GUEST_SEATS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'HIST_WHO' THEN
  new_references.HIST_WHO:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'NAME_ANNOUNCED' THEN
  new_references.NAME_ANNOUNCED:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'NAME_PRONUNCIATION' THEN
  new_references.NAME_PRONUNCIATION:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SPECIAL_REQUIREMENTS' THEN
  new_references.SPECIAL_REQUIREMENTS:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CI_SEQUENCE_NUMBER < 0 OR new_references.GRD_CI_SEQUENCE_NUMBER > 999999 THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF;

IF upper(Column_name) = 'ORDER_IN_PRESENTATION' OR COLUMN_NAME IS NULL THEN
  IF new_references.ORDER_IN_PRESENTATION < 0 OR new_references.ORDER_IN_PRESENTATION > 9999 THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF;

IF upper(Column_name) = 'CEREMONY_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.CEREMONY_NUMBER < 0 OR new_references.CEREMONY_NUMBER > 999999 THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF;

IF upper(Column_name) = 'GUEST_TICKETS_ALLOCATED' OR COLUMN_NAME IS NULL THEN
  IF new_references.GUEST_TICKETS_ALLOCATED < 0 OR new_references.GUEST_TICKETS_ALLOCATED > 999 THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF;

IF upper(Column_name) = 'GUEST_TICKETS_REQUESTED' OR COLUMN_NAME IS NULL THEN
  IF new_references.GUEST_TICKETS_REQUESTED < 0 OR new_references.GUEST_TICKETS_REQUESTED > 999 THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF;

IF upper(Column_name) = 'FEES_PAID_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.FEES_PAID_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;

IF upper(Column_name) = 'ACADEMIC_DRESS_RQRD_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.ACADEMIC_DRESS_RQRD_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;

IF upper(Column_name) = 'ACADEMIC_GOWN_SIZE' OR COLUMN_NAME IS NULL THEN
  IF new_references.ACADEMIC_GOWN_SIZE<> upper(NEW_REFERENCES.ACADEMIC_GOWN_SIZE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'ACADEMIC_HAT_SIZE' OR COLUMN_NAME IS NULL THEN
  IF new_references.ACADEMIC_HAT_SIZE<> upper(NEW_REFERENCES.ACADEMIC_HAT_SIZE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'AWARD_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.AWARD_CD<> upper(NEW_REFERENCES.AWARD_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'AWARD_COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.AWARD_COURSE_CD<> upper(NEW_REFERENCES.AWARD_COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GRADUAND_SEAT_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRADUAND_SEAT_NUMBER<> upper(NEW_REFERENCES.GRADUAND_SEAT_NUMBER) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GRD_CAL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CAL_TYPE<> upper(NEW_REFERENCES.GRD_CAL_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GUEST_SEATS' OR COLUMN_NAME IS NULL THEN
  IF new_references.GUEST_SEATS<> upper(NEW_REFERENCES.GUEST_SEATS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'HIST_WHO' OR COLUMN_NAME IS NULL THEN
  IF new_references.HIST_WHO<> upper(NEW_REFERENCES.HIST_WHO) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'NAME_ANNOUNCED' OR COLUMN_NAME IS NULL THEN
  IF new_references.NAME_ANNOUNCED<> upper(NEW_REFERENCES.NAME_ANNOUNCED) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'NAME_PRONUNCIATION' OR COLUMN_NAME IS NULL THEN
  IF new_references.NAME_PRONUNCIATION<> upper(NEW_REFERENCES.NAME_PRONUNCIATION) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SPECIAL_REQUIREMENTS' OR COLUMN_NAME IS NULL THEN
  IF new_references.SPECIAL_REQUIREMENTS<> upper(NEW_REFERENCES.SPECIAL_REQUIREMENTS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
 END Check_Constraints;

  FUNCTION Get_PK_For_Validation (
        x_GACH_ID IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRMN_HIST
      WHERE    GACH_ID = x_GACH_ID
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
         x_person_id IN NUMBER,
         x_create_dt IN DATE,
         x_grd_cal_type IN VARCHAR2,
         x_grd_ci_sequence_number IN NUMBER,
         x_ceremony_number IN NUMBER,
         x_award_course_cd IN VARCHAR2,
         x_award_crs_version_number IN NUMBER,
         x_award_cd IN VARCHAR2,
         x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRMN_HIST
      WHERE    person_id = x_person_id
	AND    create_dt = x_create_dt
	AND    grd_cal_type = x_grd_cal_type
	AND    grd_ci_sequence_number = x_grd_ci_sequence_number
	AND    ceremony_number = x_ceremony_number
	AND    award_course_cd = x_award_course_cd
	AND    award_crs_version_number = x_award_crs_version_number
	AND    award_cd = x_award_cd
	AND    hist_start_dt = x_hist_start_dt
	AND    (l_rowid is null or rowid <> l_rowid)
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

  PROCEDURE GET_FK_IGS_GR_GRADUAND (
    x_person_id IN NUMBER,
    x_create_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_AWD_CRMN_HIST
      WHERE    person_id = x_person_id
      AND      create_dt = x_create_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GACH_GR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_GRADUAND;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_GACH_ID in NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_us_group_number IN NUMBER DEFAULT NULL,
    x_order_in_presentation IN NUMBER DEFAULT NULL,
    x_graduand_seat_number IN VARCHAR2 DEFAULT NULL,
    x_name_pronunciation IN VARCHAR2 DEFAULT NULL,
    x_name_announced IN VARCHAR2 DEFAULT NULL,
    x_academic_dress_rqrd_ind IN VARCHAR2 DEFAULT NULL,
    x_academic_gown_size IN VARCHAR2 DEFAULT NULL,
    x_academic_hat_size IN VARCHAR2 DEFAULT NULL,
    x_guest_tickets_requested IN NUMBER DEFAULT NULL,
    x_guest_tickets_allocated IN NUMBER DEFAULT NULL,
    x_guest_seats IN VARCHAR2 DEFAULT NULL,
    x_fees_paid_ind IN VARCHAR2 DEFAULT NULL,
    x_special_requirements IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
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
      x_GACH_ID,
      x_person_id,
      x_create_dt,
      x_grd_cal_type,
      x_grd_ci_sequence_number,
      x_ceremony_number,
      x_award_course_cd,
      x_award_crs_version_number,
      x_award_cd,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_us_group_number,
      x_order_in_presentation,
      x_graduand_seat_number,
      x_name_pronunciation,
      x_name_announced,
      x_academic_dress_rqrd_ind,
      x_academic_gown_size,
      x_academic_hat_size,
      x_guest_tickets_requested,
      x_guest_tickets_allocated,
      x_guest_seats,
      x_fees_paid_ind,
      x_special_requirements,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
         NEW_REFERENCES.gach_id) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(NEW_REFERENCES.GACH_ID) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	check_uniqueness;
	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	check_uniqueness;
	check_constraints;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GACH_ID in out NOCOPY NUMBER,
  X_NAME_PRONUNCIATION in VARCHAR2,
  X_NAME_ANNOUNCED in VARCHAR2,
  X_ACADEMIC_DRESS_RQRD_IND in VARCHAR2,
  X_ACADEMIC_GOWN_SIZE in VARCHAR2,
  X_ACADEMIC_HAT_SIZE in VARCHAR2,
  X_GUEST_TICKETS_REQUESTED in NUMBER,
  X_GUEST_TICKETS_ALLOCATED in NUMBER,
  X_GUEST_SEATS in VARCHAR2,
  X_FEES_PAID_IND in VARCHAR2,
  X_SPECIAL_REQUIREMENTS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRADUAND_SEAT_NUMBER in VARCHAR2,
  X_HIST_WHO in NUMBER,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_PRESENTATION in NUMBER,
  X_HIST_END_DT in DATE,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_GR_AWD_CRMN_HIST
      where GACH_ID = X_GACH_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin

  SELECT IGS_GR_AWD_CRMN_HIST_GACH_ID_S.NEXTVAL INTO X_GACH_ID FROM DUAL;

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
    x_GACH_ID => X_GACH_ID,
    x_person_id => X_PERSON_ID,
    x_create_dt => X_CREATE_DT,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_us_group_number => X_US_GROUP_NUMBER,
    x_order_in_presentation => X_ORDER_IN_PRESENTATION,
    x_graduand_seat_number => X_GRADUAND_SEAT_NUMBER,
    x_name_pronunciation => X_NAME_PRONUNCIATION,
    x_name_announced => X_NAME_ANNOUNCED,
    x_academic_dress_rqrd_ind => X_ACADEMIC_DRESS_RQRD_IND,
    x_academic_gown_size => X_ACADEMIC_GOWN_SIZE,
    x_academic_hat_size => X_ACADEMIC_HAT_SIZE,
    x_guest_tickets_requested => X_GUEST_TICKETS_REQUESTED,
    x_guest_tickets_allocated => X_GUEST_TICKETS_ALLOCATED,
    x_guest_seats => X_GUEST_SEATS,
    x_fees_paid_ind => X_FEES_PAID_IND,
    x_special_requirements => X_SPECIAL_REQUIREMENTS,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_GR_AWD_CRMN_HIST (
    NAME_PRONUNCIATION,
    NAME_ANNOUNCED,
    ACADEMIC_DRESS_RQRD_IND,
    ACADEMIC_GOWN_SIZE,
    ACADEMIC_HAT_SIZE,
    GUEST_TICKETS_REQUESTED,
    GUEST_TICKETS_ALLOCATED,
    GUEST_SEATS,
    FEES_PAID_IND,
    SPECIAL_REQUIREMENTS,
    COMMENTS,
    GACH_ID,
    PERSON_ID,
    CREATE_DT,
    GRD_CAL_TYPE,
    GRADUAND_SEAT_NUMBER,
    HIST_WHO,
    US_GROUP_NUMBER,
    ORDER_IN_PRESENTATION,
    HIST_END_DT,
    GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER,
    AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER,
    AWARD_CD,
    HIST_START_DT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.NAME_PRONUNCIATION,
    NEW_REFERENCES.NAME_ANNOUNCED,
    NEW_REFERENCES.ACADEMIC_DRESS_RQRD_IND,
    NEW_REFERENCES.ACADEMIC_GOWN_SIZE,
    NEW_REFERENCES.ACADEMIC_HAT_SIZE,
    NEW_REFERENCES.GUEST_TICKETS_REQUESTED,
    NEW_REFERENCES.GUEST_TICKETS_ALLOCATED,
    NEW_REFERENCES.GUEST_SEATS,
    NEW_REFERENCES.FEES_PAID_IND,
    NEW_REFERENCES.SPECIAL_REQUIREMENTS,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.GACH_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.GRD_CAL_TYPE,
    NEW_REFERENCES.GRADUAND_SEAT_NUMBER,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.US_GROUP_NUMBER,
    NEW_REFERENCES.ORDER_IN_PRESENTATION,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.CEREMONY_NUMBER,
    NEW_REFERENCES.AWARD_COURSE_CD,
    NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    NEW_REFERENCES.AWARD_CD,
    NEW_REFERENCES.HIST_START_DT,
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
  X_ROWID in VARCHAR2,
  X_GACH_ID in NUMBER,
  X_NAME_PRONUNCIATION in VARCHAR2,
  X_NAME_ANNOUNCED in VARCHAR2,
  X_ACADEMIC_DRESS_RQRD_IND in VARCHAR2,
  X_ACADEMIC_GOWN_SIZE in VARCHAR2,
  X_ACADEMIC_HAT_SIZE in VARCHAR2,
  X_GUEST_TICKETS_REQUESTED in NUMBER,
  X_GUEST_TICKETS_ALLOCATED in NUMBER,
  X_GUEST_SEATS in VARCHAR2,
  X_FEES_PAID_IND in VARCHAR2,
  X_SPECIAL_REQUIREMENTS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRADUAND_SEAT_NUMBER in VARCHAR2,
  X_HIST_WHO in NUMBER,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_PRESENTATION in NUMBER,
  X_HIST_END_DT in DATE,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HIST_START_DT in DATE
) AS
  cursor c1 is select
      NAME_PRONUNCIATION,
      NAME_ANNOUNCED,
      ACADEMIC_DRESS_RQRD_IND,
      ACADEMIC_GOWN_SIZE,
      ACADEMIC_HAT_SIZE,
      GUEST_TICKETS_REQUESTED,
      GUEST_TICKETS_ALLOCATED,
      GUEST_SEATS,
      FEES_PAID_IND,
      SPECIAL_REQUIREMENTS,
      COMMENTS,
      PERSON_ID,
      CREATE_DT,
      GRD_CAL_TYPE,
      GRADUAND_SEAT_NUMBER,
      HIST_WHO,
      US_GROUP_NUMBER,
      ORDER_IN_PRESENTATION,
      HIST_END_DT,
      GRD_CI_SEQUENCE_NUMBER,
      CEREMONY_NUMBER,
      AWARD_COURSE_CD,
      AWARD_CRS_VERSION_NUMBER,
      AWARD_CD,
      HIST_START_DT
    from IGS_GR_AWD_CRMN_HIST
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

      if ( ((tlinfo.NAME_PRONUNCIATION = X_NAME_PRONUNCIATION)
           OR ((tlinfo.NAME_PRONUNCIATION is null)
               AND (X_NAME_PRONUNCIATION is null)))
      AND ((tlinfo.NAME_ANNOUNCED = X_NAME_ANNOUNCED)
           OR ((tlinfo.NAME_ANNOUNCED is null)
               AND (X_NAME_ANNOUNCED is null)))
      AND ((tlinfo.ACADEMIC_DRESS_RQRD_IND = X_ACADEMIC_DRESS_RQRD_IND)
           OR ((tlinfo.ACADEMIC_DRESS_RQRD_IND is null)
               AND (X_ACADEMIC_DRESS_RQRD_IND is null)))
      AND ((tlinfo.ACADEMIC_GOWN_SIZE = X_ACADEMIC_GOWN_SIZE)
           OR ((tlinfo.ACADEMIC_GOWN_SIZE is null)
               AND (X_ACADEMIC_GOWN_SIZE is null)))
      AND ((tlinfo.ACADEMIC_HAT_SIZE = X_ACADEMIC_HAT_SIZE)
           OR ((tlinfo.ACADEMIC_HAT_SIZE is null)
               AND (X_ACADEMIC_HAT_SIZE is null)))
      AND ((tlinfo.GUEST_TICKETS_REQUESTED = X_GUEST_TICKETS_REQUESTED)
           OR ((tlinfo.GUEST_TICKETS_REQUESTED is null)
               AND (X_GUEST_TICKETS_REQUESTED is null)))
      AND ((tlinfo.GUEST_TICKETS_ALLOCATED = X_GUEST_TICKETS_ALLOCATED)
           OR ((tlinfo.GUEST_TICKETS_ALLOCATED is null)
               AND (X_GUEST_TICKETS_ALLOCATED is null)))
      AND ((tlinfo.GUEST_SEATS = X_GUEST_SEATS)
           OR ((tlinfo.GUEST_SEATS is null)
               AND (X_GUEST_SEATS is null)))
      AND ((tlinfo.FEES_PAID_IND = X_FEES_PAID_IND)
           OR ((tlinfo.FEES_PAID_IND is null)
               AND (X_FEES_PAID_IND is null)))
      AND ((tlinfo.SPECIAL_REQUIREMENTS = X_SPECIAL_REQUIREMENTS)
           OR ((tlinfo.SPECIAL_REQUIREMENTS is null)
               AND (X_SPECIAL_REQUIREMENTS is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      AND (tlinfo.PERSON_ID = X_PERSON_ID)
      AND (tlinfo.CREATE_DT = X_CREATE_DT)
      AND (tlinfo.GRD_CAL_TYPE = X_GRD_CAL_TYPE)
      AND ((tlinfo.GRADUAND_SEAT_NUMBER = X_GRADUAND_SEAT_NUMBER)
           OR ((tlinfo.GRADUAND_SEAT_NUMBER is null)
               AND (X_GRADUAND_SEAT_NUMBER is null)))
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.US_GROUP_NUMBER = X_US_GROUP_NUMBER)
           OR ((tlinfo.US_GROUP_NUMBER is null)
               AND (X_US_GROUP_NUMBER is null)))
      AND ((tlinfo.ORDER_IN_PRESENTATION = X_ORDER_IN_PRESENTATION)
           OR ((tlinfo.ORDER_IN_PRESENTATION is null)
               AND (X_ORDER_IN_PRESENTATION is null)))
      AND (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER)
      AND (tlinfo.CEREMONY_NUMBER = X_CEREMONY_NUMBER)
      AND ((tlinfo.AWARD_COURSE_CD = X_AWARD_COURSE_CD)
           OR ((tlinfo.AWARD_COURSE_CD is null)
               AND (X_AWARD_COURSE_CD is null)))
      AND ((tlinfo.AWARD_CRS_VERSION_NUMBER = X_AWARD_CRS_VERSION_NUMBER)
           OR ((tlinfo.AWARD_CRS_VERSION_NUMBER is null)
               AND (X_AWARD_CRS_VERSION_NUMBER is null)))
      AND (tlinfo.AWARD_CD = X_AWARD_CD)
      AND (tlinfo.HIST_START_DT = X_HIST_START_DT)
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
  X_GACH_ID in NUMBER,
  X_NAME_PRONUNCIATION in VARCHAR2,
  X_NAME_ANNOUNCED in VARCHAR2,
  X_ACADEMIC_DRESS_RQRD_IND in VARCHAR2,
  X_ACADEMIC_GOWN_SIZE in VARCHAR2,
  X_ACADEMIC_HAT_SIZE in VARCHAR2,
  X_GUEST_TICKETS_REQUESTED in NUMBER,
  X_GUEST_TICKETS_ALLOCATED in NUMBER,
  X_GUEST_SEATS in VARCHAR2,
  X_FEES_PAID_IND in VARCHAR2,
  X_SPECIAL_REQUIREMENTS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRADUAND_SEAT_NUMBER in VARCHAR2,
  X_HIST_WHO in NUMBER,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_PRESENTATION in NUMBER,
  X_HIST_END_DT in DATE,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
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
    x_GACH_ID => X_GACH_ID,
    x_person_id => X_PERSON_ID,
    x_create_dt => X_CREATE_DT,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_ceremony_number => X_CEREMONY_NUMBER,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_us_group_number => X_US_GROUP_NUMBER,
    x_order_in_presentation => X_ORDER_IN_PRESENTATION,
    x_graduand_seat_number => X_GRADUAND_SEAT_NUMBER,
    x_name_pronunciation => X_NAME_PRONUNCIATION,
    x_name_announced => X_NAME_ANNOUNCED,
    x_academic_dress_rqrd_ind => X_ACADEMIC_DRESS_RQRD_IND,
    x_academic_gown_size => X_ACADEMIC_GOWN_SIZE,
    x_academic_hat_size => X_ACADEMIC_HAT_SIZE,
    x_guest_tickets_requested => X_GUEST_TICKETS_REQUESTED,
    x_guest_tickets_allocated => X_GUEST_TICKETS_ALLOCATED,
    x_guest_seats => X_GUEST_SEATS,
    x_fees_paid_ind => X_FEES_PAID_IND,
    x_special_requirements => X_SPECIAL_REQUIREMENTS,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_GR_AWD_CRMN_HIST set
    NAME_PRONUNCIATION = NEW_REFERENCES.NAME_PRONUNCIATION,
    NAME_ANNOUNCED = NEW_REFERENCES.NAME_ANNOUNCED,
    ACADEMIC_DRESS_RQRD_IND = NEW_REFERENCES.ACADEMIC_DRESS_RQRD_IND,
    ACADEMIC_GOWN_SIZE = NEW_REFERENCES.ACADEMIC_GOWN_SIZE,
    ACADEMIC_HAT_SIZE = NEW_REFERENCES.ACADEMIC_HAT_SIZE,
    GUEST_TICKETS_REQUESTED = NEW_REFERENCES.GUEST_TICKETS_REQUESTED,
    GUEST_TICKETS_ALLOCATED = NEW_REFERENCES.GUEST_TICKETS_ALLOCATED,
    GUEST_SEATS = NEW_REFERENCES.GUEST_SEATS,
    FEES_PAID_IND = NEW_REFERENCES.FEES_PAID_IND,
    SPECIAL_REQUIREMENTS = NEW_REFERENCES.SPECIAL_REQUIREMENTS,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    PERSON_ID = NEW_REFERENCES.PERSON_ID,
    CREATE_DT = NEW_REFERENCES.CREATE_DT,
    GRD_CAL_TYPE = NEW_REFERENCES.GRD_CAL_TYPE,
    GRADUAND_SEAT_NUMBER = NEW_REFERENCES.GRADUAND_SEAT_NUMBER,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    US_GROUP_NUMBER = NEW_REFERENCES.US_GROUP_NUMBER,
    ORDER_IN_PRESENTATION = NEW_REFERENCES.ORDER_IN_PRESENTATION,
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    GRD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    CEREMONY_NUMBER = NEW_REFERENCES.CEREMONY_NUMBER,
    AWARD_COURSE_CD = NEW_REFERENCES.AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER = NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    AWARD_CD = NEW_REFERENCES.AWARD_CD,
    HIST_START_DT = NEW_REFERENCES.HIST_START_DT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GACH_ID in out NOCOPY NUMBER,
  X_NAME_PRONUNCIATION in VARCHAR2,
  X_NAME_ANNOUNCED in VARCHAR2,
  X_ACADEMIC_DRESS_RQRD_IND in VARCHAR2,
  X_ACADEMIC_GOWN_SIZE in VARCHAR2,
  X_ACADEMIC_HAT_SIZE in VARCHAR2,
  X_GUEST_TICKETS_REQUESTED in NUMBER,
  X_GUEST_TICKETS_ALLOCATED in NUMBER,
  X_GUEST_SEATS in VARCHAR2,
  X_FEES_PAID_IND in VARCHAR2,
  X_SPECIAL_REQUIREMENTS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRADUAND_SEAT_NUMBER in VARCHAR2,
  X_HIST_WHO in NUMBER,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_PRESENTATION in NUMBER,
  X_HIST_END_DT in DATE,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_GR_AWD_CRMN_HIST
     where GACH_ID = X_GACH_ID
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GACH_ID,
     X_NAME_PRONUNCIATION,
     X_NAME_ANNOUNCED,
     X_ACADEMIC_DRESS_RQRD_IND,
     X_ACADEMIC_GOWN_SIZE,
     X_ACADEMIC_HAT_SIZE,
     X_GUEST_TICKETS_REQUESTED,
     X_GUEST_TICKETS_ALLOCATED,
     X_GUEST_SEATS,
     X_FEES_PAID_IND,
     X_SPECIAL_REQUIREMENTS,
     X_COMMENTS,
     X_PERSON_ID,
     X_CREATE_DT,
     X_GRD_CAL_TYPE,
     X_GRADUAND_SEAT_NUMBER,
     X_HIST_WHO,
     X_US_GROUP_NUMBER,
     X_ORDER_IN_PRESENTATION,
     X_HIST_END_DT,
     X_GRD_CI_SEQUENCE_NUMBER,
     X_CEREMONY_NUMBER,
     X_AWARD_COURSE_CD,
     X_AWARD_CRS_VERSION_NUMBER,
     X_AWARD_CD,
     X_HIST_START_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_GACH_ID,
   X_NAME_PRONUNCIATION,
   X_NAME_ANNOUNCED,
   X_ACADEMIC_DRESS_RQRD_IND,
   X_ACADEMIC_GOWN_SIZE,
   X_ACADEMIC_HAT_SIZE,
   X_GUEST_TICKETS_REQUESTED,
   X_GUEST_TICKETS_ALLOCATED,
   X_GUEST_SEATS,
   X_FEES_PAID_IND,
   X_SPECIAL_REQUIREMENTS,
   X_COMMENTS,
   X_PERSON_ID,
   X_CREATE_DT,
   X_GRD_CAL_TYPE,
   X_GRADUAND_SEAT_NUMBER,
   X_HIST_WHO,
   X_US_GROUP_NUMBER,
   X_ORDER_IN_PRESENTATION,
   X_HIST_END_DT,
   X_GRD_CI_SEQUENCE_NUMBER,
   X_CEREMONY_NUMBER,
   X_AWARD_COURSE_CD,
   X_AWARD_CRS_VERSION_NUMBER,
   X_AWARD_CD,
   X_HIST_START_DT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  delete from IGS_GR_AWD_CRMN_HIST
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_GR_AWD_CRMN_HIST_PKG;

/
