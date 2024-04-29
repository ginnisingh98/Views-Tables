--------------------------------------------------------
--  DDL for Package Body IGS_AD_PS_APINTUNTHS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PS_APINTUNTHS_PKG" as
/* $Header: IGSAI22B.pls 120.0 2005/06/01 17:43:36 appldev noship $*/
  l_rowid VARCHAR2(25);
  old_references IGS_AD_PS_APINTUNTHS_ALL%RowType;
  new_references IGS_AD_PS_APINTUNTHS_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		x_org_id IN NUMBER,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_acai_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_uv_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_adm_unit_outcome_status IN VARCHAR2 DEFAULT NULL,
    x_ass_tracking_id IN NUMBER DEFAULT NULL,
    x_rule_waived_dt IN DATE DEFAULT NULL,
    x_rule_waived_person_id IN NUMBER DEFAULT NULL,
    x_sup_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sup_uv_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL,
    x_adm_ps_appl_inst_unithist_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PS_APINTUNTHS_ALL
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
		new_references.org_id := x_org_id;
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.nominated_course_cd := x_nominated_course_cd;
    new_references.acai_sequence_number := x_acai_sequence_number;
    new_references.unit_cd := x_unit_cd;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.uv_version_number := x_uv_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.unit_class := x_unit_class;
    new_references.unit_mode := x_unit_mode;
    new_references.adm_unit_outcome_status := x_adm_unit_outcome_status;
    new_references.ass_tracking_id := x_ass_tracking_id;
    new_references.rule_waived_dt := TRUNC(x_rule_waived_dt);
    new_references.rule_waived_person_id := x_rule_waived_person_id;
    new_references.sup_unit_cd := x_sup_unit_cd;
    new_references.sup_uv_version_number := x_sup_uv_version_number;
    new_references.adm_ps_appl_inst_unit_id := x_adm_ps_appl_inst_unit_id;
    new_references.adm_ps_appl_inst_unit_hist_id := x_adm_ps_appl_inst_unithist_id;
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
)
 AS
 BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'ADM_UNIT_OUTCOME_STATUS' then
     new_references.adm_unit_outcome_status := column_value;
 ELSIF upper(Column_name) = 'CAL_TYPE' then
     new_references.cal_type := column_value;
 ELSIF upper(Column_name) = 'LOCATION_CD' then
     new_references.location_cd := column_value;
 ELSIF upper(Column_name) = 'SUP_UNIT_CD' then
     new_references.sup_unit_cd := column_value;
 ELSIF upper(Column_name) = 'UNIT_CD' then
     new_references.unit_cd := column_value;
 ELSIF upper(Column_name) = 'UNIT_CLASS' then
     new_references.unit_class := column_value;
 ELSIF upper(Column_name) = 'UNIT_MODE' then
     new_references.unit_mode := column_value;
 ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
     new_references.ci_sequence_number := igs_ge_number.to_num(column_value);
END IF;

