--------------------------------------------------------
--  DDL for Package Body IGS_AD_PRD_AD_PRC_CA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PRD_AD_PRC_CA_PKG" AS
/* $Header: IGSAI30B.pls 115.8 2003/10/30 13:12:17 akadam ship $*/
  l_rowid VARCHAR2(25);
  old_references IGS_AD_PRD_AD_PRC_CA%RowType;
  new_references IGS_AD_PRD_AD_PRC_CA%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_adm_cal_type IN VARCHAR2 ,
    x_adm_ci_sequence_number IN NUMBER ,
    x_admission_cat IN VARCHAR2 ,
    x_s_admission_process_type IN VARCHAR2 ,
    x_creation_date IN DATE,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_closed_ind IN VARCHAR2 ,
    x_single_response_flag IN VARCHAR2 ,
    x_include_sr_in_rollover_flag IN VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PRD_AD_PRC_CA
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.adm_cal_type := x_adm_cal_type;
    new_references.adm_ci_sequence_number := x_adm_ci_sequence_number;
    new_references.admission_cat := x_admission_cat;
    new_references.s_admission_process_type := x_s_admission_process_type;
    new_references.closed_ind := x_closed_ind;
    new_references.single_response_flag := x_single_response_flag;
    new_references.include_sr_in_rollover_flag := x_include_sr_in_rollover_flag;

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
	 Column_Name	IN	VARCHAR2	,
	 Column_Value 	IN	VARCHAR2
)
 AS
 BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'ADM_CAL_TYPE' then
     new_references.adm_cal_type := column_value;
 ELSIF upper(Column_name) = 'ADMISSION_CAT' then
     new_references.admission_cat := column_value;
 ELSIF upper(Column_name) = 'S_ADMISSION_PROCESS_TYPE' then
     new_references.s_admission_process_type := column_value;
 ELSIF upper(Column_name) = 'ADM_CI_SEQUENCE_NUMBER' then
     new_references.adm_ci_sequence_number := igs_ge_number.to_num(column_value);
END IF;

