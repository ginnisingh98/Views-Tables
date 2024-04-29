--------------------------------------------------------
--  DDL for Package Body IGS_AS_EXM_INS_SPVSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_EXM_INS_SPVSR_PKG" AS
 /* $Header: IGSDI11B.pls 115.4 2002/11/28 23:12:54 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AS_EXM_INS_SPVSR%RowType;
  new_references IGS_AS_EXM_INS_SPVSR%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_ese_id IN NUMBER DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_exam_supervisor_type IN VARCHAR2 DEFAULT NULL,
    x_override_start_time IN DATE DEFAULT NULL,
    x_override_end_time IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_EXM_INS_SPVSR
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
    new_references.person_id := x_person_id;
    new_references.ass_id := x_ass_id;
    new_references.exam_cal_type := x_exam_cal_type;
    new_references.exam_ci_sequence_number := x_exam_ci_sequence_number;
    new_references.dt_alias := x_dt_alias;
    new_references.dai_sequence_number := x_dai_sequence_number;
    new_references.start_time := x_start_time;
    new_references.end_time := x_end_time;
    new_references.ese_id := x_ese_id;
    new_references.venue_cd := x_venue_cd;
    new_references.exam_supervisor_type := x_exam_supervisor_type;
    new_references.override_start_time := x_override_start_time;
    new_references.override_end_time := x_override_end_time;
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
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	IF p_inserting THEN
		-- Call routine to fill in exam session key.
		IGS_AS_GEN_006.ASSP_GET_ESE_KEY(
			new_references.exam_cal_type,
			new_references.exam_ci_sequence_number,
			new_references.dt_alias,
			new_references.dai_sequence_number,
			new_references.start_time,
			new_references.end_time,
			new_references.ese_id);
	END IF;
	--w.r.t BUG #1956374 , Procedure assp_val_est_closed reference is changed
	-- Validate that the exam supervisor type is not closed.
	IF p_inserting OR
	   (p_updating AND
	   (new_references.exam_supervisor_type <> old_references.exam_supervisor_type)) THEN
		IF IGS_AS_VAL_ESU.assp_val_est_closed(new_references.exam_supervisor_type,
						v_message_name) = FALSE THEN
			FND_message.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.ass_id = new_references.ass_id) AND
         (old_references.exam_cal_type = new_references.exam_cal_type) AND
         (old_references.exam_ci_sequence_number = new_references.exam_ci_sequence_number) AND
         (old_references.dt_alias = new_references.dt_alias) AND
         (old_references.dai_sequence_number = new_references.dai_sequence_number) AND
         (old_references.start_time = new_references.start_time) AND
         (old_references.end_time = new_references.end_time) AND
         (old_references.venue_cd = new_references.venue_cd)) OR
        ((new_references.ass_id IS NULL) OR
         (new_references.exam_cal_type IS NULL) OR
         (new_references.exam_ci_sequence_number IS NULL) OR
         (new_references.dt_alias IS NULL) OR
         (new_references.dai_sequence_number IS NULL) OR
         (new_references.start_time IS NULL) OR
         (new_references.end_time IS NULL) OR
         (new_references.venue_cd IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_EXAM_INSTANCE_PKG.Get_PK_For_Validation (
        new_references.ass_id,
        new_references.exam_cal_type,
        new_references.exam_ci_sequence_number,
        new_references.dt_alias,
        new_references.dai_sequence_number,
        new_references.start_time,
        new_references.end_time,
        new_references.venue_cd )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;


    END IF;
    IF (((old_references.ese_id = new_references.ese_id)) OR
        ((new_references.ese_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_EXAM_SESSION_PKG.Get_UK_For_Validation (
        new_references.ese_id )THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.exam_supervisor_type = new_references.exam_supervisor_type)) OR
        ((new_references.exam_supervisor_type IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_EXM_SPRVSRTYP_PKG.Get_PK_For_Validation (
        new_references.exam_supervisor_type
        )THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_EXM_SUPRVISOR_PKG.Get_PK_For_Validation (
        new_references.person_id  )THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;
  END Check_Parent_Existance;
 function  Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ass_id IN NUMBER,
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_start_time IN DATE,
    x_end_time IN DATE,
    x_venue_cd IN VARCHAR2
    )return boolean  AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXM_INS_SPVSR
      WHERE    person_id = x_person_id
      AND      ass_id = x_ass_id
      AND      exam_cal_type = x_exam_cal_type
      AND      exam_ci_sequence_number = x_exam_ci_sequence_number
      AND      dt_alias = x_dt_alias
      AND      dai_sequence_number = x_dai_sequence_number
      AND      start_time = x_start_time
      AND      end_time = x_end_time
      AND      venue_cd = x_venue_cd
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
  PROCEDURE GET_FK_IGS_AS_EXAM_INSTANCE (
    x_ass_id IN NUMBER,
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_start_time IN DATE,
    x_end_time IN DATE,
    x_venue_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXM_INS_SPVSR
      WHERE    ass_id = x_ass_id
      AND      exam_cal_type = x_exam_cal_type
      AND      exam_ci_sequence_number = x_exam_ci_sequence_number
      AND      dt_alias = x_dt_alias
      AND      dai_sequence_number = x_dai_sequence_number
      AND      start_time = x_start_time
      AND      end_time = x_end_time
      AND      venue_cd = x_venue_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_EIS_EI_FK');
IGS_GE_MSG_STACK.ADD;
	   Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_EXAM_INSTANCE;
  PROCEDURE GET_UFK_IGS_AS_EXAM_SESSION (
    x_ese_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXM_INS_SPVSR
      WHERE    ese_id = x_ese_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_EIS_ESE_UFK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_UFK_IGS_AS_EXAM_SESSION;
  PROCEDURE GET_FK_IGS_AS_EXM_SPRVSRTYP (
    x_exam_supervisor_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXM_INS_SPVSR
      WHERE    exam_supervisor_type = x_exam_supervisor_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_EIS_EST_FK');
IGS_GE_MSG_STACK.ADD;
	   Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_EXM_SPRVSRTYP;
  PROCEDURE GET_FK_IGS_AS_EXM_SUPRVISOR (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXM_INS_SPVSR
      WHERE    person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_EIS_ESU_FK');
IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_EXM_SUPRVISOR;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_ese_id IN NUMBER DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_exam_supervisor_type IN VARCHAR2 DEFAULT NULL,
    x_override_start_time IN DATE DEFAULT NULL,
    x_override_end_time IN DATE DEFAULT NULL,
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
      x_person_id,
      x_ass_id,
      x_exam_cal_type,
      x_exam_ci_sequence_number,
      x_dt_alias,
      x_dai_sequence_number,
      x_start_time,
      x_end_time,
      x_ese_id,
      x_venue_cd,
      x_exam_supervisor_type,
      x_override_start_time,
      x_override_end_time,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );

	IF  Get_PK_For_Validation (
	         NEW_REFERENCES.person_id ,
    NEW_REFERENCES.ass_id ,
    NEW_REFERENCES.exam_cal_type ,
    NEW_REFERENCES.exam_ci_sequence_number ,
    NEW_REFERENCES.dt_alias ,
    NEW_REFERENCES.dai_sequence_number ,
    NEW_REFERENCES.start_time ,
    NEW_REFERENCES.end_time,
    NEW_REFERENCES.venue_cd ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      	     Check_Constraints;
      Check_Parent_Existance;

      	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation (
	         	         	         NEW_REFERENCES.person_id ,
    NEW_REFERENCES.ass_id ,
    NEW_REFERENCES.exam_cal_type ,
    NEW_REFERENCES.exam_ci_sequence_number ,
    NEW_REFERENCES.dt_alias ,
    NEW_REFERENCES.dai_sequence_number ,
    NEW_REFERENCES.start_time ,
    NEW_REFERENCES.end_time,
    NEW_REFERENCES.venue_cd ) THEN
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
  X_PERSON_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_EXM_INS_SPVSR
      where PERSON_ID = X_PERSON_ID
      and ASS_ID = X_ASS_ID
      and EXAM_CAL_TYPE = X_EXAM_CAL_TYPE
      and EXAM_CI_SEQUENCE_NUMBER = X_EXAM_CI_SEQUENCE_NUMBER
      and DT_ALIAS = X_DT_ALIAS
      and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
      and START_TIME = X_START_TIME
      and END_TIME = X_END_TIME
      and VENUE_CD = X_VENUE_CD;
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
  x_ass_id=>X_ASS_ID,
  x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
  x_dt_alias=>X_DT_ALIAS,
  x_end_time=>X_END_TIME,
  x_ese_id=>X_ESE_ID,
  x_exam_cal_type=>X_EXAM_CAL_TYPE,
  x_exam_ci_sequence_number=>X_EXAM_CI_SEQUENCE_NUMBER,
  x_exam_supervisor_type=>X_EXAM_SUPERVISOR_TYPE,
  x_override_end_time=>X_OVERRIDE_END_TIME,
  x_override_start_time=>X_OVERRIDE_START_TIME,
  x_person_id=>X_PERSON_ID,
  x_start_time=>X_START_TIME,
  x_venue_cd=>X_VENUE_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_AS_EXM_INS_SPVSR (
    PERSON_ID,
    ASS_ID,
    EXAM_CAL_TYPE,
    EXAM_CI_SEQUENCE_NUMBER,
    DT_ALIAS,
    DAI_SEQUENCE_NUMBER,
    START_TIME,
    END_TIME,
    ESE_ID,
    VENUE_CD,
    EXAM_SUPERVISOR_TYPE,
    OVERRIDE_START_TIME,
    OVERRIDE_END_TIME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ASS_ID,
    NEW_REFERENCES.EXAM_CAL_TYPE,
    NEW_REFERENCES.EXAM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.START_TIME,
    NEW_REFERENCES.END_TIME,
    NEW_REFERENCES.ESE_ID,
    NEW_REFERENCES.VENUE_CD,
    NEW_REFERENCES.EXAM_SUPERVISOR_TYPE,
    NEW_REFERENCES.OVERRIDE_START_TIME,
    NEW_REFERENCES.OVERRIDE_END_TIME,
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
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE
) AS
  cursor c1 is select
      ESE_ID,
      EXAM_SUPERVISOR_TYPE,
      OVERRIDE_START_TIME,
      OVERRIDE_END_TIME
    from IGS_AS_EXM_INS_SPVSR
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
  if ( (tlinfo.ESE_ID = X_ESE_ID)
      AND (tlinfo.EXAM_SUPERVISOR_TYPE = X_EXAM_SUPERVISOR_TYPE)
      AND ((tlinfo.OVERRIDE_START_TIME = X_OVERRIDE_START_TIME)
           OR ((tlinfo.OVERRIDE_START_TIME is null)
               AND (X_OVERRIDE_START_TIME is null)))
      AND ((tlinfo.OVERRIDE_END_TIME = X_OVERRIDE_END_TIME)
           OR ((tlinfo.OVERRIDE_END_TIME is null)
               AND (X_OVERRIDE_END_TIME is null)))
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
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
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
  x_ass_id=>X_ASS_ID,
  x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
  x_dt_alias=>X_DT_ALIAS,
  x_end_time=>X_END_TIME,
  x_ese_id=>X_ESE_ID,
  x_exam_cal_type=>X_EXAM_CAL_TYPE,
  x_exam_ci_sequence_number=>X_EXAM_CI_SEQUENCE_NUMBER,
  x_exam_supervisor_type=>X_EXAM_SUPERVISOR_TYPE,
  x_override_end_time=>X_OVERRIDE_END_TIME,
  x_override_start_time=>X_OVERRIDE_START_TIME,
  x_person_id=>X_PERSON_ID,
  x_start_time=>X_START_TIME,
  x_venue_cd=>X_VENUE_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  update IGS_AS_EXM_INS_SPVSR set
    ESE_ID = NEW_REFERENCES.ESE_ID,
    EXAM_SUPERVISOR_TYPE = NEW_REFERENCES.EXAM_SUPERVISOR_TYPE,
    OVERRIDE_START_TIME = NEW_REFERENCES.OVERRIDE_START_TIME,
    OVERRIDE_END_TIME = NEW_REFERENCES.OVERRIDE_END_TIME,
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
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_EXM_INS_SPVSR
     where PERSON_ID = X_PERSON_ID
     and ASS_ID = X_ASS_ID
     and EXAM_CAL_TYPE = X_EXAM_CAL_TYPE
     and EXAM_CI_SEQUENCE_NUMBER = X_EXAM_CI_SEQUENCE_NUMBER
     and DT_ALIAS = X_DT_ALIAS
     and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
     and START_TIME = X_START_TIME
     and END_TIME = X_END_TIME
     and VENUE_CD = X_VENUE_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ASS_ID,
     X_EXAM_CAL_TYPE,
     X_EXAM_CI_SEQUENCE_NUMBER,
     X_DT_ALIAS,
     X_DAI_SEQUENCE_NUMBER,
     X_START_TIME,
     X_END_TIME,
     X_VENUE_CD,
     X_ESE_ID,
     X_EXAM_SUPERVISOR_TYPE,
     X_OVERRIDE_START_TIME,
     X_OVERRIDE_END_TIME,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ASS_ID,
   X_EXAM_CAL_TYPE,
   X_EXAM_CI_SEQUENCE_NUMBER,
   X_DT_ALIAS,
   X_DAI_SEQUENCE_NUMBER,
   X_START_TIME,
   X_END_TIME,
   X_VENUE_CD,
   X_ESE_ID,
   X_EXAM_SUPERVISOR_TYPE,
   X_OVERRIDE_START_TIME,
   X_OVERRIDE_END_TIME,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_EXM_INS_SPVSR
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
	ELSIF upper(Column_name) = 'DT_ALIAS' then
	    new_references.DT_ALIAS := column_value;
		ELSIF upper(Column_name) = 'EXAM_CAL_TYPE' then
	    new_references.EXAM_CAL_TYPE := column_value;
	ELSIF upper(Column_name) = 'EXAM_SUPERVISOR_TYPE' then
	    new_references.EXAM_SUPERVISOR_TYPE := column_value;
	ELSIF upper(Column_name) = 'VENUE_CD' then
	    new_references.VENUE_CD := column_value;
	ELSIF upper(Column_name) = 'DAI_SEQUENCE_NUMBER' then
	    new_references.DAI_SEQUENCE_NUMBER := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(Column_name) = 'EXAM_CI_SEQUENCE_NUMBER' then
	    new_references.EXAM_CI_SEQUENCE_NUMBER := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(Column_name) = 'ESE_ID' then
	    new_references.ESE_ID := IGS_GE_NUMBER.TO_NUM(column_value);
		 end if;
IF upper(column_name) = 'DT_ALIAS' OR
     column_name is null Then
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
IF upper(column_name) = 'EXAM_SUPERVISOR_TYPE' OR
     column_name is null Then
     IF new_references.EXAM_SUPERVISOR_TYPE <> UPPER(new_references.EXAM_SUPERVISOR_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'VENUE_CD' OR
     column_name is null Then
     IF new_references.VENUE_CD <> UPPER(new_references.VENUE_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'DAI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.DAI_SEQUENCE_NUMBER < 1 OR new_references.DAI_SEQUENCE_NUMBER  > 999999 THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'EXAM_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.EXAM_CI_SEQUENCE_NUMBER < 1 OR new_references.EXAM_CI_SEQUENCE_NUMBER > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'ESE_ID' OR
     column_name is null Then
     IF new_references.ESE_ID < 1 OR new_references.ESE_ID > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
	END Check_Constraints;
end IGS_AS_EXM_INS_SPVSR_PKG;

/
