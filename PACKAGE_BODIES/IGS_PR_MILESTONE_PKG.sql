--------------------------------------------------------
--  DDL for Package Body IGS_PR_MILESTONE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_MILESTONE_PKG" AS
/* $Header: IGSQI01B.pls 120.0 2005/07/05 11:51:29 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_re_val_mil.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_PR_MILESTONE_ALL%RowType;
  new_references IGS_PR_MILESTONE_ALL%RowType;
PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
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
      FROM     IGS_PR_MILESTONE_ALL
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
    new_references.org_id := x_org_id;
  END Set_Column_Values;

  -- Trigger description :-
  -- "OSS_TST".trg_mil_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_PR_MILESTONE_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Turn off trigger validation when performing insert of IGS_RE_CANDIDATURE details
	-- as a result of IGS_PS_COURSE transfer
	IF igs_as_val_suaap.genp_val_sdtt_sess('ENRP_INS_CA_TRNSFR') THEN
		IF p_inserting OR
		   ( p_updating AND
		 old_references.milestone_type <> new_references.milestone_type ) THEN
		 	IF IGS_RE_VAL_MIL.resp_val_mil_mty(	new_references.milestone_type,
							v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF p_inserting OR
			( p_updating AND
			  NVL(old_references.actual_reached_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) <>
		  				NVL(new_references.actual_reached_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
			IF IGS_RE_VAL_MIL.resp_val_mil_actual(	new_references.milestone_status,
							new_references.actual_reached_dt,
							v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF p_inserting OR
			( p_updating AND
			  NVL(old_references.ovrd_ntfctn_imminent_days,-1) <>
						NVL(new_references.ovrd_ntfctn_imminent_days,-1) OR
			  NVL(old_references.ovrd_ntfctn_reminder_days,-1) <>
						NVL(new_references.ovrd_ntfctn_reminder_days,-1) OR
			  NVL(old_references.ovrd_ntfctn_re_reminder_days,-1) <>
						NVL(new_references.ovrd_ntfctn_re_reminder_days,-1)) THEN
	  		IF IGS_RE_VAL_MIL.resp_val_mil_days(	new_references.milestone_type,
						new_references.milestone_status,
						new_references.due_dt,
						old_references.ovrd_ntfctn_imminent_days,
						new_references.ovrd_ntfctn_imminent_days,
						old_references.ovrd_ntfctn_reminder_days,
						new_references.ovrd_ntfctn_reminder_days,
						old_references.ovrd_ntfctn_re_reminder_days,
						new_references.ovrd_ntfctn_re_reminder_days,
						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;
	IF p_deleting THEN
		IF IGS_RE_VAL_MIL.resp_val_mil_del(	old_references.person_id,
						old_references.ca_sequence_number,
						old_references.sequence_number,
						old_references.milestone_status,
						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_mil_ar_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_PR_MILESTONE_ALL
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
	v_rowid_saved		BOOLEAN := FALSE;
  BEGIN
	-- update of student IGS_PS_COURSE attempt after student IGS_PS_UNIT attempt is posted
	-- to the database
	IF p_updating OR p_deleting THEN
		IGS_RE_GEN_003.RESP_INS_MIL_HIST(
			old_references.person_id,
			old_references.ca_sequence_number,
			old_references.sequence_number,
			old_references.milestone_type,
			new_references.milestone_type,
			old_references.milestone_status,
			new_references.milestone_status,
			old_references.due_dt,
			new_references.due_dt,
			old_references.description,
			new_references.description,
			old_references.actual_reached_dt,
			new_references.actual_reached_dt,
			old_references.preced_sequence_number,
			new_references.preced_sequence_number,
			old_references.ovrd_ntfctn_imminent_days,
			new_references.ovrd_ntfctn_imminent_days,
			old_references.ovrd_ntfctn_reminder_days,
			new_references.ovrd_ntfctn_reminder_days,
			old_references.ovrd_ntfctn_re_reminder_days,
			new_references.ovrd_ntfctn_re_reminder_days,
			old_references.comments,
			new_references.comments,
			old_references.last_updated_by,
			NVL(new_references.last_updated_by,FND_GLOBAL.USER_ID),
			old_references.last_update_date,
			NVL(new_references.last_update_date,SYSDATE));
	END IF;


   -- The changes are done as per the Enrollments Notifications TD Bug # 3052429
   -- Workflow is raised when
   -- 1. New record is created
   -- 2. The fields MILESTONE_TYPE, MILESTONE_STATUS, DUE_DT or ACTUAL_REACHED_DT is updated.
   -- 3. Recored is deleted.

       IF p_inserting OR (p_updating AND ( new_references.milestone_type <> old_references.milestone_type OR
                                                         new_references.milestone_status <> old_references.milestone_status OR
                                                         trunc(new_references.due_dt) <> trunc(old_references.due_dt) OR
                                                        ( new_references.actual_reached_dt IS NOT NULL AND old_references.actual_reached_dt IS NOT NULL
							 AND trunc(new_references.actual_reached_dt) <> trunc(old_references.actual_reached_dt)) OR
                                                        (new_references.actual_reached_dt IS NOT NULL AND old_references.actual_reached_dt IS NULL) OR
                                                        (new_references.actual_reached_dt IS NULL AND old_references.actual_reached_dt IS NOT NULL))) THEN


		       igs_re_workflow.milestone_event(
						p_personid	=> new_references.person_id,
						p_ca_seq_num	=> new_references.ca_sequence_number,
						p_milestn_typ	=> new_references.milestone_type,
						p_milestn_stat	=> new_references.milestone_status,
						p_due_dt	=> new_references.due_dt,
						p_dt_reached	=> new_references.actual_reached_dt,
						p_deleted	=> 'FALSE'
	                                        );

       ELSIF (p_deleting AND old_references.milestone_status = 'PLANNED' ) THEN


		       igs_re_workflow.milestone_event(
						p_personid	=> old_references.person_id,
						p_ca_seq_num	=> old_references.ca_sequence_number,
						p_milestn_typ	=> old_references.milestone_type,
						p_milestn_stat	=> old_references.milestone_status,
						p_due_dt	=> old_references.due_dt,
						p_dt_reached	=> old_references.actual_reached_dt,
						p_deleted	=> 'TRUE'
	                                        );
       END IF;

  END AfterRowInsertUpdateDelete2;

  -- Trigger description :-
  -- "OSS_TST".trg_mil_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_PR_MILESTONE_ALL

  PROCEDURE AfterStmtInsertUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Turn off trigger validation when performing insert of IGS_RE_CANDIDATURE details
	-- as a result of IGS_PS_COURSE transfer
	IF igs_as_val_suaap.genp_val_sdtt_sess('ENRP_INS_CA_TRNSFR')  THEN

  		-- Validate preceeding details.
  		IF IGS_RE_VAL_MIL.resp_val_mil_prcd(	new_references.person_id,
  						new_references.ca_sequence_number,
  						new_references.sequence_number,
  						new_references.due_dt,
  						new_references.preced_sequence_number,
  						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  		END IF;
  		-- Validate milestone status.
  		IF IGS_RE_VAL_MIL.resp_val_mil_mst(new_references.person_id,
  						new_references.ca_sequence_number,
  						new_references.preced_sequence_number,
  						old_references.milestone_status,
  						new_references.milestone_status,
  						old_references.due_dt,
  						new_references.due_dt,
  						'TRIGGER',
  						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  		END IF;
  		-- Validate milestone due date.
  	  	IF IGS_RE_VAL_MIL.resp_val_mil_due(new_references.person_id,
  						new_references.ca_sequence_number,
  						new_references.sequence_number,
  						old_references.milestone_status,
  						new_references.milestone_status,
  						old_references.due_dt,
  						new_references.due_dt,
  						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  		END IF;
       END IF;

  END AfterStmtInsertUpdate3;


 PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.ca_sequence_number = new_references.ca_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.ca_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_CANDIDATURE_PKG.GET_PK_For_Validation (
        new_references.person_id,
        new_references.ca_sequence_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.ca_sequence_number = new_references.ca_sequence_number) AND
         (old_references.preced_sequence_number = new_references.preced_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.ca_sequence_number IS NULL) OR
         (new_references.preced_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_MILESTONE_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.ca_sequence_number,
        new_references.preced_sequence_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.milestone_status= new_references.milestone_status)) OR
        ((new_references.milestone_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_MS_STAT_PKG.Get_PK_For_Validation (
        new_references.milestone_status
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.milestone_type = new_references.milestone_type)) OR
        ((new_references.milestone_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_MILESTONE_TYP_PKG.Get_PK_For_Validation (
        new_references.milestone_type
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PR_MILESTONE_PKG.GET_FK_IGS_PR_MILESTONE (
      old_references.person_id,
      old_references.ca_sequence_number,
      old_references.sequence_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_MILESTONE_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      sequence_number = x_sequence_number
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

  PROCEDURE GET_FK_IGS_RE_CANDIDATURE (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_MILESTONE_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_MIL_CA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_CANDIDATURE;

  PROCEDURE GET_FK_IGS_PR_MILESTONE (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_MILESTONE_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      preced_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_MIL_MIL_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_MILESTONE;

  PROCEDURE GET_FK_IGS_PR_MS_STAT (
    x_milestone_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_MILESTONE_ALL
      WHERE    milestone_status = x_milestone_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_MIL_MST_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_MS_STAT;

  PROCEDURE GET_FK_IGS_PR_MILESTONE_TYPE (
    x_milestone_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_MILESTONE_ALL
      WHERE    milestone_type = x_milestone_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_MIL_MTY_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_MILESTONE_TYPE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
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
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF Get_PK_For_Validation (
         new_references.person_id,
         new_references.ca_sequence_number,
         new_references.sequence_number
         ) THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
         new_references.person_id,
         new_references.ca_sequence_number,
         new_references.sequence_number
         ) THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
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
      AfterRowInsertUpdateDelete2 ( p_inserting => TRUE );
      AfterStmtInsertUpdate3 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdateDelete2 ( p_updating => TRUE );
      AfterStmtInsertUpdate3 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowInsertUpdateDelete2 ( p_deleting => TRUE );
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
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
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_PR_MILESTONE_ALL
      where PERSON_ID = X_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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
    app_exception.raise_exception;
  end if;

  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_ca_sequence_number =>x_ca_sequence_number,
    x_sequence_number =>x_sequence_number ,
    x_milestone_type =>x_milestone_type ,
    x_milestone_status =>x_milestone_status ,
    x_due_dt =>x_due_dt,
    x_description =>x_description ,
    x_actual_reached_dt =>x_actual_reached_dt ,
    x_preced_sequence_number =>x_preced_sequence_number ,
    x_ovrd_ntfctn_imminent_days => x_ovrd_ntfctn_imminent_days ,
    x_ovrd_ntfctn_reminder_days =>x_ovrd_ntfctn_reminder_days ,
    x_ovrd_ntfctn_re_reminder_days =>x_ovrd_ntfctn_re_reminder_days ,
    x_comments =>x_comments ,
    x_creation_date =>x_last_update_date ,
    x_created_by =>x_last_updated_by ,
    x_last_update_date =>x_last_update_date ,
    x_last_updated_by =>x_last_updated_by ,
    x_last_update_login =>x_last_update_login,
    x_org_id=>igs_ge_gen_003.get_org_id
  ) ;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_PR_MILESTONE_ALL (
    PERSON_ID,
    CA_SEQUENCE_NUMBER,
    SEQUENCE_NUMBER,
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
 After_DML (
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
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
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
) AS
  cursor c1 is select
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
    from IGS_PR_MILESTONE_ALL
    where ROWID = X_ROWID for update nowait;
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

  if ( (tlinfo.MILESTONE_TYPE = X_MILESTONE_TYPE)
      AND (tlinfo.MILESTONE_STATUS = X_MILESTONE_STATUS)
      AND (tlinfo.DUE_DT = X_DUE_DT)
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
    app_exception.raise_exception;
  end if;
Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_ca_sequence_number =>x_ca_sequence_number,
    x_sequence_number =>x_sequence_number ,
    x_milestone_type =>x_milestone_type ,
    x_milestone_status =>x_milestone_status ,
    x_due_dt =>x_due_dt,
    x_description =>x_description ,
    x_actual_reached_dt =>x_actual_reached_dt ,
    x_preced_sequence_number =>x_preced_sequence_number ,
    x_ovrd_ntfctn_imminent_days => x_ovrd_ntfctn_imminent_days ,
    x_ovrd_ntfctn_reminder_days =>x_ovrd_ntfctn_reminder_days ,
    x_ovrd_ntfctn_re_reminder_days =>x_ovrd_ntfctn_re_reminder_days ,
    x_comments =>x_comments ,
    x_creation_date =>x_last_update_date ,
    x_created_by =>x_last_updated_by ,
    x_last_update_date =>x_last_update_date ,
    x_last_updated_by =>x_last_updated_by ,
    x_last_update_login =>x_last_update_login
  ) ;


  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_PR_MILESTONE_ALL set
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
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


After_DML (
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
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
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
  cursor c1 is select rowid from IGS_PR_MILESTONE_ALL
     where PERSON_ID = X_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
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
     X_ORG_ID );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_CA_SEQUENCE_NUMBER,
   X_SEQUENCE_NUMBER,
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
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin
    Before_DML (
    p_action=>'DELETE',
    x_rowid=>X_ROWID
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_PR_MILESTONE_ALL
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

After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
end DELETE_ROW;

  PROCEDURE  Check_Constraints (
     Column_Name IN VARCHAR2 DEFAULT NULL,
     Column_Value IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
      IF column_name is null then
         NULL;
      ELSIF  upper(Column_Name) = 'DESCRIPTION' then
         new_references.description := Column_Value;
     ELSIF upper(Column_Name) = 'MILESTONE_STATUS' then
         new_references.milestone_status := Column_Value;
      ELSIF  upper(Column_Name) = 'MILESTONE_TYPE' then
         new_references.milestone_type := Column_Value;
      ELSIF  upper(Column_Name) = 'CA_SEQUENCE_NUMBER' then
         new_references.ca_sequence_number := IGS_GE_NUMBER.to_num(Column_Value);
      ELSIF  upper(Column_Name) = 'SEQUENCE_NUMBER' then
         new_references.sequence_number := IGS_GE_NUMBER.to_num(Column_Value);
      ELSIF  upper(Column_Name) = 'PRECED_SEQUENCE_NUMBER' then
         new_references.preced_sequence_number := IGS_GE_NUMBER.to_num(Column_Value);
      ELSIF  upper(Column_Name) = 'OVRD_NTFCTN_REMINDER_DAYS' then
         new_references.ovrd_ntfctn_reminder_days := IGS_GE_NUMBER.to_num(Column_Value);
      ELSIF  upper(Column_Name) = 'OVRD_NTFCTN_RE_REMINDER_DAYS' then
         new_references.ovrd_ntfctn_re_reminder_days := IGS_GE_NUMBER.to_num(Column_Value);
      ELSIF  upper(Column_Name) = 'OVRD_NTFCTN_IMMINENT_DAYS' then
         new_references.ovrd_ntfctn_imminent_days := IGS_GE_NUMBER.to_num(Column_Value);
      END IF;

      IF upper(column_name) = 'MILESTONE_STATUS' OR
         column_name is NULL THEN
         IF new_references.milestone_status <> UPPER(new_references.milestone_status) THEN
	     Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
      END IF;


      IF upper(column_name) = 'CA_SEQUENCE_NUMBER' OR
         column_name is NULL THEN
         IF TO_NUMBER(new_references.ca_sequence_number) < 1 OR
		TO_NUMBER(new_references.ca_sequence_number) > 999999 THEN
	     Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
      END IF;


      IF upper(column_name) = 'SEQUENCE_NUMBER' OR
         column_name is NULL THEN
         IF TO_NUMBER(new_references.sequence_number) < 1 OR
		TO_NUMBER(new_references.sequence_number) > 999999 THEN
	     Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
      END IF;


     IF upper(column_name) = 'PRECED_SEQUENCE_NUMBER' OR
         column_name is NULL THEN
         IF TO_NUMBER(new_references.preced_sequence_number) < 1 OR
		TO_NUMBER(new_references.preced_sequence_number) > 999999 THEN
	     Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
      END IF;


      IF upper(column_name) = 'OVRD_NTFCTN_IMMINENT_DAYS' OR
         column_name is NULL THEN
         IF TO_NUMBER(new_references.ovrd_ntfctn_imminent_days) < 0 OR
		TO_NUMBER(new_references.ovrd_ntfctn_imminent_days) > 999 THEN
	     Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
      END IF;



      IF upper(column_name) = 'OVRD_NTFCTN_REMINDER_DAYS' OR
         column_name is NULL THEN
         IF TO_NUMBER(new_references.ovrd_ntfctn_reminder_days) < 0 OR
		TO_NUMBER(new_references.ovrd_ntfctn_reminder_days) > 999 THEN
	     Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
      END IF;

      IF upper(column_name) = 'OVRD_NTFCTN_RE_REMINDER_DAYS' OR
         column_name is NULL THEN
         IF TO_NUMBER(new_references.ovrd_ntfctn_re_reminder_days) < 0 OR
		TO_NUMBER(new_references.ovrd_ntfctn_re_reminder_days) > 999 THEN
	     Fnd_Message.Set_Name('IGS','IGS_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
      END IF;

  END Check_Constraints;
end IGS_PR_MILESTONE_PKG;

/
