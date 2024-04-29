--------------------------------------------------------
--  DDL for Package Body IGS_FI_ELM_RANGE_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_ELM_RANGE_H_PKG" AS
/* $Header: IGSSI15B.pls 115.9 2003/02/12 10:03:13 shtatiko ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_FI_ELM_RANGE_H_ALL%RowType;
  new_references IGS_FI_ELM_RANGE_H_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_lower_range IN NUMBER DEFAULT NULL,
    x_upper_range IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_ELM_RANGE_H_ALL
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
    new_references.fee_type := x_fee_type;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.s_relation_type := x_s_relation_type;
    new_references.range_number := x_range_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.fee_cat := x_fee_cat;
    new_references.lower_range := x_lower_range;
    new_references.upper_range := x_upper_range;
    new_references.s_chg_method_type := x_s_chg_method_type;
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

   PROCEDURE Check_Uniqueness AS
   Begin
   IF  Get_UK_For_Validation (
    new_references.fee_type ,
    new_references.fee_cal_type ,
    new_references.fee_ci_sequence_number ,
    new_references.range_number ,
    new_references.hist_start_dt ,
    new_references.fee_cat
    ) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END IF;
   End Check_Uniqueness;

  PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 ) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        17-May-2002     removed upper check constraint on fee_type,fee_cat columns.bug#2344826.
  ----------------------------------------------------------------------------*/
 BEGIN
  IF  column_name is null then
     NULL;
  ELSIF upper(Column_name) = 'FEE_CAL_TYPE' then
     new_references.fee_cal_type := column_value;
  ELSIF upper(Column_name) = 'S_CHG_METHOD_TYPE' then
     new_references.s_chg_method_type := column_value;
  ELSIF upper(Column_name) = 'S_RELATION_TYPE' then
     new_references.s_relation_type := column_value;
  ELSIF upper(Column_name) = 'RANGE_NUMBER' then
     new_references.range_number := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'UPPER_RANGE' then
     new_references.upper_range := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'LOWER_RANGE' then
     new_references.lower_range := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'FEE_CI_SEQUENCE_NUMBER' then
     new_references.fee_ci_sequence_number := igs_ge_number.to_num(column_value);
  End if;

  IF upper(column_name) = 'FEE_CAL_TYPE' OR
       column_name is null Then
       IF new_references.FEE_CAL_TYPE <>
  	UPPER(new_references.FEE_CAL_TYPE) Then
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
  END IF;
IF upper(column_name) = 'S_CHG_METHOD_TYPE' OR
     column_name is null Then
     IF new_references.S_CHG_METHOD_TYPE <>
	UPPER(new_references.S_CHG_METHOD_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'S_RELATION_TYPE' OR
     column_name is null Then
     IF new_references.S_RELATION_TYPE <>
	UPPER(new_references.S_RELATION_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'RANGE_NUMBER' OR
     column_name is null Then
     IF new_references.range_number  < 1 OR
          new_references.range_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'UPPER_RANGE' OR
     column_name is null Then
     IF new_references.upper_range  < 0 OR
          new_references.upper_range > 9999.999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'LOWER_RANGE' OR
     column_name is null Then
     IF new_references.lower_range  < 0 OR
          new_references.lower_range > 9999.999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'FEE_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.fee_ci_sequence_number  < 1 OR
          new_references.fee_ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END Check_Constraints;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
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
      IF  NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
        new_references.fee_cat,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number,
        new_references.fee_type
        )	THEN
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
      IF  NOT IGS_FI_F_TYP_CA_INST_PKG.Get_PK_For_Validation (
        new_references.fee_type,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number
        )	THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
             IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	END IF;
    END IF;
  END Check_Parent_Existance;
  Function Get_PK_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_range_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) Return Boolean
	AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE_H_ALL
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      s_relation_type = x_s_relation_type
      AND      range_number = x_range_number
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

    Function Get_UK_For_Validation (
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL
      ) Return Boolean
  	AS
      CURSOR cur_rowid IS
        SELECT   rowid
        FROM     IGS_FI_ELM_RANGE_H_ALL
         WHERE    fee_type = new_references.fee_type
         AND      fee_cal_type = new_references.fee_cal_type
         AND      fee_ci_sequence_number = new_references.fee_ci_sequence_number
         AND      range_number = new_references.range_number
         AND      fee_cat = new_references.fee_cat
         AND      hist_start_dt = new_references.hist_start_dt
         AND      ((l_rowid IS NULL) OR (rowid <> l_rowid)) ;
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
    END Get_UK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_lower_range IN NUMBER DEFAULT NULL,
    x_upper_range IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
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
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_s_relation_type,
      x_range_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_fee_cat,
      x_lower_range,
      x_upper_range,
      x_s_chg_method_type,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	  	IF  Get_PK_For_Validation (
    		new_references.fee_type ,
		    new_references.fee_cal_type ,
		    new_references.fee_ci_sequence_number ,
		    new_references.s_relation_type ,
		    new_references.range_number ,
		    new_references.hist_start_dt
	        ) THEN
	  	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                          IGS_GE_MSG_STACK.ADD;
	  	          App_Exception.Raise_Exception;
	  	END IF;
	  	Check_Constraints;
	    Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
	  	Check_Constraints;
	    Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	      IF  Get_PK_For_Validation (
    		new_references.fee_type ,
		    new_references.fee_cal_type ,
		    new_references.fee_ci_sequence_number ,
		    new_references.s_relation_type ,
		    new_references.range_number ,
		    new_references.hist_start_dt
			) THEN
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                  IGS_GE_MSG_STACK.ADD;
	          App_Exception.Raise_Exception;
	      END IF;
	      Check_Constraints;
	      Check_Uniqueness;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	       Check_Constraints;
	       Check_Uniqueness;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN
	      Null;
    END IF;
  END Before_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_RANGE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_ELM_RANGE_H_ALL
      where FEE_TYPE = X_FEE_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and RANGE_NUMBER = X_RANGE_NUMBER
      and HIST_START_DT = X_HIST_START_DT
      and S_RELATION_TYPE = X_S_RELATION_TYPE
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE;
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
    x_rowid => x_rowid,
    x_fee_type => x_fee_type,
    x_fee_cal_type => x_fee_cal_type,
    x_fee_ci_sequence_number => x_fee_ci_sequence_number,
    x_s_relation_type => x_s_relation_type,
    x_range_number => x_range_number,
    x_hist_start_dt => x_hist_start_dt,
    x_hist_end_dt => x_hist_end_dt ,
    x_hist_who => x_hist_who,
    x_fee_cat => x_fee_cat,
    x_lower_range => x_lower_range,
    x_upper_range => x_upper_range,
    x_s_chg_method_type => x_s_chg_method_type,
    x_org_id => igs_ge_gen_003.get_org_id,
