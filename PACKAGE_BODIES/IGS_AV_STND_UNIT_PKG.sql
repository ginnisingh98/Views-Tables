--------------------------------------------------------
--  DDL for Package Body IGS_AV_STND_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_STND_UNIT_PKG" AS
/* $Header: IGSBI04B.pls 120.0 2005/07/05 12:12:01 appldev noship $ */
  --msrinivi    24-AUG-2001     Bug No. 1956374 .Repointed genp_val_prsn_id
l_rowid VARCHAR2(25);
  old_references IGS_AV_STND_UNIT_ALL%RowType;
  new_references IGS_AV_STND_UNIT_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_as_course_cd IN VARCHAR2 DEFAULT NULL,
    x_as_version_number IN NUMBER DEFAULT NULL,
    x_s_adv_stnd_type IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_s_adv_stnd_granting_status IN VARCHAR2 DEFAULT NULL,
    x_credit_percentage IN NUMBER DEFAULT NULL,
    x_s_adv_stnd_recognition_type IN VARCHAR2 DEFAULT NULL,
    x_approved_dt IN DATE DEFAULT NULL,
    x_authorising_person_id IN NUMBER DEFAULT NULL,
    x_crs_group_ind IN VARCHAR2 DEFAULT NULL,
    x_exemption_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_granted_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_cancelled_dt IN DATE DEFAULT NULL,
    x_revoked_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    X_AV_STND_UNIT_ID     IN NUMBER DEFAULT NULL,
    X_CAL_TYPE            IN VARCHAR2 DEFAULT NULL,
    X_CI_SEQUENCE_NUMBER  IN NUMBER DEFAULT NULL,
    X_INSTITUTION_CD      IN VARCHAR2 DEFAULT NULL,
    X_UNIT_DETAILS_ID     in NUMBER DEFAULT NULL,
    X_TST_RSLT_DTLS_ID    in NUMBER DEFAULT NULL,
    X_GRADING_SCHEMA_CD   In VARCHAR2 DEFAULT NULL,
    X_GRD_SCH_VERSION_NUMBER IN NUMBER DEFAULT NULL,
    X_GRADE               IN VARCHAR2 DEFAULT NULL,
    X_ACHIEVABLE_CREDIT_POINTS IN  NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id in NUMBER,
    X_DEG_AUD_DETAIL_ID    IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      Igs_Ge_Msg_Stack.Add;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.as_course_cd := x_as_course_cd;
    new_references.as_version_number := x_as_version_number;
    new_references.s_adv_stnd_type := x_s_adv_stnd_type;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.s_adv_stnd_granting_status := x_s_adv_stnd_granting_status;
    new_references.s_adv_stnd_recognition_type := x_s_adv_stnd_recognition_type;
    new_references.approved_dt := x_approved_dt;
    new_references.authorising_person_id := x_authorising_person_id;
    new_references.crs_group_ind := x_crs_group_ind;
    new_references.exemption_institution_cd := x_exemption_institution_cd;
    new_references.granted_dt := x_granted_dt;
    new_references.expiry_dt := x_expiry_dt;
    new_references.cancelled_dt := x_cancelled_dt;
    new_references.revoked_dt := x_revoked_dt;
    new_references.comments := x_comments;
    new_references.AV_STND_UNIT_ID := X_AV_STND_UNIT_ID;
    new_references.CAL_TYPE := x_CAL_TYPE;
    new_references.CI_SEQUENCE_NUMBER := x_CI_SEQUENCE_NUMBER;
    new_references.INSTITUTION_CD := x_INSTITUTION_CD;
    new_references.UNIT_DETAILS_ID := x_UNIT_DETAILS_ID;
    new_references.TST_RSLT_DTLS_ID := x_TST_RSLT_DTLS_ID;

    new_references.GRADING_SCHEMA_CD := x_GRADING_SCHEMA_CD;
    new_references.GRD_SCH_VERSION_NUMBER := x_GRD_SCH_VERSION_NUMBER;
    new_references.GRADE := x_GRADE;
    new_references.ACHIEVABLE_CREDIT_POINTS := x_ACHIEVABLE_CREDIT_POINTS;

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
    new_references.org_id := x_org_id;
    new_references.DEG_AUD_DETAIL_ID    := x_DEG_AUD_DETAIL_ID;

  END Set_Column_Values;

  -- Trigger description :-
  -- "OSS_TST".trg_asu_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_AV_STND_UNIT_ALL
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE,
    p_adv_stnd_trans IN VARCHAR2 DEFAULT 'N'  -- This parameter has been added for Career Impact DLD.
    ) AS
  v_message_name    VARCHAR2(30);
  v_return_val      igs_pe_std_todo.sequence_number%TYPE;
  v_Person_id       igs_av_stnd_unit_all.person_id%TYPE;
  v_course_cd       igs_av_stnd_unit_all.as_course_cd%TYPE;
  v_version_number  igs_av_stnd_unit_all.as_version_number%TYPE;
  v_exemption_institution_cd igs_av_stnd_unit_all.exemption_institution_cd%TYPE;
  BEGIN
  -- Validate conditions on insert (these apply to the trigger only).
  IF p_inserting THEN
    IF new_references.s_adv_stnd_type <> 'UNIT' THEN
      Fnd_Message.Set_Name('IGS','IGS_AV_TYPE_MUSTBE_UNIT');
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
    IF (new_references.s_adv_stnd_granting_status <> 'APPROVED' AND
        p_adv_stnd_trans = 'N') THEN
      Fnd_Message.Set_Name('IGS','IGS_AV_STATUS_MUSTBE_APPROVED');
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  -- Validate that the advanced standing recognition type is open.
  IF p_inserting OR
     (p_updating AND (new_references.s_adv_stnd_recognition_type <>
      old_references.s_adv_stnd_recognition_type)) THEN
    IF igs_av_val_asu.advp_val_asrt_closed (
         new_references.s_adv_stnd_recognition_type,
         v_message_name
       ) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  -- Validate Advanced Standing Unit Approved Date
  IF (new_references.approved_dt IS NOT NULL) AND
    (p_inserting OR
    (NVL(old_references.approved_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
      new_references.approved_dt)) THEN
    IF igs_av_val_asu.advp_val_as_dates (
         new_references.approved_dt,
         'APPROVED',
         v_message_name,
         p_adv_stnd_trans
       ) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  -- On update, the granting status cannot be set to 'Granted' from anything
  -- other than 'Approved'/'Transferred'.
  IF p_updating AND
     (new_references.s_adv_stnd_granting_status = 'GRANTED') AND
     (old_references.s_adv_stnd_granting_status <> new_references.s_adv_stnd_granting_status) THEN
    IF old_references.s_adv_stnd_granting_status = 'REVOKED' THEN
      Fnd_Message.Set_Name('IGS','IGS_AV_CHG_REVOKED_APPROVED');
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    ELSIF old_references.s_adv_stnd_granting_status = 'CANCELLED' THEN
      Fnd_Message.Set_Name('IGS', 'IGS_AV_CHG_CANCELLED_APPROVED');
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    ELSIF old_references.s_adv_stnd_granting_status = 'EXPIRED' THEN
      Fnd_Message.Set_Name('IGS', 'IGS_AV_CHG_EXPIRED_APPROVED');
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  -- Validate Advanced Standing Unit Granted Date
  IF (new_references.granted_dt IS NOT NULL) AND
     (p_inserting OR
     (NVL(old_references.granted_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
      new_references.granted_dt)) THEN
    IF igs_av_val_asu.advp_val_as_dates (
         new_references.granted_dt,
         'GRANTED',
         v_message_name,
         p_adv_stnd_trans
       ) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  -- Validate expiry date is greater than current date and approved date.
  IF (new_references.expiry_dt IS NOT NULL) AND
     (p_inserting OR
     (NVL(old_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
       new_references.expiry_dt)) THEN
    IF igs_av_val_asu.advp_val_expiry_dt (
         new_references.expiry_dt,
         v_message_name,
         p_adv_stnd_trans
       ) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  -- Validate Advanced Standing Unit Cancelled Date
  IF (new_references.cancelled_dt IS NOT NULL) AND
     (p_inserting OR
     (NVL(old_references.cancelled_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
      new_references.cancelled_dt)) THEN
    IF igs_av_val_asu.advp_val_as_dates (
         new_references.cancelled_dt,
         'CANCELLED',
         v_message_name
       ) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
    IF igs_av_val_asu.advp_val_as_aprvd_dt (
         new_references.approved_dt,
         new_references.cancelled_dt,
         v_message_name
       ) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  -- Validate Advanced Standing Unit Revoked Date
  IF (new_references.revoked_dt IS NOT NULL) AND
     (p_inserting OR
     (NVL(old_references.revoked_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
      new_references.revoked_dt)) THEN
    IF igs_av_val_asu.advp_val_as_dates (
         new_references.revoked_dt,
         'REVOKED',
         v_message_name
       ) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
    IF igs_av_val_asu.advp_val_as_aprvd_dt (
         new_references.approved_dt,
         new_references.revoked_dt,
         v_message_name
       ) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  -- Validate that related date is set for the granting status.
  IF p_inserting OR (p_updating AND (new_references.s_adv_stnd_granting_status <>
      old_references.s_adv_stnd_granting_status)) THEN
    IF new_references.s_adv_stnd_granting_status = 'GRANTED' THEN
      IF igs_av_val_asu.advp_val_status_dts (
           'GRANTED',
           new_references.granted_dt,
           v_message_name,
           p_adv_stnd_trans
         ) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    ELSIF new_references.s_adv_stnd_granting_status = 'REVOKED' THEN
      IF igs_av_val_asu.advp_val_status_dts (
           'REVOKED',
           new_references.revoked_dt,
           v_message_name
         ) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    ELSIF new_references.s_adv_stnd_granting_status = 'CANCELLED' THEN
      IF igs_av_val_asu.advp_val_status_dts (
           'CANCELLED',
           new_references.cancelled_dt,
           v_message_name
         ) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    ELSIF new_references.s_adv_stnd_granting_status = 'EXPIRED' THEN
      IF igs_av_val_asu.advp_val_status_dts (
           'EXPIRED',
           new_references.expiry_dt,
           v_message_name
         ) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    ELSIF new_references.s_adv_stnd_granting_status = 'APPROVED' THEN
      IF igs_av_val_asu.advp_val_status_dts (
           'APPROVED',
           new_references.approved_dt,
           v_message_name,
           p_adv_stnd_trans
         ) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END IF;
  -- Validate Advanced Standing Unit Authorising Person Id.
  -- Validate that the authorising person_id is valid and is a staff member.
  -- Ignore the validation during Program Transfer
  IF (p_adv_stnd_trans = 'N') THEN
    IF p_inserting OR
       (p_updating AND (new_references.authorising_person_id <> old_references.authorising_person_id)) THEN
      IF igs_co_val_oc.genp_val_prsn_id (
           new_references.authorising_person_id,
           v_message_name) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
      IF igs_ad_val_acai.genp_val_staff_prsn (
           new_references.authorising_person_id,
           v_message_name) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END IF;
  IF p_updating AND ((new_references.s_adv_stnd_granting_status <>
      old_references.s_adv_stnd_granting_status) and
      (new_references.s_adv_stnd_granting_status = 'GRANTED'))
      THEN
    -- Validate that person is not encumbered when granting.
    IF igs_en_val_encmb.enrp_val_excld_prsn (
         new_references.person_id,
         new_references.as_course_cd,
         new_references.granted_dt,
         v_message_name) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  -- Validate that exemption institution code is valid.
  IF p_inserting OR (p_updating AND (new_references.exemption_institution_cd <>
      old_references.exemption_institution_cd)) THEN
    IF igs_av_val_asu.advp_val_asu_inst (
         new_references.exemption_institution_cd,
         v_message_name) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      Igs_Ge_Msg_Stack.Add;
      App_Exception.Raise_Exception;
    END IF;
  END IF;
  IF p_inserting OR p_updating THEN
    v_Person_id     :=  new_references.person_id;
    v_course_cd     :=  new_references.as_course_cd;
    v_version_number    :=  new_references.as_version_number;
  ELSE
    v_Person_id     :=  old_references.person_id;
    v_course_cd     :=  old_references.as_course_cd;
    v_version_number    :=  old_references.as_version_number;
  END IF;
  -- Just one call is made to validation as the variables are set appropriately
  IF igs_av_gen_001.advp_upd_as_totals (
       v_person_id,
       v_course_cd,
       v_version_number,
       v_message_name,
       v_exemption_institution_cd) = FALSE THEN
    Fnd_Message.Set_Name('IGS', v_message_name);
    Igs_Ge_Msg_Stack.Add;
    App_Exception.Raise_Exception;
  END IF;
  -- Insert todo entry for re-checking of unit rules if a granted unit has has
  -- been altered in a way which could affect the outcome of a unit rule.
  --
  -- If inserting a record which is CREDIT, 100% and GRANTED then insert
  -- the todo entry.
  IF p_inserting AND
      (new_references.s_adv_stnd_recognition_type = 'CREDIT' and
       new_references.s_adv_stnd_granting_status = 'GRANTED') THEN
    v_return_val := igs_ge_gen_003.genp_ins_stdnt_todo(
                      new_references.person_id,
                      'UNIT-RULES',
                      NULL);
  END IF;
  --
  -- If updating and either the recognition type, credit or granting status have
  -- been altered AND either the old or new record is CREDIT, 100% and GRANTED
  -- the insert the todo entry.
  IF p_updating AND
      (old_references.s_adv_stnd_recognition_type <> new_references.s_adv_stnd_recognition_type OR
       old_references.s_adv_stnd_granting_status <> new_references.s_adv_stnd_granting_status) AND
      ((old_references.s_adv_stnd_recognition_type = 'CREDIT' AND
         old_references.s_adv_stnd_granting_status = 'GRANTED') OR
        (new_references.s_adv_stnd_recognition_type = 'CREDIT' AND
         new_references.s_adv_stnd_granting_status = 'GRANTED')) THEN
    v_return_val := igs_ge_gen_003.genp_ins_stdnt_todo (
                      new_references.person_id,
                      'UNIT-RULES',
                      NULL,
                      'Y');
  END IF;
  --
  -- If deleting a record which is CREDIT, 100% and GRANTED then insert
  -- the todo entry.
  IF p_deleting AND
      (old_references.s_adv_stnd_recognition_type = 'CREDIT' AND
       old_references.s_adv_stnd_granting_status = 'GRANTED') THEN
    v_return_val := igs_ge_gen_003.genp_ins_stdnt_todo(old_references.person_id,
                      'UNIT-RULES',
                      NULL,
                      'Y');
  END IF;
  -- Process any advanced standing to do records
  IF p_inserting THEN
    igs_pr_gen_003.igs_pr_ins_adv_todo (
      new_references.person_id,
      new_references.as_course_cd,
      new_references.as_version_number,
      new_references.s_adv_stnd_recognition_type,
      new_references.s_adv_stnd_recognition_type,
      new_references.s_adv_stnd_granting_status,
      new_references.s_adv_stnd_granting_status,
      new_references.achievable_credit_points,
      new_references.achievable_credit_points,
      NULL,
      NULL
    );
  ELSIF p_updating THEN
    igs_pr_gen_003.igs_pr_ins_adv_todo (
      new_references.person_id,
      new_references.as_course_cd,
      new_references.as_version_number,
      old_references.s_adv_stnd_recognition_type,
      new_references.s_adv_stnd_recognition_type,
      old_references.s_adv_stnd_granting_status,
      new_references.s_adv_stnd_granting_status,
      old_references.achievable_credit_points,
      new_references.achievable_credit_points,
      NULL,
      NULL
    );
  ELSIF p_deleting THEN
    igs_pr_gen_003.igs_pr_ins_adv_todo (
      old_references.person_id,
      old_references.as_course_cd,
      old_references.as_version_number,
      old_references.s_adv_stnd_recognition_type,
      old_references.s_adv_stnd_recognition_type,
      old_references.s_adv_stnd_granting_status,
      old_references.s_adv_stnd_granting_status,
      old_references.achievable_credit_points,
      old_references.achievable_credit_points,
      NULL,
      NULL
    );
  END IF;
  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_asu_ar_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_AV_STND_UNIT_ALL
  -- FOR EACH ROW
  -- Trigger description :-
  -- "OSS_TST".trg_asu_as_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_AV_STND_UNIT_ALL
  PROCEDURE AfterRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  v_message_name  varchar2(30);
  BEGIN
  -- If trigger has not been disabled, perform required processing
          IF (p_inserting) THEN
        IF IGS_AV_GEN_001.ADVP_UPD_AS_TOTALS (
      new_references.person_id,
      new_references.as_course_cd,
      new_references.as_version_number,
      v_message_name,
      new_references.exemption_institution_cd) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
  ELSE
        IF IGS_AV_GEN_001.ADVP_UPD_AS_TOTALS (
      old_references.person_id,
      old_references.as_course_cd,
      old_references.as_version_number,
      v_message_name,
      old_references.exemption_institution_cd) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
  END IF;
  END AfterRowInsertUpdateDelete2;


PROCEDURE Check_Constraints (
 Column_Name  IN  VARCHAR2  DEFAULT NULL,
 Column_Value   IN  VARCHAR2  DEFAULT NULL
 )
 AS
 BEGIN
  IF  column_name is null then
     NULL;
  ELSIF upper(Column_name) = 'CRS_GROUP_IND' then
     new_references.crs_group_ind := column_value;
  ELSIF upper(Column_name) = 'AS_COURSE_CD' then
     new_references.as_course_cd := column_value;
  ELSIF upper(Column_name) = 'EXEMPTION_INSTITUTION_CD' then
     new_references.exemption_institution_cd := column_value;
  ELSIF upper(Column_name) = 'S_ADV_STND_GRANTING_STATUS' then
     new_references.s_adv_stnd_granting_status := column_value;
  ELSIF upper(Column_name) = 'S_ADV_STND_RECOGNITION_TYPE' then
     new_references.s_adv_stnd_recognition_type := column_value;
  ELSIF upper(Column_name) = 'S_ADV_STND_TYPE' then
     new_references.s_adv_stnd_type := column_value;
  ELSIF upper(Column_name) = 'UNIT_CD' then
     new_references.unit_cd := column_value;
  ELSIF upper(Column_name) = 'INSTITUTION_CD' then
     new_references.institution_cd := column_value;
  ELSIF upper(Column_name) = 'CAL_TYPE' then
     new_references.cal_type := column_value;
  ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
     new_references.ci_sequence_number := IGS_GE_NUMBER.TO_NUM(column_value);
  End if;
  IF upper(column_name) = 'AS_COURSE_CD' OR
       column_name is null Then
       IF new_references.AS_COURSE_CD <>
    UPPER(new_references.AS_COURSE_CD) Then
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
       END IF;
  END IF;

IF upper(column_name) = 'S_ADV_STND_GRANTING_STATUS' OR
     column_name is null Then
     IF new_references.S_ADV_STND_GRANTING_STATUS <>
  UPPER(new_references.S_ADV_STND_GRANTING_STATUS) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'S_ADV_STND_RECOGNITION_TYPE' OR
     column_name is null Then
     IF new_references.S_ADV_STND_RECOGNITION_TYPE <>
  UPPER(new_references.S_ADV_STND_RECOGNITION_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'S_ADV_STND_TYPE' OR
     column_name is null Then
     IF new_references.S_ADV_STND_TYPE <>
  UPPER(new_references.S_ADV_STND_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.UNIT_CD <>
  UPPER(new_references.UNIT_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'CRS_GROUP_IND' OR
     column_name is null Then
     IF new_references.CRS_GROUP_IND <>
  UPPER(new_references.CRS_GROUP_IND) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'CRS_GROUP_IND' OR
     column_name is null Then
     IF (new_references.crs_group_ind not in ('Y', 'N')) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'S_ADV_STND_TYPE' OR
     column_name is null Then
     IF (new_references.s_adv_stnd_type <> 'UNIT') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;

   --Start addition for Bug no. 1960126
    IF column_name IS NULL THEN
     IF (new_references.institution_cd IS NOT NULL AND
           new_references.unit_details_id IS NULL ) THEN
               Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
               Igs_Ge_Msg_Stack.Add;
               App_Exception.Raise_Exception;
     END IF;
     IF (new_references.institution_cd IS NULL AND
              new_references.tst_rslt_dtls_id IS NULL) THEN
                 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                 Igs_Ge_Msg_Stack.Add;
                 App_Exception.Raise_Exception;
     END IF;

     IF ((new_references.unit_details_id IS NULL AND
            new_references.tst_rslt_dtls_id IS NULL) OR
         (new_references.unit_details_id IS NOT NULL AND
            new_references.tst_rslt_dtls_id IS NOT NULL)) THEN
               Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
               Igs_Ge_Msg_Stack.Add;
               App_Exception.Raise_Exception;
     END IF;
   END IF;


     IF upper(column_name) = 'CAL_TYPE' OR
         column_name is null THEN
       IF (new_references.cal_type IS NULL) THEN
                 Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                 Igs_Ge_Msg_Stack.Add;
                 App_Exception.Raise_Exception;
       END IF;
     END IF;


    IF upper(column_name) = 'CI_SEQUENCE_NUMBER' OR
       column_name is null THEN
            IF (new_references.CI_SEQUENCE_NUMBER IS NULL) THEN
                  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                  Igs_Ge_Msg_Stack.Add;
                  App_Exception.Raise_Exception;
            END IF;
    END IF;
   --End of addition for Bug no. 1960126

END Check_Constraints;
--



  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.s_adv_stnd_recognition_type = new_references.s_adv_stnd_recognition_type)) OR
        ((new_references.s_adv_stnd_recognition_type IS NULL))) THEN
      NULL;
    ELSE
--
      IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation ('ADV_STND_RECOGNITION_TYPE',
         new_references.s_adv_stnd_recognition_type) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
      END IF;
    END IF;
 IF (((old_references.person_id = new_references.person_id) AND
         (old_references.as_course_cd = new_references.as_course_cd) AND
         (old_references.as_version_number = new_references.as_version_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.as_course_cd IS NULL) OR
         (new_references.as_version_number IS NULL))) THEN
      NULL;
 ELSE
     IF NOT IGS_AV_ADV_STANDING_PKG.Get_PK_For_Validation (new_references.person_id,
          new_references.as_course_cd, new_references.as_version_number,
    new_references.exemption_institution_cd) THEN
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
      END IF;
  END IF;
    IF (((old_references.authorising_person_id = new_references.authorising_person_id)) OR
        ((new_references.authorising_person_id IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (new_references.authorising_person_id) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
      END IF;
   END IF;
    IF (((old_references.s_adv_stnd_granting_status = new_references.s_adv_stnd_granting_status)) OR
        ((new_references.s_adv_stnd_granting_status IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation ('ADV_STND_GRANTING_STATUS',
          new_references.s_adv_stnd_granting_status) THEN
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
    IF NOT IGS_PS_UNIT_VER_PKG.Get_PK_For_Validation (new_references.unit_cd, new_references.version_number) THEN
       Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
    END IF;
  END IF;

   --Start of addition for Bug no. 1960126

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (new_references.cal_type,
                                                    new_references.ci_sequence_number) THEN
       Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.grd_sch_version_number = new_references.grd_sch_version_number) AND
         (old_references.grade = new_references.grade)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.grd_sch_version_number IS NULL) OR
         (new_references.grade IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AS_GRD_SCH_GRADE_PKG.Get_PK_For_Validation (new_references.grading_schema_cd,
                                                             new_references.grd_sch_version_number,
                   new_references.grade ) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
      END IF;
    END IF;

  --End of addition for Bug no. 1960126

END Check_Parent_Existance;

 PROCEDURE check_uniqueness AS
  /*************************************************************
  Created By : pkpatel
  Date Created By : 13-SEP-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

   BEGIN
        IF get_uk_for_validation (
         new_references.person_id,
                 new_references.exemption_institution_cd,
                 new_references.unit_details_id,
                 new_references.tst_rslt_dtls_id,
                 new_references.unit_cd,
                 new_references.as_course_cd,
                 new_references.as_version_number,
                 new_references.version_number,
                 new_references.s_adv_stnd_type

        ) THEN
    Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                                IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
        END IF;
 END Check_Uniqueness ;

PROCEDURE Check_Child_Existance AS
BEGIN
    IGS_AV_STND_ALT_UNIT_PKG.GET_FK_IGS_AV_STND_UNIT (
      old_references.av_stnd_unit_id
      );
    IGS_AV_STD_UNT_BASIS_PKG.GET_FK_IGS_AV_STND_UNIT (
      old_references.av_stnd_unit_id
      );
END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
    x_av_stnd_unit_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    av_stnd_unit_id = x_av_stnd_unit_id
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
   Open cur_rowid;
   Fetch cur_rowid INTO lv_rowid;
---
   IF (cur_rowid%FOUND) THEN
       Close cur_rowid;
       Return (TRUE);
   ELSE
       Close cur_rowid;
       Return (FALSE);
   END IF;
---
   END Get_PK_For_Validation;

  FUNCTION get_uk_for_validation (
    x_person_id                 IN NUMBER,
    x_exemption_institution_cd  IN VARCHAR2, /* Modified as per Bug# 2523546 */
    x_unit_details_id           IN NUMBER,
    x_tst_rslt_dtls_id          IN NUMBER,
    x_unit_cd                   IN VARCHAR2,
    x_as_course_cd              IN VARCHAR2,
    x_as_version_number         IN NUMBER,
    x_version_number            IN NUMBER,   /* Added as per Bug# 2523546 */
    x_s_adv_stnd_type           IN VARCHAR2  /* Added as per Bug# 2523546 */
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :pkpatel
  Date Created By : 13-SEP-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Nalin Kumar     02-Jan-2002     Modified the UK definition as per Bug# 2523546
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_av_stnd_unit_all
      WHERE   person_id = x_person_id  AND
       exemption_institution_cd =  x_exemption_institution_cd   AND
       ((unit_details_id = x_unit_details_id) OR (unit_details_id IS NULL AND x_unit_details_id IS NULL))   AND
       ((tst_rslt_dtls_id = x_tst_rslt_dtls_id) OR (tst_rslt_dtls_id IS NULL AND x_tst_rslt_dtls_id IS NULL)) AND
       unit_cd           = x_unit_cd           AND
       as_course_cd      = x_as_course_cd      AND
       as_version_number = x_as_version_number AND
       version_number    = x_version_number    AND
       s_adv_stnd_type   = x_s_adv_stnd_type   AND
       ((l_rowid is null) or (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(false);
    END IF;
  END get_uk_for_validation ;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW_1(
    x_s_adv_stnd_recognition_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    s_adv_stnd_recognition_type = x_s_adv_stnd_recognition_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASU_SLV_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW_1;

 PROCEDURE GET_FK_IGS_AV_ADV_STANDING (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_exemption_institution_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    person_id = x_person_id
      AND      as_course_cd = x_course_cd
      AND      as_version_number = x_version_number
      AND      exemption_institution_cd=x_exemption_institution_cd;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASU_AS_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AV_ADV_STANDING;

 --** Added as per Bug# 2401170
 PROCEDURE get_fk_igs_ad_term_unitdtls (
    x_unit_details_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    unit_details_id = x_unit_details_id;
    l_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO l_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASU_TUD_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END get_fk_igs_ad_term_unitdtls;

 PROCEDURE get_fk_igs_ad_tst_rslt_dtls (
    x_tst_rslt_dtls_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    tst_rslt_dtls_id = x_tst_rslt_dtls_id;
    l_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO l_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASU_TRD_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END get_fk_igs_ad_tst_rslt_dtls;
  --** End of new code as per Bug# 2401170

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    authorising_person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASU_PE_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW_2 (
    x_s_adv_stnd_granting_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    s_adv_stnd_granting_status = x_s_adv_stnd_granting_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASU_SLV_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW_2;

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASU_UV_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_UNIT_VER;

--Start of addition for Bug no. 1960126
  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASU_CI_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST;

PROCEDURE GET_FK_IGS_AS_GRD_SCH_GRADE (
    x_grading_schema_cd IN VARCHAR2,
    x_grd_sch_version_number IN NUMBER,
    x_grade IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_ALL
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      grd_sch_version_number = x_grd_sch_version_number
      AND      grade = x_grade;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASU_GSG_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AS_GRD_SCH_GRADE;

--End of addition for Bug no. 1960126
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_as_course_cd IN VARCHAR2 DEFAULT NULL,
    x_as_version_number IN NUMBER DEFAULT NULL,
    x_s_adv_stnd_type IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_s_adv_stnd_granting_status IN VARCHAR2 DEFAULT NULL,
    x_credit_percentage IN NUMBER DEFAULT NULL,
    x_s_adv_stnd_recognition_type IN VARCHAR2 DEFAULT NULL,
    x_approved_dt IN DATE DEFAULT NULL,
    x_authorising_person_id IN NUMBER DEFAULT NULL,
    x_crs_group_ind IN VARCHAR2 DEFAULT NULL,
    x_exemption_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_granted_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_cancelled_dt IN DATE DEFAULT NULL,
    x_revoked_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    X_AV_STND_UNIT_ID  IN NUMBER DEFAULT NULL,
    X_CAL_TYPE            IN VARCHAR2 DEFAULT NULL,
    X_CI_SEQUENCE_NUMBER  IN NUMBER DEFAULT NULL,
    X_INSTITUTION_CD      IN VARCHAR2 DEFAULT NULL,
    X_UNIT_DETAILS_ID     in NUMBER DEFAULT NULL,
    X_TST_RSLT_DTLS_ID    in NUMBER DEFAULT NULL,
    X_GRADING_SCHEMA_CD   In VARCHAR2 DEFAULT NULL,
    X_GRD_SCH_VERSION_NUMBER IN NUMBER DEFAULT NULL,
    X_GRADE               IN VARCHAR2 DEFAULT NULL,
    X_ACHIEVABLE_CREDIT_POINTS IN  NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_adv_stnd_trans IN VARCHAR2 DEFAULT 'N',  -- This parameter has been added for Career Impact DLD.
    X_DEG_AUD_DETAIL_ID    IN NUMBER DEFAULT NULL
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_as_course_cd,
      x_as_version_number,
      x_s_adv_stnd_type,
      x_unit_cd,
      x_version_number,
      x_s_adv_stnd_granting_status,
      x_credit_percentage,
      x_s_adv_stnd_recognition_type,
      x_approved_dt,
      x_authorising_person_id,
      x_crs_group_ind,
      x_exemption_institution_cd,
      x_granted_dt,
      x_expiry_dt,
      x_cancelled_dt,
      x_revoked_dt,
      x_comments,
      X_AV_STND_UNIT_ID,
      X_CAL_TYPE,
      X_CI_SEQUENCE_NUMBER,
      X_INSTITUTION_CD,
      X_UNIT_DETAILS_ID,
      X_TST_RSLT_DTLS_ID,
      X_GRADING_SCHEMA_CD,
      X_GRD_SCH_VERSION_NUMBER,
      X_GRADE,
      X_ACHIEVABLE_CREDIT_POINTS,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      X_DEG_AUD_DETAIL_ID
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
                                     p_adv_stnd_trans => x_adv_stnd_trans);
---
     IF Get_PK_For_Validation (
                new_references.av_stnd_unit_id
                ) THEN
              Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
              Igs_Ge_Msg_Stack.Add;
              App_Exception.Raise_Exception;
      END IF;
---
      check_uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      check_uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
---
      IF Get_PK_For_Validation (
                new_references.av_stnd_unit_id
                ) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
      END IF;
        check_uniqueness;
        Check_Constraints;
      ELSIF (p_action = 'VALIDATE_UPDATE') THEN
         check_uniqueness;
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
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdateDelete2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdateDelete2 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowInsertUpdateDelete2 ( p_deleting => TRUE );
    END IF;
  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_AS_COURSE_CD in VARCHAR2,
  X_AS_VERSION_NUMBER in NUMBER,
  X_S_ADV_STND_TYPE in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_ADV_STND_GRANTING_STATUS in VARCHAR2,
  X_CREDIT_PERCENTAGE in NUMBER DEFAULT NULL,
  X_S_ADV_STND_RECOGNITION_TYPE in VARCHAR2,
  X_APPROVED_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_CRS_GROUP_IND in VARCHAR2,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_GRANTED_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_CANCELLED_DT in DATE,
  X_REVOKED_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_AV_STND_UNIT_ID  IN OUT NOCOPY  NUMBER ,
  X_CAL_TYPE            IN VARCHAR2 DEFAULT NULL,
  X_CI_SEQUENCE_NUMBER  IN NUMBER DEFAULT NULL,
  X_INSTITUTION_CD      IN VARCHAR2 DEFAULT NULL,
  X_UNIT_DETAILS_ID     in NUMBER DEFAULT NULL,
  X_TST_RSLT_DTLS_ID    in NUMBER DEFAULT NULL,
  X_GRADING_SCHEMA_CD   In VARCHAR2 DEFAULT NULL,
  X_GRD_SCH_VERSION_NUMBER IN NUMBER DEFAULT NULL,
  X_GRADE               IN VARCHAR2 DEFAULT NULL,
  X_ACHIEVABLE_CREDIT_POINTS IN  NUMBER DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_ADV_STND_TRANS IN VARCHAR2 DEFAULT 'N',  -- This parameter has been added for Career Impact DLD.
  X_DEG_AUD_DETAIL_ID    IN NUMBER DEFAULT NULL
  ) AS
    cursor C is select ROWID from IGS_AV_STND_UNIT_ALL
      where PERSON_ID = new_references.PERSON_ID
      and AS_COURSE_CD = new_references.AS_COURSE_CD
      and AS_VERSION_NUMBER =new_references.AS_VERSION_NUMBER
      and S_ADV_STND_TYPE = new_references.S_ADV_STND_TYPE
      and UNIT_CD = new_references.UNIT_CD
      and VERSION_NUMBER = new_references.VERSION_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER ;
    X_PROGRAM_ID NUMBER ;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE ;

   cursor c1 is select ROWID from IGS_AV_STND_UNIT_ALL
                      WHERE AV_STND_UNIT_ID = X_AV_STND_UNIT_ID;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID ;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID ;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID ;
    if (X_REQUEST_ID = -1) then
       X_REQUEST_ID := NULL ;
       X_PROGRAM_ID := NULL ;
       X_PROGRAM_APPLICATION_ID := NULL ;
       X_PROGRAM_UPDATE_DATE := NULL ;
    else
       X_PROGRAM_UPDATE_DATE := SYSDATE ;
    end if ;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;

  SELECT IGS_AV_STND_UNIT_S.NEXTVAL INTO X_AV_STND_UNIT_ID FROM DUAL;

Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_approved_dt=>X_APPROVED_DT,
 x_as_course_cd=>X_AS_COURSE_CD,
 x_as_version_number=>X_AS_VERSION_NUMBER,
 x_authorising_person_id=>X_AUTHORISING_PERSON_ID,
 x_cancelled_dt=>X_CANCELLED_DT,
 x_comments=>X_COMMENTS,
 x_credit_percentage=> NULL,
 x_crs_group_ind=>NVL(X_CRS_GROUP_IND,'N'),
 x_exemption_institution_cd=>X_EXEMPTION_INSTITUTION_CD,
 x_expiry_dt=>X_EXPIRY_DT,
 x_granted_dt=>X_GRANTED_DT,
 x_person_id=>X_PERSON_ID,
 x_revoked_dt=>X_REVOKED_DT,
 x_s_adv_stnd_granting_status=>X_S_ADV_STND_GRANTING_STATUS,
 x_s_adv_stnd_recognition_type=>X_S_ADV_STND_RECOGNITION_TYPE,
 x_s_adv_stnd_type=>NVL(X_S_ADV_STND_TYPE,'UNIT'),
 x_unit_cd=>X_UNIT_CD,
 x_version_number=>X_VERSION_NUMBER,
 X_AV_STND_UNIT_ID => X_AV_STND_UNIT_ID,
 X_CAL_TYPE =>X_CAL_TYPE,
 X_CI_SEQUENCE_NUMBER =>X_CI_SEQUENCE_NUMBER,
 X_INSTITUTION_CD =>X_INSTITUTION_CD,
 X_UNIT_DETAILS_ID =>X_UNIT_DETAILS_ID,
 X_TST_RSLT_DTLS_ID =>X_TST_RSLT_DTLS_ID,
 X_GRADING_SCHEMA_CD =>X_GRADING_SCHEMA_CD,
 X_GRD_SCH_VERSION_NUMBER =>X_GRD_SCH_VERSION_NUMBER,
 X_GRADE =>X_GRADE,
 X_ACHIEVABLE_CREDIT_POINTS =>X_ACHIEVABLE_CREDIT_POINTS,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_org_id=>igs_ge_gen_003.get_org_id,
 x_adv_stnd_trans=>X_ADV_STND_TRANS,
 X_DEG_AUD_DETAIL_ID    => X_DEG_AUD_DETAIL_ID
 );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  INSERT INTO IGS_AV_STND_UNIT_ALL (
    PERSON_ID,
    AS_COURSE_CD,
    AS_VERSION_NUMBER,
    S_ADV_STND_TYPE,
    UNIT_CD,
    VERSION_NUMBER,
    S_ADV_STND_GRANTING_STATUS,
    CREDIT_PERCENTAGE,
    S_ADV_STND_RECOGNITION_TYPE,
    APPROVED_DT,
    AUTHORISING_PERSON_ID,
    CRS_GROUP_IND,
    EXEMPTION_INSTITUTION_CD,
    GRANTED_DT,
    EXPIRY_DT,
    CANCELLED_DT,
    REVOKED_DT,
    COMMENTS,
    AV_STND_UNIT_ID,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    INSTITUTION_CD,
    UNIT_DETAILS_ID,
    TST_RSLT_DTLS_ID,
    GRADING_SCHEMA_CD,
    GRD_SCH_VERSION_NUMBER,
    GRADE,
    ACHIEVABLE_CREDIT_POINTS,
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
    DEG_AUD_DETAIL_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.AS_COURSE_CD,
    NEW_REFERENCES.AS_VERSION_NUMBER,
    NEW_REFERENCES.S_ADV_STND_TYPE,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.S_ADV_STND_GRANTING_STATUS,
    NULL,
    NEW_REFERENCES.S_ADV_STND_RECOGNITION_TYPE,
    NEW_REFERENCES.APPROVED_DT,
    NEW_REFERENCES.AUTHORISING_PERSON_ID,
    NEW_REFERENCES.CRS_GROUP_IND,
    NEW_REFERENCES.EXEMPTION_INSTITUTION_CD,
    NEW_REFERENCES.GRANTED_DT,
    NEW_REFERENCES.EXPIRY_DT,
    NEW_REFERENCES.CANCELLED_DT,
    NEW_REFERENCES.REVOKED_DT,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.AV_STND_UNIT_ID,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.INSTITUTION_CD,
    NEW_REFERENCES.UNIT_DETAILS_ID,
    NEW_REFERENCES.TST_RSLT_DTLS_ID,
    NEW_REFERENCES.GRADING_SCHEMA_CD,
    NEW_REFERENCES.GRD_SCH_VERSION_NUMBER,
    NEW_REFERENCES.GRADE,
    NEW_REFERENCES.ACHIEVABLE_CREDIT_POINTS,
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
    NEW_REFERENCES.DEG_AUD_DETAIL_ID
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    raise no_data_found;
  end if;
  close c1;

 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;


procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_AS_COURSE_CD in VARCHAR2,
  X_AS_VERSION_NUMBER in NUMBER,
  X_S_ADV_STND_TYPE in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_ADV_STND_GRANTING_STATUS in VARCHAR2,
  X_CREDIT_PERCENTAGE in NUMBER DEFAULT NULL,
  X_S_ADV_STND_RECOGNITION_TYPE in VARCHAR2,
  X_APPROVED_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_CRS_GROUP_IND in VARCHAR2,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_GRANTED_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_CANCELLED_DT in DATE,
  X_REVOKED_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_AV_STND_UNIT_ID     IN  NUMBER,
  X_CAL_TYPE            IN VARCHAR2 DEFAULT NULL,
  X_CI_SEQUENCE_NUMBER  IN NUMBER DEFAULT NULL,
  X_INSTITUTION_CD      IN VARCHAR2 DEFAULT NULL,
  X_UNIT_DETAILS_ID     in NUMBER DEFAULT NULL,
  X_TST_RSLT_DTLS_ID    in NUMBER DEFAULT NULL,
  X_GRADING_SCHEMA_CD   In VARCHAR2 DEFAULT NULL,
  X_GRD_SCH_VERSION_NUMBER IN NUMBER DEFAULT NULL,
  X_GRADE               IN VARCHAR2 DEFAULT NULL,
  X_ACHIEVABLE_CREDIT_POINTS IN  NUMBER DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID IN NUMBER DEFAULT NULL
) AS
  CURSOR c1 IS SELECT
      S_ADV_STND_GRANTING_STATUS,
      S_ADV_STND_RECOGNITION_TYPE,
      APPROVED_DT,
      AUTHORISING_PERSON_ID,
      CRS_GROUP_IND,
      EXEMPTION_INSTITUTION_CD,
      GRANTED_DT,
      EXPIRY_DT,
      CANCELLED_DT,
      REVOKED_DT,
      COMMENTS,
      AV_STND_UNIT_ID,
      CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      INSTITUTION_CD,
      UNIT_DETAILS_ID,
      TST_RSLT_DTLS_ID,
      GRADING_SCHEMA_CD,
      GRD_SCH_VERSION_NUMBER,
      GRADE,
      ACHIEVABLE_CREDIT_POINTS,
      DEG_AUD_DETAIL_ID
    from IGS_AV_STND_UNIT_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    Igs_Ge_Msg_Stack.Add;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
  if (
      (tlinfo.S_ADV_STND_GRANTING_STATUS = X_S_ADV_STND_GRANTING_STATUS)
      AND (tlinfo.S_ADV_STND_RECOGNITION_TYPE = X_S_ADV_STND_RECOGNITION_TYPE)
      AND (TRUNC(tlinfo.APPROVED_DT) =TRUNC(X_APPROVED_DT))
      AND (tlinfo.AUTHORISING_PERSON_ID = X_AUTHORISING_PERSON_ID)
      AND (tlinfo.CRS_GROUP_IND = X_CRS_GROUP_IND)
      AND (tlinfo.EXEMPTION_INSTITUTION_CD = X_EXEMPTION_INSTITUTION_CD)
      AND ((TRUNC(tlinfo.GRANTED_DT) = TRUNC(X_GRANTED_DT))       OR ((tlinfo.GRANTED_DT is null)      AND (X_GRANTED_DT is null)))
      AND ((TRUNC(tlinfo.EXPIRY_DT) = TRUNC(X_EXPIRY_DT))         OR ((tlinfo.EXPIRY_DT is null)       AND (X_EXPIRY_DT is null)))
      AND ((TRUNC(tlinfo.CANCELLED_DT) = TRUNC(X_CANCELLED_DT))   OR ((tlinfo.CANCELLED_DT is null)    AND (X_CANCELLED_DT is null)))
      AND ((TRUNC(tlinfo.REVOKED_DT) = TRUNC(X_REVOKED_DT))       OR ((tlinfo.REVOKED_DT is null)      AND (X_REVOKED_DT is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)           OR ((tlinfo.COMMENTS is null)        AND (X_COMMENTS is null)))
      AND ((tlinfo.CAL_TYPE = X_CAL_TYPE)           OR ((tlinfo.CAL_TYPE is null)        AND (X_CAL_TYPE is null)))
      AND ((tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)           OR ((tlinfo.CI_SEQUENCE_NUMBER is null)        AND (X_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.INSTITUTION_CD = X_INSTITUTION_CD)                   OR ((tlinfo.INSTITUTION_CD is null)        AND (X_INSTITUTION_CD is null)))
      AND ((tlinfo.UNIT_DETAILS_ID = X_UNIT_DETAILS_ID)             OR ((tlinfo.UNIT_DETAILS_ID is null)        AND (X_UNIT_DETAILS_ID is null)))
      AND ((tlinfo.TST_RSLT_DTLS_ID = X_TST_RSLT_DTLS_ID)             OR ((tlinfo.TST_RSLT_DTLS_ID is null)        AND (X_TST_RSLT_DTLS_ID is null)))
      AND ((tlinfo.GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD)             OR ((tlinfo.GRADING_SCHEMA_CD is null)        AND (X_GRADING_SCHEMA_CD is null)))
      AND ((tlinfo.GRD_SCH_VERSION_NUMBER = X_GRD_SCH_VERSION_NUMBER)   OR ((tlinfo.GRD_SCH_VERSION_NUMBER is null)        AND (X_GRD_SCH_VERSION_NUMBER is null)))
      AND ((tlinfo.GRADE = X_GRADE)                                     OR ((tlinfo.GRADE is null)        AND (X_GRADE is null)))
      AND ((tlinfo.ACHIEVABLE_CREDIT_POINTS = X_ACHIEVABLE_CREDIT_POINTS)  OR ((tlinfo.ACHIEVABLE_CREDIT_POINTS is null)        AND (X_ACHIEVABLE_CREDIT_POINTS is null)))
      AND ((tlinfo.DEG_AUD_DETAIL_ID = X_DEG_AUD_DETAIL_ID)  OR ((tlinfo.DEG_AUD_DETAIL_ID is null)        AND (X_DEG_AUD_DETAIL_ID is null)))
  ) then
   null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_AS_COURSE_CD in VARCHAR2,
  X_AS_VERSION_NUMBER in NUMBER,
  X_S_ADV_STND_TYPE in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_ADV_STND_GRANTING_STATUS in VARCHAR2,
  X_CREDIT_PERCENTAGE in NUMBER DEFAULT NULL,
  X_S_ADV_STND_RECOGNITION_TYPE in VARCHAR2,
  X_APPROVED_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_CRS_GROUP_IND in VARCHAR2,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_GRANTED_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_CANCELLED_DT in DATE,
  X_REVOKED_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_AV_STND_UNIT_ID     IN  NUMBER ,
  X_CAL_TYPE            IN VARCHAR2 DEFAULT NULL,
  X_CI_SEQUENCE_NUMBER  IN NUMBER DEFAULT NULL,
  X_INSTITUTION_CD      IN VARCHAR2 DEFAULT NULL,
  X_UNIT_DETAILS_ID     in NUMBER DEFAULT NULL,
  X_TST_RSLT_DTLS_ID    in NUMBER DEFAULT NULL,
  X_GRADING_SCHEMA_CD   In VARCHAR2 DEFAULT NULL,
  X_GRD_SCH_VERSION_NUMBER IN NUMBER DEFAULT NULL,
  X_GRADE               IN VARCHAR2 DEFAULT NULL,
  X_ACHIEVABLE_CREDIT_POINTS IN  NUMBER DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID IN NUMBER DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID  NUMBER ;
    X_PROGRAM_ID  NUMBER ;
    X_PROGRAM_APPLICATION_ID  NUMBER;
    X_PROGRAM_UPDATE_DATE     DATE ;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
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
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
before_DML(
p_action=>'UPDATE',
x_rowid=>X_ROWID,
x_approved_dt=>X_APPROVED_DT,
x_as_course_cd=>X_AS_COURSE_CD,
x_as_version_number=>X_AS_VERSION_NUMBER,
x_authorising_person_id=>X_AUTHORISING_PERSON_ID,
x_cancelled_dt=>X_CANCELLED_DT,
x_comments=>X_COMMENTS,
x_credit_percentage=>NULL,
x_crs_group_ind=>X_CRS_GROUP_IND,
x_exemption_institution_cd=>X_EXEMPTION_INSTITUTION_CD,
x_expiry_dt=>X_EXPIRY_DT,
x_granted_dt=>X_GRANTED_DT,
x_person_id=>X_PERSON_ID,
x_revoked_dt=>X_REVOKED_DT,
x_s_adv_stnd_granting_status=>X_S_ADV_STND_GRANTING_STATUS,
x_s_adv_stnd_recognition_type=>X_S_ADV_STND_RECOGNITION_TYPE,
x_s_adv_stnd_type=>X_S_ADV_STND_TYPE,
x_unit_cd=>X_UNIT_CD,
x_version_number=>X_VERSION_NUMBER,
X_AV_STND_UNIT_ID=>X_AV_STND_UNIT_ID,
X_CAL_TYPE =>X_CAL_TYPE,
X_CI_SEQUENCE_NUMBER =>X_CI_SEQUENCE_NUMBER,
X_INSTITUTION_CD =>X_INSTITUTION_CD,
X_UNIT_DETAILS_ID =>X_UNIT_DETAILS_ID,
X_TST_RSLT_DTLS_ID =>X_TST_RSLT_DTLS_ID,
X_GRADING_SCHEMA_CD =>X_GRADING_SCHEMA_CD,
X_GRD_SCH_VERSION_NUMBER =>X_GRD_SCH_VERSION_NUMBER,
X_GRADE =>X_GRADE,
X_ACHIEVABLE_CREDIT_POINTS =>X_ACHIEVABLE_CREDIT_POINTS,
X_DEG_AUD_DETAIL_ID  =>   X_DEG_AUD_DETAIL_ID,
x_creation_date=>X_LAST_UPDATE_DATE,
x_created_by=>X_LAST_UPDATED_BY,
x_last_update_date=>X_LAST_UPDATE_DATE,
x_last_updated_by=>X_LAST_UPDATED_BY,
x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  if (X_MODE IN ('R', 'S')) then
     X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID ;
     X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID ;
     X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID ;
     if (X_REQUEST_ID = -1) then
         X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID ;
         X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID ;
         X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID ;
         X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE ;
      else
         X_PROGRAM_UPDATE_DATE := SYSDATE ;
      end if ;
   end if;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  UPDATE IGS_AV_STND_UNIT_ALL SET
    S_ADV_STND_GRANTING_STATUS = X_S_ADV_STND_GRANTING_STATUS,
    CREDIT_PERCENTAGE = NULL,
    S_ADV_STND_RECOGNITION_TYPE = X_S_ADV_STND_RECOGNITION_TYPE,
    APPROVED_DT = X_APPROVED_DT,
    AUTHORISING_PERSON_ID = X_AUTHORISING_PERSON_ID,
    CRS_GROUP_IND = X_CRS_GROUP_IND,
    EXEMPTION_INSTITUTION_CD = X_EXEMPTION_INSTITUTION_CD,
    GRANTED_DT = X_GRANTED_DT,
    EXPIRY_DT = X_EXPIRY_DT,
    CANCELLED_DT = X_CANCELLED_DT,
    REVOKED_DT = X_REVOKED_DT,
    COMMENTS = X_COMMENTS,
    CAL_TYPE = X_CAL_TYPE,
    CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER,
    INSTITUTION_CD = X_INSTITUTION_CD,
    UNIT_DETAILS_ID = X_UNIT_DETAILS_ID,
    TST_RSLT_DTLS_ID = X_TST_RSLT_DTLS_ID,
    GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD,
    GRD_SCH_VERSION_NUMBER = X_GRD_SCH_VERSION_NUMBER,
    GRADE = X_GRADE,
    ACHIEVABLE_CREDIT_POINTS = X_ACHIEVABLE_CREDIT_POINTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    DEG_AUD_DETAIL_ID = X_DEG_AUD_DETAIL_ID
  where ROWID = X_ROWID  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_AS_COURSE_CD in VARCHAR2,
  X_AS_VERSION_NUMBER in NUMBER,
  X_S_ADV_STND_TYPE in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_ADV_STND_GRANTING_STATUS in VARCHAR2,
  X_CREDIT_PERCENTAGE in NUMBER DEFAULT NULL,
  X_S_ADV_STND_RECOGNITION_TYPE in VARCHAR2,
  X_APPROVED_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_CRS_GROUP_IND in VARCHAR2,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_GRANTED_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_CANCELLED_DT in DATE,
  X_REVOKED_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_AV_STND_UNIT_ID  IN OUT NOCOPY NUMBER ,
  X_CAL_TYPE            IN VARCHAR2 DEFAULT NULL,
  X_CI_SEQUENCE_NUMBER  IN NUMBER DEFAULT NULL,
  X_INSTITUTION_CD      IN VARCHAR2 DEFAULT NULL,
  X_UNIT_DETAILS_ID     in NUMBER DEFAULT NULL,
  X_TST_RSLT_DTLS_ID    in NUMBER DEFAULT NULL,
  X_GRADING_SCHEMA_CD   In VARCHAR2 DEFAULT NULL,
  X_GRD_SCH_VERSION_NUMBER IN NUMBER DEFAULT NULL,
  X_GRADE               IN VARCHAR2 DEFAULT NULL,
  X_ACHIEVABLE_CREDIT_POINTS IN  NUMBER DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_DEG_AUD_DETAIL_ID IN  NUMBER DEFAULT NULL
  ) AS
  cursor c1 is select rowid from IGS_AV_STND_UNIT_ALL
     where AV_STND_UNIT_ID =X_AV_STND_UNIT_ID
  ;
begin
  open c1;
  fetch c1 into X_ROWID ;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_AS_COURSE_CD,
     X_AS_VERSION_NUMBER,
     X_S_ADV_STND_TYPE,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_S_ADV_STND_GRANTING_STATUS,
     NULL,
     X_S_ADV_STND_RECOGNITION_TYPE,
     X_APPROVED_DT,
     X_AUTHORISING_PERSON_ID,
     X_CRS_GROUP_IND,
     X_EXEMPTION_INSTITUTION_CD,
     X_GRANTED_DT,
     X_EXPIRY_DT,
     X_CANCELLED_DT,
     X_REVOKED_DT,
     X_COMMENTS,
     X_AV_STND_UNIT_ID,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_INSTITUTION_CD,
     X_UNIT_DETAILS_ID,
     X_TST_RSLT_DTLS_ID,
     X_GRADING_SCHEMA_CD,
     X_GRD_SCH_VERSION_NUMBER,
     X_GRADE,
     X_ACHIEVABLE_CREDIT_POINTS,
     X_MODE,
     X_ORG_ID,
     X_DEG_AUD_DETAIL_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID ,
   X_PERSON_ID,
   X_AS_COURSE_CD,
   X_AS_VERSION_NUMBER,
   X_S_ADV_STND_TYPE,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_S_ADV_STND_GRANTING_STATUS,
   NULL,
   X_S_ADV_STND_RECOGNITION_TYPE,
   X_APPROVED_DT,
   X_AUTHORISING_PERSON_ID,
   X_CRS_GROUP_IND,
   X_EXEMPTION_INSTITUTION_CD,
   X_GRANTED_DT,
   X_EXPIRY_DT,
   X_CANCELLED_DT,
   X_REVOKED_DT,
   X_COMMENTS,
   X_AV_STND_UNIT_ID,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_INSTITUTION_CD,
   X_UNIT_DETAILS_ID,
   X_TST_RSLT_DTLS_ID,
   X_GRADING_SCHEMA_CD,
   X_GRD_SCH_VERSION_NUMBER,
   X_GRADE,
   X_ACHIEVABLE_CREDIT_POINTS,
   X_MODE,
   X_DEG_AUD_DETAIL_ID);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2  )
AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_AV_STND_UNIT_ALL
  where ROWID = X_ROWID ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;
end IGS_AV_STND_UNIT_PKG;

/