IF upper(column_name) = 'ADM_UNIT_OUTCOME_STATUS' OR column_name is null Then
     IF new_references.adm_unit_outcome_status <> UPPER(new_references.adm_unit_outcome_status) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'CAL_TYPE' OR column_name is null Then
     IF new_references.cal_type <> UPPER(new_references.cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'LOCATION_CD' OR column_name is null Then
     IF new_references.location_cd <> UPPER(new_references.location_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'SUP_UNIT_CD' OR column_name is null Then
     IF new_references.sup_unit_cd <> UPPER(new_references.sup_unit_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'UNIT_CD' OR column_name is null Then
     IF new_references.unit_cd <> UPPER(new_references.unit_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'UNIT_CLASS' OR column_name is null Then
     IF new_references.unit_class <> UPPER(new_references.unit_class) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'UNIT_MODE' OR column_name is null Then
     IF new_references.unit_mode <> UPPER(new_references.unit_mode) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'CI_SEQUENCE_NUMBER' OR column_name is null Then
     IF new_references.ci_sequence_number  < 1 OR new_references.ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
 END Check_Constraints;

FUNCTION Get_PK_For_Validation (
    x_adm_ps_appl_inst_unithist_id IN NUMBER
    )
RETURN BOOLEAN
 AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APINTUNTHS_ALL
      WHERE    adm_ps_appl_inst_unit_hist_id = x_adm_ps_appl_inst_unithist_id
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


FUNCTION Get_UK_For_Validation (
    x_adm_ps_appl_inst_unit_id IN NUMBER,
    x_hist_start_dt IN DATE
    )
RETURN BOOLEAN
 AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APINTUNTHS_ALL
      WHERE    adm_ps_appl_inst_unit_id = x_adm_ps_appl_inst_unit_id
      AND      hist_start_dt = x_hist_start_dt
      AND      (l_rowid IS NULL OR rowid <> l_rowid)
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
  END Get_UK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_acai_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_uv_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_adm_unit_outcome_status IN VARCHAR2 DEFAULT NULL,
    x_ass_tracking_id IN NUMBER DEFAULT NULL,
    x_rule_waived_dt IN DATE DEFAULT NULL,
    x_rule_waived_person_id IN NUMBER DEFAULT NULL,
    x_sup_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sup_uv_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL,
    x_adm_ps_appl_inst_unithist_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
			x_org_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_acai_sequence_number,
      x_unit_cd,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_uv_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_location_cd,
      x_unit_class,
      x_unit_mode,
      x_adm_unit_outcome_status,
      x_ass_tracking_id,
      x_rule_waived_dt,
      x_rule_waived_person_id,
      x_sup_unit_cd,
      x_sup_uv_version_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_adm_ps_appl_inst_unit_id,
      x_adm_ps_appl_inst_unithist_id
    );

IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (new_references.adm_ps_appl_inst_unit_hist_id) OR
         Get_UK_For_Validation (
          new_references.adm_ps_appl_inst_unit_id,
          new_references.hist_start_dt
  		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 ELSIF (p_action = 'UPDATE') THEN
      new_references.adm_ps_appl_inst_unit_hist_id := old_references.adm_ps_appl_inst_unit_hist_id;
      IF Get_UK_For_Validation (
          new_references.adm_ps_appl_inst_unit_id,
          new_references.hist_start_dt
  		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (new_references.adm_ps_appl_inst_unit_hist_id) OR
         Get_UK_For_Validation (
          new_references.adm_ps_appl_inst_unit_id,
          new_references.hist_start_dt
  		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      new_references.adm_ps_appl_inst_unit_hist_id := old_references.adm_ps_appl_inst_unit_hist_id;
      IF Get_UK_For_Validation (
          new_references.adm_ps_appl_inst_unit_id,
          new_references.hist_start_dt
  		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
	x_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_ADM_UNIT_OUTCOME_STATUS in VARCHAR2,
  X_ASS_TRACKING_ID in NUMBER,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_UV_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2,
  x_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL,
  x_adm_ps_appl_inst_unithist_id IN OUT NOCOPY NUMBER
  ) AS
    cursor C is select ROWID, ADM_PS_APPL_INST_UNIT_HIST_ID from IGS_AD_PS_APINTUNTHS_ALL
      where ADM_PS_APPL_INST_UNIT_ID = X_ADM_PS_APPL_INST_UNIT_ID
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
  Before_DML(p_action =>'INSERT',
  x_rowid =>X_ROWID,
	x_org_id => igs_ge_gen_003.get_org_id,
  x_person_id=>X_PERSON_ID ,
  x_admission_appl_number=>X_ADMISSION_APPL_NUMBER ,
  x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
  x_acai_sequence_number=>X_ACAI_SEQUENCE_NUMBER,
  x_unit_cd=>X_UNIT_CD,
  x_hist_start_dt=>X_HIST_START_DT,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_who=>X_HIST_WHO,
  x_uv_version_number=>X_UV_VERSION_NUMBER,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_location_cd=>X_LOCATION_CD,
  x_unit_class=>X_UNIT_CLASS,
  x_unit_mode=>X_UNIT_MODE,
  x_adm_unit_outcome_status=>X_ADM_UNIT_OUTCOME_STATUS,
  x_ass_tracking_id=>X_ASS_TRACKING_ID,
  x_rule_waived_dt=>X_RULE_WAIVED_DT,
  x_rule_waived_person_id=>X_RULE_WAIVED_PERSON_ID,
  x_sup_unit_cd=>X_SUP_UNIT_CD,
  x_sup_uv_version_number=>X_SUP_UV_VERSION_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_adm_ps_appl_inst_unit_id => X_ADM_PS_APPL_INST_UNIT_ID,
  x_adm_ps_appl_inst_unithist_id => X_ADM_PS_APPL_INST_UNITHIST_ID
  );

  insert into IGS_AD_PS_APINTUNTHS_ALL (
		ORG_ID,
    PERSON_ID,
    ADMISSION_APPL_NUMBER,
    NOMINATED_COURSE_CD,
    ACAI_SEQUENCE_NUMBER,
    UNIT_CD,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    UV_VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    LOCATION_CD,
    UNIT_CLASS,
    UNIT_MODE,
    ADM_UNIT_OUTCOME_STATUS,
    ASS_TRACKING_ID,
    RULE_WAIVED_DT,
    RULE_WAIVED_PERSON_ID,
    SUP_UNIT_CD,
    SUP_UV_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ADM_PS_APPL_INST_UNIT_ID,
    ADM_PS_APPL_INST_UNIT_HIST_ID
  ) values (
		NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.NOMINATED_COURSE_CD,
    NEW_REFERENCES.ACAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.UV_VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.UNIT_MODE,
    NEW_REFERENCES.ADM_UNIT_OUTCOME_STATUS,
    NEW_REFERENCES.ASS_TRACKING_ID,
    NEW_REFERENCES.RULE_WAIVED_DT,
    NEW_REFERENCES.RULE_WAIVED_PERSON_ID,
    NEW_REFERENCES.SUP_UNIT_CD,
    NEW_REFERENCES.SUP_UV_VERSION_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ADM_PS_APPL_INST_UNIT_ID,
    IGS_AD_PS_APINTUNTHS_S.NEXTVAL
  );

  open c;
  fetch c into X_ROWID, X_ADM_PS_APPL_INST_UNITHIST_ID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
After_DML(
 p_action =>'INSERT',
 x_rowid => X_ROWID
);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_ADM_UNIT_OUTCOME_STATUS in VARCHAR2,
  X_ASS_TRACKING_ID in NUMBER,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_UV_VERSION_NUMBER in NUMBER,
  x_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL,
  x_adm_ps_appl_inst_unithist_id IN NUMBER DEFAULT NULL
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      UV_VERSION_NUMBER,
      CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      LOCATION_CD,
      UNIT_CLASS,
      UNIT_MODE,
      ADM_UNIT_OUTCOME_STATUS,
      ASS_TRACKING_ID,
      RULE_WAIVED_DT,
      RULE_WAIVED_PERSON_ID,
      SUP_UNIT_CD,
      SUP_UV_VERSION_NUMBER
    from IGS_AD_PS_APINTUNTHS_ALL
    where ROWID = X_ROWID for update nowait;
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
      AND ((tlinfo.UV_VERSION_NUMBER = X_UV_VERSION_NUMBER)
           OR ((tlinfo.UV_VERSION_NUMBER is null)
               AND (X_UV_VERSION_NUMBER is null)))
      AND ((tlinfo.CAL_TYPE = X_CAL_TYPE)
           OR ((tlinfo.CAL_TYPE is null)
               AND (X_CAL_TYPE is null)))
      AND ((tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.CI_SEQUENCE_NUMBER is null)
               AND (X_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.UNIT_CLASS = X_UNIT_CLASS)
           OR ((tlinfo.UNIT_CLASS is null)
               AND (X_UNIT_CLASS is null)))
      AND ((tlinfo.UNIT_MODE = X_UNIT_MODE)
           OR ((tlinfo.UNIT_MODE is null)
               AND (X_UNIT_MODE is null)))
      AND ((tlinfo.ADM_UNIT_OUTCOME_STATUS = X_ADM_UNIT_OUTCOME_STATUS)
           OR ((tlinfo.ADM_UNIT_OUTCOME_STATUS is null)
               AND (X_ADM_UNIT_OUTCOME_STATUS is null)))
      AND ((tlinfo.ASS_TRACKING_ID = X_ASS_TRACKING_ID)
           OR ((tlinfo.ASS_TRACKING_ID is null)
               AND (X_ASS_TRACKING_ID is null)))
      AND ((TRUNC(tlinfo.RULE_WAIVED_DT) = TRUNC(X_RULE_WAIVED_DT))
           OR ((tlinfo.RULE_WAIVED_DT is null)
               AND (X_RULE_WAIVED_DT is null)))
      AND ((tlinfo.RULE_WAIVED_PERSON_ID = X_RULE_WAIVED_PERSON_ID)
           OR ((tlinfo.RULE_WAIVED_PERSON_ID is null)
               AND (X_RULE_WAIVED_PERSON_ID is null)))
      AND ((tlinfo.SUP_UNIT_CD = X_SUP_UNIT_CD)
           OR ((tlinfo.SUP_UNIT_CD is null)
               AND (X_SUP_UNIT_CD is null)))
      AND ((tlinfo.SUP_UV_VERSION_NUMBER = X_SUP_UV_VERSION_NUMBER)
           OR ((tlinfo.SUP_UV_VERSION_NUMBER is null)
               AND (X_SUP_UV_VERSION_NUMBER is null)))
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
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_ADM_UNIT_OUTCOME_STATUS in VARCHAR2,
  X_ASS_TRACKING_ID in NUMBER,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_UV_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2,
  x_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL,
  x_adm_ps_appl_inst_unithist_id IN NUMBER DEFAULT NULL
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
Before_DML(p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_person_id=>X_PERSON_ID ,
  x_admission_appl_number=>X_ADMISSION_APPL_NUMBER ,
  x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
  x_acai_sequence_number=>X_ACAI_SEQUENCE_NUMBER,
  x_unit_cd=>X_UNIT_CD,
  x_hist_start_dt=>X_HIST_START_DT,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_who=>X_HIST_WHO,
  x_uv_version_number=>X_UV_VERSION_NUMBER,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_location_cd=>X_LOCATION_CD,
  x_unit_class=>X_UNIT_CLASS,
  x_unit_mode=>X_UNIT_MODE,
  x_adm_unit_outcome_status=>X_ADM_UNIT_OUTCOME_STATUS,
  x_ass_tracking_id=>X_ASS_TRACKING_ID,
  x_rule_waived_dt=>X_RULE_WAIVED_DT,
  x_rule_waived_person_id=>X_RULE_WAIVED_PERSON_ID,
  x_sup_unit_cd=>X_SUP_UNIT_CD,
      x_sup_uv_version_number=>X_SUP_UV_VERSION_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_adm_ps_appl_inst_unit_id => X_ADM_PS_APPL_INST_UNIT_ID,
  x_adm_ps_appl_inst_unithist_id => X_ADM_PS_APPL_INST_UNITHIST_ID
  );

update IGS_AD_PS_APINTUNTHS_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    UV_VERSION_NUMBER = NEW_REFERENCES.UV_VERSION_NUMBER,
    CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
    CI_SEQUENCE_NUMBER = NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    UNIT_CLASS = NEW_REFERENCES.UNIT_CLASS,
    UNIT_MODE = NEW_REFERENCES.UNIT_MODE,
    ADM_UNIT_OUTCOME_STATUS = NEW_REFERENCES.ADM_UNIT_OUTCOME_STATUS,
    ASS_TRACKING_ID = NEW_REFERENCES.ASS_TRACKING_ID,
    RULE_WAIVED_DT = NEW_REFERENCES.RULE_WAIVED_DT,
    RULE_WAIVED_PERSON_ID = NEW_REFERENCES.RULE_WAIVED_PERSON_ID,
    SUP_UNIT_CD = NEW_REFERENCES.SUP_UNIT_CD,
    SUP_UV_VERSION_NUMBER = NEW_REFERENCES.SUP_UV_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
          IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
  end if;
After_DML(
 p_action =>'UPDATE',
 x_rowid => X_ROWID
);

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
	X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_ADM_UNIT_OUTCOME_STATUS in VARCHAR2,
  X_ASS_TRACKING_ID in NUMBER,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_UV_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2,
  x_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL,
  x_adm_ps_appl_inst_unithist_id IN OUT NOCOPY NUMBER
  ) AS
  cursor c1 is select rowid from IGS_AD_PS_APINTUNTHS_ALL
     where adm_ps_appl_inst_unit_hist_id = x_adm_ps_appl_inst_unithist_id
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
		 X_ORG_ID,
     X_PERSON_ID,
     X_ADMISSION_APPL_NUMBER,
     X_NOMINATED_COURSE_CD,
     X_ACAI_SEQUENCE_NUMBER,
     X_UNIT_CD,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_UV_VERSION_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_LOCATION_CD,
     X_UNIT_CLASS,
     X_UNIT_MODE,
     X_ADM_UNIT_OUTCOME_STATUS,
     X_ASS_TRACKING_ID,
     X_RULE_WAIVED_DT,
     X_RULE_WAIVED_PERSON_ID,
     X_SUP_UNIT_CD,
     X_SUP_UV_VERSION_NUMBER,
     X_MODE,
     X_ADM_PS_APPL_INST_UNIT_ID,
     X_ADM_PS_APPL_INST_UNITHIST_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ADMISSION_APPL_NUMBER,
   X_NOMINATED_COURSE_CD,
   X_ACAI_SEQUENCE_NUMBER,
   X_UNIT_CD,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_UV_VERSION_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_LOCATION_CD,
   X_UNIT_CLASS,
   X_UNIT_MODE,
   X_ADM_UNIT_OUTCOME_STATUS,
   X_ASS_TRACKING_ID,
   X_RULE_WAIVED_DT,
   X_RULE_WAIVED_PERSON_ID,
   X_SUP_UNIT_CD,
   X_SUP_UV_VERSION_NUMBER,
   X_MODE,
   X_ADM_PS_APPL_INST_UNIT_ID,
   X_ADM_PS_APPL_INST_UNITHIST_ID);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS

e_resource_busy_exception		EXCEPTION;
PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
v_message_name varchar2(30);

begin

	Before_DML(
 		p_action =>'DELETE',
 		x_rowid => X_ROWID
		);
      -- set default value
      v_message_name := null;
  	delete from IGS_AD_PS_APINTUNTHS_ALL
  	where ROWID = X_ROWID;
  	if (sql%notfound) then
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
          IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
  	end if;
	After_DML(
 		p_action =>'DELETE',
 		x_rowid => X_ROWID
		);
EXCEPTION
	WHEN e_resource_busy_exception THEN
	  -- Set error message number
	  v_message_name := 'IGS_AD_UNABLE_TO_DELETE';
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	WHEN OTHERS THEN
            IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
              -- Code to handle Security Policy error raised
              -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
              -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
              -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
              --    that the ownerof policy function does not have privilege to access.
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
              FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
              IGS_GE_MSG_STACK.ADD;
              app_exception.raise_exception;
            ELSE
              RAISE;
            END IF;
end DELETE_ROW;
end IGS_AD_PS_APINTUNTHS_PKG;

/
