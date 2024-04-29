--------------------------------------------------------
--  DDL for Package Body IGS_CA_DA_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_DA_INST_PKG" AS
/* $Header: IGSCI04B.pls 120.0 2005/06/02 03:39:05 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_CA_DA_INST%RowType;
  new_references IGS_CA_DA_INST%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_absolute_val IN DATE,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        02-Sep-2002  Bug#2531390.Removed default values for parameters to avoid gscc
  ||                               warnings.
  ----------------------------------------------------------------------------*/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_DA_INST
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
    new_references.sequence_number := x_sequence_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.absolute_val := x_absolute_val;
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
  -- "OSS_TST".trg_dai_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_CA_DA_INST
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        02-Sep-2002  Bug#2531390.Removed default values of parameters to avoid gscc
  ||                               warnings.
  ----------------------------------------------------------------------------*/

	v_message_name	varchar2(30);
  BEGIN

	IF p_inserting OR p_updating THEN
	-- Absolute value must be entered if category is 'HOLIDAY'
		IF new_references.absolute_val IS NULL THEN
			IF IGS_CA_VAL_DAI.calp_val_holiday_cat (new_references.cal_type,
				v_message_name) = TRUE
			THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_dai_as_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_CA_DA_INST

  PROCEDURE AfterStmtInsertUpdateDelete3(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        02-Sep-2002  Bug#2531390.Removed default values of the parameters to avoid gscc
  ||                               warnings.
  ----------------------------------------------------------------------------*/

	v_message_name	varchar2(30);
  BEGIN
  	-- Validation routine calls.
  	IF p_inserting OR p_updating
  	THEN
  		-- Validate date alias instance
  		IF IGS_CA_VAL_DAI.calp_val_dai_upd(NVL (new_references.dt_alias, old_references.dt_alias),
  			NVL (new_references.sequence_number, old_references.sequence_number),
  			NVL (new_references.cal_type, old_references.cal_type),
  			NVL (new_references.ci_sequence_number, old_references.ci_sequence_number),
  			v_message_name) = FALSE
  		THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
  		IF p_inserting
  		THEN
  			-- Validate date alias instance date alias
  			IF IGS_CA_VAL_DAI.calp_val_dai_da(NVL (new_references.dt_alias, old_references.dt_alias),
  				NVL (new_references.cal_type, old_references.cal_type),
  				v_message_name) = FALSE
  			THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
  			END IF;
  		END IF;
  	END IF;
  END AfterStmtInsertUpdateDelete3;

  PROCEDURE Check_Constraints (
	Column_Name 	IN	VARCHAR2,
	Column_Value 	IN	VARCHAR2
	)
	IS
	BEGIN
	IF  column_name is null then
                        NULL;
                  Elsif UPPER(column_name) = 'CAL_TYPE ' Then
				new_references.cal_type := column_value;

                  Elsif UPPER(column_name) = 'DT_ALIAS' Then
				new_references.dt_alias := column_value;
      end if;
                 if upper(column_name) = 'CAL_TYPE' or column_name is null Then
				if new_references.cal_type <> UPPER( new_references.cal_type) then
                  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  		IGS_GE_MSG_STACK.ADD;
                  		App_Exception.Raise_Exception;
				end if;
			end if;
                  if upper(column_name) = 'DT_ALIAS' or column_name is null Then
				if new_references.dt_alias <> UPPER( new_references.dt_alias) then
                  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  		IGS_GE_MSG_STACK.ADD;
                  		App_Exception.Raise_Exception;
				end if;
			end if;

     END Check_Constraints ;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.cal_type,
        new_references.ci_sequence_number
        ) THEN
     	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.dt_alias = new_references.dt_alias)) OR
        ((new_references.dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.dt_alias
         ) THEN
     	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END IF;
     END IF;

  END Check_Parent_Existance;

  PROCEDURE check_Child_Existance
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  rmaddipa        07-Sep-2004  Enh#3316063 Added call to IGS_FI_TP_RET_SCHD_PKG.GET_FK_IGS_CA_DA_INST
  ||  vvutukur        26-Aug-2002  Bug#2531390.Removed call to IGS_FI_FEE_PAY_SCHD_PKG.GET_FK_IGS_CA_DA_INST
  ||                               to remove the foreign key relationship between tables igs_ca_da_inst
  ||                               and igs_fi_fee_pay_schd.
  ----------------------------------------------------------------------------*/
  AS
  BEGIN
    IGS_AD_PECRS_OFOP_DT_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_GR_CRMN_ROUND_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_CA_DA_INST_OFST_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );


    IGS_CA_DA_INST_PAIR_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );


    IGS_AS_EXAM_SESSION_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_FI_F_CAT_CA_INST_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_FI_F_CAT_FEE_LBL_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

/* Removed call to    IGS_FI_FEE_ENCMB_PKG.GET_FK_IGS_CA_DA_INST since the TBH is obseleted as part of
bug 2126091-sykrishn */