x_creation_date => X_LAST_UPDATE_DATE,
x_created_by => X_LAST_UPDATED_BY,
x_last_update_date => X_LAST_UPDATE_DATE,
x_last_updated_by => X_LAST_UPDATED_BY,
x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_FI_ELM_RANGE_H_ALL (
    FEE_TYPE,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    S_RELATION_TYPE,
    RANGE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    FEE_CAT,
    LOWER_RANGE,
    UPPER_RANGE,
    S_CHG_METHOD_TYPE,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_RELATION_TYPE,
    NEW_REFERENCES.RANGE_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.LOWER_RANGE,
    NEW_REFERENCES.UPPER_RANGE,
    NEW_REFERENCES.S_CHG_METHOD_TYPE,
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
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_RANGE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      FEE_CAT,
      LOWER_RANGE,
      UPPER_RANGE,
      S_CHG_METHOD_TYPE
    from IGS_FI_ELM_RANGE_H_ALL
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
  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.FEE_CAT = X_FEE_CAT)
           OR ((tlinfo.FEE_CAT is null)
               AND (X_FEE_CAT is null)))
      AND ((tlinfo.LOWER_RANGE = X_LOWER_RANGE)
           OR ((tlinfo.LOWER_RANGE is null)
               AND (X_LOWER_RANGE is null)))
      AND ((tlinfo.UPPER_RANGE = X_UPPER_RANGE)
           OR ((tlinfo.UPPER_RANGE is null)
               AND (X_UPPER_RANGE is null)))
      AND ((tlinfo.S_CHG_METHOD_TYPE = X_S_CHG_METHOD_TYPE)
           OR ((tlinfo.S_CHG_METHOD_TYPE is null)
               AND (X_S_CHG_METHOD_TYPE is null)))
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
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_RANGE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
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
	    x_rowid => x_rowid,
	    x_fee_type => x_fee_type,
	    x_fee_cal_type => x_fee_cal_type,
	    x_fee_ci_sequence_number => x_fee_ci_sequence_number,
	    x_s_relation_type => x_s_relation_type,
	    x_range_number => x_range_number,
	    x_hist_start_dt => x_hist_start_dt,
	    x_hist_end_dt => x_hist_end_dt ,
	    x_hist_who => x_hist_who,
	    x_fee_cat => x_fee_cat,
	    x_lower_range => x_lower_range,
	    x_upper_range => x_upper_range,
	    x_s_chg_method_type => x_s_chg_method_type,
x_creation_date => X_LAST_UPDATE_DATE,
x_created_by => X_LAST_UPDATED_BY,
x_last_update_date => X_LAST_UPDATE_DATE,
x_last_updated_by => X_LAST_UPDATED_BY,
x_last_update_login => X_LAST_UPDATE_LOGIN
	  );
  update IGS_FI_ELM_RANGE_H_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
    LOWER_RANGE = NEW_REFERENCES.LOWER_RANGE,
    UPPER_RANGE = NEW_REFERENCES.UPPER_RANGE,
    S_CHG_METHOD_TYPE = NEW_REFERENCES.S_CHG_METHOD_TYPE,
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
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_RANGE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_ELM_RANGE_H_ALL
     where FEE_TYPE = X_FEE_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and RANGE_NUMBER = X_RANGE_NUMBER
     and HIST_START_DT = X_HIST_START_DT
     and S_RELATION_TYPE = X_S_RELATION_TYPE
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_RANGE_NUMBER,
     X_HIST_START_DT,
     X_S_RELATION_TYPE,
     X_FEE_CAL_TYPE,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_FEE_CAT,
     X_LOWER_RANGE,
     X_UPPER_RANGE,
     X_S_CHG_METHOD_TYPE,
     X_ORG_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
  X_ROWID,
   X_FEE_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_RANGE_NUMBER,
   X_HIST_START_DT,
   X_S_RELATION_TYPE,
   X_FEE_CAL_TYPE,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_FEE_CAT,
   X_LOWER_RANGE,
   X_UPPER_RANGE,
   X_S_CHG_METHOD_TYPE,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML(
 p_action => 'DELETE',
 x_rowid  => X_ROWID
);
  delete from IGS_FI_ELM_RANGE_H_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_ELM_RANGE_H_PKG;

/
