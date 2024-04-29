--------------------------------------------------------
--  DDL for Package Body IGS_AS_EXAM_INSTANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_EXAM_INSTANCE_PKG" AS
 /* $Header: IGSDI04B.pls 115.8 2003/04/14 09:16:54 anilk ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AS_EXAM_INSTANCE_ALL%RowType;
  new_references IGS_AS_EXAM_INSTANCE_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_ese_id IN NUMBER DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_collect_person_id IN NUMBER DEFAULT NULL,
    x_special_session_ind IN VARCHAR2 DEFAULT NULL,
    x_override_start_time IN DATE DEFAULT NULL,
    x_override_end_time IN DATE DEFAULT NULL,
    x_special_announcements IN VARCHAR2 DEFAULT NULL,
    x_special_instructions IN VARCHAR2 DEFAULT NULL,
    x_worked_script_instructions IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_EXAM_INSTANCE_ALL
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
    new_references.ass_id := x_ass_id;
    new_references.exam_cal_type := x_exam_cal_type;
    new_references.exam_ci_sequence_number := x_exam_ci_sequence_number;
    new_references.dt_alias := x_dt_alias;
    new_references.dai_sequence_number := x_dai_sequence_number;
    new_references.start_time := x_start_time;
    new_references.end_time := x_end_time;
    new_references.ese_id := x_ese_id;
    new_references.venue_cd := x_venue_cd;
    new_references.collect_person_id := x_collect_person_id;
    new_references.special_session_ind := x_special_session_ind;
    new_references.override_start_time := x_override_start_time;
    new_references.override_end_time := x_override_end_time;
    new_references.special_announcements := x_special_announcements;
    new_references.special_instructions := x_special_instructions;
    new_references.worked_script_instructions := x_worked_script_instructions;
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
 v_message_name VARCHAR2(30);
  BEGIN
 -- Call routine to fill in exam session key.
 IGS_AS_GEN_006.ASSP_GET_ESE_KEY(
  new_references.exam_cal_type,
  new_references.exam_ci_sequence_number,
  new_references.dt_alias,
  new_references.dai_sequence_number,
  new_references.start_time,
  new_references.end_time,
  new_references.ese_id);
 -- Validate the venue closed indicator.
 IF igs_gr_val_gc.assp_val_ve_closed( new_references.venue_cd,
     v_message_name) = FALSE THEN
  FND_MESSAGE.SET_NAME('IGS',V_MESSAGE_NAME);
IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
 END IF;
 -- Validate other elements on insert.
 IF IGS_AS_VAL_EI.assp_val_ei_ins( new_references.exam_cal_type,
    new_references.exam_ci_sequence_number,
    new_references.ass_id,
    v_message_name) = FALSE THEN
  FND_MESSAGE.SET_NAME('IGS',V_MESSAGE_NAME);
IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
 END IF;
  END BeforeRowInsert1;
PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.ass_id = new_references.ass_id)) OR
        ((new_references.ass_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_ASSESSMNT_ITM_PKG.Get_PK_For_Validation (
        new_references.ass_id    )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.exam_cal_type = new_references.exam_cal_type) AND
         (old_references.exam_ci_sequence_number = new_references.exam_ci_sequence_number) AND
         (old_references.dt_alias = new_references.dt_alias) AND
         (old_references.dai_sequence_number = new_references.dai_sequence_number) AND
         (old_references.start_time = new_references.start_time) AND
         (old_references.end_time = new_references.end_time)) OR
        ((new_references.exam_cal_type IS NULL) OR
         (new_references.exam_ci_sequence_number IS NULL) OR
         (new_references.dt_alias IS NULL) OR
         (new_references.dai_sequence_number IS NULL) OR
         (new_references.start_time IS NULL) OR
         (new_references.end_time IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_EXAM_SESSION_PKG.Get_PK_For_Validation (
        new_references.exam_cal_type,
        new_references.exam_ci_sequence_number,
        new_references.dt_alias,
        new_references.dai_sequence_number,
        new_references.start_time,
        new_references.end_time ) 	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.ese_id = new_references.ese_id)) OR
        ((new_references.ese_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_EXAM_SESSION_PKG.Get_UK_For_Validation (
        new_references.ese_id )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.collect_person_id = new_references.collect_person_id)) OR
        ((new_references.collect_person_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.collect_person_id )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.venue_cd = new_references.venue_cd)) OR
        ((new_references.venue_cd IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_GR_VENUE_PKG.Get_PK_For_Validation (
        new_references.venue_cd )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
  END Check_Parent_Existance;
  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_AS_EXM_INS_SPVSR_PKG.GET_FK_IGS_AS_EXAM_INSTANCE (
      old_references.ass_id,
      old_references.exam_cal_type,
      old_references.exam_ci_sequence_number,
      old_references.dt_alias,
      old_references.dai_sequence_number,
      old_references.start_time,
      old_references.end_time,
      old_references.venue_cd
      );
    IGS_AS_STD_EXM_INSTN_PKG.GET_FK_IGS_AS_EXAM_INSTANCE (
      old_references.ass_id,
      old_references.exam_cal_type,
      old_references.exam_ci_sequence_number,
      old_references.dt_alias,
      old_references.dai_sequence_number,
      old_references.start_time,
      old_references.end_time,
      old_references.venue_cd
      );
  END Check_Child_Existance;
  FUNCTION Get_PK_For_Validation (
    x_ass_id IN NUMBER,
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_start_time IN DATE,
    x_end_time IN DATE,
    x_venue_cd IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_INSTANCE_ALL
      WHERE    ass_id = x_ass_id
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
  PROCEDURE GET_FK_IGS_AS_ASSESSMNT_ITM (
    x_ass_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_INSTANCE_ALL
      WHERE    ass_id = x_ass_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_EI_AI_FK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_ASSESSMNT_ITM;
  PROCEDURE GET_FK_IGS_AS_EXAM_SESSION (
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_start_time IN DATE,
    x_end_time IN DATE
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_INSTANCE_ALL
      WHERE    exam_cal_type = x_exam_cal_type
      AND      exam_ci_sequence_number = x_exam_ci_sequence_number
      AND      dt_alias = x_dt_alias
      AND      dai_sequence_number = x_dai_sequence_number
      AND      start_time = x_start_time
      AND      end_time = x_end_time ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_EI_ESE_UFK');
IGS_GE_MSG_STACK.ADD;
	   Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_EXAM_SESSION;
  PROCEDURE GET_UFK_IGS_AS_EXAM_SESSION (
    x_ese_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_INSTANCE_ALL
      WHERE    ese_id = x_ese_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_EI_ESE_UFK');
IGS_GE_MSG_STACK.ADD;
	   Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_UFK_IGS_AS_EXAM_SESSION;
  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_INSTANCE_ALL
      WHERE    collect_person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_EI_PE_FK');
IGS_GE_MSG_STACK.ADD;
	       Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;
  PROCEDURE GET_FK_IGS_GR_VENUE (
    x_venue_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXAM_INSTANCE_ALL
      WHERE    venue_cd = x_venue_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_EI_VE_FK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_GR_VENUE;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_ese_id IN NUMBER DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_collect_person_id IN NUMBER DEFAULT NULL,
    x_special_session_ind IN VARCHAR2 DEFAULT NULL,
    x_override_start_time IN DATE DEFAULT NULL,
    x_override_end_time IN DATE DEFAULT NULL,
    x_special_announcements IN VARCHAR2 DEFAULT NULL,
    x_special_instructions IN VARCHAR2 DEFAULT NULL,
    x_worked_script_instructions IN VARCHAR2 DEFAULT NULL,
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
      x_ass_id,
      x_exam_cal_type,
      x_exam_ci_sequence_number,
      x_dt_alias,
      x_dai_sequence_number,
      x_start_time,
      x_end_time,
      x_ese_id,
      x_venue_cd,
      x_collect_person_id,
      x_special_session_ind,
      x_override_start_time,
      x_override_end_time,
      x_special_announcements,
      x_special_instructions,
      x_worked_script_instructions,
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
	IF  Get_PK_For_Validation (    new_references.ass_id ,
    new_references.exam_cal_type ,
    new_references.exam_ci_sequence_number ,
    new_references.dt_alias ,
    new_references.dai_sequence_number,
     new_references.start_time,
    new_references.end_time ,
    new_references.venue_cd ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
	         new_references.ass_id ,
    new_references.exam_cal_type ,
    new_references.exam_ci_sequence_number ,
    new_references.dt_alias ,
    new_references.dai_sequence_number,
     new_references.start_time,
    new_references.end_time ,
    new_references.venue_cd ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	      Check_Constraints;

ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ASS_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_COLLECT_PERSON_ID in NUMBER,
  X_SPECIAL_SESSION_IND in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
  X_SPECIAL_ANNOUNCEMENTS in VARCHAR2,
  X_SPECIAL_INSTRUCTIONS in VARCHAR2,
  X_WORKED_SCRIPT_INSTRUCTIONS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) As
    cursor C is select ROWID from IGS_AS_EXAM_INSTANCE_ALL
      where ASS_ID = X_ASS_ID
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
 x_org_id => igs_ge_gen_003.get_org_id,
 x_ass_id=>X_ASS_ID,
 x_collect_person_id=>X_COLLECT_PERSON_ID,
 x_comments=>X_COMMENTS,
 x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
 x_dt_alias=>X_DT_ALIAS,
 x_end_time=>X_END_TIME,
 x_ese_id=>X_ESE_ID,
 x_exam_cal_type=>X_EXAM_CAL_TYPE,
 x_exam_ci_sequence_number=>X_EXAM_CI_SEQUENCE_NUMBER,
 x_override_end_time=>X_OVERRIDE_END_TIME,
 x_override_start_time=>X_OVERRIDE_START_TIME,
 x_special_announcements=>X_SPECIAL_ANNOUNCEMENTS,
 x_special_instructions=>X_SPECIAL_INSTRUCTIONS,
 x_special_session_ind=>X_SPECIAL_SESSION_IND,
 x_start_time=>X_START_TIME,
 x_venue_cd=>X_VENUE_CD,
 x_worked_script_instructions=>X_WORKED_SCRIPT_INSTRUCTIONS,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_AS_EXAM_INSTANCE_ALL (
    ASS_ID,
    ORG_ID,
    EXAM_CAL_TYPE,
    EXAM_CI_SEQUENCE_NUMBER,
    DT_ALIAS,
    DAI_SEQUENCE_NUMBER,
    START_TIME,
    END_TIME,
    ESE_ID,
    VENUE_CD,
    COLLECT_PERSON_ID,
    SPECIAL_SESSION_IND,
    OVERRIDE_START_TIME,
    OVERRIDE_END_TIME,
    SPECIAL_ANNOUNCEMENTS,
    SPECIAL_INSTRUCTIONS,
    WORKED_SCRIPT_INSTRUCTIONS,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ASS_ID,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.EXAM_CAL_TYPE,
    NEW_REFERENCES.EXAM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.START_TIME,
    NEW_REFERENCES.END_TIME,
    NEW_REFERENCES.ESE_ID,
    NEW_REFERENCES.VENUE_CD,
    NEW_REFERENCES.COLLECT_PERSON_ID,
    NEW_REFERENCES.SPECIAL_SESSION_IND,
    NEW_REFERENCES.OVERRIDE_START_TIME,
    NEW_REFERENCES.OVERRIDE_END_TIME,
    NEW_REFERENCES.SPECIAL_ANNOUNCEMENTS,
    NEW_REFERENCES.SPECIAL_INSTRUCTIONS,
    NEW_REFERENCES.WORKED_SCRIPT_INSTRUCTIONS,
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

end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_COLLECT_PERSON_ID in NUMBER,
  X_SPECIAL_SESSION_IND in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
  X_SPECIAL_ANNOUNCEMENTS in VARCHAR2,
  X_SPECIAL_INSTRUCTIONS in VARCHAR2,
  X_WORKED_SCRIPT_INSTRUCTIONS in VARCHAR2,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      ESE_ID,
      COLLECT_PERSON_ID,
      SPECIAL_SESSION_IND,
      OVERRIDE_START_TIME,
      OVERRIDE_END_TIME,
      SPECIAL_ANNOUNCEMENTS,
      SPECIAL_INSTRUCTIONS,
      WORKED_SCRIPT_INSTRUCTIONS,
      COMMENTS
    from IGS_AS_EXAM_INSTANCE_ALL
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
      AND ((tlinfo.COLLECT_PERSON_ID = X_COLLECT_PERSON_ID)
           OR ((tlinfo.COLLECT_PERSON_ID is null)
               AND (X_COLLECT_PERSON_ID is null)))
      AND (tlinfo.SPECIAL_SESSION_IND = X_SPECIAL_SESSION_IND)
      AND ((tlinfo.OVERRIDE_START_TIME = X_OVERRIDE_START_TIME)
           OR ((tlinfo.OVERRIDE_START_TIME is null)
               AND (X_OVERRIDE_START_TIME is null)))
      AND ((tlinfo.OVERRIDE_END_TIME = X_OVERRIDE_END_TIME)
           OR ((tlinfo.OVERRIDE_END_TIME is null)
               AND (X_OVERRIDE_END_TIME is null)))
      AND ((tlinfo.SPECIAL_ANNOUNCEMENTS = X_SPECIAL_ANNOUNCEMENTS)
           OR ((tlinfo.SPECIAL_ANNOUNCEMENTS is null)
               AND (X_SPECIAL_ANNOUNCEMENTS is null)))
      AND ((tlinfo.SPECIAL_INSTRUCTIONS = X_SPECIAL_INSTRUCTIONS)
           OR ((tlinfo.SPECIAL_INSTRUCTIONS is null)
               AND (X_SPECIAL_INSTRUCTIONS is null)))
      AND ((tlinfo.WORKED_SCRIPT_INSTRUCTIONS = X_WORKED_SCRIPT_INSTRUCTIONS)
           OR ((tlinfo.WORKED_SCRIPT_INSTRUCTIONS is null)
               AND (X_WORKED_SCRIPT_INSTRUCTIONS is null)))
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
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_COLLECT_PERSON_ID in NUMBER,
  X_SPECIAL_SESSION_IND in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
  X_SPECIAL_ANNOUNCEMENTS in VARCHAR2,
  X_SPECIAL_INSTRUCTIONS in VARCHAR2,
  X_WORKED_SCRIPT_INSTRUCTIONS in VARCHAR2,
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
 x_ass_id=>X_ASS_ID,
 x_collect_person_id=>X_COLLECT_PERSON_ID,
 x_comments=>X_COMMENTS,
 x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
 x_dt_alias=>X_DT_ALIAS,
 x_end_time=>X_END_TIME,
 x_ese_id=>X_ESE_ID,
 x_exam_cal_type=>X_EXAM_CAL_TYPE,
 x_exam_ci_sequence_number=>X_EXAM_CI_SEQUENCE_NUMBER,
 x_override_end_time=>X_OVERRIDE_END_TIME,
 x_override_start_time=>X_OVERRIDE_START_TIME,
 x_special_announcements=>X_SPECIAL_ANNOUNCEMENTS,
 x_special_instructions=>X_SPECIAL_INSTRUCTIONS,
 x_special_session_ind=>X_SPECIAL_SESSION_IND,
 x_start_time=>X_START_TIME,
 x_venue_cd=>X_VENUE_CD,
 x_worked_script_instructions=>X_WORKED_SCRIPT_INSTRUCTIONS,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_AS_EXAM_INSTANCE_ALL set
    ESE_ID = NEW_REFERENCES.ESE_ID,
    COLLECT_PERSON_ID = NEW_REFERENCES.COLLECT_PERSON_ID,
    SPECIAL_SESSION_IND = NEW_REFERENCES.SPECIAL_SESSION_IND,
    OVERRIDE_START_TIME = NEW_REFERENCES.OVERRIDE_START_TIME,
    OVERRIDE_END_TIME = NEW_REFERENCES.OVERRIDE_END_TIME,
    SPECIAL_ANNOUNCEMENTS = NEW_REFERENCES.SPECIAL_ANNOUNCEMENTS,
    SPECIAL_INSTRUCTIONS = NEW_REFERENCES.SPECIAL_INSTRUCTIONS,
    WORKED_SCRIPT_INSTRUCTIONS = NEW_REFERENCES.WORKED_SCRIPT_INSTRUCTIONS,
    COMMENTS = NEW_REFERENCES.COMMENTS,
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
  X_ASS_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_COLLECT_PERSON_ID in NUMBER,
  X_SPECIAL_SESSION_IND in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
  X_SPECIAL_ANNOUNCEMENTS in VARCHAR2,
  X_SPECIAL_INSTRUCTIONS in VARCHAR2,
  X_WORKED_SCRIPT_INSTRUCTIONS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_EXAM_INSTANCE_ALL
     where ASS_ID = X_ASS_ID
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
     X_ASS_ID,
     X_ORG_ID,
     X_EXAM_CAL_TYPE,
     X_EXAM_CI_SEQUENCE_NUMBER,
     X_DT_ALIAS,
     X_DAI_SEQUENCE_NUMBER,
     X_START_TIME,
     X_END_TIME,
     X_VENUE_CD,
     X_ESE_ID,
     X_COLLECT_PERSON_ID,
     X_SPECIAL_SESSION_IND,
     X_OVERRIDE_START_TIME,
     X_OVERRIDE_END_TIME,
     X_SPECIAL_ANNOUNCEMENTS,
     X_SPECIAL_INSTRUCTIONS,
     X_WORKED_SCRIPT_INSTRUCTIONS,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ASS_ID,
   X_EXAM_CAL_TYPE,
   X_EXAM_CI_SEQUENCE_NUMBER,
   X_DT_ALIAS,
   X_DAI_SEQUENCE_NUMBER,
   X_START_TIME,
   X_END_TIME,
   X_VENUE_CD,
   X_ESE_ID,
   X_COLLECT_PERSON_ID,
   X_SPECIAL_SESSION_IND,
   X_OVERRIDE_START_TIME,
   X_OVERRIDE_END_TIME,
   X_SPECIAL_ANNOUNCEMENTS,
   X_SPECIAL_INSTRUCTIONS,
   X_WORKED_SCRIPT_INSTRUCTIONS,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) is
begin
  Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_EXAM_INSTANCE_ALL
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
      ELSIF upper(Column_name) = 'SPECIAL_SESSION_IND' then
	    new_references.SPECIAL_SESSION_IND := column_value;
      ELSIF upper(Column_name) = 'VENUE_CD' then
	    new_references.VENUE_CD := column_value;
      ELSIF upper(Column_name) = 'DAI_SEQUENCE_NUMBER' then
	    new_references.DAI_SEQUENCE_NUMBER := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'EXAM_CI_SEQUENCE_NUMBER' then
	    new_references.EXAM_CI_SEQUENCE_NUMBER := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'SPECIAL_SESSION_IND' then
	    new_references.SPECIAL_SESSION_IND := column_value;
      ELSIF upper(Column_name) = 'ESE_ID' then
	    new_references.ESE_ID := igs_ge_number.to_num(column_value);
      END IF;

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
      IF upper(column_name) = 'SPECIAL_SESSION_IND' OR
     column_name is null Then
     IF new_references.SPECIAL_SESSION_IND <> UPPER(new_references.SPECIAL_SESSION_IND) Then
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
     IF new_references.DAI_SEQUENCE_NUMBER < 1 OR new_references.DAI_SEQUENCE_NUMBER > 99999  Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

            IF upper(column_name) = 'EXAM_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.EXAM_CI_SEQUENCE_NUMBER < 1 OR new_references.EXAM_CI_SEQUENCE_NUMBER> 99999  Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

      IF upper(column_name) = 'SPECIAL_SESSION_IND' OR
     column_name is null Then
     IF new_references.SPECIAL_SESSION_IND NOT IN ('Y','N')   Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'ESE_ID' OR
     column_name is null Then
     IF new_references.ESE_ID < 1 OR  new_references.ESE_ID > 999999  Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


END Check_Constraints;

end IGS_AS_EXAM_INSTANCE_PKG;

/
