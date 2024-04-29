--------------------------------------------------------
--  DDL for Package Body IGS_AS_STD_EXM_INSTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_STD_EXM_INSTN_PKG" AS
/* $Header: IGSDI09B.pls 120.0 2005/07/05 12:08:58 appldev noship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_AS_STD_EXM_INSTN_ALL%RowType;
  new_references IGS_AS_STD_EXM_INSTN_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_seat_number IN NUMBER DEFAULT NULL,
    x_timeslot IN DATE DEFAULT NULL,
    x_timeslot_duration IN DATE DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_ese_id IN NUMBER DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_attendance_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_std_exm_instn_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_STD_EXM_INSTN_ALL
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
    new_references.seat_number := x_seat_number;
    new_references.timeslot := x_timeslot;
    new_references.timeslot_duration := x_timeslot_duration;
    new_references.ass_id := x_ass_id;
    new_references.exam_cal_type := x_exam_cal_type;
    new_references.exam_ci_sequence_number := x_exam_ci_sequence_number;
    new_references.dt_alias:= x_dt_alias;
    new_references.dai_sequence_number := x_dai_sequence_number;
    new_references.start_time := x_start_time;
    new_references.end_time := x_end_time;
    new_references.ese_id := x_ese_id;
    new_references.venue_cd := x_venue_cd;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.unit_cd := x_unit_cd;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.creation_dt := x_creation_dt;
    new_references.attendance_ind := x_attendance_ind;
    new_references.uoo_id := x_uoo_id;
    new_references.std_exm_instn_id := x_std_exm_instn_id;
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

  -- Trigger description :-
  -- "OSS_TST".trg_sei_br_i
  -- BEFORE INSERT
  -- ON IGS_AS_STD_EXM_INSTN
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS

  	v_message_name		VARCHAR2(30);
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
  	-- Validate the teaching calendar instance against the examination calendar
  	-- instance.
  	IF IGS_AS_VAL_SEI.assp_val_sei_ci(	new_references.cal_type,
  					new_references.ci_sequence_number,
  					new_references.exam_cal_type,
  					new_references.exam_ci_sequence_number,
  					v_message_name) = FALSE THEN
  		FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  	END IF;


  END BeforeRowInsert1;

  -- Trigger description :-
  -- "OSS_TST".trg_sei_ar_i
  -- AFTER INSERT
  -- ON IGS_AS_STD_EXM_INSTN
  -- FOR EACH ROW

  PROCEDURE AfterRowInsert2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
	v_rowid_saved		BOOLEAN := FALSE;
  BEGIN
	IF v_rowid_saved = FALSE
	THEN
           IF  IGS_AS_VAL_SEI.assp_val_sei_dplct (
                  new_references.person_id,
                  new_references.course_cd,
                  new_references.unit_cd,
                  new_references.cal_type,
                  new_references.ci_sequence_number,
                  new_references.exam_cal_type,
                  new_references.exam_ci_sequence_number,
                  new_references.dt_alias,
                  new_references.dai_sequence_number,
                  new_references.start_time,
                  new_references.end_time,
                  new_references.ass_id,
                  new_references.venue_cd,
                  v_message_name,
                  new_references.uoo_id) = FALSE THEN
 FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
          END IF;
		v_rowid_saved := TRUE;
	END IF;


  END AfterRowInsert2;

  -- Trigger description :-
  -- "OSS_TST".trg_sei_as_i
  -- AFTER INSERT
  -- ON IGS_AS_STD_EXM_INSTN
  PROCEDURE Check_Uniqueness AS

BEGIN
    IF Get_Uk_For_Validation(
     x_ass_id =>new_references.ass_id,
    x_exam_cal_type =>new_references.exam_cal_type,
    x_exam_ci_sequence_number => new_references.exam_ci_sequence_number,
    x_dt_alias => new_references.dt_alias,
    x_dai_sequence_number =>new_references.dai_sequence_number,
    x_start_time =>new_references.start_time,
    x_end_time =>new_references.end_time,
    x_venue_cd =>new_references.venue_cd,
    x_person_id =>new_references.person_id,
    x_course_cd =>new_references.course_cd,
    x_creation_dt =>new_references.creation_dt ,
    x_uoo_id =>new_references.uoo_id)    THEN

    FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

END Check_Uniqueness;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.ass_id = new_references.ass_id) AND
         (old_references.exam_cal_type = new_references.exam_cal_type) AND
         (old_references.exam_ci_sequence_number = new_references.exam_ci_sequence_number) AND
         (old_references.dt_alias= new_references.dt_alias) AND
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
        new_references.venue_cd
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

    IF (((old_references.ese_id = new_references.ese_id)) OR
        ((new_references.ese_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_EXAM_SESSION_PKG.Get_UK_For_Validation (
        new_references.ese_id
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

    IF (((old_references.course_cd = new_references.course_cd) OR
         (old_references.person_id = new_references.person_id) OR
         (old_references.ass_id = new_references.ass_id) OR
         (old_references.creation_dt = new_references.creation_dt) OR
         (old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.person_id IS NULL) OR
         (new_references.ass_id IS NULL) OR
         (new_references.creation_dt IS NULL) OR
         (new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_SU_ATMPT_ITM_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.person_id,
        new_references.ass_id,
        new_references.creation_dt,
        new_references.uoo_id
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

  END Check_Parent_Existance;

-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    changed the PK columns as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  FUNCTION Get_PK_For_Validation (
    x_std_exm_instn_id in NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_STD_EXM_INSTN_ALL
      WHERE    std_exm_instn_id = x_std_exm_instn_id
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

FUNCTION Get_Uk_For_Validation (
    x_ass_id IN NUMBER,
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_start_time IN DATE,
    x_end_time IN DATE,
    x_venue_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_creation_dt IN DATE,
    x_uoo_id in NUMBER
    ) RETURN BOOLEAN AS
  CURSOR cur_sua IS
    SELECT ROWID
    FROM   IGS_AS_STD_EXM_INSTN_ALL
    WHERE  ass_id   = x_ass_id
    AND    exam_cal_type   = x_exam_cal_type
    AND    exam_ci_sequence_number = x_exam_ci_sequence_number
    AND    start_time  = x_start_time
    AND    end_time    = x_end_time
    AND    venue_cd    =x_venue_cd
    AND    person_id   =x_person_id
    AND    course_cd   = x_course_cd
    AND    creation_dt =x_creation_dt
    AND    uoo_id         =x_uoo_id
    AND    dt_alias = x_dt_alias
    AND   dai_sequence_number = x_dai_sequence_number
    AND    ((l_rowid IS NULL) OR (rowid <> l_rowid));
  lv_row_id     cur_sua%ROWTYPE;
 BEGIN

    OPEN cur_sua;
    FETCH cur_sua INTO lv_row_id;
    IF cur_sua%FOUND THEN
      CLOSE cur_sua;
      RETURN(TRUE);
    ELSE
      CLOSE cur_sua;
      RETURN(FALSE);
    END IF;

 END Get_Uk_For_Validation;

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
      FROM     IGS_AS_STD_EXM_INSTN_ALL
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
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SEI_EI_FK');
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
      FROM     IGS_AS_STD_EXM_INSTN_ALL
      WHERE    ese_id = x_ese_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SEI_ESE_UFK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_AS_EXAM_SESSION;

  PROCEDURE GET_FK_IGS_AS_SU_ATMPT_ITM (
    x_course_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_ass_id IN NUMBER,
    x_creation_dt IN DATE,
    x_uoo_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_STD_EXM_INSTN_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      ass_id = x_ass_id
      AND      creation_dt = x_creation_dt
      AND      uoo_id = x_uoo_id;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SEI_SUAAI_FK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_SU_ATMPT_ITM;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_seat_number IN NUMBER DEFAULT NULL,
    x_timeslot IN DATE DEFAULT NULL,
    x_timeslot_duration IN DATE DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_ese_id IN NUMBER DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_attendance_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id in NUMBER DEFAULT NULL,
    x_std_exm_instn_id in NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_seat_number,
      x_timeslot,
      x_timeslot_duration,
      x_ass_id,
      x_exam_cal_type,
      x_exam_ci_sequence_number,
      x_dt_alias,
      x_dai_sequence_number,
      x_start_time,
      x_end_time,
      x_ese_id,
      x_venue_cd,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_creation_dt,
      x_attendance_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_uoo_id,
      x_std_exm_instn_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsert1 ( p_inserting => TRUE );
      	IF  Get_PK_For_Validation (
	    NEW_REFERENCES.std_exm_instn_id
           ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;

      Check_Parent_Existance;
      Check_Uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

       Check_Constraints;

      Check_Parent_Existance;
      Check_Uniqueness;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation (
	       NEW_REFERENCES.std_exm_instn_id) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;
         Check_Uniqueness;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	      Check_Constraints;
          Check_Uniqueness;


    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsert2 ( p_inserting => TRUE );



    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_SEAT_NUMBER in NUMBER,
  X_TIMESLOT in DATE,
  X_TIMESLOT_DURATION in DATE,
  X_ESE_ID in NUMBER,
  X_ATTENDANCE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER,
  X_STD_EXM_INSTN_ID in out NOCOPY NUMBER
  ) AS
  /*---------------------------------------------------------------------------------------
  --Change History
  --Who		when		What
  --sbaliga	12-feb-2002	Assigned igs_ge_gen_003.get_org_id to x_org_id
  --				in call to before_dml as part of SWCR006 build.
  --svanukur 29-apr-03  changed the where clause to reflect the new PK
  --                     as part of MUS build, # 2829262
  ---------------------------------------------------------------------------------------*/
    cursor C is select ROWID from IGS_AS_STD_EXM_INSTN_ALL
      where STD_EXM_INSTN_ID = X_STD_EXM_INSTN_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
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

