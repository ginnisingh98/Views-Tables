--------------------------------------------------------
--  DDL for Package Body IGR_I_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_APPL_PKG" as
/* $Header: IGSRH16B.pls 120.0 2005/06/01 21:08:31 appldev noship $ */

    l_rowid VARCHAR2(25);
  old_references IGR_I_APPL_ALL%RowType;
  new_references IGR_I_APPL_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sales_lead_id IN NUMBER DEFAULT NULL,
    x_enquiry_appl_number IN NUMBER DEFAULT NULL,
    x_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_acad_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_enquiry_dt IN DATE DEFAULT NULL,
    x_registering_person_id IN NUMBER DEFAULT NULL,
    x_override_process_ind IN VARCHAR2 DEFAULT NULL,
    x_indicated_mailing_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_inq_entry_level_id IN NUMBER DEFAULT NULL,
    x_edu_goal_id IN NUMBER DEFAULT NULL,
    x_party_id IN NUMBER DEFAULT NULL,
    x_how_knowus_id IN NUMBER DEFAULT NULL,
    x_who_influenced_id IN NUMBER DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_last_process_dt IN DATE DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_pkg_reduct_ind IN VARCHAR2 DEFAULT NULL
  ) as
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGR_I_APPL_ALL
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
    new_references.person_id := x_person_id;
    new_references.sales_lead_id := x_sales_lead_id;
    new_references.enquiry_appl_number := x_enquiry_appl_number;
    new_references.acad_cal_type := x_acad_cal_type;
    new_references.acad_ci_sequence_number := x_acad_ci_sequence_number;
    new_references.adm_cal_type := x_adm_cal_type;
    new_references.adm_ci_sequence_number := x_adm_ci_sequence_number;
    new_references.enquiry_dt := TRUNC(x_enquiry_dt);
    new_references.registering_person_id := x_registering_person_id;
    new_references.override_process_ind := x_override_process_ind;
    new_references.indicated_mailing_dt := TRUNC(x_indicated_mailing_dt);
    new_references.comments := x_comments;
    new_references.inq_entry_level_id := x_inq_entry_level_id;
    new_references.edu_goal_id := x_edu_goal_id;
    new_references.party_id := x_party_id;
    new_references.how_knowus_id := x_how_knowus_id ;
    new_references.who_influenced_id := x_who_influenced_id;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.org_id := x_org_id;
    new_references.last_process_dt := TRUNC(x_last_process_dt);
    new_references.pkg_reduct_ind := NVL(x_pkg_reduct_ind,'N');
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
  -- "OSS_TST".trg_eap_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGR_I_APPL_ALL
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
    CURSOR c_birth_date(p_person_id igs_pe_person_base_v.person_id%TYPE) IS
     SELECT birth_date
     FROM   igs_pe_person_base_v
     WHERE  person_id =p_person_id ;

    CURSOR c_deceased(cp_party_id igs_pe_hz_parties.party_id%TYPE) IS
     SELECT deceased_ind
     FROM igs_pe_hz_parties
     WHERE party_id = cp_party_id;
   v_deceased_ind igs_pe_hz_parties.deceased_ind%TYPE;
   v_message_name  varchar2(30);
   l_birth_date     igs_pe_person_base_v.birth_date%TYPE;

  BEGIN
    -- Fetch the Deceased Indicator
    IF p_inserting OR p_updating THEN
          OPEN c_deceased(new_references.person_id);
      FETCH c_deceased INTO v_deceased_ind;
      CLOSE c_deceased;

      OPEN c_birth_date(new_references.person_id);
          FETCH c_birth_date INTO l_birth_date;
          CLOSE c_birth_date;

          IF ((l_birth_date IS NOT NULL) AND (l_birth_date > new_references.enquiry_dt)) THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_AD_DOB_ERROR');
            FND_MESSAGE.SET_TOKEN ('NAME',fnd_message.get_string('IGS','IGS_AD_INQ_DT'));
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;

        ELSIF p_deleting THEN
          OPEN c_deceased(old_references.person_id);
      FETCH c_deceased INTO v_deceased_ind;
      CLOSE c_deceased;
    END IF;
        -- Validate that inserts/updates/deletes are allowed if a person is deceased
        -- Validate that the person is not deceased
        IF v_deceased_ind = 'Y' THEN
           Fnd_Message.Set_Name('IGS', 'IGS_IN_DEC_NO_INQ');
       IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
    END IF;

    -- Validate that the indicated mailing date is not prior to the enquiry date.
    IF p_inserting OR
       (p_updating AND
       (new_references.enquiry_dt <> TRUNC(old_references.enquiry_dt)) OR
       (new_references.indicated_mailing_dt <> TRUNC(old_references.indicated_mailing_dt))) THEN
        IF IGR_VAL_EAP.admp_val_eap_ind_dt(new_references.enquiry_dt,
                        new_references.indicated_mailing_dt,
                        v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
              IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
        END IF;
    END IF;
  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance as

  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF    ;
    END IF;
    IF (((old_references.registering_person_id = new_references.registering_person_id)) OR
        ((new_references.registering_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.registering_person_id
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF    ;
    END IF;
    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number) AND
         (old_references.acad_cal_type = new_references.acad_cal_type) AND
         (old_references.acad_ci_sequence_number = new_references.acad_ci_sequence_number)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL) OR
         (new_references.acad_cal_type IS NULL) OR
         (new_references.acad_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_CA_INST_REL_PKG.Get_PK_For_Validation (
        new_references.adm_cal_type,
        new_references.adm_ci_sequence_number,
        new_references.acad_cal_type,
        new_references.acad_ci_sequence_number
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF    ;
    END IF;
    IF (((old_references.inq_entry_level_id = new_references.inq_entry_level_id)) OR
        ((new_references.inq_entry_level_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGR_I_ENTRY_LVLS_PKG.Get_PK_For_Validation (
        new_references.inq_entry_level_id ,
        'N'
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF    ;
    END IF;
    IF (((old_references.edu_goal_id = new_references.edu_goal_id)) OR
        ((new_references.edu_goal_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_AD_CODE_CLASSES_PKG.Get_UK2_For_Validation (
        new_references.edu_goal_id,
        'EDU_GOALS',
        'N'
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF    ;
    END IF;
    IF (((old_references.how_knowus_id = new_references.how_knowus_id)) OR
        ((new_references.how_knowus_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_AD_CODE_CLASSES_PKG.Get_UK2_For_Validation (
        new_references.how_knowus_id ,
        'INQ_HOW_KNOWUS',
        'N'
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF    ;
    END IF;
    IF (((old_references.who_influenced_id = new_references.who_influenced_id)) OR
        ((new_references.who_influenced_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_AD_CODE_CLASSES_PKG.Get_UK2_For_Validation (
        new_references.who_influenced_id,
        'INQ_WHO_INFLUENCED',
        'N'
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF    ;
    END IF;

  END Check_Parent_Existance;


PROCEDURE Check_Constraints (
Column_Name IN  VARCHAR2    DEFAULT NULL,
Column_Value    IN  VARCHAR2    DEFAULT NULL
    ) as
BEGIN
      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'ACAD_CAL_TYPE' then
         new_references.acad_cal_type:= column_value;
      ELSIF upper(Column_name) = 'ADM_CAL_TYPE' then
         new_references.adm_cal_type:= column_value;
      ELSIF upper(Column_name) = 'OVERRIDE_PROCESS_IND' then
         new_references.override_process_ind:= column_value;
      ELSIF upper(Column_name) = 'ACAD_CI_SEQUENCE_NUMBER' then
         new_references.acad_ci_sequence_number:= IGS_GE_NUMBER.to_num(column_value);
      ELSIF upper(Column_name) = 'ADM_CI_SEQUENCE_NUMBER' then
         new_references.adm_ci_sequence_number:= IGS_GE_NUMBER.to_num(column_value);


      END IF;
     IF upper(column_name) = 'ACAD_CAL_TYPE' OR
        column_name is null Then
        IF new_references.acad_cal_type <> UPPER(new_references.acad_cal_type) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'ADM_CAL_TYPE' OR
        column_name is null Then
        IF new_references.adm_cal_type <> UPPER(new_references.adm_cal_type) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'OVERRIDE_PROCESS_IND' OR
        column_name is null Then
        IF new_references.override_process_ind NOT IN ( 'Y' , 'N' )  Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'ACAD_CI_SEQUENCE_NUMBER' OR
        column_name is null Then
        IF  new_references.acad_ci_sequence_number < 1  OR  new_references.acad_ci_sequence_number > 999999 Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'ADM_CI_SEQUENCE_NUMBER' OR
        column_name is null Then
        IF  new_references.adm_ci_sequence_number < 1  AND   new_references.adm_ci_sequence_number > 999999  Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;


END Check_Constraints;

  PROCEDURE Check_Child_Existance as
  BEGIN
    IGR_I_A_CHARTYP_PKG.GET_FK_IGR_I_APPL (
      old_references.person_id,
      old_references.enquiry_appl_number
      );
    IGR_I_A_ITYPE_PKG.GET_FK_IGR_I_APPL (
      old_references.person_id,
      old_references.enquiry_appl_number
      );
    IGR_I_A_PKGITM_PKG.GET_FK_IGR_I_APPL (
      old_references.person_id,
      old_references.enquiry_appl_number
      );
    IGR_I_A_LINES_PKG.GET_FK_IGR_I_APPL (
      old_references.person_id,
      old_references.enquiry_appl_number
      );

  END Check_Child_Existance;
  FUNCTION   Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_enquiry_appl_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_APPL_ALL
      WHERE    person_id = x_person_id
      AND      enquiry_appl_number = x_enquiry_appl_number
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

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_APPL_ALL
      WHERE    person_id = x_person_id OR
               registering_person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_IN_EAP_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;
  PROCEDURE GET_FK_IGS_CA_INST_REL (
    x_sub_cal_type IN VARCHAR2,
    x_sub_ci_sequence_number IN NUMBER,
    x_sup_cal_type IN VARCHAR2,
    x_sup_ci_sequence_number IN NUMBER
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_APPL_ALL
      WHERE    adm_cal_type = x_sub_cal_type
      AND      adm_ci_sequence_number = x_sub_ci_sequence_number
      AND      acad_cal_type = x_sup_cal_type
      AND      acad_ci_sequence_number = x_sup_ci_sequence_number;

    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_IN_EAP_CIR_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST_REL;
  /*
    Code modified as part of Recruitment Build Bug #2664699
    Renamed GET_FK_IGS_AD_I_ENTRY_LVLS to GET_FK_IGR_I_ENTRY_LVLS
  */
  PROCEDURE GET_FK_IGR_I_ENTRY_LVLS (
    x_inq_entry_level_id IN NUMBER
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_APPL_ALL
      WHERE    inq_entry_level_id = x_inq_entry_level_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_IN_EAP_AIELV_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGR_I_ENTRY_LVLS;

  PROCEDURE GET_FK_IGS_AD_CODE_CLASSES (
    x_code_id IN NUMBER
    ) as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_APPL_ALL
      WHERE    edu_goal_id = x_code_id
      AND      how_knowus_id = x_code_id
      AND      who_influenced_id = x_code_id;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_IN_EAP_ADCC_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_CODE_CLASSES;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    X_sales_lead_id IN NUMBER DEFAULT NULL,
    x_enquiry_appl_number IN NUMBER DEFAULT NULL,
    x_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_acad_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_enquiry_dt IN DATE DEFAULT NULL,
    x_registering_person_id IN NUMBER DEFAULT NULL,
    x_override_process_ind IN VARCHAR2 DEFAULT NULL,
    x_indicated_mailing_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_inq_entry_level_id IN NUMBER DEFAULT NULL,
    x_edu_goal_id IN NUMBER DEFAULT NULL,
    x_party_id IN NUMBER DEFAULT NULL,
    x_how_knowus_id IN NUMBER DEFAULT NULL,
    x_who_influenced_id IN NUMBER DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_last_process_dt IN DATE DEFAULT NULL,
    X_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_pkg_reduct_ind IN VARCHAR2 DEFAULT NULL
  ) as

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      X_sales_lead_id,
      x_enquiry_appl_number,
      x_acad_cal_type,
      x_acad_ci_sequence_number,
      x_adm_cal_type,
      x_adm_ci_sequence_number,
      x_enquiry_dt,
      x_registering_person_id,
      x_override_process_ind,
      x_indicated_mailing_dt,
      x_comments,
    x_inq_entry_level_id ,
    x_edu_goal_id ,
    x_party_id ,
    x_how_knowus_id ,
    x_who_influenced_id ,
    x_attribute_category ,
    x_attribute1 ,
    x_attribute2 ,
    x_attribute3 ,
    x_attribute4 ,
    x_attribute5 ,
    x_attribute6 ,
    x_attribute7 ,
    x_attribute8 ,
    x_attribute9 ,
    x_attribute10 ,
    x_attribute11 ,
    x_attribute12 ,
    x_attribute13 ,
    x_attribute14 ,
    x_attribute15 ,
    x_attribute16 ,
    x_attribute17 ,
    x_attribute18 ,
    x_attribute19 ,
    x_attribute20 ,
      x_last_process_dt,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_pkg_reduct_ind
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
IF  Get_PK_For_Validation (
             new_references.person_id ,
             new_references.enquiry_appl_number
                         ) THEN
    Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
IF  Get_PK_For_Validation (
             new_references.person_id ,
             new_references.enquiry_appl_number
                         ) THEN
    Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END IF;
            Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
            Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
          -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdate1 ( p_deleting => TRUE );
      Check_Child_Existance;
    END IF;
  END Before_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SALES_LEAD_ID IN NUMBER,
  X_ENQUIRY_APPL_NUMBER OUT NOCOPY NUMBER,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENQUIRY_DT in DATE,
  X_REGISTERING_PERSON_ID in NUMBER,
  X_OVERRIDE_PROCESS_IND in VARCHAR2,
  X_INDICATED_MAILING_DT in DATE,
  X_LAST_PROCESS_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_INQ_ENTRY_LEVEL_ID in NUMBER DEFAULT NULL,
  X_EDU_GOAL_ID in NUMBER DEFAULT NULL,
  X_PARTY_ID in NUMBER DEFAULT NULL,
  X_HOW_KNOWUS_ID in NUMBER DEFAULT NULL,
  X_WHO_INFLUENCED_ID in NUMBER DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_PKG_REDUCT_IND IN VARCHAR2 DEFAULT NULL
  ) as
    cursor C is select ROWID from IGR_I_APPL_ALL
      where PERSON_ID = X_PERSON_ID
      and ENQUIRY_APPL_NUMBER = X_ENQUIRY_APPL_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := NULL;
     X_PROGRAM_ID := NULL;
     X_PROGRAM_APPLICATION_ID := NULL;
     X_PROGRAM_UPDATE_DATE := NULL;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  X_ENQUIRY_APPL_NUMBER := NULL;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_acad_cal_type=>X_ACAD_CAL_TYPE,
 x_acad_ci_sequence_number=>X_ACAD_CI_SEQUENCE_NUMBER,
 x_adm_cal_type=>X_ADM_CAL_TYPE,
 x_adm_ci_sequence_number=>X_ADM_CI_SEQUENCE_NUMBER,
 x_comments=>X_COMMENTS,
 x_inq_entry_level_id=>X_INQ_ENTRY_LEVEL_ID,
 x_edu_goal_id=>X_EDU_GOAL_ID,
 x_party_id=>X_PARTY_ID,
 x_how_knowus_id=>X_HOW_KNOWUS_ID,
 x_who_influenced_id=>X_WHO_INFLUENCED_ID,
 x_attribute_category=>X_ATTRIBUTE_CATEGORY,
 x_attribute1=>X_ATTRIBUTE1,
 x_attribute2=>X_ATTRIBUTE2,
 x_attribute3=>X_ATTRIBUTE3,
 x_attribute4=>X_ATTRIBUTE4,
 x_attribute5=>X_ATTRIBUTE5,
 x_attribute6=> X_ATTRIBUTE6,
 x_attribute7=>X_ATTRIBUTE7,
 x_attribute8=>X_ATTRIBUTE8,
 x_attribute9=>X_ATTRIBUTE9,
 x_attribute10=>X_ATTRIBUTE10,
 x_attribute11=>X_ATTRIBUTE11,
 x_attribute12=>X_ATTRIBUTE12,
 x_attribute13=>X_ATTRIBUTE13,
 x_attribute14=>X_ATTRIBUTE14,
 x_attribute15=>X_ATTRIBUTE15,
 x_attribute16=>X_ATTRIBUTE16,
 x_attribute17=>X_ATTRIBUTE17,
 x_attribute18=>X_ATTRIBUTE18,
 x_attribute19=>X_ATTRIBUTE19,
 x_attribute20=>X_ATTRIBUTE20,
 x_enquiry_appl_number=>X_ENQUIRY_APPL_NUMBER,
 x_enquiry_dt=>NVL(X_ENQUIRY_DT, SYSDATE),
 x_indicated_mailing_dt=>X_INDICATED_MAILING_DT,
 x_last_process_dt=>X_LAST_PROCESS_DT,
 x_override_process_ind=>NVL(X_OVERRIDE_PROCESS_IND,'N'),
 x_person_id=>X_PERSON_ID,
 x_sales_lead_id => X_sales_lead_id,
 x_registering_person_id=>X_REGISTERING_PERSON_ID,
 x_org_id => igs_ge_gen_003.get_org_id,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_pkg_reduct_ind => X_PKG_REDUCT_IND
);
  insert into IGR_I_APPL_ALL (
    PERSON_ID,
    ENQUIRY_APPL_NUMBER,
    SALES_LEAD_ID,
    ACAD_CAL_TYPE,
    ACAD_CI_SEQUENCE_NUMBER,
    ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER,
    ENQUIRY_DT,
    REGISTERING_PERSON_ID,
    OVERRIDE_PROCESS_IND,
    INDICATED_MAILING_DT,
    LAST_PROCESS_DT,
    COMMENTS,
  INQ_ENTRY_LEVEL_ID,
  EDU_GOAL_ID,
  PARTY_ID,
  HOW_KNOWUS_ID,
  WHO_INFLUENCED_ID,
  ATTRIBUTE_CATEGORY,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  ATTRIBUTE16,
  ATTRIBUTE17,
  ATTRIBUTE18,
  ATTRIBUTE19,
  ATTRIBUTE20,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    PKG_REDUCT_IND
  ) values (
    NEW_REFERENCES.PERSON_ID,
    IGR_I_APPL_S.NEXTVAL,
    NEW_REFERENCES.SALES_LEAD_ID,
    NEW_REFERENCES.ACAD_CAL_TYPE,
    NEW_REFERENCES.ACAD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADM_CAL_TYPE,
    NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
   NEW_REFERENCES.ENQUIRY_DT,
    NEW_REFERENCES.REGISTERING_PERSON_ID,
    NEW_REFERENCES.OVERRIDE_PROCESS_IND,
    NEW_REFERENCES.INDICATED_MAILING_DT,
    NEW_REFERENCES.LAST_PROCESS_DT,
    NEW_REFERENCES.COMMENTS,
  NEW_REFERENCES.INQ_ENTRY_LEVEL_ID,
  NEW_REFERENCES.EDU_GOAL_ID,
  NEW_REFERENCES.PARTY_ID,
  NEW_REFERENCES.HOW_KNOWUS_ID,
  NEW_REFERENCES.WHO_INFLUENCED_ID,
  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
  NEW_REFERENCES.ATTRIBUTE1,
  NEW_REFERENCES.ATTRIBUTE2,
  NEW_REFERENCES.ATTRIBUTE3,
  NEW_REFERENCES.ATTRIBUTE4,
  NEW_REFERENCES.ATTRIBUTE5,
  NEW_REFERENCES.ATTRIBUTE6,
  NEW_REFERENCES.ATTRIBUTE7,
  NEW_REFERENCES.ATTRIBUTE8,
  NEW_REFERENCES.ATTRIBUTE9,
  NEW_REFERENCES.ATTRIBUTE10,
  NEW_REFERENCES.ATTRIBUTE11,
  NEW_REFERENCES.ATTRIBUTE12,
  NEW_REFERENCES.ATTRIBUTE13,
  NEW_REFERENCES.ATTRIBUTE14,
  NEW_REFERENCES.ATTRIBUTE15,
  NEW_REFERENCES.ATTRIBUTE16,
  NEW_REFERENCES.ATTRIBUTE17,
  NEW_REFERENCES.ATTRIBUTE18,
  NEW_REFERENCES.ATTRIBUTE19,
  NEW_REFERENCES.ATTRIBUTE20,
    NEW_REFERENCES.ORG_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.PKG_REDUCT_IND
  )RETURNING ENQUIRY_APPL_NUMBER INTO X_ENQUIRY_APPL_NUMBER;
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
  X_PERSON_ID in NUMBER,
  X_SALES_LEAD_ID IN NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENQUIRY_DT in DATE,
  X_REGISTERING_PERSON_ID in NUMBER,
  X_OVERRIDE_PROCESS_IND in VARCHAR2,
  X_INDICATED_MAILING_DT in DATE,
  X_LAST_PROCESS_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_INQ_ENTRY_LEVEL_ID in NUMBER DEFAULT NULL,
  X_EDU_GOAL_ID in NUMBER DEFAULT NULL,
  X_PARTY_ID in NUMBER DEFAULT NULL,
  X_HOW_KNOWUS_ID in NUMBER DEFAULT NULL,
  X_WHO_INFLUENCED_ID in NUMBER DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_PKG_REDUCT_IND IN VARCHAR2 DEFAULT NULL
) as
  cursor c1 is select
      ACAD_CAL_TYPE,
      ACAD_CI_SEQUENCE_NUMBER,
      ADM_CAL_TYPE,
      ADM_CI_SEQUENCE_NUMBER,
      ENQUIRY_DT,
      REGISTERING_PERSON_ID,
      OVERRIDE_PROCESS_IND,
      INDICATED_MAILING_DT,
      LAST_PROCESS_DT,
      COMMENTS,
  INQ_ENTRY_LEVEL_ID,
  EDU_GOAL_ID,
  PARTY_ID,
  HOW_KNOWUS_ID,
  WHO_INFLUENCED_ID,
  ATTRIBUTE_CATEGORY,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  ATTRIBUTE16,
  ATTRIBUTE17,
  ATTRIBUTE18,
  ATTRIBUTE19,
  ATTRIBUTE20,
  PKG_REDUCT_IND
    from IGR_I_APPL_ALL
    where ROWID = X_ROWID
    for update nowait;
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

    if (
      ((tlinfo.ACAD_CAL_TYPE = X_ACAD_CAL_TYPE) OR ((tlinfo.ACAD_CAL_TYPE is null) AND (X_ACAD_CAL_TYPE is null)))
      AND ((tlinfo.ACAD_CI_SEQUENCE_NUMBER = X_ACAD_CI_SEQUENCE_NUMBER) OR ((tlinfo.ACAD_CI_SEQUENCE_NUMBER is null) AND (X_ACAD_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ADM_CAL_TYPE = X_ADM_CAL_TYPE) OR ((tlinfo.ADM_CAL_TYPE is null) AND (X_ADM_CAL_TYPE is null)))
      AND ((tlinfo.ADM_CI_SEQUENCE_NUMBER = X_ADM_CI_SEQUENCE_NUMBER) OR ((tlinfo.ADM_CI_SEQUENCE_NUMBER is null) AND (X_ADM_CI_SEQUENCE_NUMBER is null)))
      AND (TRUNC(tlinfo.ENQUIRY_DT) = TRUNC(X_ENQUIRY_DT))
      AND ((tlinfo.REGISTERING_PERSON_ID = X_REGISTERING_PERSON_ID) OR ((tlinfo.REGISTERING_PERSON_ID is null) AND (X_REGISTERING_PERSON_ID is null)))
      AND (tlinfo.OVERRIDE_PROCESS_IND = X_OVERRIDE_PROCESS_IND)
      AND ((TRUNC(tlinfo.INDICATED_MAILING_DT) = TRUNC(X_INDICATED_MAILING_DT)) OR ((tlinfo.INDICATED_MAILING_DT is null) AND (X_INDICATED_MAILING_DT is null)))
      AND ((TRUNC(tlinfo.LAST_PROCESS_DT) = TRUNC(X_LAST_PROCESS_DT)) OR ((tlinfo.LAST_PROCESS_DT is null) AND (X_LAST_PROCESS_DT is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS) OR ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null)))
      AND ((tlinfo.INQ_ENTRY_LEVEL_ID = X_INQ_ENTRY_LEVEL_ID) OR ((tlinfo.INQ_ENTRY_LEVEL_ID is null) AND (X_INQ_ENTRY_LEVEL_ID is null)))
      AND ((tlinfo.EDU_GOAL_ID = X_EDU_GOAL_ID) OR ((tlinfo.EDU_GOAL_ID is null) AND (X_EDU_GOAL_ID is null)))
      AND ((tlinfo.PARTY_ID = X_PARTY_ID) OR ((tlinfo.PARTY_ID is null) AND (X_PARTY_ID is null)))
      AND ((tlinfo.HOW_KNOWUS_ID = X_HOW_KNOWUS_ID) OR ((tlinfo.HOW_KNOWUS_ID is null) AND (X_HOW_KNOWUS_ID is null)))
      AND ((tlinfo.WHO_INFLUENCED_ID = X_WHO_INFLUENCED_ID) OR ((tlinfo.WHO_INFLUENCED_ID is null) AND (X_WHO_INFLUENCED_ID is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY) OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1) OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2) OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3) OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4) OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5) OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6) OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7) OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8) OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9) OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10) OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11) OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12) OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13) OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14) OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15) OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16) OR ((tlinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
      AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17) OR ((tlinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
      AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18) OR ((tlinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
      AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19) OR ((tlinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
      AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20) OR ((tlinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))
      AND ((tlinfo.PKG_REDUCT_IND = X_PKG_REDUCT_IND) OR ((tlinfo.PKG_REDUCT_IND is null) AND (X_PKG_REDUCT_IND is null)))
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
  X_SALES_LEAD_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENQUIRY_DT in DATE,
  X_REGISTERING_PERSON_ID in NUMBER,
  X_OVERRIDE_PROCESS_IND in VARCHAR2,
  X_INDICATED_MAILING_DT in DATE,
  X_LAST_PROCESS_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_INQ_ENTRY_LEVEL_ID in NUMBER DEFAULT NULL,
  X_EDU_GOAL_ID in NUMBER DEFAULT NULL,
  X_PARTY_ID in NUMBER DEFAULT NULL,
  X_HOW_KNOWUS_ID in NUMBER DEFAULT NULL,
  X_WHO_INFLUENCED_ID in NUMBER DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  X_PKG_REDUCT_IND IN VARCHAR2 DEFAULT NULL
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
 x_acad_cal_type=>X_ACAD_CAL_TYPE,
 x_acad_ci_sequence_number=>X_ACAD_CI_SEQUENCE_NUMBER,
 x_adm_cal_type=>X_ADM_CAL_TYPE,
 x_adm_ci_sequence_number=>X_ADM_CI_SEQUENCE_NUMBER,
 x_comments=>X_COMMENTS,
 x_inq_entry_level_id=>X_INQ_ENTRY_LEVEL_ID,
 x_edu_goal_id=>X_EDU_GOAL_ID,
 x_party_id=>X_PARTY_ID,
 x_how_knowus_id=>X_HOW_KNOWUS_ID,
 x_who_influenced_id=>X_WHO_INFLUENCED_ID,
 x_attribute_category=>X_ATTRIBUTE_CATEGORY,
 x_attribute1=>X_ATTRIBUTE1,
 x_attribute2=>X_ATTRIBUTE2,
 x_attribute3=>X_ATTRIBUTE3,
 x_attribute4=>X_ATTRIBUTE4,
 x_attribute5=>X_ATTRIBUTE5,
 x_attribute6=>X_ATTRIBUTE6,
 x_attribute7=>X_ATTRIBUTE7,
 x_attribute8=>X_ATTRIBUTE8,
 x_attribute9=>X_ATTRIBUTE9,
 x_attribute10=>X_ATTRIBUTE10,
 x_attribute11=>X_ATTRIBUTE11,
 x_attribute12=>X_ATTRIBUTE12,
 x_attribute13=>X_ATTRIBUTE13,
 x_attribute14=>X_ATTRIBUTE14,
 x_attribute15=>X_ATTRIBUTE15,
 x_attribute16=>X_ATTRIBUTE16,
 x_attribute17=>X_ATTRIBUTE17,
 x_attribute18=>X_ATTRIBUTE18,
 x_attribute19=>X_ATTRIBUTE19,
 x_attribute20=>X_ATTRIBUTE20,
 x_enquiry_appl_number=>X_ENQUIRY_APPL_NUMBER,
 x_enquiry_dt=>X_ENQUIRY_DT,
 x_indicated_mailing_dt=>X_INDICATED_MAILING_DT,
 x_last_process_dt=>X_LAST_PROCESS_DT,
 x_override_process_ind=>X_OVERRIDE_PROCESS_IND,
 x_person_id=>X_PERSON_ID,
 X_sales_lead_id => X_sales_lead_id,
 x_registering_person_id=>X_REGISTERING_PERSON_ID,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_pkg_reduct_ind => X_PKG_REDUCT_IND
);
 if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID :=
                OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE :=
                  OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
end if;
  update IGR_I_APPL_ALL set
    ACAD_CAL_TYPE = NEW_REFERENCES.ACAD_CAL_TYPE,
    ACAD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.ACAD_CI_SEQUENCE_NUMBER,
    ADM_CAL_TYPE = NEW_REFERENCES.ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER = NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
    ENQUIRY_DT = NEW_REFERENCES.ENQUIRY_DT,
    REGISTERING_PERSON_ID = NEW_REFERENCES.REGISTERING_PERSON_ID,
    OVERRIDE_PROCESS_IND = NEW_REFERENCES.OVERRIDE_PROCESS_IND,
    INDICATED_MAILING_DT = NEW_REFERENCES.INDICATED_MAILING_DT,
    LAST_PROCESS_DT = NEW_REFERENCES.LAST_PROCESS_DT,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    INQ_ENTRY_LEVEL_ID=NEW_REFERENCES.INQ_ENTRY_LEVEL_ID,
    EDU_GOAL_ID=NEW_REFERENCES.EDU_GOAL_ID,
    PARTY_ID=NEW_REFERENCES.PARTY_ID,
    HOW_KNOWUS_ID=NEW_REFERENCES.HOW_KNOWUS_ID,
    WHO_INFLUENCED_ID=NEW_REFERENCES.WHO_INFLUENCED_ID,
    ATTRIBUTE_CATEGORY=NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1=NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2=NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3=NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4=NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5=NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6=NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7=NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8=NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9=NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10=NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11=NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12=NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13=NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14=NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15=NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16=NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17=NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18=NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19=NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20=NEW_REFERENCES.ATTRIBUTE20,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    PKG_REDUCT_IND = X_PKG_REDUCT_IND
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_SALES_LEAD_ID in NUMBER,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENQUIRY_DT in DATE,
  X_REGISTERING_PERSON_ID in NUMBER,
  X_OVERRIDE_PROCESS_IND in VARCHAR2,
  X_INDICATED_MAILING_DT in DATE,
  X_LAST_PROCESS_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_INQ_ENTRY_LEVEL_ID in NUMBER DEFAULT NULL,
  X_EDU_GOAL_ID in NUMBER DEFAULT NULL,
  X_PARTY_ID in NUMBER DEFAULT NULL,
  X_HOW_KNOWUS_ID in NUMBER DEFAULT NULL,
  X_WHO_INFLUENCED_ID in NUMBER DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19 IN VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20 IN VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_PKG_REDUCT_IND IN VARCHAR2 DEFAULT NULL
  ) as
  cursor c1 is select rowid from IGR_I_APPL_ALL
     where PERSON_ID = X_PERSON_ID
     and ENQUIRY_APPL_NUMBER = X_ENQUIRY_APPL_NUMBER  ;
  l_sales_lead_id     IGR_I_APPL_ALL.sales_lead_id%TYPE;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
  X_ROWID,
  X_PERSON_ID,
  X_ENQUIRY_APPL_NUMBER,
  l_sales_lead_id,
  X_ACAD_CAL_TYPE,
  X_ACAD_CI_SEQUENCE_NUMBER,
  X_ADM_CAL_TYPE,
  X_ADM_CI_SEQUENCE_NUMBER,
  X_ENQUIRY_DT,
  X_REGISTERING_PERSON_ID,
  X_OVERRIDE_PROCESS_IND,
  X_INDICATED_MAILING_DT,
  X_LAST_PROCESS_DT,
  X_COMMENTS,
  X_INQ_ENTRY_LEVEL_ID,
  X_EDU_GOAL_ID,
  X_PARTY_ID,
  X_HOW_KNOWUS_ID,
  X_WHO_INFLUENCED_ID,
  X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1,
  X_ATTRIBUTE2,
  X_ATTRIBUTE3,
  X_ATTRIBUTE4,
  X_ATTRIBUTE5,
  X_ATTRIBUTE6,
  X_ATTRIBUTE7,
  X_ATTRIBUTE8,
  X_ATTRIBUTE9,
  X_ATTRIBUTE10,
  X_ATTRIBUTE11,
  X_ATTRIBUTE12,
  X_ATTRIBUTE13,
  X_ATTRIBUTE14,
  X_ATTRIBUTE15,
  X_ATTRIBUTE16,
  X_ATTRIBUTE17,
  X_ATTRIBUTE18,
  X_ATTRIBUTE19,
  X_ATTRIBUTE20,
     X_MODE,
     X_ORG_ID,
     X_PKG_REDUCT_IND);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ENQUIRY_APPL_NUMBER,
   X_SALES_LEAD_ID,
   X_ACAD_CAL_TYPE,
   X_ACAD_CI_SEQUENCE_NUMBER,
   X_ADM_CAL_TYPE,
   X_ADM_CI_SEQUENCE_NUMBER,
   X_ENQUIRY_DT,
   X_REGISTERING_PERSON_ID,
   X_OVERRIDE_PROCESS_IND,
   X_INDICATED_MAILING_DT,
   X_LAST_PROCESS_DT,
   X_COMMENTS,
  X_INQ_ENTRY_LEVEL_ID,
  X_EDU_GOAL_ID,
  X_PARTY_ID,
  X_HOW_KNOWUS_ID,
  X_WHO_INFLUENCED_ID,
  X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1,
  X_ATTRIBUTE2,
  X_ATTRIBUTE3,
  X_ATTRIBUTE4,
  X_ATTRIBUTE5,
  X_ATTRIBUTE6,
  X_ATTRIBUTE7,
  X_ATTRIBUTE8,
  X_ATTRIBUTE9,
  X_ATTRIBUTE10,
  X_ATTRIBUTE11,
  X_ATTRIBUTE12,
  X_ATTRIBUTE13,
  X_ATTRIBUTE14,
  X_ATTRIBUTE15,
  X_ATTRIBUTE16,
  X_ATTRIBUTE17,
  X_ATTRIBUTE18,
  X_ATTRIBUTE19,
  X_ATTRIBUTE20,
   X_MODE,
   X_PKG_REDUCT_IND);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGR_I_APPL_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGR_I_APPL_PKG;

/
