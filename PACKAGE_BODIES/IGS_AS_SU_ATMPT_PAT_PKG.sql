--------------------------------------------------------
--  DDL for Package Body IGS_AS_SU_ATMPT_PAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SU_ATMPT_PAT_PKG" AS
/* $Header: IGSDI07B.pls 120.0 2005/07/05 11:43:45 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The reference to igs_as_val_uai.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  --svanukur    29-APR-03    Added new column uoo_id, redefined primary Key  from
  --                          (person_id,course_cd,unit_cd,cal_type,ci_sequence_number,ass_pattern_id,creation_dt) to
  --                          (person_id,course_cd,uoo_id,ass_pattern_id,creation_dt)redefined FK
  --                           to (PERSON_ID, COURSE_CD,UOO_ID)as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_AS_SU_ATMPT_PAT%RowType;
  new_references IGS_AS_SU_ATMPT_PAT%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_pattern_id IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_s_default_ind IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_SU_ATMPT_PAT
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
    new_references.course_cd := x_course_cd;
    new_references.unit_cd := x_unit_cd;
    new_references.cal_type:= x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.ass_pattern_id := x_ass_pattern_id;
    new_references.creation_dt := x_creation_dt;
    new_references.s_default_ind := x_s_default_ind;
    new_references.logical_delete_dt := x_logical_delete_dt;
    new_references.uoo_id := x_uoo_id;
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

   -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    Passed uoo_id to IGS_AS_GEN_004.ASSP_INS_SUAAP_SUAAI as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------


  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
	v_error_count		NUMBER;
	v_warning_count		NUMBER;
	v_version_number		IGS_EN_SU_ATTEMPT.version_number%TYPE;
	CURSOR	c_sua	(cp_person_id		IGS_EN_SU_ATTEMPT.person_id%TYPE,
			cp_course_cd		IGS_EN_SU_ATTEMPT.course_cd%TYPE,
			cp_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
		SELECT	version_number
		FROM	IGS_EN_SU_ATTEMPT
		WHERE person_id		= cp_person_id	AND
			  course_cd		= cp_course_cd	AND
			  uoo_id        = cp_uoo_id;
  BEGIN
	-- If p_inserting, validate that the assessment pattern is applicable to the
	-- student IGS_PS_UNIT attempt and that the IGS_PS_UNIT attempt status is ENROLLED or
	-- UNCONFIRMED.
	IF p_inserting THEN
		IF IGS_AS_VAL_SUAAP.assp_val_suaap_ins(new_references.person_id,
						new_references.course_cd,
						new_references.unit_cd,
						new_references.cal_type,
						new_references.ci_sequence_number,
						new_references.ass_pattern_id,
						v_message_name,
                        new_references.uoo_id) = FALSE THEN
						FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
						APP_EXCEPTION.RAISE_EXCEPTION;

		END IF;
		OPEN 	c_sua(	new_references.person_id,
				new_references.course_cd,
				new_references.uoo_id);
		FETCH	c_sua 	INTO v_version_number;
		IF c_sua%NOTFOUND THEN
			CLOSE	c_sua;
			RAISE NO_DATA_FOUND;
		END IF;
		CLOSE	c_sua;
		-- Check if IGS_AS_GEN_004.ASSP_INS_SUAAP_DFLT has not disabled the trigger
		-- and the logical delete date is not set.
		IF IGS_AS_VAL_SUAAP.GENP_VAL_SDTT_SESS('IGS_AS_SU_ATMPT_PAT') AND
		    (NVL(new_references.logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))
		     =  NVL(old_references.logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
			-- Allocate unit_ass_pattern_items within the pattern to the student
			-- (IGS_AS_SU_ATMPT_ITM).
			IF IGS_AS_GEN_004.ASSP_INS_SUAAP_SUAAI(new_references.person_id,
					new_references.course_cd,
					new_references.unit_cd,
					v_version_number,
					new_references.cal_type,
					new_references.ci_sequence_number,
					new_references.ass_pattern_id,
					new_references.creation_dt,
					new_references.s_default_ind,
                    'Y', -- Called from database trigger.
					v_message_name,
                    new_references.uoo_id) = FALSE THEN
				FND_MESSAGE.SET_NAME('IGS',v_message_name); APP_EXCEPTION.RAISE_EXCEPTION;
IGS_GE_MSG_STACK.ADD;
			END IF;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;
  -- Trigger description :-
  -- "OSS_TST".trg_suaap_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_SU_ATMPT_PAT
  -- FOR EACH ROW
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    Passed uoo_id to IGS_AS_GEN_001.ASSP_DEL_SUAAP_SUAAI, IGS_AS_VAL_SUAAP.assp_val_suaap_actv as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
     v_message_name	VARCHAR2(30);
     v_error_count      NUMBER(5);
     v_warning_count    NUMBER;
  BEGIN
  	IF p_inserting  THEN
               IF IGS_AS_VAL_SUAAP.assp_val_suaap_actv(	new_references.person_id,
  						new_references.course_cd,
  						new_references.unit_cd,
  						new_references.cal_type,
  						new_references.ci_sequence_number,
  						new_references.ass_pattern_id,
  						new_references.creation_dt,
  						v_message_name,
                        new_references.uoo_id) = FALSE THEN
  			FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
  			END IF;
  		-- Validate there is only one active instance of the pattern for the student..
  		-- Cannot call assp_val_suaap_activ because trigger will be mutating.
  		 -- Save the rowid of the current row.
  	END IF;
  	IF p_updating AND
  	   (NVL(new_references.logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))
  		<>  NVL(old_references.logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
  		-- If logically p_deleting the suaap record.
  		-- Check if IGS_AS_GEN_001.ASSP_DEL_SUAAP_DFLT has not disabled the trigger.
  		IF IGS_AS_VAL_SUAAP.GENP_VAL_SDTT_SESS('IGS_AS_SU_ATMPT_PAT') THEN
           IF IGS_AS_GEN_001.ASSP_DEL_SUAAP_SUAAI(	new_references.person_id,
  						new_references.course_cd,
  						new_references.unit_cd,
  						new_references.cal_type,
  						new_references.ci_sequence_number,
  						new_references.ass_pattern_id,
  						new_references.creation_dt,
                        NULL,	-- p_ass_id
  					'Y', -- Called from database trigger.
  					NULL,	-- p_s_log_type
  					NULL,	-- p_key
  					NULL,	-- p_ssl_key
  					v_error_count,
  					v_warning_count,
  					v_message_name,
                    new_references.uoo_id) = FALSE THEN
  				FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
  			END IF;
  			-- Logically delete unit_ass_pattern_items within the pattern to the student
  			-- (IGS_AS_SU_ATMPT_ITM).
  			-- Store away the rowid as the routine IGS_AS_GEN_001.ASSP_DEL_SUAAP_SUAAI will cause the
  			-- trigger to be mutating.
  		--	IGS_AS_VAL_SUAAP.genp_set_rowid(l_rowid);
 		END IF;
  	END IF;
  END AfterRowInsertUpdate2;
  -- Trigger description :-
  -- "OSS_TST".trg_suaap_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_SU_ATMPT_PAT
  PROCEDURE Check_Parent_Existance IS
  BEGIN
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.uoo_id= new_references.uoo_id)) OR
		 ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT       IGS_EN_SU_ATTEMPT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd,
        new_references.uoo_id
        )THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.ass_pattern_id = new_references.ass_pattern_id)) OR
        ((new_references.ass_pattern_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_UNTAS_PATTERN_PKG.Get_UK_For_Validation (
        new_references.ass_pattern_id         ) 	THEN
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
    x_course_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_ass_pattern_id IN NUMBER,
    x_creation_dt IN DATE,
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_SU_ATMPT_PAT
      WHERE    course_cd = x_course_cd
      AND      person_id = x_person_id
      AND      ass_pattern_id = x_ass_pattern_id
      AND      creation_dt = x_creation_dt
      AND      uoo_id = x_uoo_id
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
  PROCEDURE GET_FK_IGS_EN_SU_ATTEMPT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_uoo_id IN NUMBER
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_SU_ATMPT_PAT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      uoo_id = x_uoo_id;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUAAP_SUA_FK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_SU_ATTEMPT;
  PROCEDURE GET_UFK_IGS_AS_UNTAS_PATTERN (
    x_ass_pattern_id IN NUMBER
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_SU_ATMPT_PAT
      WHERE    ass_pattern_id = x_ass_pattern_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUAAP_SUA_FK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_UFK_IGS_AS_UNTAS_PATTERN;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_pattern_id IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_s_default_ind IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_ass_pattern_id,
      x_creation_dt,
      x_s_default_ind,
      x_logical_delete_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_uoo_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF  Get_PK_For_Validation (
    NEW_REFERENCES.course_cd ,
    NEW_REFERENCES.person_id ,
    NEW_REFERENCES.ass_pattern_id ,
    NEW_REFERENCES.creation_dt,
    NEW_REFERENCES.uoo_id) THEN
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

    new_references.course_cd ,
    new_references.person_id ,
    new_references.ass_pattern_id ,
    new_references.creation_dt,
    new_references.uoo_id) THEN
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
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_S_DEFAULT_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_AS_SU_ATMPT_PAT
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and ASS_PATTERN_ID = X_ASS_PATTERN_ID
      and CREATION_DT = X_CREATION_DT
      and UOO_ID = X_UOO_ID;
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
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_ass_pattern_id=>X_ASS_PATTERN_ID,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_course_cd=>X_COURSE_CD,
  x_creation_dt=>X_CREATION_DT,
  x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
  x_person_id=>X_PERSON_ID,
  x_s_default_ind=> NVL(X_S_DEFAULT_IND,'N'),
  x_unit_cd=>X_UNIT_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_uoo_id=>X_UOO_ID
  );
  insert into IGS_AS_SU_ATMPT_PAT (
    PERSON_ID,
    COURSE_CD,
    UNIT_CD,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    ASS_PATTERN_ID,
    CREATION_DT,
    S_DEFAULT_IND,
    LOGICAL_DELETE_DT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    UOO_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ASS_PATTERN_ID,
    NEW_REFERENCES.CREATION_DT,
    NEW_REFERENCES.S_DEFAULT_IND,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.UOO_ID
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
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_S_DEFAULT_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_UOO_ID in NUMBER
) AS
  cursor c1 is select
      S_DEFAULT_IND,
      LOGICAL_DELETE_DT
    from IGS_AS_SU_ATMPT_PAT
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
  if ( (tlinfo.S_DEFAULT_IND = X_S_DEFAULT_IND)
      AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
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
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_S_DEFAULT_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
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
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_ass_pattern_id=>X_ASS_PATTERN_ID,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_course_cd=>X_COURSE_CD,
  x_creation_dt=>X_CREATION_DT,
  x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
  x_person_id=>X_PERSON_ID,
  x_s_default_ind=>X_S_DEFAULT_IND,
  x_unit_cd=>X_UNIT_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_uoo_id=>X_UOO_ID
  );
 if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
end if;
  update IGS_AS_SU_ATMPT_PAT set
    S_DEFAULT_IND = NEW_REFERENCES.S_DEFAULT_IND,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_S_DEFAULT_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_AS_SU_ATMPT_PAT
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and ASS_PATTERN_ID = X_ASS_PATTERN_ID
     and CREATION_DT = X_CREATION_DT
     and UOO_ID = X_UOO_ID
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_UNIT_CD,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_ASS_PATTERN_ID,
     X_CREATION_DT,
     X_S_DEFAULT_IND,
     X_LOGICAL_DELETE_DT,
     X_MODE,
     X_UOO_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_UNIT_CD,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_ASS_PATTERN_ID,
   X_CREATION_DT,
   X_S_DEFAULT_IND,
   X_LOGICAL_DELETE_DT,
   X_MODE,
   X_UOO_ID);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_SU_ATMPT_PAT
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
	ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
	    new_references.CI_SEQUENCE_NUMBER := igs_ge_number.to_num(column_value);

		ELSIF upper(Column_name) = 'S_DEFAULT_IND' then
	    new_references.S_DEFAULT_IND := column_value;
    END IF;

IF upper(column_name) = 'CI_SEQUENCE_NUMBER ' OR
     column_name is null Then
     IF new_references.ci_sequence_number <  1 OR  new_references.ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


IF upper(column_name) = 'S_DEFAULT_IND' OR
     column_name is null Then
     IF new_references.S_DEFAULT_IND  NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


	END Check_Constraints;
end IGS_AS_SU_ATMPT_PAT_PKG;

/
