--------------------------------------------------------
--  DDL for Package Body IGS_RE_THS_EXAM_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_THS_EXAM_HIST_PKG" as
/* $Header: IGSRI19B.pls 115.5 2002/11/29 03:36:43 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RE_THS_EXAM_HIST_ALL%RowType;
  new_references IGS_RE_THS_EXAM_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_the_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_submission_dt IN DATE DEFAULT NULL,
    x_thesis_exam_type IN VARCHAR2 DEFAULT NULL,
    x_thesis_panel_type IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_THS_EXAM_HIST_ALL
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
    new_references.ca_sequence_number := x_ca_sequence_number;
    new_references.the_sequence_number := x_the_sequence_number;
    new_references.creation_dt := x_creation_dt;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.submission_dt := x_submission_dt;
    new_references.thesis_exam_type := x_thesis_exam_type;
    new_references.thesis_panel_type := x_thesis_panel_type;
    new_references.tracking_id := x_tracking_id;
    new_references.thesis_result_cd := x_thesis_result_cd;
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
 ELSIF upper(Column_name) = 'CA_SEQUENCE_NUMBER' THEN
   new_references.CA_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'THE_SEQUENCE_NUMBER' THEN
   new_references.THE_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'HIST_WHO' THEN
   new_references.HIST_WHO := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'THESIS_EXAM_TYPE' THEN
   new_references.THESIS_EXAM_TYPE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'THESIS_PANEL_TYPE' THEN
   new_references.THESIS_PANEL_TYPE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'THESIS_RESULT_CD' THEN
   new_references.THESIS_RESULT_CD := COLUMN_VALUE ;
 END IF;

  IF upper(column_name) = 'CA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.CA_SEQUENCE_NUMBER < 1 OR new_references.CA_SEQUENCE_NUMBER > 999999 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'THE_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.THE_SEQUENCE_NUMBER < 1 OR new_references.THE_SEQUENCE_NUMBER > 999999 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;

  IF upper(column_name) = 'THESIS_EXAM_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.THESIS_EXAM_TYPE <> upper(NEW_REFERENCES.THESIS_EXAM_TYPE) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;

  IF upper(column_name) = 'THESIS_PANEL_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.THESIS_PANEL_TYPE <> upper(NEW_REFERENCES.THESIS_PANEL_TYPE) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;

  IF upper(column_name) = 'THESIS_RESULT_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.THESIS_RESULT_CD <> upper(NEW_REFERENCES.THESIS_RESULT_CD) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
 END Check_Constraints ;


  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_the_sequence_number IN NUMBER,
    x_creation_dt IN DATE,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN
  AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THS_EXAM_HIST_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      the_sequence_number = x_the_sequence_number
      AND      creation_dt = x_creation_dt
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
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_the_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_submission_dt IN DATE DEFAULT NULL,
    x_thesis_exam_type IN VARCHAR2 DEFAULT NULL,
    x_thesis_panel_type IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
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
      x_ca_sequence_number,
      x_the_sequence_number,
      x_creation_dt,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_submission_dt,
      x_thesis_exam_type,
      x_thesis_panel_type,
      x_tracking_id,
      x_thesis_result_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	 IF Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.ca_sequence_number,
	    new_references.the_sequence_number ,
	    new_references.creation_dt ,
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
	    new_references.ca_sequence_number,
	    new_references.the_sequence_number ,
	    new_references.creation_dt ,
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
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
    cursor C is select ROWID from IGS_RE_THS_EXAM_HIST_ALL
      where PERSON_ID = X_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
      and THE_SEQUENCE_NUMBER = X_THE_SEQUENCE_NUMBER
      and CREATION_DT = X_CREATION_DT
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
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_the_sequence_number => X_THE_SEQUENCE_NUMBER,
    x_creation_dt => X_CREATION_DT,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_submission_dt => X_SUBMISSION_DT,
    x_thesis_exam_type => X_THESIS_EXAM_TYPE,
    x_thesis_panel_type => X_THESIS_PANEL_TYPE,
    x_tracking_id => X_TRACKING_ID,
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
 );
  insert into IGS_RE_THS_EXAM_HIST_ALL (
    PERSON_ID,
    CA_SEQUENCE_NUMBER,
    THE_SEQUENCE_NUMBER,
    CREATION_DT,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    SUBMISSION_DT,
    THESIS_EXAM_TYPE,
    THESIS_PANEL_TYPE,
    TRACKING_ID,
    THESIS_RESULT_CD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.CA_SEQUENCE_NUMBER,
    NEW_REFERENCES.THE_SEQUENCE_NUMBER,
    NEW_REFERENCES.CREATION_DT,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.SUBMISSION_DT,
    NEW_REFERENCES.THESIS_EXAM_TYPE,
    NEW_REFERENCES.THESIS_PANEL_TYPE,
    NEW_REFERENCES.TRACKING_ID,
    NEW_REFERENCES.THESIS_RESULT_CD,
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
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2
) as
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      SUBMISSION_DT,
      THESIS_EXAM_TYPE,
      THESIS_PANEL_TYPE,
      TRACKING_ID,
      THESIS_RESULT_CD
    from IGS_RE_THS_EXAM_HIST_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1 ;
  fetch c1 into tlinfo ;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.SUBMISSION_DT = X_SUBMISSION_DT)
           OR ((tlinfo.SUBMISSION_DT is null)
               AND (X_SUBMISSION_DT is null)))
      AND ((tlinfo.THESIS_EXAM_TYPE = X_THESIS_EXAM_TYPE)
           OR ((tlinfo.THESIS_EXAM_TYPE is null)
               AND (X_THESIS_EXAM_TYPE is null)))
      AND ((tlinfo.THESIS_PANEL_TYPE = X_THESIS_PANEL_TYPE)
           OR ((tlinfo.THESIS_PANEL_TYPE is null)
               AND (X_THESIS_PANEL_TYPE is null)))
      AND ((tlinfo.TRACKING_ID = X_TRACKING_ID)
           OR ((tlinfo.TRACKING_ID is null)
               AND (X_TRACKING_ID is null)))
      AND ((tlinfo.THESIS_RESULT_CD = X_THESIS_RESULT_CD)
           OR ((tlinfo.THESIS_RESULT_CD is null)
               AND (X_THESIS_RESULT_CD is null)))
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
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2,
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
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_the_sequence_number => X_THE_SEQUENCE_NUMBER,
    x_creation_dt => X_CREATION_DT,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_submission_dt => X_SUBMISSION_DT,
    x_thesis_exam_type => X_THESIS_EXAM_TYPE,
    x_thesis_panel_type => X_THESIS_PANEL_TYPE,
    x_tracking_id => X_TRACKING_ID,
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  update IGS_RE_THS_EXAM_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    SUBMISSION_DT = NEW_REFERENCES.SUBMISSION_DT,
    THESIS_EXAM_TYPE = NEW_REFERENCES.THESIS_EXAM_TYPE,
    THESIS_PANEL_TYPE = NEW_REFERENCES.THESIS_PANEL_TYPE,
    TRACKING_ID = NEW_REFERENCES.TRACKING_ID,
    THESIS_RESULT_CD = NEW_REFERENCES.THESIS_RESULT_CD,
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
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_THS_EXAM_HIST_ALL
     where PERSON_ID = X_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
     and THE_SEQUENCE_NUMBER = X_THE_SEQUENCE_NUMBER
     and CREATION_DT = X_CREATION_DT
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
     X_CA_SEQUENCE_NUMBER,
     X_THE_SEQUENCE_NUMBER,
     X_CREATION_DT,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_SUBMISSION_DT,
     X_THESIS_EXAM_TYPE,
     X_THESIS_PANEL_TYPE,
     X_TRACKING_ID,
     X_THESIS_RESULT_CD,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_CA_SEQUENCE_NUMBER,
   X_THE_SEQUENCE_NUMBER,
   X_CREATION_DT,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_SUBMISSION_DT,
   X_THESIS_EXAM_TYPE,
   X_THESIS_PANEL_TYPE,
   X_TRACKING_ID,
   X_THESIS_RESULT_CD,
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

  delete from IGS_RE_THS_EXAM_HIST_ALL
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_RE_THS_EXAM_HIST_PKG;

/
