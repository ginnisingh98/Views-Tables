--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_CAT_CI_HT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_CAT_CI_HT_PKG" AS
 /* $Header: IGSSI24B.pls 115.7 2002/11/29 03:44:10 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_CAT_CI_HT_ALL%RowType;
  new_references IGS_FI_FEE_CAT_CI_HT_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_fee_cat_ci_status IN VARCHAR2 DEFAULT NULL,
    x_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_start_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_retro_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_retro_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_CAT_CI_HT_ALL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.fee_cat := x_fee_cat;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.fee_cat_ci_status := x_fee_cat_ci_status;
    new_references.start_dt_alias := x_start_dt_alias;
    new_references.start_dai_sequence_number := x_start_dai_sequence_number;
    new_references.end_dt_alias := x_end_dt_alias;
    new_references.end_dai_sequence_number := x_end_dai_sequence_number;
    new_references.retro_dt_alias := x_retro_dt_alias;
    new_references.retro_dai_sequence_number := x_retro_dai_sequence_number;
    new_references.org_id := x_org_id ;
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

   PROCEDURE Check_Constraints (
     Column_Name	IN	VARCHAR2	DEFAULT NULL,
     Column_Value 	IN	VARCHAR2	DEFAULT NULL
     )AS
   /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        20-May-2002     removed upper check constraint on fee_cat,
  ||                                  fee_cat_ci_status(alias of fee_structure_status) columns.bug#2344826.
  ----------------------------------------------------------------------------*/
   BEGIN
   IF Column_Name is NULL THEN
     	NULL;
     ELSIF upper(Column_Name) = 'START_DAI_SEQUENCE_NUMBER' then
     	new_references.start_dai_sequence_number := igs_ge_number.to_num(Column_Value);
     ELSIF upper(Column_Name) = 'RETRO_DAI_SEQUENCE_NUMBER' then
     	new_references.retro_dai_sequence_number := igs_ge_number.to_num(Column_Value);
     ELSIF upper(Column_Name) = 'END_DAI_SEQUENCE_NUMBER' then
     	new_references.end_dai_sequence_number := igs_ge_number.to_num(Column_Value);
     ELSIF upper(Column_Name) = 'FEE_CI_SEQUENCE_NUMBER' then
       	new_references.fee_ci_sequence_number := igs_ge_number.to_num(Column_Value);
     ELSIF upper(Column_Name) = 'END_DT_ALIAS' then
     	new_references.end_dt_alias := Column_Value;
     ELSIF upper(Column_Name) = 'FEE_CAL_TYPE' then
     	new_references.fee_cal_type := Column_Value;
     ELSIF upper(Column_Name) = 'RETRO_DT_ALIAS' then
     	new_references.retro_dt_alias := Column_Value;
     ELSIF upper(Column_Name) = 'START_DT_ALIAS' then
		new_references.start_dt_alias := Column_Value;
  	 END IF;
   	IF upper(Column_Name) = 'START_DAI_SEQUENCE_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.start_dai_sequence_number < 1 OR new_references.start_dai_sequence_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                        IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
	END IF;
   	IF upper(Column_Name) = 'RETRO_DAI_SEQUENCE_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.retro_dai_sequence_number < 1 OR new_references.retro_dai_sequence_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                        IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
	END IF;
   	IF upper(Column_Name) = 'END_DAI_SEQUENCE_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.end_dai_sequence_number < 1 OR new_references.end_dai_sequence_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                        IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
	END IF;
   	IF upper(Column_Name) = 'FEE_CI_SEQUENCE_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.fee_ci_sequence_number < 1 OR new_references.fee_ci_sequence_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                        IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
	END IF;

	IF upper(Column_Name) = 'END_DT_ALIAS' OR
	  		column_name is NULL THEN
			IF new_references.end_dt_alias <> UPPER(new_references.end_dt_alias) THEN
				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
	END IF;

	IF upper(Column_Name) = 'FEE_CAL_TYPE' OR
	  		column_name is NULL THEN
			IF new_references.fee_cal_type <> UPPER(new_references.fee_cal_type) THEN
				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
	END IF;

	IF upper(Column_Name) = 'RETRO_DT_ALIAS' OR
		  		column_name is NULL THEN
				IF new_references.retro_dt_alias <> UPPER(new_references.retro_dt_alias) THEN
					Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
				END IF;
	END IF;
	IF upper(Column_Name) = 'START_DT_ALIAS' OR
				column_name is NULL THEN
				IF new_references.start_dt_alias <> UPPER(new_references.start_dt_alias) THEN
					Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                        IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
				END IF;
	END IF;
  END Check_Constraints;


  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_CAT_CI_HT_ALL
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      hist_start_dt = x_hist_start_dt
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
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_fee_cat_ci_status IN VARCHAR2 DEFAULT NULL,
    x_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_start_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_retro_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_retro_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
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
      x_fee_cat,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_fee_cat_ci_status,
      x_start_dt_alias,
      x_start_dai_sequence_number,
      x_end_dt_alias,
      x_end_dai_sequence_number,
      x_retro_dt_alias,
      x_retro_dai_sequence_number,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	    IF Get_PK_For_Validation (
	      new_references.fee_cat,
	      new_references.fee_cal_type,
	      new_references.fee_ci_sequence_number,
	      new_references.hist_start_dt
    	) THEN
		        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                        IGS_GE_MSG_STACK.ADD;
		        App_Exception.Raise_Exception;
		END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	    IF Get_PK_For_Validation (
	      	new_references.fee_cat,
	      	new_references.fee_cal_type,
	      	new_references.fee_ci_sequence_number,
	      	new_references.hist_start_dt
		  ) THEN
	  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                        IGS_GE_MSG_STACK.ADD;
	  		App_Exception.Raise_Exception;
		END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
		Check_Constraints;
    END IF;
  END Before_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_FEE_CAT_CI_HT_ALL
      where FEE_CAT = X_FEE_CAT
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and HIST_START_DT = X_HIST_START_DT;
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
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_end_dai_sequence_number=>X_END_DAI_SEQUENCE_NUMBER,
 x_end_dt_alias=>X_END_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_cat_ci_status=>X_FEE_CAT_CI_STATUS,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_hist_end_dt=>X_HIST_END_DT,
 x_hist_start_dt=>X_HIST_START_DT,
 x_hist_who=>X_HIST_WHO,
 x_retro_dai_sequence_number=>X_RETRO_DAI_SEQUENCE_NUMBER,
 x_retro_dt_alias=>X_RETRO_DT_ALIAS,
 x_start_dai_sequence_number=>X_START_DAI_SEQUENCE_NUMBER,
 x_start_dt_alias=>X_START_DT_ALIAS,
 x_org_id => igs_ge_gen_003.get_org_id,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  insert into IGS_FI_FEE_CAT_CI_HT_ALL (
    FEE_CAT,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    FEE_CAT_CI_STATUS,
    START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER,
    END_DT_ALIAS,
    END_DAI_SEQUENCE_NUMBER,
    RETRO_DT_ALIAS,
    RETRO_DAI_SEQUENCE_NUMBER,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.FEE_CAT_CI_STATUS,
    NEW_REFERENCES.START_DT_ALIAS,
    NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.END_DT_ALIAS,
    NEW_REFERENCES.END_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.RETRO_DT_ALIAS,
    NEW_REFERENCES.RETRO_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ORG_ID,
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
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      FEE_CAT_CI_STATUS,
      START_DT_ALIAS,
      START_DAI_SEQUENCE_NUMBER,
      END_DT_ALIAS,
      END_DAI_SEQUENCE_NUMBER,
      RETRO_DT_ALIAS,
      RETRO_DAI_SEQUENCE_NUMBER
    from IGS_FI_FEE_CAT_CI_HT_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.FEE_CAT_CI_STATUS = X_FEE_CAT_CI_STATUS)
           OR ((tlinfo.FEE_CAT_CI_STATUS is null)
               AND (X_FEE_CAT_CI_STATUS is null)))
      AND ((tlinfo.START_DT_ALIAS = X_START_DT_ALIAS)
           OR ((tlinfo.START_DT_ALIAS is null)
               AND (X_START_DT_ALIAS is null)))
      AND ((tlinfo.START_DAI_SEQUENCE_NUMBER = X_START_DAI_SEQUENCE_NUMBER)
           OR ((tlinfo.START_DAI_SEQUENCE_NUMBER is null)
               AND (X_START_DAI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.END_DT_ALIAS = X_END_DT_ALIAS)
           OR ((tlinfo.END_DT_ALIAS is null)
               AND (X_END_DT_ALIAS is null)))
      AND ((tlinfo.END_DAI_SEQUENCE_NUMBER = X_END_DAI_SEQUENCE_NUMBER)
           OR ((tlinfo.END_DAI_SEQUENCE_NUMBER is null)
               AND (X_END_DAI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.RETRO_DT_ALIAS = X_RETRO_DT_ALIAS)
           OR ((tlinfo.RETRO_DT_ALIAS is null)
               AND (X_RETRO_DT_ALIAS is null)))
      AND ((tlinfo.RETRO_DAI_SEQUENCE_NUMBER = X_RETRO_DAI_SEQUENCE_NUMBER)
           OR ((tlinfo.RETRO_DAI_SEQUENCE_NUMBER is null)
               AND (X_RETRO_DAI_SEQUENCE_NUMBER is null)))
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
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
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
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_end_dai_sequence_number=>X_END_DAI_SEQUENCE_NUMBER,
 x_end_dt_alias=>X_END_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_cat_ci_status=>X_FEE_CAT_CI_STATUS,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_hist_end_dt=>X_HIST_END_DT,
 x_hist_start_dt=>X_HIST_START_DT,
 x_hist_who=>X_HIST_WHO,
 x_retro_dai_sequence_number=>X_RETRO_DAI_SEQUENCE_NUMBER,
 x_retro_dt_alias=>X_RETRO_DT_ALIAS,
 x_start_dai_sequence_number=>X_START_DAI_SEQUENCE_NUMBER,
 x_start_dt_alias=>X_START_DT_ALIAS,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  update IGS_FI_FEE_CAT_CI_HT_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    FEE_CAT_CI_STATUS = NEW_REFERENCES.FEE_CAT_CI_STATUS,
    START_DT_ALIAS = NEW_REFERENCES.START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    END_DT_ALIAS = NEW_REFERENCES.END_DT_ALIAS,
    END_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.END_DAI_SEQUENCE_NUMBER,
    RETRO_DT_ALIAS = NEW_REFERENCES.RETRO_DT_ALIAS,
    RETRO_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.RETRO_DAI_SEQUENCE_NUMBER,
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
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_FEE_CAT_CI_HT_ALL
     where FEE_CAT = X_FEE_CAT
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAT,
     X_FEE_CAL_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_FEE_CAT_CI_STATUS,
     X_START_DT_ALIAS,
     X_START_DAI_SEQUENCE_NUMBER,
     X_END_DT_ALIAS,
     X_END_DAI_SEQUENCE_NUMBER,
     X_RETRO_DT_ALIAS,
     X_RETRO_DAI_SEQUENCE_NUMBER,
     X_ORG_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_CAT,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_FEE_CAT_CI_STATUS,
   X_START_DT_ALIAS,
   X_START_DAI_SEQUENCE_NUMBER,
   X_END_DT_ALIAS,
   X_END_DAI_SEQUENCE_NUMBER,
   X_RETRO_DT_ALIAS,
   X_RETRO_DAI_SEQUENCE_NUMBER,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
 Before_DML (
  p_action => 'DELETE',
  x_rowid => X_ROWID
     );
  delete from IGS_FI_FEE_CAT_CI_HT_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_FEE_CAT_CI_HT_PKG;

/
