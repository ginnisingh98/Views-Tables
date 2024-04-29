--------------------------------------------------------
--  DDL for Package Body IGS_PR_S_OU_PRG_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_S_OU_PRG_CONF_PKG" as
/* $Header: IGSQI24B.pls 115.6 2002/12/23 07:32:54 ddey ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PR_S_OU_PRG_CONF%RowType;
  new_references IGS_PR_S_OU_PRG_CONF%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_apply_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_apply_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_benefit_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_penalty_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_show_cause_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_appeal_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_show_cause_ind IN VARCHAR2 DEFAULT NULL,
    x_apply_before_show_ind IN VARCHAR2 DEFAULT NULL,
    x_appeal_ind IN VARCHAR2 DEFAULT NULL,
    x_apply_before_appeal_ind IN VARCHAR2 DEFAULT NULL,
    x_count_sus_in_time_ind IN VARCHAR2 DEFAULT NULL,
    x_count_exc_in_time_ind IN VARCHAR2 DEFAULT NULL,
    x_calculate_wam_ind IN VARCHAR2 DEFAULT NULL,
    x_calculate_gpa_ind IN VARCHAR2 DEFAULT NULL,
    x_outcome_check_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_S_OU_PRG_CONF
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
    new_references.org_unit_cd := x_org_unit_cd;
    new_references.ou_start_dt := x_ou_start_dt;
    new_references.apply_start_dt_alias := x_apply_start_dt_alias;
    new_references.apply_end_dt_alias := x_apply_end_dt_alias;
    new_references.end_benefit_dt_alias := x_end_benefit_dt_alias;
    new_references.end_penalty_dt_alias := x_end_penalty_dt_alias;
    new_references.show_cause_cutoff_dt_alias := x_show_cause_cutoff_dt_alias;
    new_references.appeal_cutoff_dt_alias := x_appeal_cutoff_dt_alias;
    new_references.show_cause_ind := x_show_cause_ind;
    new_references.apply_before_show_ind := x_apply_before_show_ind;
    new_references.appeal_ind := x_appeal_ind;
    new_references.apply_before_appeal_ind := x_apply_before_appeal_ind;
    new_references.count_sus_in_time_ind := x_count_sus_in_time_ind;
    new_references.count_exc_in_time_ind := x_count_exc_in_time_ind;
    new_references.calculate_wam_ind := x_calculate_wam_ind;
    new_references.calculate_gpa_ind := x_calculate_gpa_ind;
    new_references.outcome_check_type := x_outcome_check_type;

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
  -- "OSS_TST".trg_sopc_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_PR_S_OU_PRG_CONF
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate the org IGS_PS_UNIT is active
	IF p_inserting THEN
		IF IGS_PR_VAL_SOPC.prgp_val_ou_active (
					new_references.org_unit_cd,
					new_references.ou_start_dt,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the application start date alias
	IF p_inserting OR (p_updating AND
	   new_references.apply_start_dt_alias <> old_references.apply_start_dt_alias) THEN
		IF igs_pr_val_scpc.prgp_val_da_closed (
					new_references.apply_start_dt_alias,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the application end date alias
	IF p_inserting OR (p_updating AND
	   new_references.apply_end_dt_alias <> old_references.apply_end_dt_alias) THEN
		IF igs_pr_val_scpc.prgp_val_da_closed (
					new_references.apply_end_dt_alias,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the end benefit date alias
	IF p_inserting OR (p_updating AND
	   new_references.end_benefit_dt_alias <> old_references.end_benefit_dt_alias) THEN
		IF igs_pr_val_scpc.prgp_val_da_closed (
					new_references.end_benefit_dt_alias,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the end penalty date alias
	IF p_inserting OR (p_updating AND
	   new_references.end_penalty_dt_alias <> old_references.end_penalty_dt_alias) THEN
		IF igs_pr_val_scpc.prgp_val_da_closed (
					new_references.end_penalty_dt_alias,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the show cause indicator
	IF p_inserting OR (p_updating AND
	   new_references.show_cause_ind <> old_references.show_cause_ind) THEN
		IF IGS_PR_VAL_SOPC.prgp_val_cause_ind (
					new_references.show_cause_ind,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the appeal indicator
	IF p_inserting OR (p_updating AND
	   new_references.appeal_ind <> old_references.appeal_ind) THEN
		IF IGS_PR_VAL_SOPC.prgp_val_cause_ind (
					new_references.appeal_ind,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the show cause cut off date alias can only be set when the
	-- show cause ind indicator is set to Y
	IF p_inserting OR p_updating THEN
		IF igs_pr_val_scpc.prgp_val_cause_da (
					new_references.show_cause_ind,
					new_references.show_cause_cutoff_dt_alias,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the appeal cut off date alias can only be set when the
	-- appeal ind indicator is set to Y
	IF p_inserting OR p_updating THEN
		IF igs_pr_val_scpc.prgp_val_appeal_da (
					new_references.appeal_ind,
					new_references.appeal_cutoff_dt_alias,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the show cause ind indicator cannot be set to N when there are
	-- related progression calendar records with show cause length set.
	IF p_inserting OR p_updating THEN
		IF IGS_PR_VAL_SOPC.prgp_val_sopc_cause (
					new_references.org_unit_cd,
					new_references.ou_start_dt,
					new_references.show_cause_ind,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the appeal ind indicator cannot be set to N when there are
	-- related progression calendar records with appeallength set.
	IF p_inserting OR p_updating THEN
		IF IGS_PR_VAL_SOPC.prgp_val_sopc_apl (
					new_references.org_unit_cd,
					new_references.ou_start_dt,
					new_references.appeal_ind,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the show cause cut off date alias
	IF p_inserting OR (p_updating AND
	   NVL(new_references.show_cause_cutoff_dt_alias, 'NULL') <>
	   NVL(old_references.show_cause_cutoff_dt_alias, 'NULL')) THEN
		IF igs_pr_val_scpc.prgp_val_da_closed (
					new_references.show_cause_cutoff_dt_alias,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the appeal cut off date alias
	IF p_inserting OR (p_updating AND
	   NVL(new_references.appeal_cutoff_dt_alias, 'NULL') <>
	   NVL(old_references.appeal_cutoff_dt_alias, 'NULL')) THEN
		IF igs_pr_val_scpc.prgp_val_da_closed (
					new_references.appeal_cutoff_dt_alias,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.end_benefit_dt_alias = new_references.end_benefit_dt_alias)) OR
        ((new_references.end_benefit_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.end_benefit_dt_alias
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.apply_start_dt_alias = new_references.apply_start_dt_alias)) OR
        ((new_references.apply_start_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.apply_start_dt_alias
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.show_cause_cutoff_dt_alias = new_references.show_cause_cutoff_dt_alias)) OR
        ((new_references.show_cause_cutoff_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.show_cause_cutoff_dt_alias
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.apply_end_dt_alias = new_references.apply_end_dt_alias)) OR
        ((new_references.apply_end_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.apply_end_dt_alias
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.end_penalty_dt_alias = new_references.end_penalty_dt_alias)) OR
        ((new_references.end_penalty_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.end_penalty_dt_alias
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.org_unit_cd = new_references.org_unit_cd) AND
         (old_references.ou_start_dt = new_references.ou_start_dt)) OR
        ((new_references.org_unit_cd IS NULL) OR
         (new_references.ou_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.org_unit_cd,
        new_references.ou_start_dt
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.appeal_cutoff_dt_alias = new_references.appeal_cutoff_dt_alias)) OR
        ((new_references.appeal_cutoff_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.appeal_cutoff_dt_alias
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PR_S_OU_PRG_CAL_PKG.GET_FK_IGS_PR_S_OU_PRG_CONF  (
      old_references.org_unit_cd,
      old_references.ou_start_dt
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_S_OU_PRG_CONF
      WHERE    org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_ou_start_dt
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

  PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_S_OU_PRG_CONF
      WHERE    end_penalty_dt_alias = x_dt_alias
      OR    apply_end_dt_alias = x_dt_alias
      OR    show_cause_cutoff_dt_alias = x_dt_alias
      OR    apply_start_dt_alias = x_dt_alias
      OR    end_benefit_dt_alias = x_dt_alias
      OR	appeal_cutoff_dt_alias = x_dt_alias ;


    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SOPC_DA_APPEAL_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_S_OU_PRG_CONF
      WHERE    org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SOPC_OU_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_apply_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_apply_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_benefit_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_penalty_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_show_cause_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_appeal_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_show_cause_ind IN VARCHAR2 DEFAULT NULL,
    x_apply_before_show_ind IN VARCHAR2 DEFAULT NULL,
    x_appeal_ind IN VARCHAR2 DEFAULT NULL,
    x_apply_before_appeal_ind IN VARCHAR2 DEFAULT NULL,
    x_count_sus_in_time_ind IN VARCHAR2 DEFAULT NULL,
    x_count_exc_in_time_ind IN VARCHAR2 DEFAULT NULL,
    x_calculate_wam_ind IN VARCHAR2 DEFAULT NULL,
    x_calculate_gpa_ind IN VARCHAR2 DEFAULT NULL,
    x_outcome_check_type IN VARCHAR2 DEFAULT NULL,
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
      x_org_unit_cd,
      x_ou_start_dt,
      x_apply_start_dt_alias,
      x_apply_end_dt_alias,
      x_end_benefit_dt_alias,
      x_end_penalty_dt_alias,
      x_show_cause_cutoff_dt_alias,
      x_appeal_cutoff_dt_alias,
      x_show_cause_ind,
      x_apply_before_show_ind,
      x_appeal_ind,
      x_apply_before_appeal_ind,
      x_count_sus_in_time_ind,
      x_count_exc_in_time_ind,
      x_calculate_wam_ind,
      x_calculate_gpa_ind,
      x_outcome_check_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
         new_references.org_unit_cd,
         new_references.ou_start_dt
         ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation (
         new_references.org_unit_cd ,
         new_references.ou_start_dt
         ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_APPLY_START_DT_ALIAS in VARCHAR2,
  X_APPLY_END_DT_ALIAS in VARCHAR2,
  X_END_BENEFIT_DT_ALIAS in VARCHAR2,
  X_END_PENALTY_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_APPEAL_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_IND in VARCHAR2,
  X_APPLY_BEFORE_SHOW_IND in VARCHAR2,
  X_APPEAL_IND in VARCHAR2,
  X_APPLY_BEFORE_APPEAL_IND in VARCHAR2,
  X_COUNT_SUS_IN_TIME_IND in VARCHAR2,
  X_COUNT_EXC_IN_TIME_IND in VARCHAR2,
  X_CALCULATE_WAM_IND in VARCHAR2,
  X_CALCULATE_GPA_IND in VARCHAR2,
  X_OUTCOME_CHECK_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_PR_S_OU_PRG_CONF
      where ORG_UNIT_CD = X_ORG_UNIT_CD
      and OU_START_DT = X_OU_START_DT;
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

    Before_DML(
     p_action => 'INSERT',
     x_rowid => X_ROWID,
     x_appeal_cutoff_dt_alias => X_APPEAL_CUTOFF_DT_ALIAS,
     x_appeal_ind => nvl( X_APPEAL_IND, 'Y'),
     x_apply_before_appeal_ind => nvl( X_APPLY_BEFORE_APPEAL_IND, 'Y'),
     x_apply_before_show_ind => nvl( X_APPLY_BEFORE_SHOW_IND, 'N'),
     x_apply_end_dt_alias => X_APPLY_END_DT_ALIAS,
     x_apply_start_dt_alias => X_APPLY_START_DT_ALIAS,
     x_calculate_gpa_ind => nvl( X_CALCULATE_GPA_IND, 'N'),
     x_calculate_wam_ind => nvl( X_CALCULATE_WAM_IND, 'N'),
     x_count_exc_in_time_ind => nvl( X_COUNT_EXC_IN_TIME_IND, 'N'),
     x_count_sus_in_time_ind => nvl( X_COUNT_SUS_IN_TIME_IND, 'N'),
     x_end_benefit_dt_alias => X_END_BENEFIT_DT_ALIAS,
     x_end_penalty_dt_alias => X_END_PENALTY_DT_ALIAS,
     x_org_unit_cd => X_ORG_UNIT_CD,
     x_ou_start_dt => X_OU_START_DT,
     x_show_cause_cutoff_dt_alias => X_SHOW_CAUSE_CUTOFF_DT_ALIAS,
     x_show_cause_ind => nvl( X_SHOW_CAUSE_IND, 'Y'),
     x_outcome_check_type => X_OUTCOME_CHECK_TYPE,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
     );

  insert into IGS_PR_S_OU_PRG_CONF (
    ORG_UNIT_CD,
    OU_START_DT,
    APPLY_START_DT_ALIAS,
    APPLY_END_DT_ALIAS,
    END_BENEFIT_DT_ALIAS,
    END_PENALTY_DT_ALIAS,
    SHOW_CAUSE_CUTOFF_DT_ALIAS,
    APPEAL_CUTOFF_DT_ALIAS,
    SHOW_CAUSE_IND,
    APPLY_BEFORE_SHOW_IND,
    APPEAL_IND,
    APPLY_BEFORE_APPEAL_IND,
    COUNT_SUS_IN_TIME_IND,
    COUNT_EXC_IN_TIME_IND,
    CALCULATE_WAM_IND,
    CALCULATE_GPA_IND,
    OUTCOME_CHECK_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_UNIT_CD,
    NEW_REFERENCES.OU_START_DT,
    NEW_REFERENCES.APPLY_START_DT_ALIAS,
    NEW_REFERENCES.APPLY_END_DT_ALIAS,
    NEW_REFERENCES.END_BENEFIT_DT_ALIAS,
    NEW_REFERENCES.END_PENALTY_DT_ALIAS,
    NEW_REFERENCES.SHOW_CAUSE_CUTOFF_DT_ALIAS,
    NEW_REFERENCES.APPEAL_CUTOFF_DT_ALIAS,
    NEW_REFERENCES.SHOW_CAUSE_IND,
    NEW_REFERENCES.APPLY_BEFORE_SHOW_IND,
    NEW_REFERENCES.APPEAL_IND,
    NEW_REFERENCES.APPLY_BEFORE_APPEAL_IND,
    NEW_REFERENCES.COUNT_SUS_IN_TIME_IND,
    NEW_REFERENCES.COUNT_EXC_IN_TIME_IND,
    NEW_REFERENCES.CALCULATE_WAM_IND,
    NEW_REFERENCES.CALCULATE_GPA_IND,
    NEW_REFERENCES.OUTCOME_CHECK_TYPE,
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
  X_ROWID in VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_APPLY_START_DT_ALIAS in VARCHAR2,
  X_APPLY_END_DT_ALIAS in VARCHAR2,
  X_END_BENEFIT_DT_ALIAS in VARCHAR2,
  X_END_PENALTY_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_APPEAL_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_IND in VARCHAR2,
  X_APPLY_BEFORE_SHOW_IND in VARCHAR2,
  X_APPEAL_IND in VARCHAR2,
  X_APPLY_BEFORE_APPEAL_IND in VARCHAR2,
  X_COUNT_SUS_IN_TIME_IND in VARCHAR2,
  X_COUNT_EXC_IN_TIME_IND in VARCHAR2,
  X_CALCULATE_WAM_IND in VARCHAR2,
  X_CALCULATE_GPA_IND in VARCHAR2,
  X_OUTCOME_CHECK_TYPE in VARCHAR2
) as
  cursor c1 is select
      APPLY_START_DT_ALIAS,
      APPLY_END_DT_ALIAS,
      END_BENEFIT_DT_ALIAS,
      END_PENALTY_DT_ALIAS,
      SHOW_CAUSE_CUTOFF_DT_ALIAS,
      APPEAL_CUTOFF_DT_ALIAS,
      SHOW_CAUSE_IND,
      APPLY_BEFORE_SHOW_IND,
      APPEAL_IND,
      APPLY_BEFORE_APPEAL_IND,
      COUNT_SUS_IN_TIME_IND,
      COUNT_EXC_IN_TIME_IND,
      CALCULATE_WAM_IND,
      CALCULATE_GPA_IND,
      OUTCOME_CHECK_TYPE
    from IGS_PR_S_OU_PRG_CONF
    where ROWID = X_ROWID
    for update nowait;
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

  if ( (tlinfo.APPLY_START_DT_ALIAS = X_APPLY_START_DT_ALIAS)
      AND (tlinfo.APPLY_END_DT_ALIAS = X_APPLY_END_DT_ALIAS)
      AND (tlinfo.END_BENEFIT_DT_ALIAS = X_END_BENEFIT_DT_ALIAS)
      AND (tlinfo.END_PENALTY_DT_ALIAS = X_END_PENALTY_DT_ALIAS)
      AND ((tlinfo.SHOW_CAUSE_CUTOFF_DT_ALIAS = X_SHOW_CAUSE_CUTOFF_DT_ALIAS)
           OR ((tlinfo.SHOW_CAUSE_CUTOFF_DT_ALIAS is null)
               AND (X_SHOW_CAUSE_CUTOFF_DT_ALIAS is null)))
      AND ((tlinfo.APPEAL_CUTOFF_DT_ALIAS = X_APPEAL_CUTOFF_DT_ALIAS)
           OR ((tlinfo.APPEAL_CUTOFF_DT_ALIAS is null)
               AND (X_APPEAL_CUTOFF_DT_ALIAS is null)))
      AND (tlinfo.SHOW_CAUSE_IND = X_SHOW_CAUSE_IND)
      AND (tlinfo.APPLY_BEFORE_SHOW_IND = X_APPLY_BEFORE_SHOW_IND)
      AND (tlinfo.APPEAL_IND = X_APPEAL_IND)
      AND (tlinfo.APPLY_BEFORE_APPEAL_IND = X_APPLY_BEFORE_APPEAL_IND)
      AND (tlinfo.COUNT_SUS_IN_TIME_IND = X_COUNT_SUS_IN_TIME_IND)
      AND (tlinfo.COUNT_EXC_IN_TIME_IND = X_COUNT_EXC_IN_TIME_IND)
      AND (tlinfo.CALCULATE_WAM_IND = X_CALCULATE_WAM_IND)
      AND (tlinfo.CALCULATE_GPA_IND = X_CALCULATE_GPA_IND)
      AND ((tlinfo.OUTCOME_CHECK_TYPE = X_OUTCOME_CHECK_TYPE)
      OR ((tlinfo.OUTCOME_CHECK_TYPE is null)
               AND (X_OUTCOME_CHECK_TYPE is null)))
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
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_APPLY_START_DT_ALIAS in VARCHAR2,
  X_APPLY_END_DT_ALIAS in VARCHAR2,
  X_END_BENEFIT_DT_ALIAS in VARCHAR2,
  X_END_PENALTY_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_APPEAL_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_IND in VARCHAR2,
  X_APPLY_BEFORE_SHOW_IND in VARCHAR2,
  X_APPEAL_IND in VARCHAR2,
  X_APPLY_BEFORE_APPEAL_IND in VARCHAR2,
  X_COUNT_SUS_IN_TIME_IND in VARCHAR2,
  X_COUNT_EXC_IN_TIME_IND in VARCHAR2,
  X_CALCULATE_WAM_IND in VARCHAR2,
  X_CALCULATE_GPA_IND in VARCHAR2,
  X_OUTCOME_CHECK_TYPE in VARCHAR2,
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

    Before_DML(
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
     x_appeal_cutoff_dt_alias => X_APPEAL_CUTOFF_DT_ALIAS,
     x_appeal_ind => X_APPEAL_IND,
     x_apply_before_appeal_ind => X_APPLY_BEFORE_APPEAL_IND,
     x_apply_before_show_ind => X_APPLY_BEFORE_SHOW_IND,
     x_apply_end_dt_alias => X_APPLY_END_DT_ALIAS,
     x_apply_start_dt_alias => X_APPLY_START_DT_ALIAS,
     x_calculate_gpa_ind => X_CALCULATE_GPA_IND,
     x_calculate_wam_ind => X_CALCULATE_WAM_IND,
     x_count_exc_in_time_ind => X_COUNT_EXC_IN_TIME_IND,
     x_count_sus_in_time_ind => X_COUNT_SUS_IN_TIME_IND,
     x_end_benefit_dt_alias => X_END_BENEFIT_DT_ALIAS,
     x_end_penalty_dt_alias => X_END_PENALTY_DT_ALIAS,
     x_org_unit_cd => X_ORG_UNIT_CD,
     x_ou_start_dt => X_OU_START_DT,
     x_show_cause_cutoff_dt_alias => X_SHOW_CAUSE_CUTOFF_DT_ALIAS,
     x_show_cause_ind => X_SHOW_CAUSE_IND,
     x_outcome_check_type => X_OUTCOME_CHECK_TYPE,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
     );

  update IGS_PR_S_OU_PRG_CONF set
    APPLY_START_DT_ALIAS = NEW_REFERENCES.APPLY_START_DT_ALIAS,
    APPLY_END_DT_ALIAS = NEW_REFERENCES.APPLY_END_DT_ALIAS,
    END_BENEFIT_DT_ALIAS = NEW_REFERENCES.END_BENEFIT_DT_ALIAS,
    END_PENALTY_DT_ALIAS = NEW_REFERENCES.END_PENALTY_DT_ALIAS,
    SHOW_CAUSE_CUTOFF_DT_ALIAS = NEW_REFERENCES.SHOW_CAUSE_CUTOFF_DT_ALIAS,
    APPEAL_CUTOFF_DT_ALIAS = NEW_REFERENCES.APPEAL_CUTOFF_DT_ALIAS,
    SHOW_CAUSE_IND = NEW_REFERENCES.SHOW_CAUSE_IND,
    APPLY_BEFORE_SHOW_IND = NEW_REFERENCES.APPLY_BEFORE_SHOW_IND,
    APPEAL_IND = NEW_REFERENCES.APPEAL_IND,
    APPLY_BEFORE_APPEAL_IND = NEW_REFERENCES.APPLY_BEFORE_APPEAL_IND,
    COUNT_SUS_IN_TIME_IND = NEW_REFERENCES.COUNT_SUS_IN_TIME_IND,
    COUNT_EXC_IN_TIME_IND = NEW_REFERENCES.COUNT_EXC_IN_TIME_IND,
    CALCULATE_WAM_IND = NEW_REFERENCES.CALCULATE_WAM_IND,
    CALCULATE_GPA_IND = NEW_REFERENCES.CALCULATE_GPA_IND,
    OUTCOME_CHECK_TYPE = NEW_REFERENCES.OUTCOME_CHECK_TYPE,
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
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_APPLY_START_DT_ALIAS in VARCHAR2,
  X_APPLY_END_DT_ALIAS in VARCHAR2,
  X_END_BENEFIT_DT_ALIAS in VARCHAR2,
  X_END_PENALTY_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_APPEAL_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SHOW_CAUSE_IND in VARCHAR2,
  X_APPLY_BEFORE_SHOW_IND in VARCHAR2,
  X_APPEAL_IND in VARCHAR2,
  X_APPLY_BEFORE_APPEAL_IND in VARCHAR2,
  X_COUNT_SUS_IN_TIME_IND in VARCHAR2,
  X_COUNT_EXC_IN_TIME_IND in VARCHAR2,
  X_CALCULATE_WAM_IND in VARCHAR2,
  X_CALCULATE_GPA_IND in VARCHAR2,
  X_OUTCOME_CHECK_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_PR_S_OU_PRG_CONF
     where ORG_UNIT_CD = X_ORG_UNIT_CD
     and OU_START_DT = X_OU_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_UNIT_CD,
     X_OU_START_DT,
     X_APPLY_START_DT_ALIAS,
     X_APPLY_END_DT_ALIAS,
     X_END_BENEFIT_DT_ALIAS,
     X_END_PENALTY_DT_ALIAS,
     X_SHOW_CAUSE_CUTOFF_DT_ALIAS,
     X_APPEAL_CUTOFF_DT_ALIAS,
     X_SHOW_CAUSE_IND,
     X_APPLY_BEFORE_SHOW_IND,
     X_APPEAL_IND,
     X_APPLY_BEFORE_APPEAL_IND,
     X_COUNT_SUS_IN_TIME_IND,
     X_COUNT_EXC_IN_TIME_IND,
     X_CALCULATE_WAM_IND,
     X_CALCULATE_GPA_IND,
     X_OUTCOME_CHECK_TYPE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ORG_UNIT_CD,
   X_OU_START_DT,
   X_APPLY_START_DT_ALIAS,
   X_APPLY_END_DT_ALIAS,
   X_END_BENEFIT_DT_ALIAS,
   X_END_PENALTY_DT_ALIAS,
   X_SHOW_CAUSE_CUTOFF_DT_ALIAS,
   X_APPEAL_CUTOFF_DT_ALIAS,
   X_SHOW_CAUSE_IND,
   X_APPLY_BEFORE_SHOW_IND,
   X_APPEAL_IND,
   X_APPLY_BEFORE_APPEAL_IND,
   X_COUNT_SUS_IN_TIME_IND,
   X_COUNT_EXC_IN_TIME_IND,
   X_CALCULATE_WAM_IND,
   X_CALCULATE_GPA_IND,
   X_OUTCOME_CHECK_TYPE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
    Before_DML(
     p_action => 'DELETE',
     x_rowid => X_ROWID
   );

  delete from IGS_PR_S_OU_PRG_CONF
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
ELSIF upper(Column_name) = 'APPEAL_CUTOFF_DT_ALIAS' THEN
  new_references.APPEAL_CUTOFF_DT_ALIAS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'APPEAL_IND' THEN
  new_references.APPEAL_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'APPLY_BEFORE_APPEAL_IND' THEN
  new_references.APPLY_BEFORE_APPEAL_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'APPLY_BEFORE_SHOW_IND' THEN
  new_references.APPLY_BEFORE_SHOW_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'APPLY_END_DT_ALIAS' THEN
  new_references.APPLY_END_DT_ALIAS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'APPLY_START_DT_ALIAS' THEN
  new_references.APPLY_START_DT_ALIAS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'CALCULATE_GPA_IND' THEN
  new_references.CALCULATE_GPA_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'CALCULATE_WAM_IND' THEN
  new_references.CALCULATE_WAM_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'COUNT_EXC_IN_TIME_IND' THEN
  new_references.COUNT_EXC_IN_TIME_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'COUNT_SUS_IN_TIME_IND' THEN
  new_references.COUNT_SUS_IN_TIME_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'END_BENEFIT_DT_ALIAS' THEN
  new_references.END_BENEFIT_DT_ALIAS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'END_PENALTY_DT_ALIAS' THEN
  new_references.END_PENALTY_DT_ALIAS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'ORG_UNIT_CD' THEN
  new_references.ORG_UNIT_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SHOW_CAUSE_CUTOFF_DT_ALIAS' THEN
  new_references.SHOW_CAUSE_CUTOFF_DT_ALIAS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SHOW_CAUSE_IND' THEN
  new_references.SHOW_CAUSE_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'OUTCOME_CHECK_TYPE' THEN
  new_references.OUTCOME_CHECK_TYPE:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'APPEAL_CUTOFF_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.APPEAL_CUTOFF_DT_ALIAS<> upper(new_references.APPEAL_CUTOFF_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'APPEAL_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.APPEAL_IND<> upper(new_references.APPEAL_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.APPEAL_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'APPLY_BEFORE_APPEAL_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.APPLY_BEFORE_APPEAL_IND<> upper(new_references.APPLY_BEFORE_APPEAL_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.APPLY_BEFORE_APPEAL_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'APPLY_BEFORE_SHOW_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.APPLY_BEFORE_SHOW_IND<> upper(new_references.APPLY_BEFORE_SHOW_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.APPLY_BEFORE_SHOW_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'APPLY_END_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.APPLY_END_DT_ALIAS<> upper(new_references.APPLY_END_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

 IF upper(Column_name) = 'OUTCOME_CHECK_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.OUTCOME_CHECk_TYPE<> upper(new_references.OUTCOME_CHECK_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;


IF upper(Column_name) = 'APPLY_START_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.APPLY_START_DT_ALIAS<> upper(new_references.APPLY_START_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'CALCULATE_GPA_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CALCULATE_GPA_IND<> upper(new_references.CALCULATE_GPA_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.CALCULATE_GPA_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'CALCULATE_WAM_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CALCULATE_WAM_IND<> upper(new_references.CALCULATE_WAM_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.CALCULATE_WAM_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'COUNT_EXC_IN_TIME_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.COUNT_EXC_IN_TIME_IND<> upper(new_references.COUNT_EXC_IN_TIME_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.COUNT_EXC_IN_TIME_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'COUNT_SUS_IN_TIME_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.COUNT_SUS_IN_TIME_IND<> upper(new_references.COUNT_SUS_IN_TIME_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.COUNT_SUS_IN_TIME_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'END_BENEFIT_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.END_BENEFIT_DT_ALIAS<> upper(new_references.END_BENEFIT_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'END_PENALTY_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.END_PENALTY_DT_ALIAS<> upper(new_references.END_PENALTY_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;


IF upper(Column_name) = 'SHOW_CAUSE_CUTOFF_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.SHOW_CAUSE_CUTOFF_DT_ALIAS<> upper(new_references.SHOW_CAUSE_CUTOFF_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SHOW_CAUSE_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.SHOW_CAUSE_IND<> upper(new_references.SHOW_CAUSE_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.SHOW_CAUSE_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
END Check_Constraints;

end IGS_PR_S_OU_PRG_CONF_PKG;

/
