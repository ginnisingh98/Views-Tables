--------------------------------------------------------
--  DDL for Package Body IGS_CA_DA_INST_OFST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_DA_INST_OFST_PKG" AS
/* $Header: IGSCI06B.pls 120.0 2005/06/02 03:28:57 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_CA_DA_INST_OFST%RowType;
  new_references IGS_CA_DA_INST_OFST%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_offset_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_day_offset IN NUMBER DEFAULT NULL,
    x_week_offset IN NUMBER DEFAULT NULL,
    x_month_offset IN NUMBER DEFAULT NULL,
    x_year_offset IN NUMBER DEFAULT NULL,
    x_ofst_override IN VARCHAR2 DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_offset_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_cal_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_DA_INST_OFST
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
    new_references.offset_ci_sequence_number := x_offset_ci_sequence_number;
    new_references.day_offset := x_day_offset;
    new_references.week_offset := x_week_offset;
    new_references.month_offset := x_month_offset;
    new_references.year_offset := x_year_offset;
    new_references.ofst_override := x_ofst_override;
    new_references.dt_alias := x_dt_alias;
    new_references.dai_sequence_number := x_dai_sequence_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.offset_dt_alias := x_offset_dt_alias;
    new_references.offset_dai_sequence_number := x_offset_dai_sequence_number;
    new_references.offset_cal_type := x_offset_cal_type;
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
  -- "OSS_TST".trg_daio_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_CA_DA_INST_OFST
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(80);
  BEGIN

	IF p_deleting
	THEN
		-- Validate delete of date alias insert offset
		IF IGS_CA_VAL_DAIO.calp_val_daio_del (old_references.dt_alias,
			old_references.dai_sequence_number,
			old_references.cal_type,
			old_references.ci_sequence_number,
			old_references.offset_dt_alias,
			old_references.offset_dai_sequence_number,
			old_references.offset_cal_type,
			old_references.offset_ci_sequence_number,
			v_message_name) = FALSE
		THEN
			    Fnd_Message.Set_Name('IGS',v_message_name);
			    IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_daio_as_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_CA_DA_INST_OFST

  PROCEDURE AfterStmtInsertUpdateDelete3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
v_message_name  varchar2(30);
  BEGIN
  	-- Validation routine calls.
  	IF p_inserting THEN
  		-- Validate insert of date alias insert offset
  		IF IGS_CA_VAL_DAIO.calp_val_daio_ins (NVL (new_references.dt_alias, old_references.dt_alias),
  			NVL (new_references.dai_sequence_number, old_references.dai_sequence_number),
  			NVL (new_references.cal_type, old_references.cal_type),
  			NVL (new_references.ci_sequence_number, old_references.ci_sequence_number),
  			NVL (new_references.offset_dt_alias, old_references.offset_dt_alias),
  			NVL (new_references.offset_dai_sequence_number, old_references.offset_dai_sequence_number),
  			NVL (new_references.offset_cal_type, old_references.offset_cal_type),
  			NVL (new_references.offset_ci_sequence_number, old_references.offset_ci_sequence_number),
  			v_message_name) = FALSE
  		THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
  	END IF;
  END AfterStmtInsertUpdateDelete3;


  PROCEDURE Check_Constraints (
	Column_Name 	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)
	IS
	BEGIN
	IF  column_name is null then
                        NULL;
                  ELSIF UPPER(column_name) = 'YEAR_OFFSET' Then
				new_references.year_offset :=igs_ge_number.to_num(column_value);
			Elsif UPPER(column_name) = 'WEEK_OFFSET' Then
				NEW_REFERENCES.week_offset:= igs_ge_number.to_num(column_value);
			Elsif UPPER(column_name) = 'DAY_OFFSET' Then
				NEW_REFERENCES.day_offset := igs_ge_number.to_num(column_value);
                  Elsif UPPER(column_name) = 'MONTH_OFFSET' Then
				NEW_REFERENCES.month_offset:= igs_ge_number.to_num(column_value);
                  Elsif UPPER(column_name) = 'DT_ALIAS' Then
				NEW_REFERENCES.dt_alias:= column_value;
                  Elsif UPPER(column_name) = 'CAL_TYPE' Then
				NEW_REFERENCES.cal_type:= column_value;
                  Elsif UPPER(column_name) = 'OFFSET_DT_ALIAS' Then
				NEW_REFERENCES.offset_dt_alias:= column_value;
                  Elsif UPPER(column_name) = 'OFFSET_CAL_TYPE' Then
				NEW_REFERENCES.offset_cal_type:= column_value;
                  Elsif UPPER(column_name) = 'OFST_OVERRIDE' Then
				NEW_REFERENCES.ofst_override := column_value;
	end if;
			If upper(column_name) = 'YEAR_OFFSET' or column_name is null Then
				if NEW_REFERENCES.year_offset < -9  OR
                           NEW_REFERENCES.year_offset > 9 then
                           Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                           IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
			if upper(column_name) = 'WEEK_OFFSET' or column_name is null Then
				if NEW_REFERENCES.week_offset < -99 OR
                           NEW_REFERENCES.week_offset > 99 then
                  	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  	   IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
			if upper(column_name) ='DAY_OFFSET' or column_name is null Then
				if NEW_REFERENCES.day_offset < -999 OR
                           NEW_REFERENCES.day_offset > 999 then
                  	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  	   IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
                  if upper(column_name) = 'MONTH_OFFSET' or column_name is null Then
				if NEW_REFERENCES.month_offset < -99 OR
                           NEW_REFERENCES.month_offset > 99 then
                  	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  	   IGS_GE_MSG_STACK.ADD;
                  	   App_Exception.Raise_Exception;
				end if;
			end if;
                  if upper(column_name) = 'DT_ALIAS' or column_name is null Then
				if NEW_REFERENCES.dt_alias <> UPPER( NEW_REFERENCES.dt_alias) then
                  	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  	   IGS_GE_MSG_STACK.ADD;
                   	   App_Exception.Raise_Exception;
				end if;
			end if;
                  if upper(column_name) = 'CAL_TYPE' or column_name is null Then
				if NEW_REFERENCES.cal_type <> UPPER( NEW_REFERENCES.cal_type) then
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
                  if upper(column_name) = 'OFFSET_CAL_TYPE' or column_name is null Then
				if NEW_REFERENCES.offset_cal_type <> UPPER( NEW_REFERENCES.offset_cal_type) then
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
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.dt_alias IS NULL) OR
         (new_references.dai_sequence_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
        new_references.dt_alias,
        new_references.dai_sequence_number,
        new_references.cal_type,
        new_references.ci_sequence_number
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.offset_dt_alias = new_references.offset_dt_alias) AND
         (old_references.offset_dai_sequence_number = new_references.offset_dai_sequence_number) AND
         (old_references.offset_cal_type = new_references.offset_cal_type) AND
         (old_references.offset_ci_sequence_number = new_references.offset_ci_sequence_number)) OR
        ((new_references.offset_dt_alias IS NULL) OR
         (new_references.offset_dai_sequence_number IS NULL) OR
         (new_references.offset_cal_type IS NULL) OR
         (new_references.offset_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
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

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_CA_DA_INST_OFCNT_PKG.GET_FK_IGS_CA_DA_INST_OFST (
      old_references.dt_alias,
      old_references.dai_sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number,
      old_references.offset_dt_alias,
      old_references.offset_dai_sequence_number,
      old_references.offset_cal_type,
      old_references.offset_ci_sequence_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_offset_dt_alias IN VARCHAR2,
    x_offset_dai_sequence_number IN NUMBER,
    x_offset_cal_type IN VARCHAR2,
    x_offset_ci_sequence_number IN NUMBER
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_INST_OFST
      WHERE    dt_alias = x_dt_alias
      AND      dai_sequence_number = x_dai_sequence_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      offset_dt_alias = x_offset_dt_alias
      AND      offset_dai_sequence_number = x_offset_dai_sequence_number
      AND      offset_cal_type = x_offset_cal_type
      AND      offset_ci_sequence_number = x_offset_ci_sequence_number
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

  PROCEDURE GET_FK_IGS_CA_DA_INST(
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_INST_OFST

      WHERE    (dt_alias = x_dt_alias
      AND      dai_sequence_number = x_sequence_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number)
	OR	   (offset_dt_alias = x_dt_alias
      AND      offset_dai_sequence_number = x_sequence_number
      AND      offset_cal_type = x_cal_type
      AND      offset_ci_sequence_number = x_ci_sequence_number);


    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_DAIO_DAI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA_INST;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_offset_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_day_offset IN NUMBER DEFAULT NULL,
    x_week_offset IN NUMBER DEFAULT NULL,
    x_month_offset IN NUMBER DEFAULT NULL,
    x_year_offset IN NUMBER DEFAULT NULL,
    x_ofst_override IN VARCHAR2 DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_offset_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_offset_cal_type IN VARCHAR2 DEFAULT NULL,
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
      x_offset_ci_sequence_number,
      x_day_offset,
      x_week_offset,
      x_month_offset,
      x_year_offset,
      x_ofst_override,
      x_dt_alias,
      x_dai_sequence_number,
      x_cal_type,
      x_ci_sequence_number,
      x_offset_dt_alias,
      x_offset_dai_sequence_number,
      x_offset_cal_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF Get_PK_For_Validation (
    			new_references.dt_alias ,
    			new_references.dai_sequence_number,
    			new_references.cal_type ,
   		      new_references.ci_sequence_number ,
    			new_references.offset_dt_alias ,
    			new_references.offset_dai_sequence_number ,
    			new_references.offset_cal_type ,
    			new_references.offset_ci_sequence_number )THEN
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
      Check_Child_Existance;
     ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
    			new_references.dt_alias ,
    			new_references.dai_sequence_number,
    			new_references.cal_type ,
   		      new_references.ci_sequence_number ,
    			new_references.offset_dt_alias ,
    			new_references.offset_dai_sequence_number ,
    			new_references.offset_cal_type ,
    			new_references.offset_ci_sequence_number )THEN
      	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      	IGS_GE_MSG_STACK.ADD;
      	App_Exception.Raise_Exception;
       END IF;
       CHECK_CONSTRAINTS;
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
    --  AfterRowInsert2 ( p_inserting => TRUE );
      AfterStmtInsertUpdateDelete3 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterStmtInsertUpdateDelete3 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterStmtInsertUpdateDelete3 ( p_deleting => TRUE );
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_OFFSET_DAI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_CAL_TYPE in VARCHAR2,
  X_OFFSET_CI_SEQUENCE_NUMBER in NUMBER,
  X_DAY_OFFSET in NUMBER,
  X_WEEK_OFFSET in NUMBER,
  X_MONTH_OFFSET in NUMBER,
  X_YEAR_OFFSET in NUMBER,
  X_OFST_OVERRIDE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_CA_DA_INST_OFST
      where DT_ALIAS = X_DT_ALIAS
      and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
      and CAL_TYPE = X_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
      and OFFSET_DT_ALIAS = X_OFFSET_DT_ALIAS
      and OFFSET_DAI_SEQUENCE_NUMBER = X_OFFSET_DAI_SEQUENCE_NUMBER
      and OFFSET_CAL_TYPE = X_OFFSET_CAL_TYPE
      and OFFSET_CI_SEQUENCE_NUMBER = X_OFFSET_CI_SEQUENCE_NUMBER;
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
    x_offset_ci_sequence_number =>X_OFFSET_CI_SEQUENCE_NUMBER,
    x_day_offset =>X_DAY_OFFSET,
    x_week_offset =>X_WEEK_OFFSET,
    x_month_offset =>X_MONTH_OFFSET,
    x_year_offset =>X_YEAR_OFFSET,
    x_ofst_override =>X_OFST_OVERRIDE,
    x_dt_alias =>X_DT_ALIAS,
    x_dai_sequence_number =>X_DAI_SEQUENCE_NUMBER,
    x_cal_type =>X_CAL_TYPE,
    x_ci_sequence_number =>X_CI_SEQUENCE_NUMBER,
    x_offset_dt_alias =>X_OFFSET_DT_ALIAS,
    x_offset_dai_sequence_number =>X_OFFSET_DAI_SEQUENCE_NUMBER,
    x_offset_cal_type =>X_OFFSET_CAL_TYPE,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_CA_DA_INST_OFST (
    DT_ALIAS,
    DAI_SEQUENCE_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    OFFSET_DT_ALIAS,
    OFFSET_DAI_SEQUENCE_NUMBER,
    OFFSET_CAL_TYPE,
    OFFSET_CI_SEQUENCE_NUMBER,
    DAY_OFFSET,
    WEEK_OFFSET,
    MONTH_OFFSET,
    YEAR_OFFSET,
    OFST_OVERRIDE,
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
    NEW_REFERENCES.DAY_OFFSET,
    NEW_REFERENCES.WEEK_OFFSET,
    NEW_REFERENCES.MONTH_OFFSET,
    NEW_REFERENCES.YEAR_OFFSET,
    NEW_REFERENCES.OFST_OVERRIDE,
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
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_OFFSET_DAI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_CAL_TYPE in VARCHAR2,
  X_OFFSET_CI_SEQUENCE_NUMBER in NUMBER,
  X_DAY_OFFSET in NUMBER,
  X_WEEK_OFFSET in NUMBER,
  X_MONTH_OFFSET in NUMBER,
  X_YEAR_OFFSET in NUMBER,
  X_OFST_OVERRIDE in VARCHAR2
) AS
  cursor c1 is select
      DAY_OFFSET,
      WEEK_OFFSET,
      MONTH_OFFSET,
      YEAR_OFFSET,
      OFST_OVERRIDE
    from IGS_CA_DA_INST_OFST
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

      if ( ((tlinfo.DAY_OFFSET = X_DAY_OFFSET)
           OR ((tlinfo.DAY_OFFSET is null)
               AND (X_DAY_OFFSET is null)))
      AND ((tlinfo.WEEK_OFFSET = X_WEEK_OFFSET)
           OR ((tlinfo.WEEK_OFFSET is null)
               AND (X_WEEK_OFFSET is null)))
      AND ((tlinfo.MONTH_OFFSET = X_MONTH_OFFSET)
           OR ((tlinfo.MONTH_OFFSET is null)
               AND (X_MONTH_OFFSET is null)))
      AND ((tlinfo.YEAR_OFFSET = X_YEAR_OFFSET)
           OR ((tlinfo.YEAR_OFFSET is null)
               AND (X_YEAR_OFFSET is null)))
      AND ((tlinfo.OFST_OVERRIDE = X_OFST_OVERRIDE)
           OR ((tlinfo.OFST_OVERRIDE is null)
               AND (X_OFST_OVERRIDE is null)))
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
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_OFFSET_DAI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_CAL_TYPE in VARCHAR2,
  X_OFFSET_CI_SEQUENCE_NUMBER in NUMBER,
  X_DAY_OFFSET in NUMBER,
  X_WEEK_OFFSET in NUMBER,
  X_MONTH_OFFSET in NUMBER,
  X_YEAR_OFFSET in NUMBER,
  X_OFST_OVERRIDE in VARCHAR2,
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
    x_offset_ci_sequence_number =>X_OFFSET_CI_SEQUENCE_NUMBER,
    x_day_offset =>X_DAY_OFFSET,
    x_week_offset =>X_WEEK_OFFSET,
    x_month_offset =>X_MONTH_OFFSET,
    x_year_offset =>X_YEAR_OFFSET,
    x_ofst_override =>X_OFST_OVERRIDE,
    x_dt_alias =>X_DT_ALIAS,
    x_dai_sequence_number =>X_DAI_SEQUENCE_NUMBER,
    x_cal_type =>X_CAL_TYPE,
    x_ci_sequence_number =>X_CI_SEQUENCE_NUMBER,
    x_offset_dt_alias =>X_OFFSET_DT_ALIAS,
    x_offset_dai_sequence_number =>X_OFFSET_DAI_SEQUENCE_NUMBER,
    x_offset_cal_type =>X_OFFSET_CAL_TYPE,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  update IGS_CA_DA_INST_OFST set
    DAY_OFFSET = NEW_REFERENCES.DAY_OFFSET,
    WEEK_OFFSET = NEW_REFERENCES.WEEK_OFFSET,
    MONTH_OFFSET = NEW_REFERENCES.MONTH_OFFSET,
    YEAR_OFFSET = NEW_REFERENCES.YEAR_OFFSET,
    OFST_OVERRIDE = NEW_REFERENCES.OFST_OVERRIDE,
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
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_OFFSET_DAI_SEQUENCE_NUMBER in NUMBER,
  X_OFFSET_CAL_TYPE in VARCHAR2,
  X_OFFSET_CI_SEQUENCE_NUMBER in NUMBER,
  X_DAY_OFFSET in NUMBER,
  X_WEEK_OFFSET in NUMBER,
  X_MONTH_OFFSET in NUMBER,
  X_YEAR_OFFSET in NUMBER,
  X_OFST_OVERRIDE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_CA_DA_INST_OFST
     where DT_ALIAS = X_DT_ALIAS
     and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
     and CAL_TYPE = X_CAL_TYPE
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
     and OFFSET_DT_ALIAS = X_OFFSET_DT_ALIAS
     and OFFSET_DAI_SEQUENCE_NUMBER = X_OFFSET_DAI_SEQUENCE_NUMBER
     and OFFSET_CAL_TYPE = X_OFFSET_CAL_TYPE
     and OFFSET_CI_SEQUENCE_NUMBER = X_OFFSET_CI_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_DT_ALIAS,
     X_DAI_SEQUENCE_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_OFFSET_DT_ALIAS,
     X_OFFSET_DAI_SEQUENCE_NUMBER,
     X_OFFSET_CAL_TYPE,
     X_OFFSET_CI_SEQUENCE_NUMBER,
     X_DAY_OFFSET,
     X_WEEK_OFFSET,
     X_MONTH_OFFSET,
     X_YEAR_OFFSET,
     X_OFST_OVERRIDE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_DT_ALIAS,
   X_DAI_SEQUENCE_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_OFFSET_DT_ALIAS,
   X_OFFSET_DAI_SEQUENCE_NUMBER,
   X_OFFSET_CAL_TYPE,
   X_OFFSET_CI_SEQUENCE_NUMBER,
   X_DAY_OFFSET,
   X_WEEK_OFFSET,
   X_MONTH_OFFSET,
   X_YEAR_OFFSET,
   X_OFST_OVERRIDE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  delete from IGS_CA_DA_INST_OFST
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
end DELETE_ROW;

end IGS_CA_DA_INST_OFST_PKG;

/