SELECT IGS_AS_STD_EXM_INSTN_ALL_S.nextval
INTO X_STD_EXM_INSTN_ID
FROM DUAL;

  Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_org_id=>igs_ge_gen_003.get_org_id,
  x_ass_id=>X_ASS_ID,
  x_attendance_ind=>X_ATTENDANCE_IND,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_course_cd=>X_COURSE_CD,
  x_creation_dt=>X_CREATION_DT,
  x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
  x_dt_alias=>X_DT_ALIAS,
  x_end_time=>X_END_TIME,
  x_ese_id=>X_ESE_ID,
  x_exam_cal_type=>X_EXAM_CAL_TYPE,
  x_exam_ci_sequence_number=>X_EXAM_CI_SEQUENCE_NUMBER,
  x_person_id=>X_PERSON_ID,
  x_seat_number=>X_SEAT_NUMBER,
  x_start_time=>X_START_TIME,
  x_timeslot=>X_TIMESLOT,
  x_timeslot_duration=>X_TIMESLOT_DURATION,
  x_unit_cd=>X_UNIT_CD,
  x_venue_cd=>X_VENUE_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_uoo_id => X_UOO_ID,
  x_std_exm_instn_id =>X_STD_EXM_INSTN_ID
  );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_AS_STD_EXM_INSTN_ALL (
    ORG_ID,
    SEAT_NUMBER,

    TIMESLOT,
    TIMESLOT_DURATION,
    ASS_ID,
    EXAM_CAL_TYPE,
    EXAM_CI_SEQUENCE_NUMBER,
    DT_ALIAS,
    DAI_SEQUENCE_NUMBER,
    START_TIME,
    END_TIME,
    ESE_ID,
    VENUE_CD,
    PERSON_ID,
    COURSE_CD,
    UNIT_CD,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    CREATION_DT,
    ATTENDANCE_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    UOO_ID,
    STD_EXM_INSTN_ID
  ) values (
        new_references.ORG_ID,
    	new_references.SEAT_NUMBER,
    	new_references.TIMESLOT,
    	new_references.TIMESLOT_DURATION,
    	new_references.ASS_ID,
    	new_references.EXAM_CAL_TYPE,
    	new_references.EXAM_CI_SEQUENCE_NUMBER,
    	new_references.DT_ALIAS,
    	new_references.DAI_SEQUENCE_NUMBER,
    	new_references.START_TIME,
    	new_references.END_TIME,
    	new_references.ESE_ID,
    	new_references.VENUE_CD,
    	new_references.PERSON_ID,
    	new_references.COURSE_CD,
    	new_references.UNIT_CD,
    	new_references.CAL_TYPE,
    	new_references.CI_SEQUENCE_NUMBER,
    	new_references.CREATION_DT,
    	new_references.ATTENDANCE_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    new_references.uoo_id,
    new_references.STD_EXM_INSTN_ID
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_SEAT_NUMBER in NUMBER,
    X_TIMESLOT in DATE,
  X_TIMESLOT_DURATION in DATE,
  X_ESE_ID in NUMBER,
  X_ATTENDANCE_IND in VARCHAR2,
  X_UOO_ID in NUMBER,
  X_STD_EXM_INSTN_ID in NUMBER
) AS
  cursor c1 is select
      SEAT_NUMBER,
      TIMESLOT,
      TIMESLOT_DURATION,
      ESE_ID,
      ATTENDANCE_IND
    from IGS_AS_STD_EXM_INSTN_ALL
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

      if ( ((tlinfo.SEAT_NUMBER = X_SEAT_NUMBER)
           OR ((tlinfo.SEAT_NUMBER is null)
               AND (X_SEAT_NUMBER is null)))

      AND ((tlinfo.TIMESLOT = X_TIMESLOT)
           OR ((tlinfo.TIMESLOT is null)
               AND (X_TIMESLOT is null)))
      AND ((tlinfo.TIMESLOT_DURATION = X_TIMESLOT_DURATION)
           OR ((tlinfo.TIMESLOT_DURATION is null)
               AND (X_TIMESLOT_DURATION is null)))
      AND (tlinfo.ESE_ID = X_ESE_ID)
      AND (tlinfo.ATTENDANCE_IND = X_ATTENDANCE_IND)
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_SEAT_NUMBER in NUMBER,
    X_TIMESLOT in DATE,
  X_TIMESLOT_DURATION in DATE,
  X_ESE_ID in NUMBER,
  X_ATTENDANCE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER,
  X_STD_EXM_INSTN_ID in NUMBER
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
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
  x_attendance_ind=>X_ATTENDANCE_IND,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_course_cd=>X_COURSE_CD,
  x_creation_dt=>X_CREATION_DT,
  x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
  x_dt_alias=>X_DT_ALIAS,
  x_end_time=>X_END_TIME,
  x_ese_id=>X_ESE_ID,
  x_exam_cal_type=>X_EXAM_CAL_TYPE,
  x_exam_ci_sequence_number=>X_EXAM_CI_SEQUENCE_NUMBER,
  x_person_id=>X_PERSON_ID,
  x_seat_number=>X_SEAT_NUMBER,
  x_start_time=>X_START_TIME,
  x_timeslot=>X_TIMESLOT,
  x_timeslot_duration=>X_TIMESLOT_DURATION,
  x_unit_cd=>X_UNIT_CD,
  x_venue_cd=>X_VENUE_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_uoo_id => X_UOO_ID,
  x_std_exm_instn_id => X_STD_EXM_INSTN_ID
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_AS_STD_EXM_INSTN_ALL set
    SEAT_NUMBER = 	new_references.SEAT_NUMBER,
       TIMESLOT = 	new_references.TIMESLOT,
    TIMESLOT_DURATION = 	new_references.TIMESLOT_DURATION,
    ESE_ID = 	new_references.ESE_ID,
    ATTENDANCE_IND = 	new_references.ATTENDANCE_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where  ROWID = X_ROWID
  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_SEAT_NUMBER in NUMBER,
    X_TIMESLOT in DATE,
  X_TIMESLOT_DURATION in DATE,
  X_ESE_ID in NUMBER,
  X_ATTENDANCE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_uoo_id in NUMBER,
  x_std_exm_instn_id in out NOCOPY NUMBER
  ) AS
  cursor c1 is select rowid from IGS_AS_STD_EXM_INSTN_ALL
     where std_exm_instn_id = X_STD_EXM_INSTN_ID;



begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_ASS_ID,
     X_EXAM_CAL_TYPE,
     X_EXAM_CI_SEQUENCE_NUMBER,
     X_DT_ALIAS,
     X_DAI_SEQUENCE_NUMBER,
     X_START_TIME,
     X_END_TIME,
     X_VENUE_CD,
     X_PERSON_ID,
     X_COURSE_CD,
     X_UNIT_CD,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_CREATION_DT,
     X_SEAT_NUMBER,
     X_TIMESLOT,
     X_TIMESLOT_DURATION,
     X_ESE_ID,
     X_ATTENDANCE_IND,
     X_MODE,
     X_UOO_ID,
     X_STD_EXM_INSTN_ID);
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
   X_PERSON_ID,
   X_COURSE_CD,
   X_UNIT_CD,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_CREATION_DT,
   X_SEAT_NUMBER,
      X_TIMESLOT,
   X_TIMESLOT_DURATION,
   X_ESE_ID,
   X_ATTENDANCE_IND,
   X_MODE,
   X_UOO_ID,
   X_STD_EXM_INSTN_ID);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin
  Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_AS_STD_EXM_INSTN_ALL
   where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)
	AS
	BEGIN
		IF  column_name is null then
	    NULL;
	ELSIF upper(Column_name) = 'ATTENDANCE_IND' then
	    new_references.ATTENDANCE_IND := column_value;
     ELSIF upper(Column_name) = 'ESE_ID' then
	    new_references.ESE_ID := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(Column_name) = 'DAI_SEQUENCE_NUMBER' then
	    new_references.DAI_SEQUENCE_NUMBER := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(Column_name) = 'EXAM_CI_SEQUENCE_NUMBER' then
	    new_references.EXAM_CI_SEQUENCE_NUMBER := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(Column_name) = 'ATTENDANCE_IND' then
	    new_references.ATTENDANCE_IND := column_value;
	ELSIF upper(Column_name) = 'CAL_TYPE' then
	    new_references.CAL_TYPE := column_value;
	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.COURSE_CD := column_value;
	ELSIF upper(Column_name) = 'DT_ALIAS' then
	    new_references.DT_ALIAS := column_value;
	ELSIF upper(Column_name) = 'EXAM_CAL_TYPE' then
	    new_references.EXAM_CAL_TYPE := column_value;
	ELSIF upper(Column_name) = 'UNIT_CD' then
	    new_references.UNIT_CD := column_value;
	ELSIF upper(Column_name) = 'VENUE_CD' then
	    new_references.VENUE_CD := column_value;
	ELSIF upper(Column_name) = 'SEAT_NUMBER' then
	    new_references.SEAT_NUMBER := IGS_GE_NUMBER.TO_NUM(column_value);
		 end if ;

IF upper(column_name) = 'ATTENDANCE_IND' OR
     column_name is null Then
     IF new_references.ATTENDANCE_IND NOT IN ('Y','N')  Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'ESE_ID' OR
     column_name is null Then
     IF new_references.ESE_ID < 1  OR new_references.ESE_ID > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


IF upper(column_name) = 'DAI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.DAI_SEQUENCE_NUMBER < 1 OR new_references.DAI_SEQUENCE_NUMBER >  999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


IF upper(column_name) = 'EXAM_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.EXAM_CI_SEQUENCE_NUMBER < 1 OR new_references.EXAM_CI_SEQUENCE_NUMBER> 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'ATTENDANCE_IND' OR
     column_name is null Then
     IF new_references.ATTENDANCE_IND <> UPPER(new_references.ATTENDANCE_IND) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
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
IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.UNIT_CD <> UPPER(new_references.UNIT_CD) Then
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

IF upper(column_name) = 'SEAT_NUMBER' OR
     column_name is null Then
     IF new_references.SEAT_NUMBER <  0 OR new_references.SEAT_NUMBER > 9999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

	END Check_Constraints;


end IGS_AS_STD_EXM_INSTN_PKG;

/
