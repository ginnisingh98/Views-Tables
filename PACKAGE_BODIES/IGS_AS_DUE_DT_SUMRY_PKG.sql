--------------------------------------------------------
--  DDL for Package Body IGS_AS_DUE_DT_SUMRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_DUE_DT_SUMRY_PKG" AS
/* $Header: IGSDI50B.pls 115.5 2002/11/28 23:23:14 nsidana ship $ */

l_rowid VARCHAR2(25);
  old_references IGS_AS_DUE_DT_SUMRY%RowType;
  new_references IGS_AS_DUE_DT_SUMRY%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_session_id IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_owner_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_owner_ou_start_dt IN DATE DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_week_ending_dt IN DATE DEFAULT NULL,
    x_base_count IN NUMBER DEFAULT NULL,
    x_expected_overdue_count IN NUMBER DEFAULT NULL,
    x_one_week_extension_count IN NUMBER DEFAULT NULL,
    x_two_week_extension_count IN NUMBER DEFAULT NULL,
    x_three_week_plus_extnsn_count IN NUMBER DEFAULT NULL,
    x_received_count IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_DUE_DT_SUMRY
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      Igs_Ge_Msg_Stack.Add;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.session_id := x_session_id;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.owner_org_unit_cd := x_owner_org_unit_cd;
    new_references.owner_ou_start_dt := x_owner_ou_start_dt;
    new_references.unit_mode := x_unit_mode;
    new_references.ass_id := x_ass_id;
    new_references.week_ending_dt := x_week_ending_dt;
    new_references.base_count := x_base_count;
    new_references.expected_overdue_count := x_expected_overdue_count;
    new_references.one_week_extension_count := x_one_week_extension_count;
    new_references.two_week_extension_count := x_two_week_extension_count;
    new_references.three_week_plus_extnsn_count := x_three_week_plus_extnsn_count;
    new_references.received_count := x_received_count;
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
    x_at_id IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_DUE_DT_SUMRY
      WHERE    at_id = x_at_id
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
    X_AT_ID IN NUMBER DEFAULT NULL,
    x_session_id IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_owner_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_owner_ou_start_dt IN DATE DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_week_ending_dt IN DATE DEFAULT NULL,
    x_base_count IN NUMBER DEFAULT NULL,
    x_expected_overdue_count IN NUMBER DEFAULT NULL,
    x_one_week_extension_count IN NUMBER DEFAULT NULL,
    x_two_week_extension_count IN NUMBER DEFAULT NULL,
    x_three_week_plus_extnsn_count IN NUMBER DEFAULT NULL,
    x_received_count IN NUMBER DEFAULT NULL,
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
      x_session_id,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_owner_org_unit_cd,
      x_owner_ou_start_dt,
      x_unit_mode,
      x_ass_id,
      x_week_ending_dt,
      x_base_count,
      x_expected_overdue_count,
      x_one_week_extension_count,
      x_two_week_extension_count,
      x_three_week_plus_extnsn_count,
      x_received_count,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.

      IF  Get_PK_For_Validation (
          new_references.at_id ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
      END IF;
       NULL;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       NULL;
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      NULL;

  ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.at_id ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
      END IF;
      NULL;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       NULL;
ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
 END IF;

  END Before_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AT_ID in out NOCOPY NUMBER,
  X_SESSION_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_UNIT_MODE in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_WEEK_ENDING_DT in DATE,
  X_BASE_COUNT in NUMBER,
  X_EXPECTED_OVERDUE_COUNT in NUMBER,
  X_ONE_WEEK_EXTENSION_COUNT in NUMBER,
  X_TWO_WEEK_EXTENSION_COUNT in NUMBER,
  X_THREE_WEEK_PLUS_EXTNSN_COUNT in NUMBER,
  X_RECEIVED_COUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_DUE_DT_SUMRY
      where AT_ID = X_AT_ID;
X_LAST_UPDATE_DATE DATE;
X_LAST_UPDATED_BY NUMBER;
X_LAST_UPDATE_LOGIN NUMBER;
              	X_REQUEST_ID NUMBER;
    			X_PROGRAM_ID NUMBER;
    			X_PROGRAM_APPLICATION_ID NUMBER;
X_PROGRAM_UPDATE_DATE DATE;

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
     X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;

   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := NULL;
     X_PROGRAM_ID := NULL;
     X_PROGRAM_APPLICATION_ID := NULL;
     X_PROGRAM_UPDATE_DATE := NULL;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;

  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;

select IGS_AS_ASSR1020_TMP_AT_ID_S.nextval
    INTO X_AT_ID
    FROM DUAL;

   Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_ass_id=>X_ASS_ID,
  x_base_count=>X_BASE_COUNT,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_expected_overdue_count=>X_EXPECTED_OVERDUE_COUNT,
  x_one_week_extension_count=>X_ONE_WEEK_EXTENSION_COUNT,
  x_owner_org_unit_cd=>X_OWNER_ORG_UNIT_CD,
  x_owner_ou_start_dt=>X_OWNER_OU_START_DT,
  x_received_count=>X_RECEIVED_COUNT,
  x_session_id=>X_SESSION_ID,
  x_AT_id=>X_AT_ID,
  x_three_week_plus_extnsn_count=>X_THREE_WEEK_PLUS_EXTNSN_COUNT,
  x_two_week_extension_count=>X_TWO_WEEK_EXTENSION_COUNT,
  x_unit_cd=>X_UNIT_CD,
  x_unit_mode=>X_UNIT_MODE,
  x_version_number=>X_VERSION_NUMBER,
  x_week_ending_dt=>X_WEEK_ENDING_DT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AS_DUE_DT_SUMRY (
    SESSION_ID,
    AT_ID,
    UNIT_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    OWNER_ORG_UNIT_CD,
    OWNER_OU_START_DT,
    UNIT_MODE,
    ASS_ID,
    WEEK_ENDING_DT,
    BASE_COUNT,
    EXPECTED_OVERDUE_COUNT,
    ONE_WEEK_EXTENSION_COUNT,
    TWO_WEEK_EXTENSION_COUNT,
    THREE_WEEK_PLUS_EXTNSN_COUNT,
    RECEIVED_COUNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
     NEW_REFERENCES.SESSION_ID,
     NEW_REFERENCES.AT_ID,
     NEW_REFERENCES.UNIT_CD,
     NEW_REFERENCES.VERSION_NUMBER,
     NEW_REFERENCES.CAL_TYPE,
     NEW_REFERENCES.CI_SEQUENCE_NUMBER,
     NEW_REFERENCES.OWNER_ORG_UNIT_CD,
     NEW_REFERENCES.OWNER_OU_START_DT,
     NEW_REFERENCES.UNIT_MODE,
     NEW_REFERENCES.ASS_ID,
     NEW_REFERENCES.WEEK_ENDING_DT,
     NEW_REFERENCES.BASE_COUNT,
     NEW_REFERENCES.EXPECTED_OVERDUE_COUNT,
     NEW_REFERENCES.ONE_WEEK_EXTENSION_COUNT,
     NEW_REFERENCES.TWO_WEEK_EXTENSION_COUNT,
     NEW_REFERENCES.THREE_WEEK_PLUS_EXTNSN_COUNT,
     NEW_REFERENCES.RECEIVED_COUNT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
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
  X_AT_ID in NUMBER,
  X_SESSION_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_UNIT_MODE in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_WEEK_ENDING_DT in DATE,
  X_BASE_COUNT in NUMBER,
  X_EXPECTED_OVERDUE_COUNT in NUMBER,
  X_ONE_WEEK_EXTENSION_COUNT in NUMBER,
  X_TWO_WEEK_EXTENSION_COUNT in NUMBER,
  X_THREE_WEEK_PLUS_EXTNSN_COUNT in NUMBER,
  X_RECEIVED_COUNT in NUMBER
) AS
  cursor c1 is select
      SESSION_ID,
      UNIT_CD,
      VERSION_NUMBER,
      CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      OWNER_ORG_UNIT_CD,
      OWNER_OU_START_DT,
      UNIT_MODE,
      ASS_ID,
      WEEK_ENDING_DT,
      BASE_COUNT,
      EXPECTED_OVERDUE_COUNT,
      ONE_WEEK_EXTENSION_COUNT,
      TWO_WEEK_EXTENSION_COUNT,
      THREE_WEEK_PLUS_EXTNSN_COUNT,
      RECEIVED_COUNT
    from IGS_AS_DUE_DT_SUMRY
    where ROWID =X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    Igs_Ge_Msg_Stack.Add;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.SESSION_ID = X_SESSION_ID)
      AND (tlinfo.UNIT_CD = X_UNIT_CD)
      AND (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND (tlinfo.CAL_TYPE = X_CAL_TYPE)
      AND (tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)
      AND (tlinfo.OWNER_ORG_UNIT_CD = X_OWNER_ORG_UNIT_CD)
      AND ((tlinfo.OWNER_OU_START_DT = X_OWNER_OU_START_DT)
           OR ((tlinfo.OWNER_OU_START_DT is null)
               AND (X_OWNER_OU_START_DT is null)))
      AND (tlinfo.UNIT_MODE = X_UNIT_MODE)
      AND (tlinfo.ASS_ID = X_ASS_ID)
      AND (tlinfo.WEEK_ENDING_DT = X_WEEK_ENDING_DT)
      AND ((tlinfo.BASE_COUNT = X_BASE_COUNT)
           OR ((tlinfo.BASE_COUNT is null)
               AND (X_BASE_COUNT is null)))
      AND ((tlinfo.EXPECTED_OVERDUE_COUNT = X_EXPECTED_OVERDUE_COUNT)
           OR ((tlinfo.EXPECTED_OVERDUE_COUNT is null)
               AND (X_EXPECTED_OVERDUE_COUNT is null)))
      AND ((tlinfo.ONE_WEEK_EXTENSION_COUNT = X_ONE_WEEK_EXTENSION_COUNT)
           OR ((tlinfo.ONE_WEEK_EXTENSION_COUNT is null)
               AND (X_ONE_WEEK_EXTENSION_COUNT is null)))
      AND ((tlinfo.TWO_WEEK_EXTENSION_COUNT = X_TWO_WEEK_EXTENSION_COUNT)
           OR ((tlinfo.TWO_WEEK_EXTENSION_COUNT is null)
               AND (X_TWO_WEEK_EXTENSION_COUNT is null)))
      AND ((tlinfo.THREE_WEEK_PLUS_EXTNSN_COUNT = X_THREE_WEEK_PLUS_EXTNSN_COUNT)
           OR ((tlinfo.THREE_WEEK_PLUS_EXTNSN_COUNT is null)
               AND (X_THREE_WEEK_PLUS_EXTNSN_COUNT is null)))
      AND ((tlinfo.RECEIVED_COUNT = X_RECEIVED_COUNT)
           OR ((tlinfo.RECEIVED_COUNT is null)
               AND (X_RECEIVED_COUNT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_AT_ID in NUMBER,
  X_SESSION_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_UNIT_MODE in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_WEEK_ENDING_DT in DATE,
  X_BASE_COUNT in NUMBER,
  X_EXPECTED_OVERDUE_COUNT in NUMBER,
  X_ONE_WEEK_EXTENSION_COUNT in NUMBER,
  X_TWO_WEEK_EXTENSION_COUNT in NUMBER,
  X_THREE_WEEK_PLUS_EXTNSN_COUNT in NUMBER,
  X_RECEIVED_COUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
    Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_ass_id=>X_ASS_ID,
  x_base_count=>X_BASE_COUNT,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_expected_overdue_count=>X_EXPECTED_OVERDUE_COUNT,
  x_one_week_extension_count=>X_ONE_WEEK_EXTENSION_COUNT,
  x_owner_org_unit_cd=>X_OWNER_ORG_UNIT_CD,
  x_owner_ou_start_dt=>X_OWNER_OU_START_DT,
  x_received_count=>X_RECEIVED_COUNT,
  x_session_id=>X_SESSION_ID,
  x_AT_id=>X_AT_ID,
  x_three_week_plus_extnsn_count=>X_THREE_WEEK_PLUS_EXTNSN_COUNT,
  x_two_week_extension_count=>X_TWO_WEEK_EXTENSION_COUNT,
  x_unit_cd=>X_UNIT_CD,
  x_unit_mode=>X_UNIT_MODE,
  x_version_number=>X_VERSION_NUMBER,
  x_week_ending_dt=>X_WEEK_ENDING_DT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID :=
                OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE :=
                  OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
end if;

  update IGS_AS_DUE_DT_SUMRY set
    SESSION_ID =  NEW_REFERENCES.SESSION_ID,
    UNIT_CD =  NEW_REFERENCES.UNIT_CD,
    VERSION_NUMBER =  NEW_REFERENCES.VERSION_NUMBER,
    CAL_TYPE =  NEW_REFERENCES.CAL_TYPE,
    CI_SEQUENCE_NUMBER =  NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    OWNER_ORG_UNIT_CD =  NEW_REFERENCES.OWNER_ORG_UNIT_CD,
    OWNER_OU_START_DT =  NEW_REFERENCES.OWNER_OU_START_DT,
    UNIT_MODE =  NEW_REFERENCES.UNIT_MODE,
    ASS_ID =  NEW_REFERENCES.ASS_ID,
    WEEK_ENDING_DT =  NEW_REFERENCES.WEEK_ENDING_DT,
    BASE_COUNT =  NEW_REFERENCES.BASE_COUNT,
    EXPECTED_OVERDUE_COUNT =  NEW_REFERENCES.EXPECTED_OVERDUE_COUNT,
    ONE_WEEK_EXTENSION_COUNT =  NEW_REFERENCES.ONE_WEEK_EXTENSION_COUNT,
    TWO_WEEK_EXTENSION_COUNT =  NEW_REFERENCES.TWO_WEEK_EXTENSION_COUNT,
    THREE_WEEK_PLUS_EXTNSN_COUNT =  NEW_REFERENCES.THREE_WEEK_PLUS_EXTNSN_COUNT,
    RECEIVED_COUNT =  NEW_REFERENCES.RECEIVED_COUNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE

  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AT_ID in out NOCOPY NUMBER,
  X_SESSION_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_UNIT_MODE in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_WEEK_ENDING_DT in DATE,
  X_BASE_COUNT in NUMBER,
  X_EXPECTED_OVERDUE_COUNT in NUMBER,
  X_ONE_WEEK_EXTENSION_COUNT in NUMBER,
  X_TWO_WEEK_EXTENSION_COUNT in NUMBER,
  X_THREE_WEEK_PLUS_EXTNSN_COUNT in NUMBER,
  X_RECEIVED_COUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_DUE_DT_SUMRY
     where AT_ID = X_AT_ID
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_AT_ID,
     X_SESSION_ID,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_OWNER_ORG_UNIT_CD,
     X_OWNER_OU_START_DT,
     X_UNIT_MODE,
     X_ASS_ID,
     X_WEEK_ENDING_DT,
     X_BASE_COUNT,
     X_EXPECTED_OVERDUE_COUNT,
     X_ONE_WEEK_EXTENSION_COUNT,
     X_TWO_WEEK_EXTENSION_COUNT,
     X_THREE_WEEK_PLUS_EXTNSN_COUNT,
     X_RECEIVED_COUNT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_AT_ID,
   X_SESSION_ID,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_OWNER_ORG_UNIT_CD,
   X_OWNER_OU_START_DT,
   X_UNIT_MODE,
   X_ASS_ID,
   X_WEEK_ENDING_DT,
   X_BASE_COUNT,
   X_EXPECTED_OVERDUE_COUNT,
   X_ONE_WEEK_EXTENSION_COUNT,
   X_TWO_WEEK_EXTENSION_COUNT,
   X_THREE_WEEK_PLUS_EXTNSN_COUNT,
   X_RECEIVED_COUNT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
  Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_DUE_DT_SUMRY
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGS_AS_DUE_DT_SUMRY_PKG;

/
