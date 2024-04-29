--------------------------------------------------------
--  DDL for Package Body IGS_FI_F_RET_SCHD_HT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_F_RET_SCHD_HT_PKG" AS
/* $Header: IGSSI48B.pls 120.1 2006/05/26 13:43:08 skharida noship $*/
  l_rowid VARCHAR2(25);
  old_references IGS_FI_F_RET_SCHD_HT_ALL%RowType;
  new_references IGS_FI_F_RET_SCHD_HT_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_schedule_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_retention_percentage IN NUMBER DEFAULT NULL,
    x_retention_amount IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.Removed parameter x_deduction_amount and its reference in
  ||                               copying old_references value into new_references.value.
  ----------------------------------------------------------------------------*/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_F_RET_SCHD_HT_ALL
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
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.s_relation_type := x_s_relation_type;
    new_references.sequence_number := x_sequence_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.fee_type := x_fee_type;
    new_references.fee_cat := x_fee_cat;
    new_references.schedule_number := x_schedule_number;
    new_references.dt_alias := x_dt_alias;
    new_references.dai_sequence_number := x_dai_sequence_number;
    new_references.retention_percentage := x_retention_percentage;
    new_references.retention_amount := x_retention_amount;
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
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  ) AS
   /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || skharida         26-May-2006  Bug 5217319 Removed the hardcoded precision check
  ||  vvutukur        19_jul-2002  Bug#2425767.Removed x_deduction_amount references(from if conditions).
  ||  vvutukur        18-May-2002  removed upper check on fee_type,fee_cat columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'RETENTION_PERCENTAGE') THEN
      new_references.retention_percentage := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER (column_name) = 'RETENTION_AMOUNT') THEN
      new_references.retention_amount := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER (column_name) = 'DT_ALIAS') THEN
      new_references.dt_alias := column_value;
    ELSIF (UPPER (column_name) = 'FEE_CAL_TYPE') THEN
      new_references.fee_cal_type := column_value;
    ELSIF (UPPER (column_name) = 'S_RELATION_TYPE') THEN
      new_references.s_relation_type := column_value;
    ELSIF (UPPER (column_name) = 'SEQUENCE_NUMBER') THEN
      new_references.sequence_number := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER (column_name) = 'DAI_SEQUENCE_NUMBER') THEN
      new_references.dai_sequence_number := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER (column_name) = 'SCHEDULE_NUMBER') THEN
      new_references.schedule_number := IGS_GE_NUMBER.TO_NUM (column_value);
    ELSIF (UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') THEN
      new_references.fee_ci_sequence_number := IGS_GE_NUMBER.TO_NUM (column_value);
    END IF;
    IF ((UPPER (column_name) = 'RETENTION_PERCENTAGE') OR (column_name IS NULL)) THEN
      IF ((new_references.retention_percentage < 0) OR (new_references.retention_percentage > 100.00)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'RETENTION_AMOUNT') OR (column_name IS NULL)) THEN
      IF ((new_references.retention_amount < 0)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'DT_ALIAS') OR (column_name IS NULL)) THEN
      IF (new_references.dt_alias <> UPPER (new_references.dt_alias)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.fee_cal_type <> UPPER (new_references.fee_cal_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'S_RELATION_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.s_relation_type <> UPPER (new_references.s_relation_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.sequence_number < 1) OR (new_references.sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'DAI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.dai_sequence_number < 1) OR (new_references.dai_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'SCHEDULE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.schedule_number < 1) OR (new_references.schedule_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.fee_ci_sequence_number < 1) OR (new_references.fee_ci_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;
  PROCEDURE Check_Uniqueness AS
  BEGIN
    IF Get_UK1_For_Validation (
         new_references.fee_cal_type,
         new_references.fee_ci_sequence_number,
         new_references.fee_type,
         new_references.fee_cat,
         new_references.schedule_number,
	     new_references.hist_start_dt
         ) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
  END Check_Uniqueness;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_CAT_CA_INST_PKG.Get_PK_For_Validation (
               new_references.fee_cat,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
               new_references.fee_cat,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number,
               new_references.fee_type
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_TYP_CA_INST_PKG.Get_PK_For_Validation (
               new_references.fee_type,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;
  FUNCTION Get_PK_For_Validation (
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_RET_SCHD_HT_ALL
      WHERE    fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      s_relation_type = x_s_relation_type
      AND      sequence_number = x_sequence_number
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
  FUNCTION Get_UK1_For_Validation (
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_schedule_number IN NUMBER,
	x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_RET_SCHD_HT_ALL
      WHERE    fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      fee_cat = x_fee_cat
      AND      schedule_number = x_schedule_number
      AND      hist_start_dt = x_hist_start_dt
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
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
  END Get_UK1_For_Validation;
  PROCEDURE GET_FK_IGS_FI_F_CAT_CA_INST (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_RET_SCHD_HT_ALL
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FRTNSH_FCCI_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_F_CAT_CA_INST;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_schedule_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_retention_percentage IN NUMBER DEFAULT NULL,
    x_retention_amount IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter x_deduction_amount and its reference in
  ||                               from call to set_column_values.
  ----------------------------------------------------------------------------*/
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_s_relation_type,
      x_sequence_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_fee_type,
      x_fee_cat,
      x_schedule_number,
      x_dt_alias,
      x_dai_sequence_number,
      x_retention_percentage,
      x_retention_amount,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF (Get_PK_For_Validation (
            new_references.fee_cal_type,
            new_references.fee_ci_sequence_number,
			new_references.s_relation_type,
			new_references.sequence_number,
			new_references.hist_start_dt
            )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            new_references.fee_cal_type,
            new_references.fee_ci_sequence_number,
			new_references.s_relation_type,
			new_references.sequence_number,
			new_references.hist_start_dt
          )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    END IF;
  END Before_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter x_deduction_amount and its references
  ||                               (from call to before_dml and insert statement).
  ----------------------------------------------------------------------------*/
    cursor C is select ROWID from IGS_FI_F_RET_SCHD_HT_ALL
      where FEE_CAL_TYPE = X_FEE_CAL_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and S_RELATION_TYPE = X_S_RELATION_TYPE
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
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
 x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
 x_dt_alias=>X_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_fee_type=>X_FEE_TYPE,
 x_hist_end_dt=>X_HIST_END_DT,
 x_hist_start_dt=>X_HIST_START_DT,
 x_hist_who=>X_HIST_WHO,
 x_retention_amount=>X_RETENTION_AMOUNT,
 x_retention_percentage=>X_RETENTION_PERCENTAGE,
 x_s_relation_type=>X_S_RELATION_TYPE,
 x_schedule_number=>X_SCHEDULE_NUMBER,
 x_sequence_number=>X_SEQUENCE_NUMBER,
 x_org_id=>igs_ge_gen_003.get_org_id,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_FI_F_RET_SCHD_HT_ALL (
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    S_RELATION_TYPE,
    SEQUENCE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    FEE_TYPE,
    FEE_CAT,
    SCHEDULE_NUMBER,
    DT_ALIAS,
    DAI_SEQUENCE_NUMBER,
    RETENTION_PERCENTAGE,
    RETENTION_AMOUNT,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_RELATION_TYPE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.SCHEDULE_NUMBER,
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.RETENTION_PERCENTAGE,
    NEW_REFERENCES.RETENTION_AMOUNT,
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
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER
) is
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter x_payment_hierarchy_rank and its references
  ||                               (from cursor c1 and from if condition).
  ----------------------------------------------------------------------------*/
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      FEE_TYPE,
      FEE_CAT,
      SCHEDULE_NUMBER,
      DT_ALIAS,
      DAI_SEQUENCE_NUMBER,
      RETENTION_PERCENTAGE,
      RETENTION_AMOUNT
    from IGS_FI_F_RET_SCHD_HT_ALL
    where ROWID=X_ROWID
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
  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.FEE_TYPE = X_FEE_TYPE)
           OR ((tlinfo.FEE_TYPE is null)
               AND (X_FEE_TYPE is null)))
      AND ((tlinfo.FEE_CAT = X_FEE_CAT)
           OR ((tlinfo.FEE_CAT is null)
               AND (X_FEE_CAT is null)))
      AND ((tlinfo.SCHEDULE_NUMBER = X_SCHEDULE_NUMBER)
           OR ((tlinfo.SCHEDULE_NUMBER is null)
               AND (X_SCHEDULE_NUMBER is null)))
      AND ((tlinfo.DT_ALIAS = X_DT_ALIAS)
           OR ((tlinfo.DT_ALIAS is null)
               AND (X_DT_ALIAS is null)))
      AND ((tlinfo.DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER)
           OR ((tlinfo.DAI_SEQUENCE_NUMBER is null)
               AND (X_DAI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.RETENTION_PERCENTAGE = X_RETENTION_PERCENTAGE)
           OR ((tlinfo.RETENTION_PERCENTAGE is null)
               AND (X_RETENTION_PERCENTAGE is null)))
      AND ((tlinfo.RETENTION_AMOUNT = X_RETENTION_AMOUNT)
           OR ((tlinfo.RETENTION_AMOUNT is null)
               AND (X_RETENTION_AMOUNT is null)))
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
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter x_deduction_amount and its references
  ||                               (from call to before_dml and update statement).
  ----------------------------------------------------------------------------*/
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
 x_dai_sequence_number=>X_DAI_SEQUENCE_NUMBER,
 x_dt_alias=>X_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_fee_type=>X_FEE_TYPE,
 x_hist_end_dt=>X_HIST_END_DT,
 x_hist_start_dt=>X_HIST_START_DT,
 x_hist_who=>X_HIST_WHO,
 x_retention_amount=>X_RETENTION_AMOUNT,
 x_retention_percentage=>X_RETENTION_PERCENTAGE,
 x_s_relation_type=>X_S_RELATION_TYPE,
 x_schedule_number=>X_SCHEDULE_NUMBER,
 x_sequence_number=>X_SEQUENCE_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_FI_F_RET_SCHD_HT_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    FEE_TYPE = NEW_REFERENCES.FEE_TYPE,
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
    SCHEDULE_NUMBER = NEW_REFERENCES.SCHEDULE_NUMBER,
    DT_ALIAS = NEW_REFERENCES.DT_ALIAS,
    DAI_SEQUENCE_NUMBER = NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    RETENTION_PERCENTAGE = NEW_REFERENCES.RETENTION_PERCENTAGE,
    RETENTION_AMOUNT = NEW_REFERENCES.RETENTION_AMOUNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) is
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter x_deduction_amount and its references
  ||                               (from calls to insert_row and update_row).
  ----------------------------------------------------------------------------*/
  cursor c1 is select rowid from IGS_FI_F_RET_SCHD_HT_ALL
     where FEE_CAL_TYPE = X_FEE_CAL_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and S_RELATION_TYPE = X_S_RELATION_TYPE
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAL_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_S_RELATION_TYPE,
     X_SEQUENCE_NUMBER,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_FEE_TYPE,
     X_FEE_CAT,
     X_SCHEDULE_NUMBER,
     X_DT_ALIAS,
     X_DAI_SEQUENCE_NUMBER,
     X_RETENTION_PERCENTAGE,
     X_RETENTION_AMOUNT,
     X_ORG_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_S_RELATION_TYPE,
   X_SEQUENCE_NUMBER,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_FEE_TYPE,
   X_FEE_CAT,
   X_SCHEDULE_NUMBER,
   X_DT_ALIAS,
   X_DAI_SEQUENCE_NUMBER,
   X_RETENTION_PERCENTAGE,
   X_RETENTION_AMOUNT,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) is
begin
Before_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_FI_F_RET_SCHD_HT_ALL
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_F_RET_SCHD_HT_PKG;

/
