--------------------------------------------------------
--  DDL for Package Body IGS_PR_MILESTONE_HST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_MILESTONE_HST_PKG" as
/* $Header: IGSQI02B.pls 115.6 2002/11/29 03:13:48 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PR_MILESTONE_HST_ALL%RowType;
  new_references IGS_PR_MILESTONE_HST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_milestone_type IN VARCHAR2 DEFAULT NULL,
    x_milestone_status IN VARCHAR2 DEFAULT NULL,
    x_due_dt IN DATE DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_actual_reached_dt IN DATE DEFAULT NULL,
    x_preced_sequence_number IN NUMBER DEFAULT NULL,
    x_ovrd_ntfctn_imminent_days IN NUMBER DEFAULT NULL,
    x_ovrd_ntfctn_reminder_days IN NUMBER DEFAULT NULL,
    x_ovrd_ntfctn_re_reminder_days IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_MILESTONE_HST_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.ca_sequence_number := x_ca_sequence_number;
    new_references.sequence_number := x_sequence_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.milestone_type := x_milestone_type;
    new_references.milestone_status := x_milestone_status;
    new_references.due_dt := x_due_dt;
    new_references.description := x_description;
    new_references.actual_reached_dt := x_actual_reached_dt;
    new_references.preced_sequence_number := x_preced_sequence_number;
    new_references.ovrd_ntfctn_imminent_days := x_ovrd_ntfctn_imminent_days;
    new_references.ovrd_ntfctn_reminder_days := x_ovrd_ntfctn_reminder_days;
    new_references.ovrd_ntfctn_re_reminder_days := x_ovrd_ntfctn_re_reminder_days;
    new_references.comments := x_comments;
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


  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_MILESTONE_HST_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      sequence_number = x_sequence_number
      AND      hist_start_dt = x_hist_start_dt
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close Cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_milestone_type IN VARCHAR2 DEFAULT NULL,
    x_milestone_status IN VARCHAR2 DEFAULT NULL,
    x_due_dt IN DATE DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_actual_reached_dt IN DATE DEFAULT NULL,
    x_preced_sequence_number IN NUMBER DEFAULT NULL,
    x_ovrd_ntfctn_imminent_days IN NUMBER DEFAULT NULL,
    x_ovrd_ntfctn_reminder_days IN NUMBER DEFAULT NULL,
    x_ovrd_ntfctn_re_reminder_days IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
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
      x_sequence_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_milestone_type,
      x_milestone_status,
      x_due_dt,
      x_description,
      x_actual_reached_dt,
      x_preced_sequence_number,
      x_ovrd_ntfctn_imminent_days,
      x_ovrd_ntfctn_reminder_days,
      x_ovrd_ntfctn_re_reminder_days,
      x_comments,
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
         new_references.person_id ,
         new_references.ca_sequence_number,
         new_references.sequence_number,
         new_references.hist_start_dt
         ) THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation (
         new_references.person_id ,
         new_references.ca_sequence_number,
         new_references.sequence_number,
         new_references.hist_start_dt
         ) THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_MILESTONE_TYPE in VARCHAR2,
  X_MILESTONE_STATUS in VARCHAR2,
  X_DUE_DT in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ACTUAL_REACHED_DT in DATE,
  X_PRECED_SEQUENCE_NUMBER in NUMBER,
  X_OVRD_NTFCTN_IMMINENT_DAYS in NUMBER,
  X_OVRD_NTFCTN_REMINDER_DAYS in NUMBER,
  X_OVRD_NTFCTN_RE_REMINDER_DAYS in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) AS
    cursor C is select ROWID from IGS_PR_MILESTONE_HST_ALL
      where PERSON_ID = X_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
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
    x_rowid => x_rowid,
    x_person_id =>x_person_id,
    x_ca_sequence_number => x_ca_sequence_number,
    x_sequence_number => x_sequence_number,
    x_hist_start_dt => x_hist_start_dt,
    x_hist_end_dt =>x_hist_end_dt,
    x_hist_who => x_hist_who,
    x_milestone_type =>x_milestone_type,
    x_milestone_status =>x_milestone_status ,
    x_due_dt =>x_due_dt,
    x_description =>x_description,
    x_actual_reached_dt =>x_actual_reached_dt,
    x_preced_sequence_number =>x_preced_sequence_number,
    x_ovrd_ntfctn_imminent_days =>x_ovrd_ntfctn_imminent_days,
    x_ovrd_ntfctn_reminder_days =>x_ovrd_ntfctn_reminder_days,
    x_ovrd_ntfctn_re_reminder_days =>x_ovrd_ntfctn_re_reminder_days,
    x_comments => x_comments,
    x_creation_date =>x_last_update_date,
    x_created_by =>x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by =>x_last_updated_by,
    x_last_update_login => x_last_update_login,
    x_org_id=>igs_ge_gen_003.get_org_id
  ) ;

  insert into IGS_PR_MILESTONE_HST_ALL (
    PERSON_ID,
    CA_SEQUENCE_NUMBER,
    SEQUENCE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    MILESTONE_TYPE,
    MILESTONE_STATUS,
    DUE_DT,
    DESCRIPTION,
    ACTUAL_REACHED_DT,
    PRECED_SEQUENCE_NUMBER,
    OVRD_NTFCTN_IMMINENT_DAYS,
    OVRD_NTFCTN_REMINDER_DAYS,
    OVRD_NTFCTN_RE_REMINDER_DAYS,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.CA_SEQUENCE_NUMBER,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.MILESTONE_TYPE,
    NEW_REFERENCES.MILESTONE_STATUS,
    NEW_REFERENCES.DUE_DT,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.ACTUAL_REACHED_DT,
    NEW_REFERENCES.PRECED_SEQUENCE_NUMBER,
    NEW_REFERENCES.OVRD_NTFCTN_IMMINENT_DAYS,
    NEW_REFERENCES.OVRD_NTFCTN_REMINDER_DAYS,
    NEW_REFERENCES.OVRD_NTFCTN_RE_REMINDER_DAYS,
    NEW_REFERENCES.COMMENTS,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_MILESTONE_TYPE in VARCHAR2,
  X_MILESTONE_STATUS in VARCHAR2,
  X_DUE_DT in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ACTUAL_REACHED_DT in DATE,
  X_PRECED_SEQUENCE_NUMBER in NUMBER,
  X_OVRD_NTFCTN_IMMINENT_DAYS in NUMBER,
  X_OVRD_NTFCTN_REMINDER_DAYS in NUMBER,
  X_OVRD_NTFCTN_RE_REMINDER_DAYS in NUMBER,
  X_COMMENTS in VARCHAR2
) as
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      MILESTONE_TYPE,
      MILESTONE_STATUS,
      DUE_DT,
      DESCRIPTION,
      ACTUAL_REACHED_DT,
      PRECED_SEQUENCE_NUMBER,
      OVRD_NTFCTN_IMMINENT_DAYS,
      OVRD_NTFCTN_REMINDER_DAYS,
      OVRD_NTFCTN_RE_REMINDER_DAYS,
      COMMENTS
    from IGS_PR_MILESTONE_HST_ALL
    where ROWID = X_ROWID  for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.MILESTONE_TYPE = X_MILESTONE_TYPE)
           OR ((tlinfo.MILESTONE_TYPE is null)
               AND (X_MILESTONE_TYPE is null)))
      AND ((tlinfo.MILESTONE_STATUS = X_MILESTONE_STATUS)
           OR ((tlinfo.MILESTONE_STATUS is null)
               AND (X_MILESTONE_STATUS is null)))
      AND ((tlinfo.DUE_DT = X_DUE_DT)
           OR ((tlinfo.DUE_DT is null)
               AND (X_DUE_DT is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.ACTUAL_REACHED_DT = X_ACTUAL_REACHED_DT)
           OR ((tlinfo.ACTUAL_REACHED_DT is null)
               AND (X_ACTUAL_REACHED_DT is null)))
      AND ((tlinfo.PRECED_SEQUENCE_NUMBER = X_PRECED_SEQUENCE_NUMBER)
           OR ((tlinfo.PRECED_SEQUENCE_NUMBER is null)
               AND (X_PRECED_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.OVRD_NTFCTN_IMMINENT_DAYS = X_OVRD_NTFCTN_IMMINENT_DAYS)
           OR ((tlinfo.OVRD_NTFCTN_IMMINENT_DAYS is null)
               AND (X_OVRD_NTFCTN_IMMINENT_DAYS is null)))
      AND ((tlinfo.OVRD_NTFCTN_REMINDER_DAYS = X_OVRD_NTFCTN_REMINDER_DAYS)
           OR ((tlinfo.OVRD_NTFCTN_REMINDER_DAYS is null)
               AND (X_OVRD_NTFCTN_REMINDER_DAYS is null)))
      AND ((tlinfo.OVRD_NTFCTN_RE_REMINDER_DAYS = X_OVRD_NTFCTN_RE_REMINDER_DAYS)
           OR ((tlinfo.OVRD_NTFCTN_RE_REMINDER_DAYS is null)
               AND (X_OVRD_NTFCTN_RE_REMINDER_DAYS is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))

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
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_MILESTONE_TYPE in VARCHAR2,
  X_MILESTONE_STATUS in VARCHAR2,
  X_DUE_DT in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ACTUAL_REACHED_DT in DATE,
  X_PRECED_SEQUENCE_NUMBER in NUMBER,
  X_OVRD_NTFCTN_IMMINENT_DAYS in NUMBER,
  X_OVRD_NTFCTN_REMINDER_DAYS in NUMBER,
  X_OVRD_NTFCTN_RE_REMINDER_DAYS in NUMBER,
  X_COMMENTS in VARCHAR2,
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
    x_rowid => x_rowid,
    x_person_id =>x_person_id,
    x_ca_sequence_number => x_ca_sequence_number,
    x_sequence_number => x_sequence_number,
    x_hist_start_dt => x_hist_start_dt,
    x_hist_end_dt =>x_hist_end_dt,
    x_hist_who => x_hist_who,
    x_milestone_type =>x_milestone_type,
    x_milestone_status =>x_milestone_status ,
    x_due_dt =>x_due_dt,
    x_description =>x_description,
    x_actual_reached_dt =>x_actual_reached_dt,
    x_preced_sequence_number =>x_preced_sequence_number,
    x_ovrd_ntfctn_imminent_days =>x_ovrd_ntfctn_imminent_days,
    x_ovrd_ntfctn_reminder_days =>x_ovrd_ntfctn_reminder_days,
    x_ovrd_ntfctn_re_reminder_days =>x_ovrd_ntfctn_re_reminder_days,
    x_comments => x_comments,
    x_creation_date =>x_last_update_date,
    x_created_by =>x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by =>x_last_updated_by,
    x_last_update_login => x_last_update_login
  ) ;

  update IGS_PR_MILESTONE_HST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    MILESTONE_TYPE = NEW_REFERENCES.MILESTONE_TYPE,
    MILESTONE_STATUS = NEW_REFERENCES.MILESTONE_STATUS,
    DUE_DT = NEW_REFERENCES.DUE_DT,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    ACTUAL_REACHED_DT = NEW_REFERENCES.ACTUAL_REACHED_DT,
    PRECED_SEQUENCE_NUMBER = NEW_REFERENCES.PRECED_SEQUENCE_NUMBER,
    OVRD_NTFCTN_IMMINENT_DAYS = NEW_REFERENCES.OVRD_NTFCTN_IMMINENT_DAYS,
    OVRD_NTFCTN_REMINDER_DAYS = NEW_REFERENCES.OVRD_NTFCTN_REMINDER_DAYS,
    OVRD_NTFCTN_RE_REMINDER_DAYS = NEW_REFERENCES.OVRD_NTFCTN_RE_REMINDER_DAYS,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where  ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_MILESTONE_TYPE in VARCHAR2,
  X_MILESTONE_STATUS in VARCHAR2,
  X_DUE_DT in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_ACTUAL_REACHED_DT in DATE,
  X_PRECED_SEQUENCE_NUMBER in NUMBER,
  X_OVRD_NTFCTN_IMMINENT_DAYS in NUMBER,
  X_OVRD_NTFCTN_REMINDER_DAYS in NUMBER,
  X_OVRD_NTFCTN_RE_REMINDER_DAYS in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PR_MILESTONE_HST_ALL
     where PERSON_ID = X_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
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
     X_CA_SEQUENCE_NUMBER,
     X_SEQUENCE_NUMBER,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_MILESTONE_TYPE,
     X_MILESTONE_STATUS,
     X_DUE_DT,
     X_DESCRIPTION,
     X_ACTUAL_REACHED_DT,
     X_PRECED_SEQUENCE_NUMBER,
     X_OVRD_NTFCTN_IMMINENT_DAYS,
     X_OVRD_NTFCTN_REMINDER_DAYS,
     X_OVRD_NTFCTN_RE_REMINDER_DAYS,
     X_COMMENTS,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_CA_SEQUENCE_NUMBER,
   X_SEQUENCE_NUMBER,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_MILESTONE_TYPE,
   X_MILESTONE_STATUS,
   X_DUE_DT,
   X_DESCRIPTION,
   X_ACTUAL_REACHED_DT,
   X_PRECED_SEQUENCE_NUMBER,
   X_OVRD_NTFCTN_IMMINENT_DAYS,
   X_OVRD_NTFCTN_REMINDER_DAYS,
   X_OVRD_NTFCTN_RE_REMINDER_DAYS,
   X_COMMENTS,
   X_MODE
  );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid  => X_ROWID
  );

  delete from IGS_PR_MILESTONE_HST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

  PROCEDURE  Check_Constraints (
     Column_Name IN VARCHAR2 DEFAULT NULL,
     Column_Value IN VARCHAR2 DEFAULT NULL
  ) AS

  BEGIN

IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'CA_SEQUENCE_NUMBER' THEN
  new_references.CA_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' THEN
  new_references.SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'PRECED_SEQUENCE_NUMBER' THEN
  new_references.PRECED_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'CA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.CA_SEQUENCE_NUMBER < 1 or new_references.CA_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.SEQUENCE_NUMBER < 1 or new_references.SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRECED_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRECED_SEQUENCE_NUMBER < 1 or new_references.PRECED_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
END Check_Constraints;

end IGS_PR_MILESTONE_HST_PKG;

/
