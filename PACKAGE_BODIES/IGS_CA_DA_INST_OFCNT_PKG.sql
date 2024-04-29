--------------------------------------------------------
--  DDL for Package Body IGS_CA_DA_INST_OFCNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_DA_INST_OFCNT_PKG" AS
/* $Header: IGSCI05B.pls 120.1 2006/01/25 09:17:10 skpandey noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_CA_DA_INST_OFCNT%RowType;
  new_references IGS_CA_DA_INST_OFCNT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_offset_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_cal_type IN VARCHAR2 DEFAULT NULL,
    x_offset_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_dt_offset_constraint_type IN VARCHAR2 DEFAULT NULL,
    x_constraint_condition IN VARCHAR2 DEFAULT NULL,
    x_constraint_resolution IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_DA_INST_OFCNT
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.dt_alias := x_dt_alias;
    new_references.dai_sequence_number := x_dai_sequence_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.offset_dt_alias := x_offset_dt_alias;
    new_references.offset_dai_sequence_number := x_offset_dai_sequence_number;
    new_references.offset_cal_type := x_offset_cal_type;
    new_references.offset_ci_sequence_number := x_offset_ci_sequence_number;
    new_references.s_dt_offset_constraint_type := x_s_dt_offset_constraint_type;
    new_references.constraint_condition := x_constraint_condition;
    new_references.constraint_resolution := x_constraint_resolution;
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
  -- "OSS_TST".trg_daioc_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_CA_DA_INST_OFCNT
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
  BEGIN
	IF p_inserting
	THEN
		-- Validate constraint type is not closed.
		IF IGS_CA_VAL_DAIOC.calp_val_sdoct_clsd(
					new_references.s_dt_offset_constraint_type,
					v_message_name) = FALSE
		THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

	END IF;
  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_daioc_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_CA_DA_INST_OFCNT

  PROCEDURE AfterStmtInsertUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
  BEGIN
  	-- Validate the dt alias instance offset constraint.
  	IF p_inserting or p_updating THEN
  		IF IGS_CA_VAL_DAIOC.calp_val_sdoct_clash
  			             (new_references.dt_alias,
  		    	              new_references.offset_dt_alias,
  			              new_references.dai_sequence_number,
  		    	              new_references.offset_dai_sequence_number,
  			              new_references.cal_type,
  		    	              new_references.offset_cal_type,
  			              new_references.ci_sequence_number,
  		    	              new_references.offset_ci_sequence_number,
  			              new_references.s_dt_offset_constraint_type,
  			              new_references.constraint_condition,
  			              new_references.constraint_resolution,
  			              v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
  	END IF;
  END AfterStmtInsertUpdate3;

 PROCEDURE Check_Constraints (
	Column_Name 	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)
	AS
	BEGIN
	IF  column_name is null then
                        NULL;
                  ELSIF UPPER(column_name) = 'DAI_SEQUENCE_NUMBER ' Then
				new_references.dai_sequence_number := igs_ge_number.to_num(column_value);
			Elsif UPPER(column_name) = 'CAL_TYPE' Then
				NEW_REFERENCES.cal_type:= column_value;
			Elsif UPPER(column_name) = 'DT_ALIAS' Then
				NEW_REFERENCES.dt_alias := column_value;
                  Elsif UPPER(column_name) = 'OFFSET_CAL_TYPE' Then
				NEW_REFERENCES.offset_cal_type:= column_value;
                  Elsif UPPER(column_name) = 'OFFSET_DT_ALIAS' Then
				NEW_REFERENCES.offset_dt_alias:= column_value;
                  Elsif UPPER(column_name) = 'S_DT_OFFSET_CONSTRAINT_TYPE' Then
				NEW_REFERENCES.s_dt_offset_constraint_type:= column_value;
                  Elsif UPPER(column_name) = 'CONSTRAINT_CONDITION' Then
				NEW_REFERENCES.constraint_condition:= column_value;
                  Elsif UPPER(column_name) = 'CONSTRAINT_RESOLUTION' Then
				NEW_REFERENCES.constraint_resolution:= igs_ge_number.to_num(column_value);
                  ELSIF UPPER(column_name) = 'OFFSET_CI_SEQUENCE_NUMBER' Then
				new_references.offset_ci_sequence_number := igs_ge_number.to_num(column_value);
			Elsif UPPER(column_name) = 'OFFSET_DAI_SEQUENCE_NUMBER' Then
				NEW_REFERENCES.offset_dai_sequence_number := igs_ge_number.to_num(column_value);
			Elsif UPPER(column_name) = 'CI_SEQUENCE_NUMBER' Then
				NEW_REFERENCES.ci_sequence_number :=igs_ge_number.to_num(column_value);
     	end if;
			If upper(column_name) = 'DAI_SEQUENCE_NUMBER' or column_name is null Then
				if NEW_REFERENCES.dai_sequence_number <1  OR
                           NEW_REFERENCES.dai_sequence_number > 999999 then
                           Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                           IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
			if upper(column_name) = 'CAL_TYPE' or column_name is null Then
				if NEW_REFERENCES.cal_type <> UPPER(NEW_REFERENCES.cal_type )THEN
                       	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                       	   IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
			if upper(column_name) = 'DT_ALIAS' or column_name is null Then
				if NEW_REFERENCES.dt_alias <> UPPER(NEW_REFERENCES.dt_alias)THEN
                       	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                       	   IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;

                  if upper(column_name) = 'OFFSET_CAL_TYPE' or column_name is null Then
				if NEW_REFERENCES.offset_cal_type <> UPPER(NEW_REFERENCES.offset_cal_type)THEN
                       	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                       	   IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
                  if upper(column_name) = 'OFFSET_DT_ALIAS' or column_name is null Then
				if NEW_REFERENCES.offset_dt_alias <> UPPER( NEW_REFERENCES.offset_dt_alias) then
                  	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  	   IGS_GE_MSG_STACK.ADD;
                   	   App_Exception.Raise_Exception;
				end if;
			end if;
                  if upper(column_name) = 'S_DT_OFFSET_CONSTRAINT_TYPE' or column_name is null Then
				if NEW_REFERENCES.s_dt_offset_constraint_type <> UPPER( NEW_REFERENCES.s_dt_offset_constraint_type ) then
                  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  		IGS_GE_MSG_STACK.ADD;
                  		App_Exception.Raise_Exception;
				end if;
			end if;
                  if upper(column_name) = 'CONSTRAINT_CONDITION' or column_name is null Then
				if NEW_REFERENCES.constraint_condition NOT IN ('MUST' , 'MUST NOT') then
                  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  		IGS_GE_MSG_STACK.ADD;
                  		App_Exception.Raise_Exception;
				end if;
			end if;
                  If upper(column_name) = 'CONSTRAINT_RESOLUTION' or column_name is null Then
				if NEW_REFERENCES.constraint_resolution < -9 OR
                           NEW_REFERENCES.constraint_resolution > 9 then
                           Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                           IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
                  If upper(column_name) = 'OFFSET_CI_SEQUENCE_NUMBER ' or column_name is null Then
				if NEW_REFERENCES.offset_ci_sequence_number < 1 OR
                           NEW_REFERENCES.offset_ci_sequence_number > 999999 then
                           Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                           IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
                  If upper(column_name) = 'OFFSET_DAI_SEQUENCE_NUMBER' or column_name is null Then
				if NEW_REFERENCES.offset_dai_sequence_number < 1 OR
                           NEW_REFERENCES.offset_dai_sequence_number > 999999 then
                           Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                           IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
                  If upper(column_name) = 'CI_SEQUENCE_NUMBER' or column_name is null Then
				if NEW_REFERENCES.ci_sequence_number < 1 OR
                           NEW_REFERENCES.ci_sequence_number > 999999 then
                           Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                           IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;

    END Check_Constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.dt_alias = new_references.dt_alias) AND
         (old_references.dai_sequence_number = new_references.dai_sequence_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.offset_dt_alias = new_references.offset_dt_alias) AND
         (old_references.offset_dai_sequence_number = new_references.offset_dai_sequence_number) AND
         (old_references.offset_cal_type = new_references.offset_cal_type) AND
         (old_references.offset_ci_sequence_number = new_references.offset_ci_sequence_number)) OR
        ((new_references.dt_alias IS NULL) OR
         (new_references.dai_sequence_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.offset_dt_alias IS NULL) OR
         (new_references.offset_dai_sequence_number IS NULL) OR
         (new_references.offset_cal_type IS NULL) OR
         (new_references.offset_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_OFST_PKG.Get_PK_For_Validation (
        new_references.dt_alias,
        new_references.dai_sequence_number,
        new_references.cal_type,
        new_references.ci_sequence_number,
        new_references.offset_dt_alias,
        new_references.offset_dai_sequence_number,
        new_references.offset_cal_type,
        new_references.offset_ci_sequence_number
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.s_dt_offset_constraint_type = new_references.s_dt_offset_constraint_type)) OR
        ((new_references.s_dt_offset_constraint_type IS NULL))) THEN
      NULL;
    ELSE
         NULL;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_offset_cal_type IN VARCHAR2,
    x_offset_ci_sequence_number IN NUMBER,
    x_offset_dt_alias IN VARCHAR2,
    x_offset_dai_sequence_number IN NUMBER,
    x_s_dt_offset_constraint_type IN VARCHAR2
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_INST_OFCNT
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      dt_alias = x_dt_alias
      AND      dai_sequence_number = x_dai_sequence_number
      AND      offset_cal_type = x_offset_cal_type
      AND      offset_ci_sequence_number = x_offset_ci_sequence_number
      AND      offset_dt_alias = x_offset_dt_alias
      AND      offset_dai_sequence_number = x_offset_dai_sequence_number
      AND      s_dt_offset_constraint_type = x_s_dt_offset_constraint_type
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

  PROCEDURE GET_FK_IGS_CA_DA_INST_OFST (
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_offset_dt_alias IN VARCHAR2,
    x_offset_dai_sequence_number IN NUMBER,
    x_offset_cal_type IN VARCHAR2,
    x_offset_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_INST_OFCNT
      WHERE    dt_alias = x_dt_alias
      AND      dai_sequence_number = x_dai_sequence_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      offset_dt_alias = x_offset_dt_alias
      AND      offset_dai_sequence_number = x_offset_dai_sequence_number
      AND      offset_cal_type = x_offset_cal_type
      AND      offset_ci_sequence_number = x_offset_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_DAIOC_DAIO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA_INST_OFST;

--skpandey; Bug#3686538: Stubbed as a part of query optimization
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_dt_offset_constraint_type IN VARCHAR2
    ) AS
  BEGIN
	NULL;
  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_offset_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_cal_type IN VARCHAR2 DEFAULT NULL,
    x_offset_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_dt_offset_constraint_type IN VARCHAR2 DEFAULT NULL,
    x_constraint_condition IN VARCHAR2 DEFAULT NULL,
    x_constraint_resolution IN NUMBER DEFAULT NULL,
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
      x_dt_alias,
      x_dai_sequence_number,
      x_cal_type,
      x_ci_sequence_number,
      x_offset_dt_alias,
      x_offset_dai_sequence_number,
      x_offset_cal_type,
      x_offset_ci_sequence_number,
      x_s_dt_offset_constraint_type,
      x_constraint_condition,
      x_constraint_resolution,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
    		new_references.cal_type ,
    		new_references.ci_sequence_number ,
            new_references.dt_alias ,
    		new_references.dai_sequence_number ,
    		new_references.offset_cal_type ,
    		new_references.offset_ci_sequence_number ,
    		new_references.offset_dt_alias ,
    		new_references.offset_dai_sequence_number ,
    		new_references.s_dt_offset_constraint_type ) Then
	       		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	       		IGS_GE_MSG_STACK.ADD;
	      		App_Exception.Raise_Exception;
       END IF;
      CHECK_CONSTRAINTS;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      CHECK_CONSTRAINTS;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
      	new_references.cal_type ,
    		new_references.ci_sequence_number ,
            new_references.dt_alias ,
    		new_references.dai_sequence_number ,
    		new_references.offset_cal_type ,
    		new_references.offset_ci_sequence_number ,
    		new_references.offset_dt_alias ,
    		new_references.offset_dai_sequence_number ,
    		new_references.s_dt_offset_constraint_type ) Then
      	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      	IGS_GE_MSG_STACK.ADD;
      	App_Exception.Raise_Exception;
       END IF;
       CHECK_CONSTRAINTS;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
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
      AfterStmtInsertUpdate3 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterStmtInsertUpdate3 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_CAL_TYPE in VARCHAR2,
  X_OFFSET_CI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_OFFSET_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_CA_DA_INST_OFCNT
      where CAL_TYPE = X_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
      and DT_ALIAS = X_DT_ALIAS
      and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
      and OFFSET_CAL_TYPE = X_OFFSET_CAL_TYPE
      and OFFSET_CI_SEQUENCE_NUMBER = X_OFFSET_CI_SEQUENCE_NUMBER
      and OFFSET_DT_ALIAS = X_OFFSET_DT_ALIAS
      and OFFSET_DAI_SEQUENCE_NUMBER = X_OFFSET_DAI_SEQUENCE_NUMBER
      and S_DT_OFFSET_CONSTRAINT_TYPE = X_S_DT_OFFSET_CONSTRAINT_TYPE;
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
    p_action =>'INSERT',
    x_rowid =>X_ROWID,
    x_dt_alias =>X_DT_ALIAS,
    x_dai_sequence_number =>X_DAI_SEQUENCE_NUMBER,
    x_cal_type =>X_CAL_TYPE,
    x_ci_sequence_number =>X_CI_SEQUENCE_NUMBER,
    x_offset_dt_alias =>X_OFFSET_DT_ALIAS,
    x_offset_dai_sequence_number =>X_OFFSET_DAI_SEQUENCE_NUMBER,
    x_offset_cal_type =>X_OFFSET_CAL_TYPE,
    x_offset_ci_sequence_number =>X_OFFSET_CI_SEQUENCE_NUMBER,
    x_s_dt_offset_constraint_type =>X_S_DT_OFFSET_CONSTRAINT_TYPE,
    x_constraint_condition =>X_CONSTRAINT_CONDITION,
    x_constraint_resolution =>X_CONSTRAINT_RESOLUTION,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_CA_DA_INST_OFCNT (
    DT_ALIAS,
    DAI_SEQUENCE_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    OFFSET_DT_ALIAS,
    OFFSET_DAI_SEQUENCE_NUMBER,
    OFFSET_CAL_TYPE,
    OFFSET_CI_SEQUENCE_NUMBER,
    S_DT_OFFSET_CONSTRAINT_TYPE,
    CONSTRAINT_CONDITION,
    CONSTRAINT_RESOLUTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.OFFSET_DT_ALIAS,
    NEW_REFERENCES.OFFSET_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.OFFSET_CAL_TYPE,
    NEW_REFERENCES.OFFSET_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_DT_OFFSET_CONSTRAINT_TYPE,
    NEW_REFERENCES.CONSTRAINT_CONDITION,
    NEW_REFERENCES.CONSTRAINT_RESOLUTION,
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
After_DML (
    p_action =>'INSERT',
    x_rowid =>X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_CAL_TYPE in VARCHAR2,
  X_OFFSET_CI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_OFFSET_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER
) AS
  cursor c1 is select
      CONSTRAINT_CONDITION,
      CONSTRAINT_RESOLUTION
    from IGS_CA_DA_INST_OFCNT
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.CONSTRAINT_CONDITION = X_CONSTRAINT_CONDITION)
      AND (tlinfo.CONSTRAINT_RESOLUTION = X_CONSTRAINT_RESOLUTION)
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
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_CAL_TYPE in VARCHAR2,
  X_OFFSET_CI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_OFFSET_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER,
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
    p_action =>'UPDATE',
    x_rowid =>X_ROWID,
    x_dt_alias =>X_DT_ALIAS,
    x_dai_sequence_number =>X_DAI_SEQUENCE_NUMBER,
    x_cal_type =>X_CAL_TYPE,
    x_ci_sequence_number =>X_CI_SEQUENCE_NUMBER,
    x_offset_dt_alias =>X_OFFSET_DT_ALIAS,
    x_offset_dai_sequence_number =>X_OFFSET_DAI_SEQUENCE_NUMBER,
    x_offset_cal_type =>X_OFFSET_CAL_TYPE,
    x_offset_ci_sequence_number =>X_OFFSET_CI_SEQUENCE_NUMBER,
    x_s_dt_offset_constraint_type =>X_S_DT_OFFSET_CONSTRAINT_TYPE,
    x_constraint_condition =>X_CONSTRAINT_CONDITION,
    x_constraint_resolution =>X_CONSTRAINT_RESOLUTION,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
update IGS_CA_DA_INST_OFCNT set
    CONSTRAINT_CONDITION = NEW_REFERENCES.CONSTRAINT_CONDITION,
    CONSTRAINT_RESOLUTION = NEW_REFERENCES.CONSTRAINT_RESOLUTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'UPDATE',
    x_rowid =>X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_CAL_TYPE in VARCHAR2,
  X_OFFSET_CI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_OFFSET_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_CA_DA_INST_OFCNT
     where CAL_TYPE = X_CAL_TYPE
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
     and DT_ALIAS = X_DT_ALIAS
     and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
     and OFFSET_CAL_TYPE = X_OFFSET_CAL_TYPE
     and OFFSET_CI_SEQUENCE_NUMBER = X_OFFSET_CI_SEQUENCE_NUMBER
     and OFFSET_DT_ALIAS = X_OFFSET_DT_ALIAS
     and OFFSET_DAI_SEQUENCE_NUMBER = X_OFFSET_DAI_SEQUENCE_NUMBER
     and S_DT_OFFSET_CONSTRAINT_TYPE = X_S_DT_OFFSET_CONSTRAINT_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_DT_ALIAS,
     X_DAI_SEQUENCE_NUMBER,
     X_OFFSET_CAL_TYPE,
     X_OFFSET_CI_SEQUENCE_NUMBER,
     X_OFFSET_DT_ALIAS,
     X_OFFSET_DAI_SEQUENCE_NUMBER,
     X_S_DT_OFFSET_CONSTRAINT_TYPE,
     X_CONSTRAINT_CONDITION,
     X_CONSTRAINT_RESOLUTION,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_DT_ALIAS,
   X_DAI_SEQUENCE_NUMBER,
   X_OFFSET_CAL_TYPE,
   X_OFFSET_CI_SEQUENCE_NUMBER,
   X_OFFSET_DT_ALIAS,
   X_OFFSET_DAI_SEQUENCE_NUMBER,
   X_S_DT_OFFSET_CONSTRAINT_TYPE,
   X_CONSTRAINT_CONDITION,
   X_CONSTRAINT_RESOLUTION,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  delete from IGS_CA_DA_INST_OFCNT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
end DELETE_ROW;

end IGS_CA_DA_INST_OFCNT_PKG;

/