IF upper(column_name) = 'ADM_CAL_TYPE' OR
     column_name is null Then
     IF new_references.adm_cal_type <> UPPER(new_references.adm_cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ADMISSION_CAT' OR
     column_name is null Then
     IF new_references.admission_cat <> UPPER(new_references.admission_cat) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'S_ADMISSION_PROCESS_TYPE' OR
     column_name is null Then
     IF new_references.s_admission_process_type <> UPPER(new_references.s_admission_process_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ADM_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.adm_ci_sequence_number  < 1 OR
          new_references.adm_ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number) AND
         (old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL) OR
         (new_references.admission_cat IS NULL))) THEN
      NULL;
    ELSE
	 IF NOT IGS_AD_PERD_AD_CAT_PKG.Get_PK_For_Validation (
      	  new_references.adm_cal_type,
	        new_references.adm_ci_sequence_number,
	        new_references.admission_cat
			) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	 END IF;
    END IF;

    IF (((old_references.admission_cat = new_references.admission_cat) AND
         (old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.admission_cat IS NULL) OR
         (new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
 	IF NOT IGS_AD_PRCS_CAT_PKG.Get_PK_For_Validation (
        new_references.admission_cat,
        new_references.s_admission_process_type ,
         'N') THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	 END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_APPL_PKG.GET_FK_IGS_AD_PRD_AD_PRC_CA (
      old_references.adm_cal_type,
      old_references.adm_ci_sequence_number,
      old_references.admission_cat,
      old_references.s_admission_process_type
      );

    IGS_AD_PRD_PS_OF_OPT_PKG.GET_FK_IGS_AD_PRD_AD_PRC_CA (
      old_references.adm_cal_type,
      old_references.adm_ci_sequence_number,
      old_references.admission_cat,
      old_references.s_admission_process_type
      );

    IGS_AD_PECRS_OFOP_DT_PKG.GET_FK_IGS_AD_PRD_AD_PRC_CA (
      old_references.adm_cal_type,
      old_references.adm_ci_sequence_number,
      old_references.admission_cat,
      old_references.s_admission_process_type
      );

  END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2
    )
RETURN BOOLEAN
AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRD_AD_PRC_CA
      WHERE    adm_cal_type = x_adm_cal_type
      AND      adm_ci_sequence_number = x_adm_ci_sequence_number
      AND      admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type AND
               closed_ind = NVL(x_closed_ind,closed_ind);

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

  PROCEDURE GET_FK_IGS_AD_PERD_AD_CAT (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRD_AD_PRC_CA
      WHERE    adm_cal_type = x_adm_cal_type
      AND      adm_ci_sequence_number = x_adm_ci_sequence_number
      AND      admission_cat = x_admission_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APAPC_APAC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_PERD_AD_CAT;

  PROCEDURE GET_FK_IGS_AD_PRCS_CAT (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRD_AD_PRC_CA
      WHERE    admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APAPC_APC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
       Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_PRCS_CAT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_adm_cal_type IN VARCHAR2 ,
    x_adm_ci_sequence_number IN NUMBER ,
    x_admission_cat IN VARCHAR2 ,
    x_s_admission_process_type IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_closed_ind IN VARCHAR2,
    x_single_response_flag IN VARCHAR2,
    x_include_sr_in_rollover_flag IN VARCHAR2
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_adm_cal_type,
      x_adm_ci_sequence_number,
      x_admission_cat,
      x_s_admission_process_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_closed_ind,
      x_single_response_flag,
      x_include_sr_in_rollover_flag
    );

 IF (p_action = 'INSERT') THEN
	Null;
      IF  Get_PK_For_Validation (
          new_references.adm_cal_type,
          new_references.adm_ci_sequence_number,
          new_references.admission_cat,
          new_references.s_admission_process_type
		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
       Check_Child_Existance;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.adm_cal_type,
          new_references.adm_ci_sequence_number,
          new_references.admission_cat,
          new_references.s_admission_process_type
		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
 ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
 END IF;

 -- Navin.Sinha 9/25/2003 Enhancement: 3132406 ENFORCE SINGLE RESPONSE TO OFFER
 -- Rollover checkbox can be checked only if the Single Response checkbox is checked.
 -- If rollover checkbox is checked without checking the Single Response checkbox the
 -- raise the error message saying 'You cannot check the Single Response Rollover
 -- checkbox without checking the Single Response checkbox'
 IF p_action IN ('INSERT', 'UPDATE', 'VALIDATE_INSERT', 'VALIDATE_UPDATE') THEN
     IF NVL(new_references.include_sr_in_rollover_flag,'N')  = 'Y' AND NVL(new_references.single_response_flag,'N')  = 'N' THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_AD_SR_CHECK_VALUE'); -- Single Response Rollover checkbox cannot be checked without checking Single Response checkbox.
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
 END IF;

END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

PROCEDURE INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 ,
  x_closed_ind IN VARCHAR2,
  x_single_response_flag IN VARCHAR2,
  x_include_sr_in_rollover_flag IN VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_AD_PRD_AD_PRC_CA
      where ADM_CAL_TYPE = X_ADM_CAL_TYPE
      and ADM_CI_SEQUENCE_NUMBER = X_ADM_CI_SEQUENCE_NUMBER
      and ADMISSION_CAT = X_ADMISSION_CAT
      and S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY is NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN is NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
  Before_DML(p_action =>'INSERT',
  x_rowid =>X_ROWID,
  x_adm_cal_type => X_ADM_CAL_TYPE,
  x_adm_ci_sequence_number => X_ADM_CI_SEQUENCE_NUMBER,
  x_admission_cat => X_ADMISSION_CAT,
  x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_closed_ind => x_closed_ind,
  x_single_response_flag =>  x_single_response_flag,
  x_include_sr_in_rollover_flag => x_include_sr_in_rollover_flag
  );

  INSERT INTO IGS_AD_PRD_AD_PRC_CA (
    ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER,
    ADMISSION_CAT,
    S_ADMISSION_PROCESS_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CLOSED_IND,
    SINGLE_RESPONSE_FLAG,
    INCLUDE_SR_IN_ROLLOVER_FLAG
  ) values (
    NEW_REFERENCES.ADM_CAL_TYPE,
    NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.S_ADMISSION_PROCESS_TYPE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.SINGLE_RESPONSE_FLAG,
    NEW_REFERENCES.INCLUDE_SR_IN_ROLLOVER_FLAG
  );

  OPEN c;
  FETCH c into X_ROWID;
  IF (c%notfound) then
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;
After_DML(
 p_action =>'INSERT',
 x_rowid => X_ROWID
);
END INSERT_ROW;


PROCEDURE update_row (
  X_ROWID in  VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 ,
  x_closed_ind IN VARCHAR2,
  x_single_response_flag IN VARCHAR2,
  x_include_sr_in_rollover_flag IN VARCHAR2
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
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
  Before_DML(p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_adm_cal_type => X_ADM_CAL_TYPE,
  x_adm_ci_sequence_number => X_ADM_CI_SEQUENCE_NUMBER,
  x_admission_cat => X_ADMISSION_CAT,
  x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_closed_ind => x_closed_ind,
  x_single_response_flag =>  x_single_response_flag,
  x_include_sr_in_rollover_flag => x_include_sr_in_rollover_flag
  );

  UPDATE IGS_AD_PRD_AD_PRC_CA SET
    ADM_CAL_TYPE = new_references.adm_cal_type,
    ADM_CI_SEQUENCE_NUMBER = new_references.adm_ci_sequence_number,
    ADMISSION_CAT = new_references.admission_cat,
    S_ADMISSION_PROCESS_TYPE = new_references.s_admission_process_type,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    CLOSED_IND = X_CLOSED_IND,
    SINGLE_RESPONSE_FLAG = X_SINGLE_RESPONSE_FLAG,
    INCLUDE_SR_IN_ROLLOVER_FLAG = X_INCLUDE_SR_IN_ROLLOVER_FLAG
  WHERE
    ROWID = X_ROWID;

  IF SQL%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;

After_DML(
 p_action =>'UPDATE',
 x_rowid => X_ROWID
);
END update_row;

PROCEDURE LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_CLOSED_IND IN VARCHAR2,
  x_single_response_flag IN VARCHAR2,
  x_include_sr_in_rollover_flag IN VARCHAR2
) AS
  CURSOR c1 IS SELECT
    rowid
    FROM IGS_AD_PRD_AD_PRC_CA
    WHERE ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

BEGIN
  OPEN c1;
  FETCH c1 into tlinfo;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;
  RETURN;
END LOCK_ROW;

PROCEDURE DELETE_ROW (
X_ROWID in VARCHAR2
) AS
BEGIN
Before_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
);
  DELETE FROM IGS_AD_PRD_AD_PRC_CA
  WHERE ROWID = X_ROWID;
  IF (sql%notfound) then
    raise no_data_found;
  END IF;
After_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
);

END DELETE_ROW;

END IGS_AD_PRD_AD_PRC_CA_PKG;

/
