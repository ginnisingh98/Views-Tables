--------------------------------------------------------
--  DDL for Package Body IGS_AV_STND_UNIT_LVL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_STND_UNIT_LVL_PKG" AS
/* $Header: IGSBI06B.pls 120.1 2005/07/06 00:46:47 appldev ship $ */
/*****  Bug No :   1956374
          Task   :   Duplicated Procedures and functions
          PROCEDURE  admp_val_as_aprvd_dt  reference is changed
                     admp_val_asu_inst reference is changed
                     admp_val_expiry_dt reference is changed
                      *****/
  l_rowid VARCHAR2(25);
  old_references IGS_AV_STND_UNIT_LVL_ALL%RowType;
  new_references IGS_AV_STND_UNIT_LVL_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action        IN VARCHAR2,
    x_rowid       IN VARCHAR2,
    x_person_id       IN NUMBER,
    x_as_course_cd      IN VARCHAR2,
    x_as_version_number     IN NUMBER,
    x_s_adv_stnd_type     IN VARCHAR2,
    x_unit_level      IN VARCHAR2,
    x_crs_group_ind     IN VARCHAR2,
    x_exemption_institution_cd    IN VARCHAR2,
    x_s_adv_stnd_granting_status  IN VARCHAR2,
    x_credit_points     IN NUMBER,
    x_approved_dt     IN DATE,
    x_authorising_person_id   IN NUMBER,
    x_granted_dt      IN DATE,
    x_expiry_dt       IN DATE,
    x_cancelled_dt      IN DATE,
    x_revoked_dt      IN DATE,
    x_comments        IN VARCHAR2,
    X_AV_STND_UNIT_LVL_ID   IN NUMBER,
    X_CAL_TYPE        IN VARCHAR2,
    X_CI_SEQUENCE_NUMBER    IN NUMBER,
    X_INSTITUTION_CD      IN VARCHAR2,
    X_UNIT_DETAILS_ID                   in NUMBER,
    X_TST_RSLT_DTLS_ID                  in NUMBER,
    x_creation_date     IN DATE,
    x_created_by      IN NUMBER,
    x_last_update_date      IN DATE,
    x_last_updated_by     IN NUMBER,
    x_last_update_login     IN NUMBER,
    x_org_id        IN NUMBER,
    X_DEG_AUD_DETAIL_ID     IN NUMBER,
    X_QUAL_DETS_ID      IN NUMBER,
    X_UNIT_LEVEL_MARK     IN NUMBER
    ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AV_STND_UNIT_LVL_ALL
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
    new_references.UNIT_LEVEL := x_unit_level;
    new_references.crs_group_ind := x_crs_group_ind;
    new_references.exemption_institution_cd := x_exemption_institution_cd;
    new_references.s_adv_stnd_granting_status := x_s_adv_stnd_granting_status;
    new_references.credit_points := x_credit_points;
    new_references.approved_dt := x_approved_dt;
    new_references.authorising_person_id := x_authorising_person_id;
    new_references.granted_dt := x_granted_dt;
    new_references.expiry_dt := x_expiry_dt;
    new_references.cancelled_dt := x_cancelled_dt;
    new_references.revoked_dt := x_revoked_dt;
    new_references.comments := x_comments;
    new_references.AV_STND_UNIT_LVL_ID := X_AV_STND_UNIT_LVL_ID;
    new_references.CAL_TYPE := x_CAL_TYPE;
    new_references.CI_SEQUENCE_NUMBER := x_CI_SEQUENCE_NUMBER;
    new_references.INSTITUTION_CD := x_INSTITUTION_CD;
    new_references.UNIT_DETAILS_ID := x_UNIT_DETAILS_ID;
    new_references.TST_RSLT_DTLS_ID := x_TST_RSLT_DTLS_ID;
    new_references.UNIT_LEVEL_MARK := X_UNIT_LEVEL_MARK;

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
    new_references.DEG_AUD_DETAIL_ID  := x_DEG_AUD_DETAIL_ID;
    new_references.QUAL_DETS_ID := X_QUAL_DETS_ID;

  END Set_Column_Values;

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN,
    p_adv_stnd_trans IN VARCHAR2 -- This parameter has been added for Career Impact DLD.
    ) AS
    v_message_name   VARCHAR2(30);
    v_person_id      igs_av_stnd_unit_lvl_all.person_id%TYPE;
    v_course_cd      igs_av_stnd_unit_lvl_all.as_course_cd%TYPE;
    v_version_number igs_av_stnd_unit_lvl_all.as_version_number%TYPE;
    v_exemption_institution_cd   igs_av_stnd_unit_lvl_all.exemption_institution_cd%TYPE;
  BEGIN
    -- Validate conditions on insert (these apply to the trigger only).
    IF p_inserting THEN
      IF new_references.s_adv_stnd_type <> 'LEVEL' THEN
        Fnd_Message.Set_Name('IGS', 'IGS_AV_TYPE_MUSTBE_LEVEL');
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
      IF new_references.s_adv_stnd_granting_status <> 'APPROVED' AND
         p_adv_stnd_trans = 'N' THEN
        Fnd_Message.Set_Name('IGS', 'IGS_AV_STATUS_MUSTBE_APPROVED');
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    -- Validate Unit Level closed indicator.
    IF p_inserting OR p_updating THEN
      IF igs_av_val_asule.advp_val_ule_closed (
           new_references.UNIT_LEVEL,
           v_message_name) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    -- Validate Advanced Standing Unit Level Approved Date
    IF (new_references.approved_dt IS NOT NULL) AND
       (p_inserting OR
       (NVL(old_references.approved_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
        new_references.approved_dt)) THEN
      IF igs_av_val_asu.advp_val_as_dates (
           new_references.approved_dt,
           'APPROVED',
           v_message_name,
           p_adv_stnd_trans) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    -- On update, the granting status cannot be set to 'Granted' from anything
    -- other than 'Approved'.
    IF p_updating AND
       (new_references.s_adv_stnd_granting_status = 'GRANTED') AND
       (old_references.s_adv_stnd_granting_status <> new_references.s_adv_stnd_granting_status) THEN
      IF old_references.s_adv_stnd_granting_status = 'REVOKED' THEN
        Fnd_Message.Set_Name('IGS', 'IGS_AV_CHG_REVOKED_APPROVED');
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
    -- Validate Advanced Standing Unit Level Granted Date
    IF (new_references.granted_dt IS NOT NULL) AND
       (p_inserting OR
       (NVL(old_references.granted_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
        new_references.granted_dt)) THEN
      IF igs_av_val_asu.advp_val_as_dates (
           new_references.granted_dt,
           'GRANTED',
           v_message_name,
           p_adv_stnd_trans) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    -- Validate expiry date is greater than current date.
    IF (new_references.expiry_dt IS NOT NULL) AND
       (p_inserting OR
       (NVL(old_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
        new_references.expiry_dt)) THEN
      IF igs_av_val_asu.advp_val_expiry_dt (
          new_references.expiry_dt,
          v_message_name,
          p_adv_stnd_trans) = FALSE THEN
                           Fnd_Message.Set_Name('IGS', v_message_name);
                           Igs_Ge_Msg_Stack.Add;
                           App_Exception.Raise_Exception;
      END IF;
    END IF;
    -- Validate Advanced Standing Unit Level Cancelled Date
    IF (new_references.cancelled_dt IS NOT NULL) AND
       (p_inserting OR
       (NVL(old_references.cancelled_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
        new_references.cancelled_dt)) THEN
      IF igs_av_val_asu.advp_val_as_dates (
          new_references.cancelled_dt,
          'CANCELLED',
          v_message_name) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
      IF igs_av_val_asu.advp_val_as_aprvd_dt (
          new_references.approved_dt,
          new_references.cancelled_dt,
          v_message_name) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    -- Validate Advanced Standing Unit Level Revoked Date
    IF (new_references.revoked_dt IS NOT NULL) AND
       (p_inserting OR
       (NVL(old_references.revoked_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
        new_references.revoked_dt)) THEN
      IF igs_av_val_asu.advp_val_as_dates (
          new_references.revoked_dt,
          'REVOKED',
          v_message_name) = FALSE THEN
        Fnd_Message.Set_Name('IGS', v_message_name);
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
      IF igs_av_val_asu.advp_val_as_aprvd_dt (
          new_references.approved_dt,
          new_references.revoked_dt,
          v_message_name) = FALSE THEN
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
    -- Validate Advanced Standing Unit Level Authorising Person Id.
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
    --
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
    -- Store column values to update Advanced Standing in AS trigger.
    IF p_inserting OR p_updating THEN
      v_person_id   :=  new_references.person_id;
      v_course_cd   :=  new_references.as_course_cd;
      v_version_number  :=  new_references.as_version_number;
      v_exemption_institution_cd := new_references.exemption_institution_cd;
    ELSE
      v_person_id   :=  old_references.person_id;
      v_course_cd   :=  old_references.as_course_cd;
      v_version_number  :=  old_references.as_version_number;
      v_exemption_institution_cd := old_references.exemption_institution_cd;
    END IF;
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
    -- Process any advanced standing to do records
    IF p_inserting THEN
      igs_pr_gen_003.igs_pr_ins_adv_todo (
        new_references.person_id,
        new_references.as_course_cd,
        new_references.as_version_number,
        'CREDIT',
        'CREDIT',
        new_references.s_adv_stnd_granting_status,
        new_references.s_adv_stnd_granting_status,
        new_references.credit_points,
        new_references.credit_points,
        NULL,
        NULL
      );
    ELSIF p_updating THEN
      igs_pr_gen_003.igs_pr_ins_adv_todo (
        new_references.person_id,
        new_references.as_course_cd,
        new_references.as_version_number,
        'CREDIT',
        'CREDIT',
        old_references.s_adv_stnd_granting_status,
        new_references.s_adv_stnd_granting_status,
        old_references.credit_points,
        new_references.credit_points,
        NULL,
        NULL
      );
    ELSIF p_deleting THEN
      igs_pr_gen_003.igs_pr_ins_adv_todo (
        old_references.person_id,
        old_references.as_course_cd,
        old_references.as_version_number,
        'CREDIT',
        'CREDIT',
        old_references.s_adv_stnd_granting_status,
        old_references.s_adv_stnd_granting_status,
        old_references.credit_points,
        old_references.credit_points,
        NULL,
        NULL
      );
    END IF;
  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_asule_ar_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_AV_STND_UNIT_LVL_ALL
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
  v_rowid_saved   BOOLEAN := FALSE;
  v_message_name  varchar2(30);
  v_person_id   IGS_AV_STND_UNIT_LVL_ALL.person_id%TYPE;
  v_course_cd   IGS_AV_STND_UNIT_LVL_ALL.as_course_cd%TYPE;
  v_version_number  IGS_AV_STND_UNIT_LVL_ALL.as_version_number%TYPE;
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
 Column_Name  IN  VARCHAR2,
 Column_Value   IN  VARCHAR2
 )
 AS
 BEGIN
  IF  column_name is null then
     NULL;
  ELSIF upper(Column_name) = 'S_ADV_STND_TYPE' then
     new_references.s_adv_stnd_type := column_value;
  ELSIF upper(Column_name) = 'UNIT_LEVEL' then
     new_references.UNIT_LEVEL := column_value;
  ELSIF upper(Column_name) = 'AS_COURSE_CD' then
     new_references.as_course_cd := column_value;
  ELSIF upper(Column_name) = 'S_ADV_STND_GRANTING_STATUS' then
     new_references.s_adv_stnd_granting_status := column_value;
  ELSIF upper(Column_name) = 'CRS_GROUP_IND' then
     new_references.crs_group_ind := column_value;
  ELSIF upper(Column_name) = 'EXEMPTION_INSTITUTION_CD' then
     new_references.exemption_institution_cd := column_value;
  ELSIF upper(Column_name) = 'CRS_GROUP_IND' then
     new_references.crs_group_ind := column_value;
  ELSIF upper(Column_name) = 'CREDIT_POINTS' then
     new_references.credit_points := IGS_GE_NUMBER.TO_NUM(column_value);
  ELSIF upper(Column_name) = 'INSTITUTION_CD' then
     new_references.institution_cd := column_value;
  ELSIF upper(Column_name) = 'CAL_TYPE' then
     new_references.cal_type := column_value;
  ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
     new_references.ci_sequence_number := IGS_GE_NUMBER.TO_NUM(column_value);
  End if;
IF upper(column_name) = 'S_ADV_STND_TYPE' OR
     column_name is null Then
     IF new_references.S_ADV_STND_TYPE <>
  UPPER(new_references.S_ADV_STND_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'UNIT_LEVEL' OR
     column_name is null Then
     IF new_references.UNIT_LEVEL <>
  UPPER(new_references.UNIT_LEVEL) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;
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
IF upper(column_name) = 'CRS_GROUP_IND' OR
     column_name is null Then
     IF new_references.crs_group_ind <>
  UPPER(new_references.crs_group_ind) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'CREDIT_POINTS' OR
     column_name is null Then
     -- 16-Oct-2002; kdande; Bug# 2627933
     -- Changed the credit point limit to 999.999 from 99
     IF new_references.credit_points  < 0 OR
          new_references.credit_points > 999.999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'UNIT_LEVEL_MARK' OR
     column_name is null Then
     IF new_references.unit_level_mark  < 0 OR
          new_references.unit_level_mark > 100.000 Then
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
     IF (new_references.s_adv_stnd_type <> 'LEVEL') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;

-- Start of addition for Bug no. 1960126
     --Added qual_dets_id in if condition w.r.t. ARCR032 CCR
     IF (new_references.institution_cd IS NOT NULL) AND
           (new_references.unit_details_id IS NULL AND new_references.QUAL_DETS_ID IS NULL ) THEN
               Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
               Igs_Ge_Msg_Stack.Add;
               App_Exception.Raise_Exception;
     END IF;

     IF (new_references.institution_cd IS NULL AND
            new_references.tst_rslt_dtls_id  IS NULL) THEN
               Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
               Igs_Ge_Msg_Stack.Add;
               App_Exception.Raise_Exception;
     END IF;

     --Added qual_dets_id in if condition w.r.t. ARCR032 CCR
     IF ((new_references.unit_details_id IS NULL AND new_references.tst_rslt_dtls_id  IS NULL AND new_references.qual_dets_id IS NULL)
         OR
           ((new_references.unit_details_id IS NOT NULL AND new_references.tst_rslt_dtls_id  IS NOT NULL) OR
      (new_references.unit_details_id IS NOT NULL AND new_references.qual_dets_id IS NOT NULL ) OR
            (new_references.qual_dets_id IS NOT NULL AND new_references.tst_rslt_dtls_id  IS NOT NULL))

      ) THEN
               Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
               Igs_Ge_Msg_Stack.Add;
               App_Exception.Raise_Exception;
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
-- End of addition for Bug no. 1960126

END Check_Constraints;

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
                          new_references.unit_level,
                          new_references.as_course_cd,
                          new_references.as_version_number,
                          new_references.qual_dets_id,
                          new_references.s_adv_stnd_type,
                          new_references.crs_group_ind
        ) THEN
    Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                                IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
        END IF;
 END Check_Uniqueness ;

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.as_course_cd = new_references.as_course_cd) AND
         (old_references.as_version_number = new_references.as_version_number)) OR
        ((new_references.person_id IS NULL) AND
         (new_references.as_course_cd IS NULL) AND
         (new_references.as_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_AV_ADV_STANDING_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.as_course_cd,
        new_references.as_version_number,
  new_references.exemption_institution_cd
        ) THEN
       Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END IF;
    END IF;
    --Added If condition as part of ARCR032 CCR(Enh bug no:2233334)
    IF ( (old_references.qual_dets_id = new_references.qual_dets_id) OR
         (new_references.qual_dets_id IS NULL) ) THEN
      NULL;
    ELSE
      NULL;
-- check if the packag IGS_UC_QUAL_DETS_PKG is present in the user_objects
     DECLARE
         CURSOR c_exists IS
      SELECT 1
      FROM  user_objects
      WHERE object_name = 'IGS_UC_QUAL_DETS_PKG'
      AND   object_type='PACKAGE';
          l_result BOOLEAN;
     BEGIN
        FOR rec_exists IN c_exists
        LOOP

         EXECUTE IMMEDIATE
          'BEGIN IF NOT IGS_UC_QUAL_DETS_PKG.Get_PK_For_Validation(:1) THEN Fnd_Message.Set_Name (''FND'', ''FORM_RECORD_DELETED''); Igs_Ge_Msg_Stack.Add; App_Exception.Raise_Exception; END IF; END;'
         USING
           new_references.qual_dets_id;

              END LOOP;
      END;
    END IF;

    IF (((old_references.authorising_person_id = new_references.authorising_person_id)) OR
        ((new_references.authorising_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.authorising_person_id
        ) THEN
       Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END IF;
    END IF;
    IF (((old_references.s_adv_stnd_granting_status = new_references.s_adv_stnd_granting_status)) OR
        ((new_references.s_adv_stnd_granting_status IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation (
        'ADV_STND_GRANTING_STATUS',
        new_references.s_adv_stnd_granting_status
        ) THEN
       Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END IF;
    END IF;
    IF (((old_references.UNIT_LEVEL = new_references.UNIT_LEVEL)) OR
        ((new_references.UNIT_LEVEL IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_PS_UNIT_LEVEL_PKG.Get_PK_For_Validation (
        new_references.UNIT_LEVEL
        ) THEN
       Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END IF;
    END IF;

    -- Added for Bug no. 1960126
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

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_AV_STD_ULVLBASIS_PKG.GET_FK_IGS_AV_STND_UNIT_LVL (
      old_references.AV_STND_UNIT_LVL_ID
      );
  END Check_Child_Existance;

  Function Get_PK_For_Validation (
  x_av_stnd_unit_lvl_id IN NUMBER
    ) Return Boolean
  AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_LVL_ALL
      WHERE    av_stnd_unit_lvl_id = x_av_stnd_unit_lvl_id
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

   FUNCTION get_uk_for_validation(
    x_person_id                 IN NUMBER,
    x_exemption_institution_cd  IN VARCHAR2, /* Modified as per Bug# 2523546 */
    x_unit_details_id           IN NUMBER,
    x_tst_rslt_dtls_id          IN NUMBER,
    x_unit_level                IN VARCHAR2,
    x_as_course_cd              IN VARCHAR2,
    x_as_version_number         IN NUMBER,
    x_qual_dets_id              IN NUMBER,   /* Added as per Bug# 2423651 */
    x_s_adv_stnd_type           IN VARCHAR2, /* Added as per Bug# 2523546 */
    x_crs_group_ind             IN VARCHAR2  /* Added as per Bug# 2523546 */
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Nalin Kumar     02-Jan-2002     Modified the UK definition as per Bug# 2523546
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_av_stnd_unit_lvl_all
      WHERE   person_id = x_person_id  AND
       exemption_institution_cd =  x_exemption_institution_cd AND
       ((unit_details_id = x_unit_details_id ) OR (unit_details_id IS NULL AND x_unit_details_id IS NULL))        AND
       ((tst_rslt_dtls_id = x_tst_rslt_dtls_id) OR ( tst_rslt_dtls_id IS NULL AND x_tst_rslt_dtls_id IS NULL))  AND
       ((qual_dets_id = x_qual_dets_id) OR ( qual_dets_id IS NULL AND x_qual_dets_id IS NULL))  AND /* Added as per bug#2423651 */
       unit_level        = x_unit_level        AND
       as_course_cd      = x_as_course_cd      AND
       as_version_number = x_as_version_number AND
       s_adv_stnd_type   = x_s_adv_stnd_type   AND
       crs_group_ind     = x_crs_group_ind     AND
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



----CHANGED **********

  PROCEDURE GET_FK_IGS_AV_ADV_STANDING (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_exemption_institution_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_LVL_ALL
      WHERE    person_id = x_person_id
      AND      as_course_cd = x_course_cd
      AND      as_version_number = x_version_number
      AND      exemption_institution_cd=x_exemption_institution_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASULE_AS_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AV_ADV_STANDING;




  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_LVL_ALL
      WHERE    authorising_person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASULE_PE_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_adv_stnd_granting_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_LVL_ALL
      WHERE    s_adv_stnd_granting_status = x_s_adv_stnd_granting_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASULE_SLV_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW;


 -- Added for Bug no. 1960126
  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_LVL_ALL
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASULE_CI_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST;

    --Added get_fk_igs_uc_qual_dets procedure as part of ARCR032 CCR(Enh bug no:2233334)
  PROCEDURE GET_FK_IGS_UC_QUAL_DETS (
    x_qual_dets_id  IN NUMBER
    ) AS
    CURSOR cur_rowid IS
  SELECT   rowid
  FROM     IGS_AV_STND_UNIT_LVL_ALL
  WHERE    qual_dets_id = x_qual_dets_id;
    lv_rowid   cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid into lv_rowid;
    IF (cur_rowid%FOUND) THEN
  Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASULE_UCQD_FK');
  Igs_Ge_Msg_Stack.Add;
  Close cur_rowid;
  App_Exception.Raise_Exception;
  Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_UC_QUAL_DETS;

 --** Added as per Bug# 2401170
 PROCEDURE get_fk_igs_ad_term_unitdtls (
    x_unit_details_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_UNIT_LVL_ALL
      WHERE    unit_details_id = x_unit_details_id;
    l_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO l_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASULE_TUD_FK');
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
      FROM     IGS_AV_STND_UNIT_LVL_ALL
      WHERE    tst_rslt_dtls_id = x_tst_rslt_dtls_id;
    l_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO l_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_ASULE_TRD_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END get_fk_igs_ad_tst_rslt_dtls;
  --** End of new code as per Bug# 2401170



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_person_id IN NUMBER,
    x_as_course_cd IN VARCHAR2,
    x_as_version_number IN NUMBER,
    x_s_adv_stnd_type IN VARCHAR2,
    x_unit_level IN VARCHAR2,
    x_crs_group_ind IN VARCHAR2,
    x_exemption_institution_cd IN VARCHAR2,
    x_s_adv_stnd_granting_status IN VARCHAR2,
    x_credit_points IN NUMBER,
    x_approved_dt IN DATE,
    x_authorising_person_id IN NUMBER,
    x_granted_dt IN DATE,
    x_expiry_dt IN DATE,
    x_cancelled_dt IN DATE,
    x_revoked_dt IN DATE,
    x_comments IN VARCHAR2,
    X_AV_STND_UNIT_LVL_ID IN NUMBER ,
    X_CAL_TYPE            IN VARCHAR2,
    X_CI_SEQUENCE_NUMBER  IN NUMBER,
    X_INSTITUTION_CD      IN VARCHAR2,
    X_UNIT_DETAILS_ID     in NUMBER,
    X_TST_RSLT_DTLS_ID    in NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_org_id IN NUMBER,
    x_adv_stnd_trans IN VARCHAR2, -- This parameter has been added for Career Impact DLD.
    X_DEG_AUD_DETAIL_ID  IN NUMBER,
    X_QUAL_DETS_ID  IN NUMBER,
    X_UNIT_LEVEL_MARK     IN NUMBER

  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_as_course_cd,
      x_as_version_number,
      x_s_adv_stnd_type,
      x_unit_level,
      x_crs_group_ind,
      x_exemption_institution_cd,
      x_s_adv_stnd_granting_status,
      x_credit_points,
      x_approved_dt,
      x_authorising_person_id,
      x_granted_dt,
      x_expiry_dt,
      x_cancelled_dt,
      x_revoked_dt,
      x_comments,
      X_AV_STND_UNIT_LVL_ID,
      X_CAL_TYPE,
      X_CI_SEQUENCE_NUMBER,
      X_INSTITUTION_CD,
      X_UNIT_DETAILS_ID,
      X_TST_RSLT_DTLS_ID,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      X_DEG_AUD_DETAIL_ID,
      X_QUAL_DETS_ID,
      X_UNIT_LEVEL_MARK
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
                                     p_updating  => FALSE,
                                     p_deleting  => FALSE,
                                     p_adv_stnd_trans => x_adv_stnd_trans);
      IF  Get_PK_For_Validation (
                new_references.av_stnd_unit_lvl_id
          ) THEN
               Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
               Igs_Ge_Msg_Stack.Add;
                App_Exception.Raise_Exception;
      END IF;
      check_uniqueness;
      Check_Constraints;
    Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating  => TRUE,
                                     p_deleting  => FALSE,
             p_adv_stnd_trans => 'N');
            check_uniqueness;
      Check_Constraints;
            Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating  => FALSE,
                                     p_deleting  => TRUE,
             p_adv_stnd_trans => 'N');

           Check_Child_Existance;
  ELSIF (p_action = 'VALIDATE_INSERT') THEN
        IF  Get_PK_For_Validation (
                new_references.av_stnd_unit_lvl_id
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
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdateDelete2( p_inserting => TRUE,
                                     p_updating  => FALSE,
                                     p_deleting  => FALSE);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdateDelete2( p_inserting => FALSE,
                                     p_updating  => TRUE,
                                     p_deleting  => FALSE);
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowInsertUpdateDelete2( p_inserting => FALSE,
                                     p_updating  => FALSE,
                                     p_deleting  => TRUE);
    END IF;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_AS_COURSE_CD in VARCHAR2,
  X_AS_VERSION_NUMBER in NUMBER,
  X_S_ADV_STND_TYPE in out NOCOPY VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_CRS_GROUP_IND in out NOCOPY VARCHAR2,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_S_ADV_STND_GRANTING_STATUS in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_APPROVED_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_GRANTED_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_CANCELLED_DT in DATE,
  X_REVOKED_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_AV_STND_UNIT_LVL_ID IN OUT NOCOPY NUMBER,
  X_CAL_TYPE            IN VARCHAR2,
  X_CI_SEQUENCE_NUMBER  IN NUMBER,
  X_INSTITUTION_CD      IN VARCHAR2,
  X_UNIT_DETAILS_ID     in NUMBER,
  X_TST_RSLT_DTLS_ID    in NUMBER,
  X_MODE    in VARCHAR2,
  X_ORG_ID    in NUMBER,
  X_ADV_STND_TRANS  IN VARCHAR2,  -- This parameter has been added for Career Impact DLD.
  X_DEG_AUD_DETAIL_ID IN NUMBER,
  X_QUAL_DETS_ID  IN NUMBER,
  X_UNIT_LEVEL_MARK     IN NUMBER
  ) AS
    cursor C is select ROWID from IGS_AV_STND_UNIT_LVL_ALL
      where av_stnd_unit_lvl_id = x_av_stnd_unit_lvl_id;

    X_LAST_UPDATE_DATE    DATE;
    X_LAST_UPDATED_BY   NUMBER;
    X_LAST_UPDATE_LOGIN   NUMBER;
    X_REQUEST_ID    NUMBER ;
    X_PROGRAM_ID    NUMBER ;
    X_PROGRAM_APPLICATION_ID  NUMBER ;
    X_PROGRAM_UPDATE_DATE DATE;
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
    if (X_REQUEST_ID  = -1) then
        X_REQUEST_ID := NULL ;
        X_PROGRAM_ID := NULL ;
        X_PROGRAM_APPLICATION_ID := NULL;
        X_PROGRAM_UPDATE_DATE := NULL;
     else
        X_PROGRAM_UPDATE_DATE := SYSDATE ;
     end if ;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
  select IGS_AV_STND_UNIT_LVL_S.NEXTVAL INTO x_av_stnd_unit_lvl_id FROM DUAL;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_approved_dt=>X_APPROVED_DT,
 x_as_course_cd=>X_AS_COURSE_CD,
 x_as_version_number=>X_AS_VERSION_NUMBER,
 x_authorising_person_id=>X_AUTHORISING_PERSON_ID,
 x_cancelled_dt=>X_CANCELLED_DT,
 x_comments=>X_COMMENTS,
 x_credit_points=>X_CREDIT_POINTS,
 x_crs_group_ind=>NVL(X_CRS_GROUP_IND,'N'),
 x_exemption_institution_cd=>X_EXEMPTION_INSTITUTION_CD,
 x_expiry_dt=>X_EXPIRY_DT,
 x_granted_dt=>X_GRANTED_DT,
 x_person_id=>X_PERSON_ID,
 x_revoked_dt=>X_REVOKED_DT,
 x_s_adv_stnd_granting_status=>X_S_ADV_STND_GRANTING_STATUS,
 x_s_adv_stnd_type=>NVL(X_S_ADV_STND_TYPE,'LEVEL'),
 x_unit_level=>X_UNIT_LEVEL,
 X_AV_STND_UNIT_LVL_ID=>X_AV_STND_UNIT_LVL_ID,
 X_CAL_TYPE =>X_CAL_TYPE,
 X_CI_SEQUENCE_NUMBER =>X_CI_SEQUENCE_NUMBER,
 X_INSTITUTION_CD =>X_INSTITUTION_CD,
 X_UNIT_DETAILS_ID =>X_UNIT_DETAILS_ID,
 X_TST_RSLT_DTLS_ID =>X_TST_RSLT_DTLS_ID,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_org_id=>igs_ge_gen_003.get_org_id,
 x_adv_stnd_trans=>X_ADV_STND_TRANS,
 X_DEG_AUD_DETAIL_ID  => X_DEG_AUD_DETAIL_ID,
 X_QUAL_DETS_ID => X_QUAL_DETS_ID,
 X_UNIT_LEVEL_MARK => X_UNIT_LEVEL_MARK
 );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_AV_STND_UNIT_LVL_ALL (
    PERSON_ID,
    AS_COURSE_CD,
    AS_VERSION_NUMBER,
    S_ADV_STND_TYPE,
    UNIT_LEVEL,
    CRS_GROUP_IND,
    EXEMPTION_INSTITUTION_CD,
    S_ADV_STND_GRANTING_STATUS,
    CREDIT_POINTS,
    APPROVED_DT,
    AUTHORISING_PERSON_ID,
    GRANTED_DT,
    EXPIRY_DT,
    CANCELLED_DT,
    REVOKED_DT,
    COMMENTS,
    AV_STND_UNIT_LVL_ID,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    INSTITUTION_CD,
    UNIT_DETAILS_ID,
    TST_RSLT_DTLS_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    ORG_ID,
    DEG_AUD_DETAIL_ID,
    QUAL_DETS_ID,
    UNIT_LEVEL_MARK
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.AS_COURSE_CD,
    NEW_REFERENCES.AS_VERSION_NUMBER,
    NEW_REFERENCES.S_ADV_STND_TYPE,
    NEW_REFERENCES.UNIT_LEVEL,
    NEW_REFERENCES.CRS_GROUP_IND,
    NEW_REFERENCES.EXEMPTION_INSTITUTION_CD,
    NEW_REFERENCES.S_ADV_STND_GRANTING_STATUS,
    NEW_REFERENCES.CREDIT_POINTS,
    NEW_REFERENCES.APPROVED_DT,
    NEW_REFERENCES.AUTHORISING_PERSON_ID,
    NEW_REFERENCES.GRANTED_DT,
    NEW_REFERENCES.EXPIRY_DT,
    NEW_REFERENCES.CANCELLED_DT,
    NEW_REFERENCES.REVOKED_DT,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.AV_STND_UNIT_LVL_ID,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.INSTITUTION_CD,
    NEW_REFERENCES.UNIT_DETAILS_ID,
    NEW_REFERENCES.TST_RSLT_DTLS_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.DEG_AUD_DETAIL_ID,
    NEW_REFERENCES.QUAL_DETS_ID,
    NEW_REFERENCES.UNIT_LEVEL_MARK
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


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
  X_UNIT_LEVEL in VARCHAR2,
  X_CRS_GROUP_IND in VARCHAR2,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_S_ADV_STND_GRANTING_STATUS in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_APPROVED_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_GRANTED_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_CANCELLED_DT in DATE,
  X_REVOKED_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_AV_STND_UNIT_LVL_ID IN NUMBER,
  X_CAL_TYPE            IN VARCHAR2,
  X_CI_SEQUENCE_NUMBER  IN NUMBER,
  X_INSTITUTION_CD      IN VARCHAR2,
  X_UNIT_DETAILS_ID     in NUMBER,
  X_TST_RSLT_DTLS_ID    in NUMBER,
  X_DEG_AUD_DETAIL_ID IN NUMBER,
  X_QUAL_DETS_ID  IN NUMBER,
  X_UNIT_LEVEL_MARK     IN NUMBER
) AS
  cursor c1 is select
      S_ADV_STND_GRANTING_STATUS,
      CREDIT_POINTS,
      APPROVED_DT,
      AUTHORISING_PERSON_ID,
      GRANTED_DT,
      EXPIRY_DT,
      CANCELLED_DT,
      REVOKED_DT,
      COMMENTS,
      AV_STND_UNIT_LVL_ID,
      CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      INSTITUTION_CD,
      UNIT_DETAILS_ID,
      TST_RSLT_DTLS_ID,
      DEG_AUD_DETAIL_ID,
      QUAL_DETS_ID,
      UNIT_LEVEL_MARK
    from IGS_AV_STND_UNIT_LVL_ALL
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
  if ( (tlinfo.S_ADV_STND_GRANTING_STATUS = X_S_ADV_STND_GRANTING_STATUS)
      AND (tlinfo.CREDIT_POINTS = X_CREDIT_POINTS)
      AND (TRUNC(tlinfo.APPROVED_DT) = TRUNC(X_APPROVED_DT))
      AND (tlinfo.AUTHORISING_PERSON_ID = X_AUTHORISING_PERSON_ID)
      AND ((TRUNC(tlinfo.GRANTED_DT) = TRUNC(X_GRANTED_DT)) -- Added 'Trunc' to fix bug# 2344136.
           OR ((tlinfo.GRANTED_DT is null)
               AND (X_GRANTED_DT is null)))
      AND ((TRUNC(tlinfo.EXPIRY_DT) = TRUNC(X_EXPIRY_DT))
           OR ((tlinfo.EXPIRY_DT is null)
               AND (X_EXPIRY_DT is null)))
      AND ((TRUNC(tlinfo.CANCELLED_DT) = TRUNC(X_CANCELLED_DT))
           OR ((tlinfo.CANCELLED_DT is null)
               AND (X_CANCELLED_DT is null)))
      AND ((TRUNC(tlinfo.REVOKED_DT) = TRUNC(X_REVOKED_DT))
           OR ((tlinfo.REVOKED_DT is null)
               AND (X_REVOKED_DT is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      AND ((tlinfo.CAL_TYPE = X_CAL_TYPE)
           OR ((tlinfo.CAL_TYPE is null)
               AND (X_CAL_TYPE is null)))
      AND ((tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.CI_SEQUENCE_NUMBER is null)
               AND (X_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.INSTITUTION_CD = X_INSTITUTION_CD)
           OR ((tlinfo.INSTITUTION_CD is null)
               AND (X_INSTITUTION_CD is null)))
      AND ((tlinfo.UNIT_DETAILS_ID = X_UNIT_DETAILS_ID)
           OR ((tlinfo.UNIT_DETAILS_ID is null)
               AND (X_UNIT_DETAILS_ID is null)))
      AND ((tlinfo.TST_RSLT_DTLS_ID = X_TST_RSLT_DTLS_ID)
           OR ((tlinfo.TST_RSLT_DTLS_ID is null)
              AND (X_TST_RSLT_DTLS_ID is null)))
      AND ((tlinfo.DEG_AUD_DETAIL_ID = X_DEG_AUD_DETAIL_ID)
           OR ((tlinfo.DEG_AUD_DETAIL_ID is null)
              AND (X_DEG_AUD_DETAIL_ID is null)))
      AND ((tlinfo.QUAL_DETS_ID = X_QUAL_DETS_ID)
           OR ((tlinfo.QUAL_DETS_ID is null)
              AND (X_QUAL_DETS_ID is null)))
      AND ((tlinfo.UNIT_LEVEL_MARK = X_UNIT_LEVEL_MARK)
           OR ((tlinfo.UNIT_LEVEL_MARK is null)
              AND (X_UNIT_LEVEL_MARK is null)))
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
  X_UNIT_LEVEL in VARCHAR2,
  X_CRS_GROUP_IND in VARCHAR2,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_S_ADV_STND_GRANTING_STATUS in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_APPROVED_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_GRANTED_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_CANCELLED_DT in DATE,
  X_REVOKED_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_AV_STND_UNIT_LVL_ID IN NUMBER,
  X_CAL_TYPE            IN VARCHAR2,
  X_CI_SEQUENCE_NUMBER  IN NUMBER,
  X_INSTITUTION_CD      IN VARCHAR2,
  X_UNIT_DETAILS_ID     in NUMBER,
  X_TST_RSLT_DTLS_ID    in NUMBER,
  X_DEG_AUD_DETAIL_ID   IN NUMBER,
  X_MODE    in VARCHAR2,
  X_QUAL_DETS_ID  IN NUMBER,
  X_UNIT_LEVEL_MARK     IN NUMBER
  ) AS

    X_LAST_UPDATE_DATE    DATE;
    X_LAST_UPDATED_BY   NUMBER;
    X_LAST_UPDATE_LOGIN   NUMBER;
    X_REQUEST_ID    NUMBER;
    X_PROGRAM_ID    NUMBER ;
    X_PROGRAM_APPLICATION_ID  NUMBER ;
    X_PROGRAM_UPDATE_DATE DATE;
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

Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_approved_dt=>X_APPROVED_DT,
 x_as_course_cd=>X_AS_COURSE_CD,
 x_as_version_number=>X_AS_VERSION_NUMBER,
 x_authorising_person_id=>X_AUTHORISING_PERSON_ID,
 x_cancelled_dt=>X_CANCELLED_DT,
 x_comments=>X_COMMENTS,
 x_credit_points=>X_CREDIT_POINTS,
 x_crs_group_ind=>X_CRS_GROUP_IND,
 x_exemption_institution_cd=>X_EXEMPTION_INSTITUTION_CD,
 x_expiry_dt=>X_EXPIRY_DT,
 x_granted_dt=>X_GRANTED_DT,
 x_person_id=>X_PERSON_ID,
 x_revoked_dt=>X_REVOKED_DT,
 x_s_adv_stnd_granting_status=>X_S_ADV_STND_GRANTING_STATUS,
 x_s_adv_stnd_type=>X_S_ADV_STND_TYPE,
 x_unit_level=>X_UNIT_LEVEL,
 X_AV_STND_UNIT_LVL_ID => X_AV_STND_UNIT_LVL_ID,
 X_CAL_TYPE =>X_CAL_TYPE,
 X_CI_SEQUENCE_NUMBER =>X_CI_SEQUENCE_NUMBER,
 X_INSTITUTION_CD =>X_INSTITUTION_CD,
 X_UNIT_DETAILS_ID =>X_UNIT_DETAILS_ID,
 X_TST_RSLT_DTLS_ID =>X_TST_RSLT_DTLS_ID,
 X_DEG_AUD_DETAIL_ID  =>   X_DEG_AUD_DETAIL_ID ,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 X_QUAL_DETS_ID => X_QUAL_DETS_ID,
 X_UNIT_LEVEL_MARK => X_UNIT_LEVEL_MARK
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
  end if ;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  UPDATE IGS_AV_STND_UNIT_LVL_ALL SET
    S_ADV_STND_GRANTING_STATUS = NEW_REFERENCES.S_ADV_STND_GRANTING_STATUS,
    CREDIT_POINTS = NEW_REFERENCES.CREDIT_POINTS,
    APPROVED_DT = NEW_REFERENCES.APPROVED_DT,
    AUTHORISING_PERSON_ID = NEW_REFERENCES.AUTHORISING_PERSON_ID,
    GRANTED_DT = NEW_REFERENCES.GRANTED_DT,
    EXPIRY_DT = NEW_REFERENCES.EXPIRY_DT,
    CANCELLED_DT = NEW_REFERENCES.CANCELLED_DT,
    REVOKED_DT = NEW_REFERENCES.REVOKED_DT,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
    CI_SEQUENCE_NUMBER = NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    INSTITUTION_CD = NEW_REFERENCES.INSTITUTION_CD,
    UNIT_DETAILS_ID = NEW_REFERENCES.UNIT_DETAILS_ID,
    TST_RSLT_DTLS_ID = NEW_REFERENCES.TST_RSLT_DTLS_ID,
    DEG_AUD_DETAIL_ID   =  NEW_REFERENCES.DEG_AUD_DETAIL_ID ,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    QUAL_DETS_ID = X_QUAL_DETS_ID,
    UNIT_LEVEL_MARK = X_UNIT_LEVEL_MARK
  where rowid = X_ROWID ;
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
  X_ROWID     in out NOCOPY VARCHAR2,
  X_PERSON_ID     in NUMBER,
  X_AS_COURSE_CD    in VARCHAR2,
  X_AS_VERSION_NUMBER   in NUMBER,
  X_S_ADV_STND_TYPE   in out NOCOPY VARCHAR2,
  X_UNIT_LEVEL      in VARCHAR2,
  X_CRS_GROUP_IND   in out NOCOPY VARCHAR2,
  X_EXEMPTION_INSTITUTION_CD  in VARCHAR2,
  X_S_ADV_STND_GRANTING_STATUS  in VARCHAR2,
  X_CREDIT_POINTS   in NUMBER,
  X_APPROVED_DT     in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_GRANTED_DT      in DATE,
  X_EXPIRY_DT     in DATE,
  X_CANCELLED_DT    in DATE,
  X_REVOKED_DT      in DATE,
  X_COMMENTS      in VARCHAR2,
  X_AV_STND_UNIT_LVL_ID   IN OUT NOCOPY NUMBER,
  X_CAL_TYPE      IN VARCHAR2,
  X_CI_SEQUENCE_NUMBER    IN NUMBER,
  X_INSTITUTION_CD    IN VARCHAR2,
  X_UNIT_DETAILS_ID   in NUMBER,
  X_TST_RSLT_DTLS_ID    in NUMBER,
  X_MODE      in VARCHAR2,
  X_ORG_ID      in NUMBER,
  X_DEG_AUD_DETAIL_ID   IN NUMBER,
  X_QUAL_DETS_ID    IN NUMBER,
  X_UNIT_LEVEL_MARK     IN NUMBER
  ) AS
  cursor c1 is select rowid from IGS_AV_STND_UNIT_LVL_ALL
     where AV_STND_UNIT_LVL_ID =X_AV_STND_UNIT_LVL_ID;
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
     X_UNIT_LEVEL,
     X_CRS_GROUP_IND,
     X_EXEMPTION_INSTITUTION_CD,
     X_S_ADV_STND_GRANTING_STATUS,
     X_CREDIT_POINTS,
     X_APPROVED_DT,
     X_AUTHORISING_PERSON_ID,
     X_GRANTED_DT,
     X_EXPIRY_DT,
     X_CANCELLED_DT,
     X_REVOKED_DT,
     X_COMMENTS,
     X_AV_STND_UNIT_LVL_ID,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_INSTITUTION_CD,
     X_UNIT_DETAILS_ID,
     X_TST_RSLT_DTLS_ID,
     X_MODE,
     X_ORG_ID,
     X_DEG_AUD_DETAIL_ID,
     X_QUAL_DETS_ID,
     X_UNIT_LEVEL_MARK
     );
    return;
  end if;
  close c1;

  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_AS_COURSE_CD,
   X_AS_VERSION_NUMBER,
   X_S_ADV_STND_TYPE,
   X_UNIT_LEVEL,
   X_CRS_GROUP_IND,
   X_EXEMPTION_INSTITUTION_CD,
   X_S_ADV_STND_GRANTING_STATUS,
   X_CREDIT_POINTS,
   X_APPROVED_DT,
   X_AUTHORISING_PERSON_ID,
   X_GRANTED_DT,
   X_EXPIRY_DT,
   X_CANCELLED_DT,
   X_REVOKED_DT,
   X_COMMENTS,
   X_AV_STND_UNIT_LVL_ID,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_INSTITUTION_CD,
   X_UNIT_DETAILS_ID,
   X_TST_RSLT_DTLS_ID,
   X_MODE,
   X_DEG_AUD_DETAIL_ID,
   X_QUAL_DETS_ID,
   X_UNIT_LEVEL_MARK
   );

end ADD_ROW;


procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_AV_STND_UNIT_LVL_ALL
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

end IGS_AV_STND_UNIT_LVL_PKG;

/