--Removed call to IGS_FI_FEE_PAY_SCHD_PKG.GET_FK_IGS_CA_DA_INST as part of SFCR005 CleanUp.Bug#2531390.

    IGS_FI_FEE_RET_SCHD_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_FI_F_TYP_CA_INST_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );

    IGS_GR_CRMN_PKG.GET_FK_IGS_CA_DA_INST (
      old_references.dt_alias,
      old_references.sequence_number,
      old_references.cal_type,
      old_references.ci_sequence_number
      );
    IGS_FI_TP_RET_SCHD_PKG.GET_FK_IGS_CA_DA_INST(
      x_dt_alias => old_references.dt_alias,
      x_dai_sequence_number => old_references.sequence_number,
      x_teach_cal_type => old_references.cal_type,
      x_teach_ci_sequence_number => old_references.ci_sequence_number
      );
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_INST
      WHERE    dt_alias = x_dt_alias
      AND      sequence_number = x_sequence_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
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

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_INST
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_DAI_CI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_INST
      WHERE    dt_alias = x_dt_alias ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_DAI_DA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_absolute_val IN DATE,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        02-Sep-2002  Bug#2531390.The calls to BeforeRowInsertUpdateDelete1 procedure are
  ||                               modified as defaulting the parametes in that procedure using DEFAULT
  ||                               clause is removed.Hence passed FALSE to the parameters which were not
  ||                               passed earlier.
  ----------------------------------------------------------------------------*/
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_dt_alias,
      x_sequence_number,
      x_cal_type,
      x_ci_sequence_number,
      x_absolute_val,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
                                     p_updating  => FALSE,
				     p_deleting  => FALSE);
     IF   Get_PK_For_Validation (
            new_references.dt_alias ,
    		new_references.sequence_number ,
    		new_references.cal_type ,
    		new_references.ci_sequence_number  ) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
            IGS_GE_MSG_STACK.ADD;
      	App_Exception.Raise_Exception;
       END IF;
      CHECK_CONSTRAINTS;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
            new_references.dt_alias ,
    		new_references.sequence_number ,
    		new_references.cal_type ,
    		new_references.ci_sequence_number  ) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
            IGS_GE_MSG_STACK.ADD;
      	App_Exception.Raise_Exception;
       END IF;
        CHECK_CONSTRAINTS;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating => TRUE,
				     p_deleting => FALSE);
      CHECK_CONSTRAINTS;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
     Check_Constraints;
     ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating => FALSE,
                                     p_deleting => TRUE );
      Check_Child_Existance;

    ELSIF (p_action = 'VALIDATE_DELETE') THEN
       Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        02-Sep-2002  Bug#2531390.The calls to AfterStmtInsertUpdateDelete3 procedure, are
  ||                               modified because defaulting the parametes in that procedure using DEFAULT
  ||                               clause is removed.Hence passed FALSE to the parameters which were not
  ||                               passed earlier.
  ----------------------------------------------------------------------------*/
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterStmtInsertUpdateDelete3 ( p_inserting => TRUE,
                                     p_updating  => FALSE,
				     p_deleting  => FALSE);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterStmtInsertUpdateDelete3 ( p_inserting => FALSE,
                                     p_updating => TRUE,
				     p_deleting  => FALSE);
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterStmtInsertUpdateDelete3 ( p_inserting => FALSE,
                                     p_updating  => FALSE,
                                     p_deleting => TRUE );
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ABSOLUTE_VAL in DATE,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_CA_DA_INST
      where DT_ALIAS = X_DT_ALIAS
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
      and CAL_TYPE = X_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER;
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
    x_sequence_number =>X_SEQUENCE_NUMBER,
    x_cal_type =>X_CAL_TYPE,
    x_ci_sequence_number =>X_CI_SEQUENCE_NUMBER,
    x_absolute_val =>X_ABSOLUTE_VAL,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_CA_DA_INST (
    DT_ALIAS,
    SEQUENCE_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    ABSOLUTE_VAL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ABSOLUTE_VAL,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ABSOLUTE_VAL in DATE
) AS
  cursor c1 is select
      ABSOLUTE_VAL
    from IGS_CA_DA_INST
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

      if ( ((tlinfo.ABSOLUTE_VAL = X_ABSOLUTE_VAL)
           OR ((tlinfo.ABSOLUTE_VAL is null)
               AND (X_ABSOLUTE_VAL is null)))
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ABSOLUTE_VAL in DATE,
  X_MODE in VARCHAR2
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
    x_sequence_number =>X_SEQUENCE_NUMBER,
    x_cal_type =>X_CAL_TYPE,
    x_ci_sequence_number =>X_CI_SEQUENCE_NUMBER,
    x_absolute_val =>X_ABSOLUTE_VAL,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  update IGS_CA_DA_INST set
    ABSOLUTE_VAL = NEW_REFERENCES.ABSOLUTE_VAL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ABSOLUTE_VAL in DATE,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_CA_DA_INST
     where DT_ALIAS = X_DT_ALIAS
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and CAL_TYPE = X_CAL_TYPE
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_DT_ALIAS,
     X_SEQUENCE_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_ABSOLUTE_VAL,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_DT_ALIAS,
   X_SEQUENCE_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_ABSOLUTE_VAL,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (X_ROWID in VARCHAR2
) AS
begin
After_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  delete from IGS_CA_DA_INST
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
end DELETE_ROW;

end IGS_CA_DA_INST_PKG;

/
