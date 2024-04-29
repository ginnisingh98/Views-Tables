--------------------------------------------------------
--  DDL for Package Body IGS_PR_RU_CA_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_RU_CA_TYPE_PKG" AS
/* $Header: IGSQI12B.pls 115.6 2002/11/29 03:16:51 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PR_RU_CA_TYPE_ALL%RowType;
  new_references IGS_PR_RU_CA_TYPE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_start_sequence_number IN NUMBER DEFAULT NULL,
    x_end_sequence_number IN NUMBER DEFAULT NULL,
    x_start_effective_period IN NUMBER DEFAULT NULL,
    x_num_of_applications IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_RU_CA_TYPE_ALL
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
    new_references.progression_rule_cat := x_progression_rule_cat;
    new_references.pra_sequence_number := x_pra_sequence_number;
    new_references.prg_cal_type := x_prg_cal_type;
    new_references.start_sequence_number := x_start_sequence_number;
    new_references.end_sequence_number := x_end_sequence_number;
    new_references.start_effective_period := x_start_effective_period;
    new_references.num_of_applications := x_num_of_applications;
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

  -- Trigger description :-
  -- "OSS_TST".trg_prct_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_PR_RU_CA_TYPE
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate the progression calendar type
	IF p_inserting THEN
		IF igs_pr_val_scpca.prgp_val_cfg_cat (
					new_references.prg_cal_type,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the start and end sequence number
	IF p_inserting OR (p_updating AND
	   (NVL(new_references.start_sequence_number, 0) <> NVL(old_references.start_sequence_number, 0) OR
	   NVL(new_references.end_sequence_number, 0) <> NVL(old_references.end_sequence_number, 0))) THEN
		IF IGS_PR_VAL_PRCT.prgp_val_prct_ci (
					new_references.prg_cal_type,
					new_references.start_sequence_number,
					new_references.end_sequence_number,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.prg_cal_type = new_references.prg_cal_type)) OR
        ((new_references.prg_cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_TYPE_PKG.Get_PK_For_Validation (
        new_references.prg_cal_type
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.prg_cal_type = new_references.prg_cal_type) AND
         (old_references.end_sequence_number = new_references.end_sequence_number)) OR
        ((new_references.prg_cal_type IS NULL) OR
         (new_references.end_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.prg_cal_type,
        new_references.end_sequence_number
        ) THEN
			Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.prg_cal_type = new_references.prg_cal_type) AND
         (old_references.start_sequence_number = new_references.start_sequence_number)) OR
        ((new_references.prg_cal_type IS NULL) OR
         (new_references.start_sequence_number IS NULL))) THEN
      NULL;
    ELSE
     IF NOT  IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.prg_cal_type,
        new_references.start_sequence_number
        ) THEN

	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.progression_rule_cat = new_references.progression_rule_cat) AND
         (old_references.pra_sequence_number = new_references.pra_sequence_number)) OR
        ((new_references.progression_rule_cat IS NULL) OR
         (new_references.pra_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_RU_APPL_PKG.Get_PK_For_Validation (
        new_references.progression_rule_cat,
        new_references.pra_sequence_number
        ) THEN

		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_prg_cal_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_CA_TYPE_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_pra_sequence_number
      AND      prg_cal_type = x_prg_cal_type
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

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_CA_TYPE_ALL
      WHERE    prg_cal_type = x_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRCT_CAT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_TYPE;

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_CA_TYPE_ALL
      WHERE   ( prg_cal_type = x_cal_type
      AND      end_sequence_number = x_sequence_number )
      OR       (prg_cal_type = x_cal_type
      AND      start_sequence_number = x_sequence_number) ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRCT_CI_END_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_PR_RU_APPL (
    x_progression_rule_cat IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_CA_TYPE_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRCT_PRA_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_RU_APPL;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_start_sequence_number IN NUMBER DEFAULT NULL,
    x_end_sequence_number IN NUMBER DEFAULT NULL,
    x_start_effective_period IN NUMBER DEFAULT NULL,
    x_num_of_applications IN NUMBER DEFAULT NULL,
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
      x_progression_rule_cat,
      x_pra_sequence_number,
      x_prg_cal_type,
      x_start_sequence_number,
      x_end_sequence_number,
      x_start_effective_period,
      x_num_of_applications,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      Check_Parent_Existance;
	IF GET_PK_FOR_VALIDATION(
		    new_references.progression_rule_cat,
		    new_references.pra_sequence_number,
		    new_references.prg_cal_type ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;
	CHECK_CONSTRAINTS;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Parent_Existance;
	CHECK_CONSTRAINTS;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
		    new_references.progression_rule_cat,
		    new_references.pra_sequence_number,
		    new_references.prg_cal_type ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;
	CHECK_CONSTRAINTS;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	CHECK_CONSTRAINTS;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_START_SEQUENCE_NUMBER in NUMBER,
  X_END_SEQUENCE_NUMBER in NUMBER,
  X_START_EFFECTIVE_PERIOD in NUMBER,
  X_NUM_OF_APPLICATIONS in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  x_ORG_ID IN NUMBER
  ) AS
    cursor C is select ROWID from IGS_PR_RU_CA_TYPE_ALL
      where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
      and PRA_SEQUENCE_NUMBER = X_PRA_SEQUENCE_NUMBER
      and PRG_CAL_TYPE = X_PRG_CAL_TYPE;
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
    x_rowid => x_rowid ,
    x_progression_rule_cat => x_progression_rule_cat ,
    x_pra_sequence_number => x_pra_sequence_number ,
    x_prg_cal_type => x_prg_cal_type ,
    x_start_sequence_number => x_start_sequence_number ,
    x_end_sequence_number => x_end_sequence_number ,
    x_start_effective_period => x_start_effective_period ,
    x_num_of_applications => x_num_of_applications ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login,
    x_org_id => igs_ge_gen_003.get_org_id
  );
  insert into IGS_PR_RU_CA_TYPE_ALL (
    PROGRESSION_RULE_CAT,
    PRA_SEQUENCE_NUMBER,
    PRG_CAL_TYPE,
    START_SEQUENCE_NUMBER,
    END_SEQUENCE_NUMBER,
    START_EFFECTIVE_PERIOD,
    NUM_OF_APPLICATIONS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PROGRESSION_RULE_CAT,
    NEW_REFERENCES.PRA_SEQUENCE_NUMBER,
    NEW_REFERENCES.PRG_CAL_TYPE,
    NEW_REFERENCES.START_SEQUENCE_NUMBER,
    NEW_REFERENCES.END_SEQUENCE_NUMBER,
    NEW_REFERENCES.START_EFFECTIVE_PERIOD,
    NEW_REFERENCES.NUM_OF_APPLICATIONS,
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
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_START_SEQUENCE_NUMBER in NUMBER,
  X_END_SEQUENCE_NUMBER in NUMBER,
  X_START_EFFECTIVE_PERIOD in NUMBER,
  X_NUM_OF_APPLICATIONS in NUMBER
) AS
  cursor c1 is select
      START_SEQUENCE_NUMBER,
      END_SEQUENCE_NUMBER,
      START_EFFECTIVE_PERIOD,
      NUM_OF_APPLICATIONS
    from IGS_PR_RU_CA_TYPE_ALL
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

      if ( ((tlinfo.START_SEQUENCE_NUMBER = X_START_SEQUENCE_NUMBER)
           OR ((tlinfo.START_SEQUENCE_NUMBER is null)
               AND (X_START_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.END_SEQUENCE_NUMBER = X_END_SEQUENCE_NUMBER)
           OR ((tlinfo.END_SEQUENCE_NUMBER is null)
               AND (X_END_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.START_EFFECTIVE_PERIOD = X_START_EFFECTIVE_PERIOD)
           OR ((tlinfo.START_EFFECTIVE_PERIOD is null)
               AND (X_START_EFFECTIVE_PERIOD is null)))
      AND ((tlinfo.NUM_OF_APPLICATIONS = X_NUM_OF_APPLICATIONS)
           OR ((tlinfo.NUM_OF_APPLICATIONS is null)
               AND (X_NUM_OF_APPLICATIONS is null)))
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
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_START_SEQUENCE_NUMBER in NUMBER,
  X_END_SEQUENCE_NUMBER in NUMBER,
  X_START_EFFECTIVE_PERIOD in NUMBER,
  X_NUM_OF_APPLICATIONS in NUMBER,
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
    x_rowid => x_rowid ,
    x_progression_rule_cat => x_progression_rule_cat ,
    x_pra_sequence_number => x_pra_sequence_number ,
    x_prg_cal_type => x_prg_cal_type ,
    x_start_sequence_number => x_start_sequence_number ,
    x_end_sequence_number => x_end_sequence_number ,
    x_start_effective_period => x_start_effective_period ,
    x_num_of_applications => x_num_of_applications ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login
  );

  update IGS_PR_RU_CA_TYPE_ALL set
    START_SEQUENCE_NUMBER = NEW_REFERENCES.START_SEQUENCE_NUMBER,
    END_SEQUENCE_NUMBER = NEW_REFERENCES.END_SEQUENCE_NUMBER,
    START_EFFECTIVE_PERIOD = NEW_REFERENCES.START_EFFECTIVE_PERIOD,
    NUM_OF_APPLICATIONS = NEW_REFERENCES.NUM_OF_APPLICATIONS,
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
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_START_SEQUENCE_NUMBER in NUMBER,
  X_END_SEQUENCE_NUMBER in NUMBER,
  X_START_EFFECTIVE_PERIOD in NUMBER,
  X_NUM_OF_APPLICATIONS in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PR_RU_CA_TYPE_ALL
     where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
     and PRA_SEQUENCE_NUMBER = X_PRA_SEQUENCE_NUMBER
     and PRG_CAL_TYPE = X_PRG_CAL_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PROGRESSION_RULE_CAT,
     X_PRA_SEQUENCE_NUMBER,
     X_PRG_CAL_TYPE,
     X_START_SEQUENCE_NUMBER,
     X_END_SEQUENCE_NUMBER,
     X_START_EFFECTIVE_PERIOD,
     X_NUM_OF_APPLICATIONS,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PROGRESSION_RULE_CAT,
   X_PRA_SEQUENCE_NUMBER,
   X_PRG_CAL_TYPE,
   X_START_SEQUENCE_NUMBER,
   X_END_SEQUENCE_NUMBER,
   X_START_EFFECTIVE_PERIOD,
   X_NUM_OF_APPLICATIONS,
   X_MODE );

end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
BEFORE_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_PR_RU_CA_TYPE_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
    BEGIN
	IF column_name IS NULL THEN
		NULL;
	ELSIF upper(Column_name) = 'PRA_SEQUENCE_NUMBER' then
	    new_references.pra_sequence_number := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'END_SEQUENCE_NUMBER'  then
	    new_references.end_sequence_number := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'START_SEQUENCE_NUMBER'  then
	    new_references.start_sequence_number := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'PRG_CAL_TYPE'  then
	    new_references.prg_cal_type:= column_value;
	ELSIF upper(Column_name) = 'PROGRESSION_RULE_CAT' then
	    new_references.progression_rule_cat:= column_value;
	ELSIF upper(Column_name) = 'START_EFFECTIVE_PERIOD'  then
	    new_references.start_effective_period := IGS_GE_NUMBER.to_num(column_value);
	ELSIF upper(Column_name) = 'NUM_OF_APPLICATIONS' then
	    new_references.num_of_applications := IGS_GE_NUMBER.to_num(column_value);
	END IF;

IF UPPER(column_name) = 'PRA_SEQUENCE_NUMBER' OR column_name IS NULL THEN
	IF new_references.pra_sequence_number < 1 OR
	   new_references.pra_sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;

IF UPPER(column_name) = 'END_SEQUENCE_NUMBER' OR column_name IS NULL THEN
	IF new_references.end_sequence_number < 1 OR
	   new_references.end_sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;
IF UPPER(column_name) = 'START_SEQUENCE_NUMBER' OR column_name IS NULL THEN
	IF new_references.start_sequence_number < 1 OR
	   new_references.start_sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;
IF UPPER(column_name) = 'START_EFFECTIVE_PERIOD'  OR column_name IS NULL THEN
	IF new_references.start_effective_period < 1 OR
	   new_references.start_effective_period > 99 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;

IF UPPER(column_name) = 'NUM_OF_APPLICATIONS' OR column_name IS NULL THEN
	IF new_references.num_of_applications < 1 OR
	   new_references.num_of_applications > 99 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;

IF UPPER(column_name) = 'PRG_CAL_TYPE'  OR column_name IS NULL THEN
		IF new_references.prg_cal_type <> UPPER(new_references.prg_cal_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;

IF UPPER(column_name) = 'PROGRESSION_RULE_CAT' OR column_name IS NULL THEN
		IF new_references.progression_rule_cat<> UPPER(new_references.progression_rule_cat) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
END IF;

END Check_Constraints;
end IGS_PR_RU_CA_TYPE_PKG;

/
