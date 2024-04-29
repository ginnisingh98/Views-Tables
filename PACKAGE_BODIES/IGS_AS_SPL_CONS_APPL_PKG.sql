--------------------------------------------------------
--  DDL for Package Body IGS_AS_SPL_CONS_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SPL_CONS_APPL_PKG" AS
/* $Header: IGSDI10B.pls 120.0 2005/07/05 12:02:13 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AS_SPL_CONS_APPL%RowType;
  new_references IGS_AS_SPL_CONS_APPL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_received_dt IN DATE DEFAULT NULL,
    x_spcl_consideration_cat IN VARCHAR2 DEFAULT NULL,
    x_sought_outcome IN VARCHAR2 DEFAULT NULL,
    x_spcl_consideration_outcome IN VARCHAR2 DEFAULT NULL,
    x_estimated_processing_days IN NUMBER DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_notified_date IN  DATE DEFAULT NULL
  ) IS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_SPL_CONS_APPL
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
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.ass_id := x_ass_id;
    new_references.creation_dt := x_creation_dt;
    new_references.received_dt := x_received_dt;
    new_references.spcl_consideration_cat := x_spcl_consideration_cat;
    new_references.sought_outcome := x_sought_outcome;
    new_references.spcl_consideration_outcome := x_spcl_consideration_outcome;
    new_references.estimated_processing_days := x_estimated_processing_days;
    new_references.tracking_id := x_tracking_id;
    new_references.comments := x_comments;
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
  --svanukur    29-APR-03    Passed uoo_id to IGS_AS_VAL_SCAP.assp_val_suaai_ins , IGS_AS_VAL_SCAP.assp_val_suaai_delet
  --                           as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
		-- <scap1>
		-- Validate IGS_AS_SPCL_CONS_CAT closed indicator
		IF	IGS_AS_VAL_SCAP.assp_val_spcc_closed (	new_references.spcl_consideration_cat,
								v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		-- <scap2>
		-- Validate IGS_AS_SPCL_CONS_OUT closed indicator for
		-- the sought_outcome field
		IF  IGS_AS_VAL_SCAP.assp_val_spco_closed( new_references.sought_outcome,
							v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		-- <scap3>
		-- Validate IGS_AS_SPCL_CONS_OUT closed indicator for
		-- the IGS_AS_SPCL_CONS_OUT field
		IF  IGS_AS_VAL_SCAP.assp_val_spco_closed(	new_references.spcl_consideration_outcome,
							v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
		--<scap4>
		-- Validate SUA is correct status and has valid links
		-- This uses the same valid'n as that for creation of SUAAI,
		-- the latter being slightly different in that they can not be
		-- added for SUA status = 'COMPLETED'. That's why this code
		-- traps for that error and allows valid'n to succeed if it is
		-- encountered
		IF  (IGS_AS_VAL_SCAP.assp_val_suaai_ins (	new_references.person_id,
							new_references.course_cd,
							new_references.unit_cd,
							new_references.cal_type,
							new_references.ci_sequence_number,
							new_references.ass_id,
							v_message_name,
                            new_references.uoo_id) = FALSE AND
				v_message_name <> 'IGS_CA_AA_CIR_FK') THEN
			IF  v_message_name ='IGS_CA_AA_CIR_FK' THEN

				FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
			ELSE
				FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
		END IF;
	END IF;
	IF  p_inserting THEN
		--<scap6>
		IF  IGS_AS_VAL_SCAP.assp_val_suaai_delet(
						new_references.person_id,
						new_references.course_cd,
						new_references.unit_cd,
						new_references.cal_type,
						new_references.ci_sequence_number,
						new_references.ass_id,
						new_references.creation_dt,
						v_message_name,
                        new_references.uoo_id) = FALSE THEN

			FND_MESSAGE.SET_NAME('IGS','IGS_PS_POSU_POSP_FK');
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	IF  p_updating THEN
		--<scap7>
		IF  new_references.spcl_consideration_outcome IS NOT NULL AND
			IGS_AS_VAL_SCAP.assp_val_suaai_delet(
							new_references.person_id,
							new_references.course_cd,
							new_references.unit_cd,
							new_references.cal_type,
							new_references.ci_sequence_number,
							new_references.ass_id,
							new_references.creation_dt,
							v_message_name,
                            new_references.uoo_id) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS','IGS_PE_PIG_PE_FK');
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.sought_outcome = new_references.sought_outcome)) OR
        ((new_references.sought_outcome IS NULL))) THEN
      NULL;
    ELSIF NOT  IGS_AS_SPCL_CONS_OUT_PKG.Get_PK_For_Validation (
        new_references.sought_outcome
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.spcl_consideration_outcome= new_references.spcl_consideration_outcome)) OR
        ((new_references.spcl_consideration_outcome IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_SPCL_CONS_OUT_PKG.Get_PK_For_Validation (
        new_references.spcl_consideration_outcome
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF ((
         (old_references.course_cd = new_references.course_cd) OR
         (old_references.person_id = new_references.person_id) OR
         (old_references.ass_id = new_references.ass_id) OR
         (old_references.creation_dt = new_references.creation_dt)OR
         (old_references.uoo_id = new_references.uoo_id)) OR
        (
         (new_references.course_cd IS NULL) OR
         (new_references.person_id IS NULL) OR
         (new_references.ass_id IS NULL) OR
         (new_references.creation_dt IS NULL) OR
         (new_references.uoo_id IS NULL) )) THEN
      NULL;
    ELSIF NOT IGS_AS_SU_ATMPT_ITM_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.person_id,
        new_references.ass_id,
        new_references.creation_dt,
        new_references.uoo_id)THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    IF (((old_references.spcl_consideration_cat= new_references.spcl_consideration_cat)) OR
        ((new_references.spcl_consideration_cat IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_SPCL_CONS_CAT_PKG.Get_PK_For_Validation (
        new_references.spcl_consideration_cat
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
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_ass_id IN NUMBER,
    x_creation_dt IN DATE,
    x_received_dt IN DATE,
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_SPL_CONS_APPL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      ass_id = x_ass_id
      AND      creation_dt = x_creation_dt
      AND      received_dt = x_received_dt
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

  PROCEDURE GET_FK_IGS_AS_SPCL_CONS_OUT (
    x_spcl_consideration_outcome IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_SPL_CONS_APPL
      WHERE    sought_outcome = x_spcl_consideration_outcome OR
               spcl_consideration_outcome= x_spcl_consideration_outcome ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SCAP_SPCO_FK');
IGS_GE_MSG_STACK.ADD;
	   Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_SPCL_CONS_OUT;
   -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    Added uoo_id  as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  PROCEDURE GET_FK_IGS_AS_SU_ATMPT_ITM (
    x_course_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_ass_id IN NUMBER,
    x_creation_dt IN DATE,
    x_uoo_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_SPL_CONS_APPL
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
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SCAP_SUAAI_FK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_SU_ATMPT_ITM;
  PROCEDURE GET_FK_IGS_AS_SPCL_CONS_CAT (
    x_spcl_consideration_cat IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_SPL_CONS_APPL
      WHERE    spcl_consideration_cat= x_spcl_consideration_cat ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SCAP_SPCC_FK');
IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_SPCL_CONS_CAT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_received_dt IN DATE DEFAULT NULL,
    x_spcl_consideration_cat IN VARCHAR2 DEFAULT NULL,
    x_sought_outcome IN VARCHAR2 DEFAULT NULL,
    x_spcl_consideration_outcome IN VARCHAR2 DEFAULT NULL,
    x_estimated_processing_days IN NUMBER DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_notified_date IN DATE DEFAULT NULL
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
      x_ass_id,
      x_creation_dt,
      x_received_dt,
      x_spcl_consideration_cat,
      x_sought_outcome,
      x_spcl_consideration_outcome,
      x_estimated_processing_days,
      x_tracking_id,
      x_comments,
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
	NEW_REFERENCES.person_id ,
    NEW_REFERENCES.course_cd ,
    NEW_REFERENCES.ass_id ,
    NEW_REFERENCES.creation_dt ,
    NEW_REFERENCES.received_dt ,
    NEW_REFERENCES.uoo_id
) THEN
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
    NEW_REFERENCES.course_cd ,
    NEW_REFERENCES.ass_id ,
    NEW_REFERENCES.creation_dt ,
    NEW_REFERENCES.received_dt,
    NEW_REFERENCES.uoo_id ) THEN
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
  X_ASS_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_RECEIVED_DT in DATE,
  X_SPCL_CONSIDERATION_CAT in VARCHAR2,
  X_SOUGHT_OUTCOME in VARCHAR2,
  X_SPCL_CONSIDERATION_OUTCOME in VARCHAR2,
  X_ESTIMATED_PROCESSING_DAYS in NUMBER,
  X_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER,
  X_NOTIFIED_DATE DATE
  ) AS
    cursor C is select ROWID from IGS_AS_SPL_CONS_APPL
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and ASS_ID = X_ASS_ID
      and CREATION_DT = X_CREATION_DT
      and RECEIVED_DT = X_RECEIVED_DT
      and UOO_ID = X_UOO_ID;
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
 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_ass_id=>X_ASS_ID,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_comments=>X_COMMENTS,
  x_course_cd=>X_COURSE_CD,
  x_creation_dt=>X_CREATION_DT,
  x_estimated_processing_days=>X_ESTIMATED_PROCESSING_DAYS,
  x_person_id=>X_PERSON_ID,
  x_received_dt=>X_RECEIVED_DT,
  x_sought_outcome=>X_SOUGHT_OUTCOME,
  x_spcl_consideration_cat=>X_SPCL_CONSIDERATION_CAT,
  x_spcl_consideration_outcome=>X_SPCL_CONSIDERATION_OUTCOME,
  x_tracking_id=>X_TRACKING_ID,
  x_unit_cd=>X_UNIT_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_uoo_id => X_UOO_ID,
  x_notified_date =>  X_NOTIFIED_DATE
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_AS_SPL_CONS_APPL (
    PERSON_ID,
    COURSE_CD,
    UNIT_CD,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    ASS_ID,
    CREATION_DT,
    RECEIVED_DT,
    SPCL_CONSIDERATION_CAT,
    SOUGHT_OUTCOME,
    SPCL_CONSIDERATION_OUTCOME,
    ESTIMATED_PROCESSING_DAYS,
    TRACKING_ID,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    UOO_ID,
    NOTIFIED_DATE
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ASS_ID,
    NEW_REFERENCES.CREATION_DT,
    NEW_REFERENCES.RECEIVED_DT,
    NEW_REFERENCES.SPCL_CONSIDERATION_CAT,
    NEW_REFERENCES.SOUGHT_OUTCOME,
    NEW_REFERENCES.SPCL_CONSIDERATION_OUTCOME,
    NEW_REFERENCES.ESTIMATED_PROCESSING_DAYS,
    NEW_REFERENCES.TRACKING_ID,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.UOO_ID,
    X_NOTIFIED_DATE
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_RECEIVED_DT in DATE,
  X_SPCL_CONSIDERATION_CAT in VARCHAR2,
  X_SOUGHT_OUTCOME in VARCHAR2,
  X_SPCL_CONSIDERATION_OUTCOME in VARCHAR2,
  X_ESTIMATED_PROCESSING_DAYS in NUMBER,
  X_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_UOO_ID in NUMBER,
  X_NOTIFIED_DATE in DATE
) AS
  cursor c1 is select
      SPCL_CONSIDERATION_CAT,
      SOUGHT_OUTCOME,
      SPCL_CONSIDERATION_OUTCOME,
      ESTIMATED_PROCESSING_DAYS,
      TRACKING_ID,
      COMMENTS
    from IGS_AS_SPL_CONS_APPL
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
  if ( (tlinfo.SPCL_CONSIDERATION_CAT = X_SPCL_CONSIDERATION_CAT)
      AND ((tlinfo.SOUGHT_OUTCOME = X_SOUGHT_OUTCOME)
           OR ((tlinfo.SOUGHT_OUTCOME is null)
               AND (X_SOUGHT_OUTCOME is null)))
      AND ((tlinfo.SPCL_CONSIDERATION_OUTCOME = X_SPCL_CONSIDERATION_OUTCOME)
           OR ((tlinfo.SPCL_CONSIDERATION_OUTCOME is null)
               AND (X_SPCL_CONSIDERATION_OUTCOME is null)))
      AND ((tlinfo.ESTIMATED_PROCESSING_DAYS = X_ESTIMATED_PROCESSING_DAYS)
           OR ((tlinfo.ESTIMATED_PROCESSING_DAYS is null)
               AND (X_ESTIMATED_PROCESSING_DAYS is null)))
      AND ((tlinfo.TRACKING_ID = X_TRACKING_ID)
           OR ((tlinfo.TRACKING_ID is null)
               AND (X_TRACKING_ID is null)))
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_RECEIVED_DT in DATE,
  X_SPCL_CONSIDERATION_CAT in VARCHAR2,
  X_SOUGHT_OUTCOME in VARCHAR2,
  X_SPCL_CONSIDERATION_OUTCOME in VARCHAR2,
  X_ESTIMATED_PROCESSING_DAYS in NUMBER,
  X_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER,
  X_NOTIFIED_DATE in DATE
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
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_comments=>X_COMMENTS,
  x_course_cd=>X_COURSE_CD,
  x_creation_dt=>X_CREATION_DT,
  x_estimated_processing_days=>X_ESTIMATED_PROCESSING_DAYS,
  x_person_id=>X_PERSON_ID,
  x_received_dt=>X_RECEIVED_DT,
  x_sought_outcome=>X_SOUGHT_OUTCOME,
  x_spcl_consideration_cat=>X_SPCL_CONSIDERATION_CAT,
  x_spcl_consideration_outcome=>X_SPCL_CONSIDERATION_OUTCOME,
  x_tracking_id=>X_TRACKING_ID,
  x_unit_cd=>X_UNIT_CD,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_uoo_id=>X_UOO_ID,
  x_notified_date =>  X_NOTIFIED_DATE
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_AS_SPL_CONS_APPL set
    SPCL_CONSIDERATION_CAT = NEW_REFERENCES.SPCL_CONSIDERATION_CAT,
    SOUGHT_OUTCOME = NEW_REFERENCES.SOUGHT_OUTCOME,
    SPCL_CONSIDERATION_OUTCOME = NEW_REFERENCES.SPCL_CONSIDERATION_OUTCOME,
    ESTIMATED_PROCESSING_DAYS = NEW_REFERENCES.ESTIMATED_PROCESSING_DAYS,
    TRACKING_ID = NEW_REFERENCES.TRACKING_ID,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    NOTIFIED_DATE = X_NOTIFIED_DATE
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_RECEIVED_DT in DATE,
  X_SPCL_CONSIDERATION_CAT in VARCHAR2,
  X_SOUGHT_OUTCOME in VARCHAR2,
  X_SPCL_CONSIDERATION_OUTCOME in VARCHAR2,
  X_ESTIMATED_PROCESSING_DAYS in NUMBER,
  X_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER,
  X_NOTIFIED_DATE in DATE
  ) AS
  cursor c1 is select rowid from IGS_AS_SPL_CONS_APPL
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and ASS_ID = X_ASS_ID
     and CREATION_DT = X_CREATION_DT
     and RECEIVED_DT = X_RECEIVED_DT
     and UOO_ID = X_UOO_ID;
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
     X_ASS_ID,
     X_CREATION_DT,
     X_RECEIVED_DT,
     X_SPCL_CONSIDERATION_CAT,
     X_SOUGHT_OUTCOME,
     X_SPCL_CONSIDERATION_OUTCOME,
     X_ESTIMATED_PROCESSING_DAYS,
     X_TRACKING_ID,
     X_COMMENTS,
     X_MODE,
     X_UOO_ID,
     X_NOTIFIED_DATE );
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
   X_ASS_ID,
   X_CREATION_DT,
   X_RECEIVED_DT,
   X_SPCL_CONSIDERATION_CAT,
   X_SOUGHT_OUTCOME,
   X_SPCL_CONSIDERATION_OUTCOME,
   X_ESTIMATED_PROCESSING_DAYS,
   X_TRACKING_ID,
   X_COMMENTS,
   X_MODE,
   X_UOO_ID,
   X_NOTIFIED_DATE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_AS_SPL_CONS_APPL
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
	    new_references.CI_SEQUENCE_NUMBER := IGS_GE_NUMBER.TO_NUM(column_value);

	ELSIF upper(Column_name) = 'ESTIMATED_PROCESSING_DAYS' then
	    new_references.ESTIMATED_PROCESSING_DAYS := IGS_GE_NUMBER.TO_NUM(column_value);

	ELSIF upper(Column_name) = 'CAL_TYPE' then
	    new_references.CAL_TYPE := column_value;

	ELSIF upper(Column_name) = 'SPCL_CONSIDERATION_CAT' then
	    new_references.SPCL_CONSIDERATION_CAT := column_value;

	ELSIF upper(Column_name) = 'SPCL_CONSIDERATION_OUTCOME' then
	    new_references.SPCL_CONSIDERATION_OUTCOME := column_value;

	ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.COURSE_CD := column_value;

	ELSIF upper(Column_name) = 'UNIT_CD' then
	    new_references.UNIT_CD := column_value;
    end if;

IF upper(column_name) = 'CI_SEQUENCE_NUMBER ' OR
     column_name is null Then
     IF new_references.ci_sequence_number <  1 OR new_references.ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'ESTIMATED_PROCESSING_DAYS' OR
     column_name is null Then
     IF new_references.ESTIMATED_PROCESSING_DAYS  < 0 OR new_references.ESTIMATED_PROCESSING_DAYS > 99  Then
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
IF upper(column_name) = 'CAL_TYPE' OR
     column_name is null Then
     IF new_references.CAL_TYPE<> UPPER(new_references.CAL_TYPE) Then
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
IF upper(column_name) = 'SPCL_CONSIDERATION_CAT' OR
     column_name is null Then
     IF new_references.SPCL_CONSIDERATION_CAT <> UPPER(new_references.SPCL_CONSIDERATION_CAT) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'SPCL_CONSIDERATION_OUTCOME' OR
     column_name is null Then
     IF new_references.SPCL_CONSIDERATION_OUTCOME <> UPPER(new_references.SPCL_CONSIDERATION_OUTCOME) Then
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
	END Check_Constraints;

end IGS_AS_SPL_CONS_APPL_PKG;

/
