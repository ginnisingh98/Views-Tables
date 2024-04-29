--------------------------------------------------------
--  DDL for Package Body IGS_AS_SU_SETATMPT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SU_SETATMPT_H_PKG" AS
/* $Header: IGSDI28B.pls 115.7 2002/11/28 23:17:56 nsidana ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_AS_SU_SETATMPT_H_ALL%RowType;
  new_references IGS_AS_SU_SETATMPT_H_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_selection_dt IN DATE DEFAULT NULL,
    x_student_confirmed_ind IN VARCHAR2 DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_parent_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_parent_sequence_number IN NUMBER DEFAULT NULL,
    x_primary_set_ind IN VARCHAR2 DEFAULT NULL,
    x_voluntary_end_ind IN VARCHAR2 DEFAULT NULL,
    x_authorised_person_id IN NUMBER DEFAULT NULL,
    x_authorised_on IN DATE DEFAULT NULL,
    x_override_title IN VARCHAR2 DEFAULT NULL,
    x_rqrmnts_complete_ind IN VARCHAR2 DEFAULT NULL,
    x_rqrmnts_complete_dt IN DATE DEFAULT NULL,
    x_s_completed_source_type IN VARCHAR2 DEFAULT NULL,
    X_CATALOG_CAL_TYPE in VARCHAR2 DEFAULT NULL,
    X_CATALOG_SEQ_NUM  in NUMBER  DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_SU_SETATMPT_H_ALL
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
    new_references.org_id := x_org_id;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.us_version_number := x_us_version_number;
    new_references.selection_dt := x_selection_dt;
    new_references.student_confirmed_ind := x_student_confirmed_ind;
    new_references.end_dt := x_end_dt;
    new_references.parent_unit_set_cd := x_parent_unit_set_cd;
    new_references.parent_sequence_number := x_parent_sequence_number;
    new_references.primary_set_ind := x_primary_set_ind;
    new_references.voluntary_end_ind := x_voluntary_end_ind;
    new_references.authorised_person_id := x_authorised_person_id;
    new_references.authorised_on := x_authorised_on;
    new_references.override_title := x_override_title;
    new_references.rqrmnts_complete_ind := x_rqrmnts_complete_ind;
    new_references.rqrmnts_complete_dt := x_rqrmnts_complete_dt;
    new_references.s_completed_source_type := x_s_completed_source_type;
    new_references.CATALOG_CAL_TYPE := X_CATALOG_CAL_TYPE;
    new_references.CATALOG_SEQ_NUM  := X_CATALOG_SEQ_NUM;
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
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_SU_SETATMPT_H_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      unit_set_cd = x_unit_set_cd
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
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_selection_dt IN DATE DEFAULT NULL,
    x_student_confirmed_ind IN VARCHAR2 DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_parent_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_parent_sequence_number IN NUMBER DEFAULT NULL,
    x_primary_set_ind IN VARCHAR2 DEFAULT NULL,
    x_voluntary_end_ind IN VARCHAR2 DEFAULT NULL,
    x_authorised_person_id IN NUMBER DEFAULT NULL,
    x_authorised_on IN DATE DEFAULT NULL,
    x_override_title IN VARCHAR2 DEFAULT NULL,
    x_rqrmnts_complete_ind IN VARCHAR2 DEFAULT NULL,
    x_rqrmnts_complete_dt IN DATE DEFAULT NULL,
    x_s_completed_source_type IN VARCHAR2 DEFAULT NULL,
    X_CATALOG_CAL_TYPE in VARCHAR2 DEFAULT NULL,
    X_CATALOG_SEQ_NUM  in NUMBER  DEFAULT NULL,
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
      x_org_id,
      x_person_id,
      x_course_cd,
      x_unit_set_cd,
      x_sequence_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_us_version_number,
      x_selection_dt,
      x_student_confirmed_ind,
      x_end_dt,
      x_parent_unit_set_cd,
      x_parent_sequence_number,
      x_primary_set_ind,
      x_voluntary_end_ind,
      x_authorised_person_id,
      x_authorised_on,
      x_override_title,
      x_rqrmnts_complete_ind,
      x_rqrmnts_complete_dt,
      x_s_completed_source_type,
      X_CATALOG_CAL_TYPE ,
      X_CATALOG_SEQ_NUM ,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      	IF  Get_PK_For_Validation (
	         NEW_REFERENCES.person_id ,
    NEW_REFERENCES.course_cd ,
    NEW_REFERENCES.unit_set_cd,
    NEW_REFERENCES.sequence_number,
    NEW_REFERENCES.hist_start_dt
) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;
	     Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

      Check_Constraints;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation ( NEW_REFERENCES.person_id ,
    NEW_REFERENCES.course_cd ,
    NEW_REFERENCES.unit_set_cd,
    NEW_REFERENCES.sequence_number,
    NEW_REFERENCES.hist_start_dt ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;
	     Check_Constraints;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	      Check_Constraints;

    END IF;
  END Before_DML;

--
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_US_VERSION_NUMBER in NUMBER,
  X_SELECTION_DT in DATE,
  X_STUDENT_CONFIRMED_IND in VARCHAR2,
  X_END_DT in DATE,
  X_PARENT_UNIT_SET_CD in VARCHAR2,
  X_PARENT_SEQUENCE_NUMBER in NUMBER,
  X_PRIMARY_SET_IND in VARCHAR2,
  X_VOLUNTARY_END_IND in VARCHAR2,
  X_AUTHORISED_PERSON_ID in NUMBER,
  X_AUTHORISED_ON in DATE,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_CATALOG_CAL_TYPE in VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM  in NUMBER DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_SU_SETATMPT_H_ALL
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and UNIT_SET_CD = X_UNIT_SET_CD
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
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
--
  Before_DML(
   p_action=>'INSERT',
   x_rowid=>X_ROWID,
   x_org_id=> igs_ge_gen_003.get_org_id,
   x_authorised_on=>X_AUTHORISED_ON,
   x_authorised_person_id=>X_AUTHORISED_PERSON_ID,
   x_course_cd=>X_COURSE_CD,
   x_end_dt=>X_END_DT,
   x_hist_end_dt=>X_HIST_END_DT,
   x_hist_start_dt=>X_HIST_START_DT,
   x_hist_who=>X_HIST_WHO,
   x_override_title=>X_OVERRIDE_TITLE,
   x_parent_sequence_number=>X_PARENT_SEQUENCE_NUMBER,
   x_parent_unit_set_cd=>X_PARENT_UNIT_SET_CD,
   x_person_id=>X_PERSON_ID,
   x_primary_set_ind=>X_PRIMARY_SET_IND,
   x_rqrmnts_complete_dt=>X_RQRMNTS_COMPLETE_DT,
   x_rqrmnts_complete_ind=>X_RQRMNTS_COMPLETE_IND,
   x_s_completed_source_type=>X_S_COMPLETED_SOURCE_TYPE,
   X_CATALOG_CAL_TYPE => X_CATALOG_CAL_TYPE,
   X_CATALOG_SEQ_NUM => X_CATALOG_SEQ_NUM,
   x_selection_dt=>X_SELECTION_DT,
   x_sequence_number=>X_SEQUENCE_NUMBER,
   x_student_confirmed_ind=>X_STUDENT_CONFIRMED_IND,
   x_unit_set_cd=>X_UNIT_SET_CD,
   x_us_version_number=>X_US_VERSION_NUMBER,
   x_voluntary_end_ind=>X_VOLUNTARY_END_IND,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
--
  insert into IGS_AS_SU_SETATMPT_H_ALL (
    ORG_ID,
    PERSON_ID,
    COURSE_CD,
    UNIT_SET_CD,
    SEQUENCE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    US_VERSION_NUMBER,
    SELECTION_DT,
    STUDENT_CONFIRMED_IND,
    END_DT,
    PARENT_UNIT_SET_CD,
    PARENT_SEQUENCE_NUMBER,
    PRIMARY_SET_IND,
    VOLUNTARY_END_IND,
    AUTHORISED_PERSON_ID,
    AUTHORISED_ON,
    OVERRIDE_TITLE,
    RQRMNTS_COMPLETE_IND,
    RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE,
    CATALOG_CAL_TYPE,
    CATALOG_SEQ_NUM,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.US_VERSION_NUMBER,
    NEW_REFERENCES.SELECTION_DT,
    NEW_REFERENCES.STUDENT_CONFIRMED_IND,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.PARENT_UNIT_SET_CD,
    NEW_REFERENCES.PARENT_SEQUENCE_NUMBER,
    NEW_REFERENCES.PRIMARY_SET_IND,
    NEW_REFERENCES.VOLUNTARY_END_IND,
    NEW_REFERENCES.AUTHORISED_PERSON_ID,
    NEW_REFERENCES.AUTHORISED_ON,
    NEW_REFERENCES.OVERRIDE_TITLE,
    NEW_REFERENCES.RQRMNTS_COMPLETE_IND,
    NEW_REFERENCES.RQRMNTS_COMPLETE_DT,
    NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    NEW_REFERENCES.CATALOG_CAL_TYPE,
    NEW_REFERENCES.CATALOG_SEQ_NUM,
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_US_VERSION_NUMBER in NUMBER,
  X_SELECTION_DT in DATE,
  X_STUDENT_CONFIRMED_IND in VARCHAR2,
  X_END_DT in DATE,
  X_PARENT_UNIT_SET_CD in VARCHAR2,
  X_PARENT_SEQUENCE_NUMBER in NUMBER,
  X_PRIMARY_SET_IND in VARCHAR2,
  X_VOLUNTARY_END_IND in VARCHAR2,
  X_AUTHORISED_PERSON_ID in NUMBER,
  X_AUTHORISED_ON in DATE,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_CATALOG_CAL_TYPE in VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM in NUMBER DEFAULT NULL
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      US_VERSION_NUMBER,
      SELECTION_DT,
      STUDENT_CONFIRMED_IND,
      END_DT,
      PARENT_UNIT_SET_CD,
      PARENT_SEQUENCE_NUMBER,
      PRIMARY_SET_IND,
      VOLUNTARY_END_IND,
      AUTHORISED_PERSON_ID,
      AUTHORISED_ON,
      OVERRIDE_TITLE,
      RQRMNTS_COMPLETE_IND,
      RQRMNTS_COMPLETE_DT,
      S_COMPLETED_SOURCE_TYPE,
      CATALOG_CAL_TYPE ,
      CATALOG_SEQ_NUM
    from IGS_AS_SU_SETATMPT_H_ALL
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
  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.US_VERSION_NUMBER = X_US_VERSION_NUMBER)
           OR ((tlinfo.US_VERSION_NUMBER is null)
               AND (X_US_VERSION_NUMBER is null)))
      AND ((tlinfo.SELECTION_DT = X_SELECTION_DT)
           OR ((tlinfo.SELECTION_DT is null)
               AND (X_SELECTION_DT is null)))
      AND ((tlinfo.STUDENT_CONFIRMED_IND = X_STUDENT_CONFIRMED_IND)
           OR ((tlinfo.STUDENT_CONFIRMED_IND is null)
               AND (X_STUDENT_CONFIRMED_IND is null)))
      AND ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND ((tlinfo.PARENT_UNIT_SET_CD = X_PARENT_UNIT_SET_CD)
           OR ((tlinfo.PARENT_UNIT_SET_CD is null)
               AND (X_PARENT_UNIT_SET_CD is null)))
      AND ((tlinfo.PARENT_SEQUENCE_NUMBER = X_PARENT_SEQUENCE_NUMBER)
           OR ((tlinfo.PARENT_SEQUENCE_NUMBER is null)
               AND (X_PARENT_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.PRIMARY_SET_IND = X_PRIMARY_SET_IND)
           OR ((tlinfo.PRIMARY_SET_IND is null)
               AND (X_PRIMARY_SET_IND is null)))
      AND ((tlinfo.VOLUNTARY_END_IND = X_VOLUNTARY_END_IND)
           OR ((tlinfo.VOLUNTARY_END_IND is null)
               AND (X_VOLUNTARY_END_IND is null)))
      AND ((tlinfo.AUTHORISED_PERSON_ID = X_AUTHORISED_PERSON_ID)
           OR ((tlinfo.AUTHORISED_PERSON_ID is null)
               AND (X_AUTHORISED_PERSON_ID is null)))
      AND ((tlinfo.AUTHORISED_ON = X_AUTHORISED_ON)
           OR ((tlinfo.AUTHORISED_ON is null)
               AND (X_AUTHORISED_ON is null)))
      AND ((tlinfo.OVERRIDE_TITLE = X_OVERRIDE_TITLE)
           OR ((tlinfo.OVERRIDE_TITLE is null)
               AND (X_OVERRIDE_TITLE is null)))
      AND ((tlinfo.RQRMNTS_COMPLETE_IND = X_RQRMNTS_COMPLETE_IND)
           OR ((tlinfo.RQRMNTS_COMPLETE_IND is null)
               AND (X_RQRMNTS_COMPLETE_IND is null)))
      AND ((tlinfo.RQRMNTS_COMPLETE_DT = X_RQRMNTS_COMPLETE_DT)
           OR ((tlinfo.RQRMNTS_COMPLETE_DT is null)
               AND (X_RQRMNTS_COMPLETE_DT is null)))
      AND ((tlinfo.S_COMPLETED_SOURCE_TYPE = X_S_COMPLETED_SOURCE_TYPE)
           OR ((tlinfo.S_COMPLETED_SOURCE_TYPE is null)
               AND (X_S_COMPLETED_SOURCE_TYPE is null)))
      AND ((tlinfo.CATALOG_CAL_TYPE = X_CATALOG_CAL_TYPE)
           OR ((tlinfo.CATALOG_CAL_TYPE is null)
                 AND (X_CATALOG_CAL_TYPE is null)))
      AND ((tlinfo.CATALOG_SEQ_NUM = X_CATALOG_SEQ_NUM)
           OR ((tlinfo.CATALOG_SEQ_NUM is null)
               AND (X_CATALOG_SEQ_NUM is null)))
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_US_VERSION_NUMBER in NUMBER,
  X_SELECTION_DT in DATE,
  X_STUDENT_CONFIRMED_IND in VARCHAR2,
  X_END_DT in DATE,
  X_PARENT_UNIT_SET_CD in VARCHAR2,
  X_PARENT_SEQUENCE_NUMBER in NUMBER,
  X_PRIMARY_SET_IND in VARCHAR2,
  X_VOLUNTARY_END_IND in VARCHAR2,
  X_AUTHORISED_PERSON_ID in NUMBER,
  X_AUTHORISED_ON in DATE,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_CATALOG_CAL_TYPE in VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM in NUMBER DEFAULT NULL,
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
--
  Before_DML(
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_authorised_on=>X_AUTHORISED_ON,
   x_authorised_person_id=>X_AUTHORISED_PERSON_ID,
   x_course_cd=>X_COURSE_CD,
   x_end_dt=>X_END_DT,
   x_hist_end_dt=>X_HIST_END_DT,
   x_hist_start_dt=>X_HIST_START_DT,
   x_hist_who=>X_HIST_WHO,
   x_override_title=>X_OVERRIDE_TITLE,
   x_parent_sequence_number=>X_PARENT_SEQUENCE_NUMBER,
   x_parent_unit_set_cd=>X_PARENT_UNIT_SET_CD,
   x_person_id=>X_PERSON_ID,
   x_primary_set_ind=>X_PRIMARY_SET_IND,
   x_rqrmnts_complete_dt=>X_RQRMNTS_COMPLETE_DT,
   x_rqrmnts_complete_ind=>X_RQRMNTS_COMPLETE_IND,
   x_s_completed_source_type=>X_S_COMPLETED_SOURCE_TYPE,
   X_CATALOG_CAL_TYPE =>X_CATALOG_CAL_TYPE,
   X_CATALOG_SEQ_NUM =>X_CATALOG_SEQ_NUM,
   x_selection_dt=>X_SELECTION_DT,
   x_sequence_number=>X_SEQUENCE_NUMBER,
   x_student_confirmed_ind=>X_STUDENT_CONFIRMED_IND,
   x_unit_set_cd=>X_UNIT_SET_CD,
   x_us_version_number=>X_US_VERSION_NUMBER,
   x_voluntary_end_ind=>X_VOLUNTARY_END_IND,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
--
  update IGS_AS_SU_SETATMPT_H_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    US_VERSION_NUMBER = NEW_REFERENCES.US_VERSION_NUMBER,
    SELECTION_DT = NEW_REFERENCES.SELECTION_DT,
    STUDENT_CONFIRMED_IND = NEW_REFERENCES.STUDENT_CONFIRMED_IND,
    END_DT = NEW_REFERENCES.END_DT,
    PARENT_UNIT_SET_CD = NEW_REFERENCES.PARENT_UNIT_SET_CD,
    PARENT_SEQUENCE_NUMBER = NEW_REFERENCES.PARENT_SEQUENCE_NUMBER,
    PRIMARY_SET_IND = NEW_REFERENCES.PRIMARY_SET_IND,
    VOLUNTARY_END_IND = NEW_REFERENCES.VOLUNTARY_END_IND,
    AUTHORISED_PERSON_ID = NEW_REFERENCES.AUTHORISED_PERSON_ID,
    AUTHORISED_ON = NEW_REFERENCES.AUTHORISED_ON,
    OVERRIDE_TITLE = NEW_REFERENCES.OVERRIDE_TITLE,
    RQRMNTS_COMPLETE_IND = NEW_REFERENCES.RQRMNTS_COMPLETE_IND,
    RQRMNTS_COMPLETE_DT = NEW_REFERENCES.RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE = NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    CATALOG_CAL_TYPE =NEW_REFERENCES.CATALOG_CAL_TYPE,
    CATALOG_SEQ_NUM =NEW_REFERENCES.CATALOG_SEQ_NUM,
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
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_US_VERSION_NUMBER in NUMBER,
  X_SELECTION_DT in DATE,
  X_STUDENT_CONFIRMED_IND in VARCHAR2,
  X_END_DT in DATE,
  X_PARENT_UNIT_SET_CD in VARCHAR2,
  X_PARENT_SEQUENCE_NUMBER in NUMBER,
  X_PRIMARY_SET_IND in VARCHAR2,
  X_VOLUNTARY_END_IND in VARCHAR2,
  X_AUTHORISED_PERSON_ID in NUMBER,
  X_AUTHORISED_ON in DATE,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_CATALOG_CAL_TYPE in VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM in NUMBER DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_SU_SETATMPT_H_ALL
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and UNIT_SET_CD = X_UNIT_SET_CD
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
     X_ORG_ID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_UNIT_SET_CD,
     X_SEQUENCE_NUMBER,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_US_VERSION_NUMBER,
     X_SELECTION_DT,
     X_STUDENT_CONFIRMED_IND,
     X_END_DT,
     X_PARENT_UNIT_SET_CD,
     X_PARENT_SEQUENCE_NUMBER,
     X_PRIMARY_SET_IND,
     X_VOLUNTARY_END_IND,
     X_AUTHORISED_PERSON_ID,
     X_AUTHORISED_ON,
     X_OVERRIDE_TITLE,
     X_RQRMNTS_COMPLETE_IND,
     X_RQRMNTS_COMPLETE_DT,
     X_S_COMPLETED_SOURCE_TYPE,
     X_CATALOG_CAL_TYPE ,
     X_CATALOG_SEQ_NUM ,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_UNIT_SET_CD,
   X_SEQUENCE_NUMBER,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_US_VERSION_NUMBER,
   X_SELECTION_DT,
   X_STUDENT_CONFIRMED_IND,
   X_END_DT,
   X_PARENT_UNIT_SET_CD,
   X_PARENT_SEQUENCE_NUMBER,
   X_PRIMARY_SET_IND,
   X_VOLUNTARY_END_IND,
   X_AUTHORISED_PERSON_ID,
   X_AUTHORISED_ON,
   X_OVERRIDE_TITLE,
   X_RQRMNTS_COMPLETE_IND,
   X_RQRMNTS_COMPLETE_DT,
   X_S_COMPLETED_SOURCE_TYPE,
   X_CATALOG_CAL_TYPE ,
   X_CATALOG_SEQ_NUM ,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) AS
begin
--
Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
--
  delete from IGS_AS_SU_SETATMPT_H_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) theN
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
	ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' then
	    new_references.SEQUENCE_NUMBER := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'STUDENT_CONFIRMED_IND' then
	    new_references.STUDENT_CONFIRMED_IND := column_value;
	ELSIF upper(Column_name) = 'PARENT_SEQUENCE_NUMBER' then
	    new_references.PARENT_SEQUENCE_NUMBER := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'PRIMARY_SET_IND' then
	    new_references.PRIMARY_SET_IND := column_value;
	ELSIF upper(Column_name) = 'OVERRIDE_TITLE' then
	    new_references.OVERRIDE_TITLE := column_value;
	ELSIF upper(Column_name) = 'PARENT_UNIT_SET_CD' then
	    new_references.PARENT_UNIT_SET_CD := column_value;
	ELSIF upper(Column_name) = 'PRIMARY_SET_IND' then
	    new_references.PRIMARY_SET_IND := column_value;
	ELSIF upper(Column_name) = 'RQRMNTS_COMPLETE_IND' then
	    new_references.RQRMNTS_COMPLETE_IND := column_value;
	ELSIF upper(Column_name) = 'STUDENT_CONFIRMED_IND' then
	    new_references.STUDENT_CONFIRMED_IND := column_value;
	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.COURSE_CD:= column_value;
	ELSIF upper(Column_name) = 'UNIT_SET_CD' then
	    new_references.UNIT_SET_CD := column_value;
	ELSIF upper(Column_name) = 'S_COMPLETED_SOURCE_TYPE' then
	    new_references.S_COMPLETED_SOURCE_TYPE := column_value;
	ELSIF upper(Column_name) = 'VOLUNTARY_END_IND' then
	    new_references.VOLUNTARY_END_IND := column_value;
	ELSIF upper(Column_name) = 'VOLUNTARY_END_IND' then
	    new_references.VOLUNTARY_END_IND := column_value;
	ELSIF upper(Column_name) = 'AUTHORISED_PERSON_ID' then
	    new_references.AUTHORISED_PERSON_ID := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_name) = 'RQRMNTS_COMPLETE_IND' then
	    new_references.RQRMNTS_COMPLETE_IND := column_value;
	ELSIF upper(Column_name) = 'S_COMPLETED_SOURCE_TYPE' then
	    new_references.S_COMPLETED_SOURCE_TYPE := column_value;
	ELSIF upper(Column_name) = 'CATALOG_CAL_TYPE' then
	    new_references.CATALOG_CAL_TYPE:= column_value;
        ELSIF upper(Column_name) = 'CATALOG_SEQ_NUM' then
	    new_references.CATALOG_SEQ_NUM := column_value;
        END IF;
            IF upper(column_name) = 'SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.SEQUENCE_NUMBER < 1 OR new_references.SEQUENCE_NUMBER > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'STUDENT_CONFIRMED_IND' OR
     column_name is null Then
     IF new_references.STUDENT_CONFIRMED_IND NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'PARENT_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.PARENT_SEQUENCE_NUMBER < 1 OR new_references.PARENT_SEQUENCE_NUMBER > 999999  Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'PRIMARY_SET_IND' OR
     column_name is null Then
     IF new_references.PRIMARY_SET_IND NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'OVERRIDE_TITLE' OR
     column_name is null Then
     IF new_references.OVERRIDE_TITLE <> UPPER(new_references.OVERRIDE_TITLE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'PARENT_UNIT_SET_CD' OR
     column_name is null Then
     IF new_references.PARENT_UNIT_SET_CD <> UPPER(new_references.PARENT_UNIT_SET_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'PRIMARY_SET_IND' OR
     column_name is null Then
     IF new_references.PRIMARY_SET_IND<> UPPER(new_references.PRIMARY_SET_IND) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'RQRMNTS_COMPLETE_IND' OR
     column_name is null Then
     IF new_references.RQRMNTS_COMPLETE_IND <> UPPER(new_references.RQRMNTS_COMPLETE_IND) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'STUDENT_CONFIRMED_IND' OR
     column_name is null Then
     IF new_references.STUDENT_CONFIRMED_IND <> UPPER(new_references.STUDENT_CONFIRMED_IND) Then
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
IF upper(column_name) = 'UNIT_SET_CD' OR
     column_name is null Then
     IF new_references.UNIT_SET_CD <> UPPER(new_references.UNIT_SET_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'S_COMPLETED_SOURCE_TYPE' OR
     column_name is null Then
     IF new_references.S_COMPLETED_SOURCE_TYPE <> UPPER(new_references.S_COMPLETED_SOURCE_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'VOLUNTARY_END_IND' OR
     column_name is null Then
     IF new_references.VOLUNTARY_END_IND <> UPPER(new_references.VOLUNTARY_END_IND) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'VOLUNTARY_END_IND' OR
     column_name is null Then
     IF new_references.VOLUNTARY_END_IND NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;

                   END IF;
              END IF;
IF upper(column_name) = 'AUTHORISED_PERSON_ID' OR
     column_name is null Then
     IF new_references.AUTHORISED_PERSON_ID < 0 OR  new_references.AUTHORISED_PERSON_ID > 9999999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'RQRMNTS_COMPLETE_IND' OR
     column_name is null Then
     IF new_references.RQRMNTS_COMPLETE_IND NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'S_COMPLETED_SOURCE_TYPE' OR
     column_name is null Then
     IF new_references.S_COMPLETED_SOURCE_TYPE NOT IN ('SYSTEM','MANUAL') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
	END Check_Constraints;
end IGS_AS_SU_SETATMPT_H_PKG;

/
