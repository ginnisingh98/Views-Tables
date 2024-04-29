--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERS_PREFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERS_PREFS_PKG" AS
 /* $Header: IGSNI28B.pls 115.5 2002/11/29 01:20:39 nsidana ship $ */



  l_rowid VARCHAR2(25);
  old_references IGS_PE_PERS_PREFS_ALL%RowType;
  new_references IGS_PE_PERS_PREFS_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_server_printer_dflt IN VARCHAR2 DEFAULT NULL,
    x_allow_stnd_req_ind IN VARCHAR2 DEFAULT NULL,
    x_enq_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_enq_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_enq_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_enq_acad_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_enr_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_enr_acad_sequence_number IN NUMBER DEFAULT NULL,
    x_enr_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_enr_enr_method_type IN VARCHAR2 DEFAULT NULL,
    x_adm_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_acad_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_adm_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_adm_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_adm_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PERS_PREFS_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
       App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.server_printer_dflt := x_server_printer_dflt;
    new_references.allow_stnd_req_ind := x_allow_stnd_req_ind;
    new_references.enq_adm_cal_type := x_enq_adm_cal_type;
    new_references.enq_adm_ci_sequence_number := x_enq_adm_ci_sequence_number;
    new_references.enq_acad_cal_type := x_enq_acad_cal_type;
    new_references.enq_acad_ci_sequence_number := x_enq_acad_ci_sequence_number;
    new_references.person_id := x_person_id;
    new_references.enr_acad_cal_type := x_enr_acad_cal_type;
    new_references.enr_acad_sequence_number := x_enr_acad_sequence_number;
    new_references.enr_enrolment_cat := x_enr_enrolment_cat;
    new_references.enr_enr_method_type := x_enr_enr_method_type;
    new_references.adm_acad_cal_type := x_adm_acad_cal_type;
    new_references.adm_acad_ci_sequence_number := x_adm_acad_ci_sequence_number;
    new_references.adm_adm_cal_type := x_adm_adm_cal_type;
    new_references.adm_adm_ci_sequence_number := x_adm_adm_ci_sequence_number;
    new_references.adm_admission_cat := x_adm_admission_cat;
    new_references.adm_s_admission_process_type := x_adm_s_admission_process_type;
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
  -- "TRG_PP_BR_IUD" BEFORE INSERT OR DELETE OR UPDATE ON OSS_TST.IGS_PE_PERS_PREFS REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name  varchar2(30);
	/*v_current_person_id	IGS_PE_PERSON.person_id%TYPE;
	v_person_id		IGS_PE_PERSON.person_id%TYPE;
	v_user_person_id		IGS_PE_PERSON.person_id%TYPE;*/
  BEGIN
		IF (p_inserting AND
		     new_references.allow_stnd_req_ind <> 'N') OR
		   (p_updating AND
		   new_references.allow_stnd_req_ind <> old_references.allow_stnd_req_ind) THEN
		 Fnd_Message.Set_Name('IGS', 'IGS_AV_INSUFICIENT_PRIV');
		 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;




  END BeforeRowInsertUpdateDelete2;




 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
    IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) =  'ADM_ACAD_CAL_TYPE' then
     new_references.adm_acad_cal_type:= column_value;
 ELSIF upper(Column_name) = 'ADM_ADMISSION_CAT' then
     new_references.adm_admission_cat := column_value;
 ELSIF upper(Column_name) = 'ADM_ADM_CAL_TYPE' then
     new_references.adm_adm_cal_type := column_value;
 ELSIF upper(Column_name) = 'ADM_S_ADMISSION_PROCESS_TYPE' then
     new_references.adm_s_admission_process_type:= column_value;
 ELSIF upper(Column_name) =  'ENR_ACAD_CAL_TYPE' then
     new_references.enr_acad_cal_type:= column_value;
 ELSIF upper(Column_name) = 'ENR_ENROLMENT_CAT' then
     new_references.enr_enrolment_cat := column_value;
 ELSIF upper(Column_name) = 'ENR_ENR_METHOD_TYPE' then
     new_references.enr_enr_method_type := column_value;
 ELSIF upper(Column_name) = 'ADM_ADM_CI_SEQUENCE_NUMBER' then
     new_references.adm_adm_ci_sequence_number :=IGS_GE_NUMBER.to_num(column_value);
 ELSIF upper(Column_name) = 'ALLOW_STND_REQ_IND' then
     new_references.allow_stnd_req_ind := column_value;
 ELSIF upper(Column_name) = 'ADM_ACAD_CI_SEQUENCE_NUMBER' then
     new_references.adm_acad_ci_sequence_number := IGS_GE_NUMBER.to_num(column_value);
 ELSIF upper(Column_name) = 'ENR_ACAD_SEQUENCE_NUMBER' then
     new_references.enr_acad_sequence_number :=IGS_GE_NUMBER.to_num(column_value);
 ELSIF upper(Column_name) = 'ENR_ACAD_CI_SEQUENCE_NUMBER' then
     new_references.enq_acad_ci_sequence_number := IGS_GE_NUMBER.to_num(column_value);
