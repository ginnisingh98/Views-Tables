--------------------------------------------------------
--  DDL for Package Body IGS_AS_EXAM_SESSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_EXAM_SESSION_PKG" AS
 /* $Header: IGSDI12B.pls 115.7 2002/11/28 23:13:12 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AS_EXAM_SESSION_ALL%RowType;
  new_references IGS_AS_EXAM_SESSION_ALL%RowType;
PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_ci_start_dt IN DATE DEFAULT NULL,
    x_ci_end_dt IN DATE DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_ese_id IN NUMBER DEFAULT NULL,
    x_exam_session_number IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_EXAM_SESSION_ALL
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
IGS_GE_MSG_STACK.ADD;
	  Close cur_old_ref_values;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.exam_cal_type := x_exam_cal_type;
    new_references.exam_ci_sequence_number := x_exam_ci_sequence_number;
    new_references.dt_alias := x_dt_alias;
    new_references.dai_sequence_number := x_dai_sequence_number;
    new_references.ci_start_dt := x_ci_start_dt;
    new_references.ci_end_dt := x_ci_end_dt;
    new_references.start_time := x_start_time;
    new_references.end_time := x_end_time;
    new_references.ese_id := x_ese_id;
    new_references.exam_session_number := x_exam_session_number;
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
 PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- If not set, call routine to set the ci_start_dt and ci_end_dt values.
	IF new_references.ci_start_dt IS NULL OR new_references.ci_end_dt IS NULL THEN
		IGS_CA_GEN_001.CALP_GET_CI_DATES(new_references.exam_cal_type,new_references.exam_ci_sequence_number,
			new_references.ci_start_dt,new_references.ci_end_dt);
	END IF;
	-- Check that both the start/end time have the standard 1/1/1900 date component
	-- to ensure primary key integrity.
	IF new_references.start_time <> IGS_GE_GEN_003.GENP_SET_TIME(new_references.start_time) THEN
		new_references.start_time := IGS_GE_GEN_003.GENP_SET_TIME(new_references.start_time);
	END IF;
	IF new_references.end_time <> IGS_GE_GEN_003.GENP_SET_TIME(new_references.end_time) THEN
		new_references.end_time := IGS_GE_GEN_003.GENP_SET_TIME(new_references.end_time);
	END IF;
	-- Validate the calendar instance of the record.
	IF IGS_AS_VAL_ESE.assp_val_ese_ci(	new_references.exam_cal_type,
					new_references.exam_ci_sequence_number,
					v_message_name) = FALSE THEN
		FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
	-- Validate the start/end time.
	IF IGS_AS_VAL_ESE.genp_val_strt_end_tm(	new_references.start_time,
					new_references.end_time,
					v_message_name) = FALSE THEN
		FND_MESSAGE.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
  END BeforeRowInsert1;

PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.dt_alias = new_references.dt_alias) AND
         (old_references.dai_sequence_number = new_references.dai_sequence_number) AND
         (old_references.exam_cal_type = new_references.exam_cal_type) AND
         (old_references.exam_ci_sequence_number = new_references.exam_ci_sequence_number)) OR
        ((new_references.dt_alias IS NULL) OR
         (new_references.dai_sequence_number IS NULL) OR
         (new_references.exam_cal_type IS NULL) OR
         (new_references.exam_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
        new_references.dt_alias,
        new_references.dai_sequence_number,
        new_references.exam_cal_type,
        new_references.exam_ci_sequence_number )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;


    IF (((old_references.exam_cal_type = new_references.exam_cal_type) OR
         (old_references.exam_ci_sequence_number = new_references.exam_ci_sequence_number)) OR
        ((new_references.exam_cal_type IS NULL) OR
         (new_references.exam_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.exam_cal_type,
        new_references.exam_ci_sequence_number )THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;


    END IF;
  END Check_Parent_Existance;
  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_AS_EXAM_INSTANCE_PKG.GET_FK_IGS_AS_EXAM_SESSION (
      old_references.exam_cal_type,
      old_references.exam_ci_sequence_number,
      old_references.dt_alias,
      old_references.dai_sequence_number,
      old_references.start_time,
      old_references.end_time
      );
    IGS_AS_EXMVNU_SESAVL_PKG.GET_FK_IGS_AS_EXAM_SESSION  (
      old_references.exam_cal_type,
      old_references.exam_ci_sequence_number,
      old_references.dt_alias,
      old_references.dai_sequence_number,
      old_references.start_time,
      old_references.end_time
      );
   IGS_AS_STD_EXM_INSTN_PKG.GET_UFK_IGS_AS_EXAM_SESSION(
      old_references.ese_id
      );

   IGS_AS_EXM_INS_SPVSR_PKG.GET_UFK_IGS_AS_EXAM_SESSION(
      old_references.ese_id
      );
   IGS_AS_EXM_SES_VN_SP_PKG.GET_UFK_IGS_AS_EXAM_SESSION(
      old_references.ese_id
      );
   IGS_AS_EXMVNU_SESAVL_PKG.GET_UFK_IGS_AS_EXAM_SESSION  (
      old_references.ese_id
      );

  END Check_Child_Existance;

PROCEDURE Check_UK_Child_Existance AS
  BEGIN

    IF ((old_references.ese_id = new_references.ese_id)
    OR (old_references.ese_id IS NULL)) THEN
       NULL;
    ELSE
       IGS_AS_EXAM_INSTANCE_PKG.GET_UFK_IGS_AS_EXAM_SESSION(old_references.ese_id);
       IGS_AS_EXM_INS_SPVSR_PKG.GET_UFK_IGS_AS_EXAM_SESSION(old_references.ese_id);
       IGS_AS_EXM_SES_VN_SP_PKG.GET_UFK_IGS_AS_EXAM_SESSION(old_references.ese_id);
       IGS_AS_EXMVNU_SESAVL_PKG.GET_UFK_IGS_AS_EXAM_SESSION(old_references.ese_id);
    END IF;
  END Check_UK_Child_Existance;


  function Get_PK_For_Validation (
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_start_time IN DATE,
    x_end_time IN DATE
    )return boolean  AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_SESSION_ALL
      WHERE    exam_cal_type = x_exam_cal_type
      AND      exam_ci_sequence_number = x_exam_ci_sequence_number
      AND      dt_alias = x_dt_alias
      AND      dai_sequence_number = x_dai_sequence_number
      AND      to_char(start_time,'HH24:MI') = to_char(x_start_time,'HH24:MI')
      AND      to_char(end_time,'HH24:MI')  = to_char(x_end_time,'HH24:MI')
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
    x_ese_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_SESSION_ALL
      WHERE    ese_id = x_ese_id
      AND      (l_rowid is null or rowid <> l_rowid)
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
  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_SESSION_ALL
      WHERE    dt_alias = x_dt_alias
      AND      dai_sequence_number = x_sequence_number
      AND      exam_cal_type = x_cal_type
      AND      exam_ci_sequence_number = x_ci_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_ESE_CI_FK');
IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_DA_INST;
  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_SESSION_ALL
      WHERE    exam_cal_type = x_cal_type
      AND      exam_ci_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_ESE_DAI_FK');
IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_ci_start_dt IN DATE DEFAULT NULL,
    x_ci_end_dt IN DATE DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_ese_id IN NUMBER DEFAULT NULL,
    x_exam_session_number IN NUMBER DEFAULT NULL,
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
      x_org_id,
      x_exam_cal_type,
      x_exam_ci_sequence_number,
      x_dt_alias,
      x_dai_sequence_number,
      x_ci_start_dt,
      x_ci_end_dt,
      x_start_time,
      x_end_time,
      x_ese_id,
      x_exam_session_number,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsert1 ( p_inserting => TRUE );
	IF  Get_PK_For_Validation (NEW_REFERENCES.exam_cal_type ,
    NEW_REFERENCES.exam_ci_sequence_number ,
    NEW_REFERENCES.dt_alias ,
    NEW_REFERENCES.dai_sequence_number,
    NEW_REFERENCES.start_time ,
    NEW_REFERENCES.end_time  ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;
	     Check_Uniqueness;
	     Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

      	Check_Uniqueness;
	     Check_Constraints;

      Check_Parent_Existance;
      Check_UK_Child_Existance;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation (NEW_REFERENCES.exam_cal_type ,
    NEW_REFERENCES.exam_ci_sequence_number ,
    NEW_REFERENCES.dt_alias ,
    NEW_REFERENCES.dai_sequence_number,
    NEW_REFERENCES.start_time ,
    NEW_REFERENCES.end_time) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;
	     Check_Uniqueness;
	     Check_Constraints;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	      Check_Uniqueness;
	      Check_Constraints;
	      Check_UK_Child_Existance;
ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_ESE_ID in NUMBER,
  X_EXAM_SESSION_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_EXAM_SESSION_ALL
      where EXAM_CAL_TYPE = X_EXAM_CAL_TYPE
      and EXAM_CI_SEQUENCE_NUMBER = X_EXAM_CI_SEQUENCE_NUMBER
      and DT_ALIAS = X_DT_ALIAS
      and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
      and to_char(start_time,'HH24:MI') = to_char(x_start_time,'HH24:MI')
      and to_char(end_time,'HH24:MI')  = to_char(x_end_time,'HH24:MI') ;
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
 x_org_id => igs_ge_gen_003.get_org_id,
 x_ci_end_dt=>X_CI_END_DT,
 x_ci_start_dt=>X_CI_START_DT,
 x_comments=>X_COMMENTS,
 x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
 x_dt_alias=>X_DT_ALIAS,
 x_end_time=>X_END_TIME,
 x_ese_id=>X_ESE_ID,
 x_exam_cal_type=>X_EXAM_CAL_TYPE,
 x_exam_ci_sequence_number=>X_EXAM_CI_SEQUENCE_NUMBER,
 x_exam_session_number=>X_EXAM_SESSION_NUMBER,
 x_start_time=>X_START_TIME,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_AS_EXAM_SESSION_ALL (
    ORG_ID,
    EXAM_CAL_TYPE,
    EXAM_CI_SEQUENCE_NUMBER,
    DT_ALIAS,
    DAI_SEQUENCE_NUMBER,
    CI_START_DT,
    CI_END_DT,
    START_TIME,
    END_TIME,
    ESE_ID,
    EXAM_SESSION_NUMBER,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.EXAM_CAL_TYPE,
    NEW_REFERENCES.EXAM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.CI_START_DT,
    NEW_REFERENCES.CI_END_DT,
    NEW_REFERENCES.START_TIME,
    NEW_REFERENCES.END_TIME,
    NEW_REFERENCES.ESE_ID,
    NEW_REFERENCES.EXAM_SESSION_NUMBER,
    NEW_REFERENCES.COMMENTS,
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
l_rowid:=NULL;
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_ESE_ID in NUMBER,
  X_EXAM_SESSION_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      CI_START_DT,
      CI_END_DT,
      ESE_ID,
      EXAM_SESSION_NUMBER,
      COMMENTS
    from IGS_AS_EXAM_SESSION_ALL
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
  if ( (tlinfo.CI_START_DT = X_CI_START_DT)
      AND (tlinfo.CI_END_DT = X_CI_END_DT)
      AND (tlinfo.ESE_ID = X_ESE_ID)
      AND (tlinfo.EXAM_SESSION_NUMBER = X_EXAM_SESSION_NUMBER)
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
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
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_ESE_ID in NUMBER,
  X_EXAM_SESSION_NUMBER in NUMBER,
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
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
 Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_ci_end_dt=>X_CI_END_DT,
 x_ci_start_dt=>X_CI_START_DT,
 x_comments=>X_COMMENTS,
 x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
 x_dt_alias=>X_DT_ALIAS,
 x_end_time=>X_END_TIME,
 x_ese_id=>X_ESE_ID,
 x_exam_cal_type=>X_EXAM_CAL_TYPE,
 x_exam_ci_sequence_number=>X_EXAM_CI_SEQUENCE_NUMBER,
 x_exam_session_number=>X_EXAM_SESSION_NUMBER,
 x_start_time=>X_START_TIME,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_AS_EXAM_SESSION_ALL set
    CI_START_DT = NEW_REFERENCES.CI_START_DT,
    CI_END_DT = NEW_REFERENCES.CI_END_DT,
    ESE_ID = NEW_REFERENCES.ESE_ID,
    EXAM_SESSION_NUMBER = NEW_REFERENCES.EXAM_SESSION_NUMBER,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
l_rowid:=NULL;
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_ESE_ID in NUMBER,
  X_EXAM_SESSION_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_EXAM_SESSION_ALL
     where EXAM_CAL_TYPE = X_EXAM_CAL_TYPE
     and EXAM_CI_SEQUENCE_NUMBER = X_EXAM_CI_SEQUENCE_NUMBER
     and DT_ALIAS = X_DT_ALIAS
     and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
     and to_char(start_time,'HH24:MI') = to_char(x_start_time,'HH24:MI')
     and to_char(end_time,'HH24:MI')  = to_char(x_end_time,'HH24:MI')
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_EXAM_CAL_TYPE,
     X_EXAM_CI_SEQUENCE_NUMBER,
     X_DT_ALIAS,
     X_DAI_SEQUENCE_NUMBER,
     X_START_TIME,
     X_END_TIME,
     X_CI_START_DT,
     X_CI_END_DT,
     X_ESE_ID,
     X_EXAM_SESSION_NUMBER,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_EXAM_CAL_TYPE,
   X_EXAM_CI_SEQUENCE_NUMBER,
   X_DT_ALIAS,
   X_DAI_SEQUENCE_NUMBER,
   X_START_TIME,
   X_END_TIME,
   X_CI_START_DT,
   X_CI_END_DT,
   X_ESE_ID,
   X_EXAM_SESSION_NUMBER,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_EXAM_SESSION_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
l_rowid:=NULL;
end DELETE_ROW;

	PROCEDURE Check_Uniqueness AS
	Begin
	IF  Get_UK_For_Validation (
	         new_references.ESE_ID) THEN
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;
	End Check_Uniqueness;

	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)AS
	BEGIN
  	IF  column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'DT_ALIAS' then
	    new_references.DT_ALIAS := column_value;
	ELSIF upper(Column_name) = 'EXAM_CAL_TYPE' then
	    new_references.EXAM_CAL_TYPE := column_value;
	ELSIF upper(Column_name) = 'EXAM_CI_SEQUENCE_NUMBER' then
	    new_references.EXAM_CI_SEQUENCE_NUMBER := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(Column_name) = 'EXAM_SESSION_NUMBER' then
	    new_references.EXAM_SESSION_NUMBER := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(Column_name) = 'ESE_ID'  then
	    new_references.ESE_ID := IGS_GE_NUMBER.TO_NUM(column_value);
	end if;


IF upper(column_name) = 'DT_ALIAS' OR      column_name is null  Then
     IF new_references.DT_ALIAS <> UPPER(new_references.DT_ALIAS) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'EXAM_CAL_TYPE' OR
     column_name is null Then
     IF new_references.EXAM_CAL_TYPE <> UPPER(new_references.EXAM_CAL_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'EXAM_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.EXAM_CI_SEQUENCE_NUMBER < 1 OR new_references.EXAM_CI_SEQUENCE_NUMBER >  999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'EXAM_SESSION_NUMBER' OR
     column_name is null Then
     IF new_references.EXAM_SESSION_NUMBER < 0 OR new_references.EXAM_SESSION_NUMBER > 99 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'DAI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.DAI_SEQUENCE_NUMBER < 1 OR NEW_REFERENCES.DAI_SEQUENCE_NUMBER > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(Column_name) = 'ESE_ID'  OR  column_name is null Then
     IF new_references.ESE_ID < 0 OR new_references.ESE_ID > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

	END Check_Constraints;


end IGS_AS_EXAM_SESSION_PKG;

/