ELSIF upper(Column_name) = 'ENQ_ADM_CI_SEQUENCE_NUMBER' then
     new_references.enq_adm_ci_sequence_number := IGS_GE_NUMBER.to_num(column_value);
END IF;

IF upper(column_name) = 'ADM_ACAD_CAL_TYPE' OR
     column_name is null Then
     IF  new_references.adm_acad_cal_type <>UPPER(new_references.adm_acad_cal_type )Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

IF upper(column_name) = 'ADM_ADMISSION_CAT' OR
     column_name is null Then
     IF new_references.adm_admission_cat <>UPPER(new_references.adm_admission_cat)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
 IF upper(column_name) = 'ADM_ADM_CAL_TYPE' OR
     column_name is null Then
     IF new_references.adm_adm_cal_type <>UPPER(new_references.adm_adm_cal_type ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'ADM_S_ADMISSION_PROCESS_TYPE' OR
     column_name is null Then
     IF    new_references.adm_s_admission_process_type <>UPPER(new_references.adm_s_admission_process_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
 IF upper(column_name) = 'ENR_ACAD_CAL_TYPE' OR
     column_name is null Then
     IF new_references.enr_acad_cal_type <>UPPER(new_references.enr_acad_cal_type)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
 IF upper(column_name) = 'ENR_ENROLMENT_CAT' OR
     column_name is null Then
     IF new_references.enr_enrolment_cat <>UPPER(new_references.enr_enrolment_cat ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'ENR_ENR_METHOD_TYPE' OR
     column_name is null Then
     IF    new_references.enr_enr_method_type <>UPPER(new_references.enr_enr_method_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'ADM_ADM_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF    new_references.adm_adm_ci_sequence_number  < 0 OR  new_references.adm_adm_ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'ALLOW_STND_REQ_IND' OR
     column_name is null Then
     IF    new_references.allow_stnd_req_ind NOT IN ( 'Y' , 'N' ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'ADM_ACAD_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF    new_references.adm_acad_ci_sequence_number  < 0  OR new_references.adm_acad_ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'ENR_ACAD_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF    new_references.enr_acad_sequence_number  < 0 OR  new_references.enr_acad_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'ENR_ACAD_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF    new_references.enq_acad_ci_sequence_number < 0 OR new_references.enq_acad_ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
 IF upper(column_name) = 'ENQ_ADM_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF    new_references.enq_adm_ci_sequence_number < 0 OR new_references.enq_adm_ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

 END Check_Constraints;

      --Redundent Procedure

   PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE

       IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
         new_references.person_id) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_PREFS_ALL
      WHERE    person_id = x_person_id
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

   --Redundent Procedure
  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERS_PREFS_ALL
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PP_PE_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_server_printer_dflt IN VARCHAR2 DEFAULT NULL,
    x_allow_stnd_req_ind IN VARCHAR2 DEFAULT NULL,
    x_enq_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_enq_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_enq_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_enq_acad_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_enr_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_enr_acad_sequence_number IN NUMBER DEFAULT NULL,
    x_enr_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_enr_enr_method_type IN VARCHAR2 DEFAULT NULL,
    x_adm_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_acad_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_adm_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_adm_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_adm_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
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
      x_server_printer_dflt,
      x_allow_stnd_req_ind,
      x_enq_adm_cal_type,
      x_enq_adm_ci_sequence_number,
      x_enq_acad_cal_type,
      x_enq_acad_ci_sequence_number,
      x_person_id,
      x_enr_acad_cal_type,
      x_enr_acad_sequence_number,
      x_enr_enrolment_cat,
      x_enr_enr_method_type,
      x_adm_acad_cal_type,
      x_adm_acad_ci_sequence_number,
      x_adm_adm_cal_type,
      x_adm_adm_ci_sequence_number,
      x_adm_admission_cat,
      x_adm_s_admission_process_type,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
     BeforeRowInsertUpdatedelete2 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
          new_references.person_id  ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
     -- Check_Parent_Existance; for Oracle username issue
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdatedelete2 ( p_updating => TRUE );

       Check_Constraints; -- if procedure present
       --Check_Parent_Existance; for Oracle username issue

 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdatedelete2( p_deleting => TRUE );
     NULL;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.person_id  ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       Check_Constraints; -- if procedure present

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
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENR_ACAD_CAL_TYPE in VARCHAR2,
  X_ENR_ACAD_SEQUENCE_NUMBER in NUMBER,
  X_ENR_ENROLMENT_CAT in VARCHAR2,
  X_ENR_ENR_METHOD_TYPE in VARCHAR2,
  X_ADM_ACAD_CAL_TYPE in VARCHAR2,
  X_ADM_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_ADMISSION_CAT in VARCHAR2,
  X_ADM_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ENQ_ACAD_CAL_TYPE in VARCHAR2,
  X_ENQ_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENQ_ADM_CAL_TYPE in VARCHAR2,
  X_ENQ_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_SERVER_PRINTER_DFLT in VARCHAR2,
  X_ALLOW_STND_REQ_IND in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PE_PERS_PREFS_ALL
      where PERSON_ID = X_PERSON_ID;
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
  x_adm_acad_cal_type=>X_ADM_ACAD_CAL_TYPE,
  x_adm_acad_ci_sequence_number=>X_ADM_ACAD_CI_SEQUENCE_NUMBER,
  x_adm_adm_cal_type=>X_ADM_ADM_CAL_TYPE,
  x_adm_adm_ci_sequence_number=>X_ADM_ADM_CI_SEQUENCE_NUMBER,
  x_adm_admission_cat=>X_ADM_ADMISSION_CAT,
  x_adm_s_admission_process_type=>X_ADM_S_ADMISSION_PROCESS_TYPE,
  x_allow_stnd_req_ind=> NVL(X_ALLOW_STND_REQ_IND,'N'),
  x_enq_acad_cal_type=>X_ENQ_ACAD_CAL_TYPE,
  x_enq_acad_ci_sequence_number=>X_ENQ_ACAD_CI_SEQUENCE_NUMBER,
  x_enq_adm_cal_type=>X_ENQ_ADM_CAL_TYPE,
  x_enq_adm_ci_sequence_number=>X_ENQ_ADM_CI_SEQUENCE_NUMBER,
  x_enr_acad_cal_type=>X_ENR_ACAD_CAL_TYPE,
  x_enr_acad_sequence_number=>X_ENR_ACAD_SEQUENCE_NUMBER,
  x_enr_enr_method_type=>X_ENR_ENR_METHOD_TYPE,
  x_enr_enrolment_cat=>X_ENR_ENROLMENT_CAT,
  x_person_id=>X_PERSON_ID,
  x_server_printer_dflt=>X_SERVER_PRINTER_DFLT,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_PE_PERS_PREFS_ALL (
    PERSON_ID,
    ENR_ACAD_CAL_TYPE,
    ENR_ACAD_SEQUENCE_NUMBER,
    ENR_ENROLMENT_CAT,
    ENR_ENR_METHOD_TYPE,
    ADM_ACAD_CAL_TYPE,
    ADM_ACAD_CI_SEQUENCE_NUMBER,
    ADM_ADM_CAL_TYPE,
    ADM_ADM_CI_SEQUENCE_NUMBER,
    ADM_ADMISSION_CAT,
    ADM_S_ADMISSION_PROCESS_TYPE,
    ENQ_ACAD_CAL_TYPE,
    ENQ_ACAD_CI_SEQUENCE_NUMBER,
    ENQ_ADM_CAL_TYPE,
    ENQ_ADM_CI_SEQUENCE_NUMBER,
    SERVER_PRINTER_DFLT,
    ALLOW_STND_REQ_IND,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ENR_ACAD_CAL_TYPE,
    NEW_REFERENCES.ENR_ACAD_SEQUENCE_NUMBER,
    NEW_REFERENCES.ENR_ENROLMENT_CAT,
    NEW_REFERENCES.ENR_ENR_METHOD_TYPE,
    NEW_REFERENCES.ADM_ACAD_CAL_TYPE,
    NEW_REFERENCES.ADM_ACAD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADM_ADM_CAL_TYPE,
    NEW_REFERENCES.ADM_ADM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADM_ADMISSION_CAT,
    NEW_REFERENCES.ADM_S_ADMISSION_PROCESS_TYPE,
    NEW_REFERENCES.ENQ_ACAD_CAL_TYPE,
    NEW_REFERENCES.ENQ_ACAD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ENQ_ADM_CAL_TYPE,
    NEW_REFERENCES.ENQ_ADM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.SERVER_PRINTER_DFLT,
    NEW_REFERENCES.ALLOW_STND_REQ_IND,
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
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENR_ACAD_CAL_TYPE in VARCHAR2,
  X_ENR_ACAD_SEQUENCE_NUMBER in NUMBER,
  X_ENR_ENROLMENT_CAT in VARCHAR2,
  X_ENR_ENR_METHOD_TYPE in VARCHAR2,
  X_ADM_ACAD_CAL_TYPE in VARCHAR2,
  X_ADM_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_ADMISSION_CAT in VARCHAR2,
  X_ADM_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ENQ_ACAD_CAL_TYPE in VARCHAR2,
  X_ENQ_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENQ_ADM_CAL_TYPE in VARCHAR2,
  X_ENQ_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_SERVER_PRINTER_DFLT in VARCHAR2,
  X_ALLOW_STND_REQ_IND in VARCHAR2
) AS
  cursor c1 is select
      ENR_ACAD_CAL_TYPE,
      ENR_ACAD_SEQUENCE_NUMBER,
      ENR_ENROLMENT_CAT,
      ENR_ENR_METHOD_TYPE,
      ADM_ACAD_CAL_TYPE,
      ADM_ACAD_CI_SEQUENCE_NUMBER,
      ADM_ADM_CAL_TYPE,
      ADM_ADM_CI_SEQUENCE_NUMBER,
      ADM_ADMISSION_CAT,
      ADM_S_ADMISSION_PROCESS_TYPE,
      ENQ_ACAD_CAL_TYPE,
      ENQ_ACAD_CI_SEQUENCE_NUMBER,
      ENQ_ADM_CAL_TYPE,
      ENQ_ADM_CI_SEQUENCE_NUMBER,
      SERVER_PRINTER_DFLT,
      ALLOW_STND_REQ_IND
    from IGS_PE_PERS_PREFS_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');

    close c1;
    App_Exception.Raise_Exception;
    return;
  end if;
  close c1;

      if ( ((tlinfo.ENR_ACAD_CAL_TYPE = X_ENR_ACAD_CAL_TYPE)
           OR ((tlinfo.ENR_ACAD_CAL_TYPE is null)
               AND (X_ENR_ACAD_CAL_TYPE is null)))
      AND ((tlinfo.ENR_ACAD_SEQUENCE_NUMBER = X_ENR_ACAD_SEQUENCE_NUMBER)
           OR ((tlinfo.ENR_ACAD_SEQUENCE_NUMBER is null)
               AND (X_ENR_ACAD_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ENR_ENROLMENT_CAT = X_ENR_ENROLMENT_CAT)
           OR ((tlinfo.ENR_ENROLMENT_CAT is null)
               AND (X_ENR_ENROLMENT_CAT is null)))
      AND ((tlinfo.ENR_ENR_METHOD_TYPE = X_ENR_ENR_METHOD_TYPE)
           OR ((tlinfo.ENR_ENR_METHOD_TYPE is null)
               AND (X_ENR_ENR_METHOD_TYPE is null)))
      AND ((tlinfo.ADM_ACAD_CAL_TYPE = X_ADM_ACAD_CAL_TYPE)
           OR ((tlinfo.ADM_ACAD_CAL_TYPE is null)
               AND (X_ADM_ACAD_CAL_TYPE is null)))
      AND ((tlinfo.ADM_ACAD_CI_SEQUENCE_NUMBER = X_ADM_ACAD_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.ADM_ACAD_CI_SEQUENCE_NUMBER is null)
               AND (X_ADM_ACAD_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ADM_ADM_CAL_TYPE = X_ADM_ADM_CAL_TYPE)
           OR ((tlinfo.ADM_ADM_CAL_TYPE is null)
               AND (X_ADM_ADM_CAL_TYPE is null)))
      AND ((tlinfo.ADM_ADM_CI_SEQUENCE_NUMBER = X_ADM_ADM_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.ADM_ADM_CI_SEQUENCE_NUMBER is null)
               AND (X_ADM_ADM_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ADM_ADMISSION_CAT = X_ADM_ADMISSION_CAT)
           OR ((tlinfo.ADM_ADMISSION_CAT is null)
               AND (X_ADM_ADMISSION_CAT is null)))
      AND ((tlinfo.ADM_S_ADMISSION_PROCESS_TYPE = X_ADM_S_ADMISSION_PROCESS_TYPE)
           OR ((tlinfo.ADM_S_ADMISSION_PROCESS_TYPE is null)
               AND (X_ADM_S_ADMISSION_PROCESS_TYPE is null)))
      AND ((tlinfo.ENQ_ACAD_CAL_TYPE = X_ENQ_ACAD_CAL_TYPE)
           OR ((tlinfo.ENQ_ACAD_CAL_TYPE is null)
               AND (X_ENQ_ACAD_CAL_TYPE is null)))
      AND ((tlinfo.ENQ_ACAD_CI_SEQUENCE_NUMBER = X_ENQ_ACAD_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.ENQ_ACAD_CI_SEQUENCE_NUMBER is null)
               AND (X_ENQ_ACAD_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ENQ_ADM_CAL_TYPE = X_ENQ_ADM_CAL_TYPE)
           OR ((tlinfo.ENQ_ADM_CAL_TYPE is null)
               AND (X_ENQ_ADM_CAL_TYPE is null)))
      AND ((tlinfo.ENQ_ADM_CI_SEQUENCE_NUMBER = X_ENQ_ADM_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.ENQ_ADM_CI_SEQUENCE_NUMBER is null)
               AND (X_ENQ_ADM_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.SERVER_PRINTER_DFLT = X_SERVER_PRINTER_DFLT)
           OR ((tlinfo.SERVER_PRINTER_DFLT is null)
               AND (X_SERVER_PRINTER_DFLT is null)))
      AND (tlinfo.ALLOW_STND_REQ_IND = X_ALLOW_STND_REQ_IND)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENR_ACAD_CAL_TYPE in VARCHAR2,
  X_ENR_ACAD_SEQUENCE_NUMBER in NUMBER,
  X_ENR_ENROLMENT_CAT in VARCHAR2,
  X_ENR_ENR_METHOD_TYPE in VARCHAR2,
  X_ADM_ACAD_CAL_TYPE in VARCHAR2,
  X_ADM_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_ADMISSION_CAT in VARCHAR2,
  X_ADM_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ENQ_ACAD_CAL_TYPE in VARCHAR2,
  X_ENQ_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENQ_ADM_CAL_TYPE in VARCHAR2,
  X_ENQ_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_SERVER_PRINTER_DFLT in VARCHAR2,
  X_ALLOW_STND_REQ_IND in VARCHAR2,
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
  x_adm_acad_cal_type=>X_ADM_ACAD_CAL_TYPE,
  x_adm_acad_ci_sequence_number=>X_ADM_ACAD_CI_SEQUENCE_NUMBER,
  x_adm_adm_cal_type=>X_ADM_ADM_CAL_TYPE,
  x_adm_adm_ci_sequence_number=>X_ADM_ADM_CI_SEQUENCE_NUMBER,
  x_adm_admission_cat=>X_ADM_ADMISSION_CAT,
  x_adm_s_admission_process_type=>X_ADM_S_ADMISSION_PROCESS_TYPE,
  x_allow_stnd_req_ind=>X_ALLOW_STND_REQ_IND,
  x_enq_acad_cal_type=>X_ENQ_ACAD_CAL_TYPE,
  x_enq_acad_ci_sequence_number=>X_ENQ_ACAD_CI_SEQUENCE_NUMBER,
  x_enq_adm_cal_type=>X_ENQ_ADM_CAL_TYPE,
  x_enq_adm_ci_sequence_number=>X_ENQ_ADM_CI_SEQUENCE_NUMBER,
  x_enr_acad_cal_type=>X_ENR_ACAD_CAL_TYPE,
  x_enr_acad_sequence_number=>X_ENR_ACAD_SEQUENCE_NUMBER,
  x_enr_enr_method_type=>X_ENR_ENR_METHOD_TYPE,
  x_enr_enrolment_cat=>X_ENR_ENROLMENT_CAT,
  x_person_id=>X_PERSON_ID,
  x_server_printer_dflt=>X_SERVER_PRINTER_DFLT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  update IGS_PE_PERS_PREFS_ALL set
    ENR_ACAD_CAL_TYPE = NEW_REFERENCES.ENR_ACAD_CAL_TYPE,
    ENR_ACAD_SEQUENCE_NUMBER = NEW_REFERENCES.ENR_ACAD_SEQUENCE_NUMBER,
    ENR_ENROLMENT_CAT = NEW_REFERENCES.ENR_ENROLMENT_CAT,
    ENR_ENR_METHOD_TYPE = NEW_REFERENCES.ENR_ENR_METHOD_TYPE,
    ADM_ACAD_CAL_TYPE = NEW_REFERENCES.ADM_ACAD_CAL_TYPE,
    ADM_ACAD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.ADM_ACAD_CI_SEQUENCE_NUMBER,
    ADM_ADM_CAL_TYPE = NEW_REFERENCES.ADM_ADM_CAL_TYPE,
    ADM_ADM_CI_SEQUENCE_NUMBER = NEW_REFERENCES.ADM_ADM_CI_SEQUENCE_NUMBER,
    ADM_ADMISSION_CAT = NEW_REFERENCES.ADM_ADMISSION_CAT,
    ADM_S_ADMISSION_PROCESS_TYPE = NEW_REFERENCES.ADM_S_ADMISSION_PROCESS_TYPE,
    ENQ_ACAD_CAL_TYPE = NEW_REFERENCES.ENQ_ACAD_CAL_TYPE,
    ENQ_ACAD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.ENQ_ACAD_CI_SEQUENCE_NUMBER,
    ENQ_ADM_CAL_TYPE = NEW_REFERENCES.ENQ_ADM_CAL_TYPE,
    ENQ_ADM_CI_SEQUENCE_NUMBER = NEW_REFERENCES.ENQ_ADM_CI_SEQUENCE_NUMBER,
    SERVER_PRINTER_DFLT = NEW_REFERENCES.SERVER_PRINTER_DFLT,
    ALLOW_STND_REQ_IND = NEW_REFERENCES.ALLOW_STND_REQ_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENR_ACAD_CAL_TYPE in VARCHAR2,
  X_ENR_ACAD_SEQUENCE_NUMBER in NUMBER,
  X_ENR_ENROLMENT_CAT in VARCHAR2,
  X_ENR_ENR_METHOD_TYPE in VARCHAR2,
  X_ADM_ACAD_CAL_TYPE in VARCHAR2,
  X_ADM_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_ADMISSION_CAT in VARCHAR2,
  X_ADM_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ENQ_ACAD_CAL_TYPE in VARCHAR2,
  X_ENQ_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENQ_ADM_CAL_TYPE in VARCHAR2,
  X_ENQ_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_SERVER_PRINTER_DFLT in VARCHAR2,
  X_ALLOW_STND_REQ_IND in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PE_PERS_PREFS_ALL
     where PERSON_ID = X_PERSON_ID
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_ENR_ACAD_CAL_TYPE,
     X_ENR_ACAD_SEQUENCE_NUMBER,
     X_ENR_ENROLMENT_CAT,
     X_ENR_ENR_METHOD_TYPE,
     X_ADM_ACAD_CAL_TYPE,
     X_ADM_ACAD_CI_SEQUENCE_NUMBER,
     X_ADM_ADM_CAL_TYPE,
     X_ADM_ADM_CI_SEQUENCE_NUMBER,
     X_ADM_ADMISSION_CAT,
     X_ADM_S_ADMISSION_PROCESS_TYPE,
     X_ENQ_ACAD_CAL_TYPE,
     X_ENQ_ACAD_CI_SEQUENCE_NUMBER,
     X_ENQ_ADM_CAL_TYPE,
     X_ENQ_ADM_CI_SEQUENCE_NUMBER,
     X_SERVER_PRINTER_DFLT,
     X_ALLOW_STND_REQ_IND,
     X_ORG_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ENR_ACAD_CAL_TYPE,
   X_ENR_ACAD_SEQUENCE_NUMBER,
   X_ENR_ENROLMENT_CAT,
   X_ENR_ENR_METHOD_TYPE,
   X_ADM_ACAD_CAL_TYPE,
   X_ADM_ACAD_CI_SEQUENCE_NUMBER,
   X_ADM_ADM_CAL_TYPE,
   X_ADM_ADM_CI_SEQUENCE_NUMBER,
   X_ADM_ADMISSION_CAT,
   X_ADM_S_ADMISSION_PROCESS_TYPE,
   X_ENQ_ACAD_CAL_TYPE,
   X_ENQ_ACAD_CI_SEQUENCE_NUMBER,
   X_ENQ_ADM_CAL_TYPE,
   X_ENQ_ADM_CI_SEQUENCE_NUMBER,
   X_SERVER_PRINTER_DFLT,
   X_ALLOW_STND_REQ_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_PE_PERS_PREFS_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_PE_PERS_PREFS_PKG;

/
