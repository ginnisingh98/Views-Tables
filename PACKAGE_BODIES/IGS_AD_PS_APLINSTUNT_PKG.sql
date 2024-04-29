--------------------------------------------------------
--  DDL for Package Body IGS_AD_PS_APLINSTUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PS_APLINSTUNT_PKG" as
/* $Header: IGSAI20B.pls 120.3 2005/10/03 08:19:56 appldev ship $*/
  l_rowid VARCHAR2(25);
  old_references IGS_AD_PS_APLINSTUNT_ALL%RowType;
  new_references IGS_AD_PS_APLINSTUNT_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
                x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_acai_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
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
    x_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PS_APLINSTUNT_ALL
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
    new_references.uv_version_number := x_uv_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.unit_class:= x_unit_class;
    new_references.unit_mode:= x_unit_mode;
    new_references.adm_unit_outcome_status:= x_adm_unit_outcome_status;
    new_references.ass_tracking_id := x_ass_tracking_id;
    new_references.rule_waived_dt := TRUNC(x_rule_waived_dt);
    new_references.rule_waived_person_id := x_rule_waived_person_id;
    new_references.sup_unit_cd := x_sup_unit_cd;
    new_references.sup_uv_version_number := x_sup_uv_version_number;
    new_references.adm_ps_appl_inst_unit_id := x_adm_ps_appl_inst_unit_id;
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
        v_message_name                  varchar2(30);
        v_return_type                   VARCHAR2(1);
        v_person_id                     IGS_AD_APPL.person_id%TYPE;
        v_admission_appl_number         IGS_AD_APPL.admission_appl_number%TYPE;
        v_nominated_course_cd           IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE;
        v_acai_sequence_number          IGS_AD_PS_APPL_INST.sequence_number%TYPE;
        v_admission_cat                 IGS_AD_APPL.admission_cat%TYPE;
        v_s_admission_process_type      IGS_AD_APPL.s_admission_process_type%TYPE;
        v_acad_cal_type                 IGS_AD_APPL.acad_cal_type%TYPE;
        v_aa_acad_ci_sequence_number    IGS_AD_APPL.acad_ci_sequence_number%TYPE;
        v_aa_adm_cal_type               IGS_AD_APPL.adm_cal_type%TYPE;
        v_aa_adm_ci_sequence_number     IGS_AD_APPL.adm_ci_sequence_number%TYPE;
        v_acad_ci_sequence_number       IGS_AD_APPL.acad_ci_sequence_number%TYPE;
        v_adm_cal_type                  IGS_AD_APPL.adm_cal_type%TYPE;
        v_adm_ci_sequence_number        IGS_AD_APPL.adm_ci_sequence_number%TYPE;
        v_appl_dt                               IGS_AD_APPL.appl_dt%TYPE;
        v_adm_appl_status               IGS_AD_APPL.adm_appl_status%TYPE;
        v_adm_fee_status                        IGS_AD_APPL.adm_fee_status%TYPE;
        v_acai_adm_cal_type             IGS_AD_PS_APPL_INST.adm_cal_type%TYPE;
        v_acai_adm_ci_sequence_number
                        IGS_AD_PS_APPL_INST.adm_ci_sequence_number%TYPE;
        v_offer_ind                     VARCHAR2(1);
        v_unit_encmb_chk_ind            VARCHAR2(1);
        v_unit_restr_ind                        VARCHAR2(1);
        cst_error                               CONSTANT        VARCHAR2(1):= 'E';
        CURSOR c_apcs (
                cp_admission_cat                IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                cp_s_admission_process_type IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
        SELECT  s_admission_step_type
        FROM    IGS_AD_PRCS_CAT_STEP
        WHERE   admission_cat = cp_admission_cat AND
                s_admission_process_type = cp_s_admission_process_type AND
                step_group_type <> 'TRACK'; --2402377
        CURSOR c_acai (
                cp_person_id            IGS_AD_PS_APPL_INST.person_id%TYPE,
                cp_admission_appl_number        IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                cp_nominated_course_cd  IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
                cp_sequence_number      IGS_AD_PS_APPL_INST.sequence_number%TYPE) IS
        SELECT  adm_cal_type,
                adm_ci_sequence_number,
                course_cd
        FROM    IGS_AD_PS_APPL_INST
        WHERE   person_id = cp_person_id AND
                admission_appl_number = cp_admission_appl_number AND
                nominated_course_cd = cp_nominated_course_cd AND
                sequence_number = cp_sequence_number;
        v_acai_rec      c_acai%ROWTYPE;
  BEGIN
        v_offer_ind             := 'N';
        v_unit_encmb_chk_ind    := 'N';
        v_unit_restr_ind        := 'N';

        IF p_inserting OR p_updating OR p_deleting THEN
                IF p_deleting THEN
                        v_person_id := old_references.person_id;
                        v_admission_appl_number := old_references.admission_appl_number;
                        v_nominated_course_cd := old_references.nominated_course_cd;
                        v_acai_sequence_number := old_references.acai_sequence_number;
                ELSE
                        v_person_id := new_references.person_id;
                        v_admission_appl_number := new_references.admission_appl_number;
                        v_nominated_course_cd := new_references.nominated_course_cd;
                        v_acai_sequence_number := new_references.acai_sequence_number;
                END IF;
                -- Get admission application details required for validation.
                IGS_AD_GEN_002.ADMP_GET_AA_DTL(
                        v_person_id,
                        v_admission_appl_number,
                        v_admission_cat,
                        v_s_admission_process_type,
                        v_acad_cal_type,
                        v_aa_acad_ci_sequence_number,
                        v_aa_adm_cal_type,
                        v_aa_adm_ci_sequence_number,
                        v_appl_dt,
                        v_adm_appl_status,
                        v_adm_fee_status);
                FOR v_apcs_rec IN c_apcs (
                                v_admission_cat,
                                v_s_admission_process_type)
                LOOP
                        IF v_apcs_rec.s_admission_step_type = 'CHKUENCUMB' THEN
                                v_unit_encmb_chk_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'UNIT-RESTR' THEN
                                v_unit_restr_ind := 'Y';
                        END IF;
                END LOOP;
                -- Validate inserts,updates,deletes
                IF IGS_AD_VAL_ACAIU.admp_val_acaiu_iud(
                        v_person_id,
                        v_admission_appl_number,
                        v_nominated_course_cd,
                        v_acai_sequence_number,
                        v_unit_restr_ind,
                        v_message_name) = FALSE THEN
                Fnd_Message.Set_Name('IGS',v_message_name);
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END IF;
        END IF;
        IF p_inserting OR p_updating THEN
                -- Determine the Academic and Admission period for validation.
                OPEN c_acai (
                        new_references.person_id,
                        new_references.admission_appl_number,
                        new_references.nominated_course_cd,
                        new_references.acai_sequence_number);
                FETCH c_acai INTO v_acai_rec;
                CLOSE c_acai;
                IF  v_acai_rec.adm_cal_type IS NULL THEN
                        v_acad_ci_sequence_number := v_aa_acad_ci_sequence_number;
                        v_adm_cal_type := v_aa_adm_cal_type;
                        v_adm_ci_sequence_number := v_aa_adm_ci_sequence_number;
                ELSE
                        v_acad_ci_sequence_number := IGS_CA_GEN_001.CALP_GET_SUP_INST (
                                                        v_acad_cal_type,
                                                        v_acai_rec.adm_cal_type,
                                                        v_acai_rec.adm_ci_sequence_number);
                        v_adm_cal_type := v_acai_rec.adm_cal_type;
                        v_adm_ci_sequence_number := v_acai_rec.adm_ci_sequence_number;
                END IF;
                -- Determine the offer indicator.
                IF NVL(IGS_AD_GEN_008.ADMP_GET_SAUOS(new_references.adm_unit_outcome_status), 'NONE') = 'OFFER' THEN
                        v_offer_ind := 'Y';
                END IF;
        END IF;
        IF p_inserting THEN
                -- Validate the unit code.
                IF IGS_AD_VAL_ACAIU.admp_val_acaiu_unit (
                        new_references.unit_cd,
                        new_references.uv_version_number,
                        v_adm_cal_type,
                        v_adm_ci_sequence_number,
                        v_acad_cal_type,
                        v_acad_ci_sequence_number,
                        v_s_admission_process_type,
                        v_offer_ind,
                        v_message_name) = FALSE THEN
                Fnd_Message.Set_Name('IGS',v_message_name);
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
                END IF;
                -- Validate a research unit.
                IF IGS_AD_VAL_ACAIU.admp_val_res_unit (
                                new_references.person_id,
                                new_references.admission_appl_number,
                                new_references.nominated_course_cd,
                                new_references.acai_sequence_number,
                                new_references.unit_cd,
                                new_references.uv_version_number,
                                v_acai_rec.course_cd,
                                v_offer_ind,
                                v_s_admission_process_type,
                                v_message_name,
                                v_return_type) = FALSE THEN
                        IF v_return_type = cst_error THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validate unit encumbrances.
                IF v_unit_encmb_chk_ind = 'Y' THEN
                        IF IGS_AD_VAL_ACAIU.admp_val_acaiu_encmb (
                                        new_references.person_id,
                                        v_acai_rec.course_cd,
                                        new_references.unit_cd,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_unit_encmb_chk_ind,
                                        v_offer_ind,
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                END IF;
        END IF;
        IF p_inserting OR p_updating THEN
                -- Validate admission unit outcome status
                IF NVL(old_references.adm_unit_outcome_status, '-1') <>
                                        new_references.adm_unit_outcome_status THEN
                        IF IGS_AD_VAL_ACAIU.admp_val_acaiu_auos (
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.acai_sequence_number,
                                        new_references.adm_unit_outcome_status,
                                        v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                        END IF;
                        IF v_offer_ind = 'Y' THEN
                                -- Validate that unit version is active
                                IF IGS_AD_VAL_ACAIU.admp_val_acaiu_uv(
                                        new_references.unit_cd,
                                        new_references.uv_version_number,
                                        v_s_admission_process_type,
                                        v_offer_ind,
                                        v_message_name) = FALSE THEN
                                Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                                END IF;
                                -- Validate a research unit.
                                IF IGS_AD_VAL_ACAIU.admp_val_res_unit (
                                                new_references.person_id,
                                                new_references.admission_appl_number,
                                                new_references.nominated_course_cd,
                                                new_references.acai_sequence_number,
                                                new_references.unit_cd,
                                                new_references.uv_version_number,
                                                v_acai_rec.course_cd,
                                                v_offer_ind,
                                                v_s_admission_process_type,
                                                v_message_name,
                                                v_return_type) = FALSE THEN
                                        IF v_return_type = cst_error THEN
                                        Fnd_Message.Set_Name('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_Exception;
                                        END IF;
                                END IF;
                        END IF;
                END IF;
                -- Validate unit mode.
                IF (NVL(old_references.unit_mode, '-1') <> NVL(new_references.unit_mode, '-1'))  THEN
                -- As part of the bug# 1956374 changed to the below call from IGS_AD_VAL_ACAIU.crsp_val_um_closed
                        IF IGS_AS_VAL_UAI.crsp_val_um_closed (
                                        new_references.unit_mode,
                                        v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF (NVL(old_references.unit_mode, '-1') <> NVL(new_references.unit_mode, '-1')) OR
                                (NVL(old_references.unit_class, '-1') <> NVL(new_references.unit_class, '-1')) THEN
                        IF IGS_AD_VAL_ACAIU.admp_val_acaiu_um (
                                        new_references.unit_class,
                                        new_references.unit_mode,
                                        v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validate the options of the admission course application unit
                IF (NVL(old_references.uv_version_number, -1) <> new_references.uv_version_number) OR
                                (NVL(old_references.cal_type, '-1') <> NVL(new_references.cal_type, '-1')) OR
                                (NVL(old_references.ci_sequence_number, -1) <> NVL(new_references.ci_sequence_number, -1)) OR
                                (NVL(old_references.location_cd, '-1') <> NVL(new_references.location_cd, '-1')) OR
                                (NVL(old_references.unit_class, '-1') <> NVL(new_references.unit_class, '-1')) OR
                                (NVL(old_references.unit_mode, '-1') <> NVL(new_references.unit_mode, '-1')) OR
                                ((NVL(old_references.adm_unit_outcome_status, '-1') <>
                                                new_references.adm_unit_outcome_status) AND
                                v_offer_ind = 'Y') THEN
                        IF IGS_AD_VAL_ACAIU.admp_val_acaiu_opt (
                                        new_references.unit_cd,
                                        new_references.uv_version_number,
                                        new_references.cal_type,
                                        new_references.ci_sequence_number,
                                        new_references.location_cd,
                                        new_references.unit_class,
                                        new_references.unit_mode,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_acad_cal_type,
                                        v_acad_ci_sequence_number,
                                        v_offer_ind,
                                        v_message_name) = FALSE THEN
                                Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validate the unit version against the teaching period.
                IF (NVL(old_references.uv_version_number, -1) <> new_references.uv_version_number) OR
                                (NVL(old_references.cal_type, '-1') <> NVL(new_references.cal_type, '-1')) OR
                                (NVL(old_references.ci_sequence_number, -1) <> NVL(new_references.ci_sequence_number, -1)) THEN
                        IF IGS_AD_VAL_ACAIU.admp_val_acaiu_uv_ci (
                                        new_references.unit_cd,
                                        new_references.uv_version_number,
                                        new_references.cal_type,
                                        new_references.ci_sequence_number,
                                        v_message_name) = FALSE THEN
                                Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                        END IF;
                END IF;
        END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
        v_admission_cat                 IGS_AD_APPL.admission_cat%TYPE;
        v_s_admission_process_type      IGS_AD_APPL.s_admission_process_type%TYPE;
        v_acad_cal_type                 IGS_AD_APPL.acad_cal_type%TYPE;
        v_aa_acad_ci_sequence_number    IGS_AD_APPL.acad_ci_sequence_number%TYPE;
        v_aa_adm_cal_type               IGS_AD_APPL.adm_cal_type%TYPE;
        v_aa_adm_ci_sequence_number     IGS_AD_APPL.adm_ci_sequence_number%TYPE;
        v_acad_ci_sequence_number       IGS_AD_APPL.acad_ci_sequence_number%TYPE;
        v_adm_cal_type                  IGS_AD_APPL.adm_cal_type%TYPE;
        v_adm_ci_sequence_number        IGS_AD_APPL.adm_ci_sequence_number%TYPE;
        v_appl_dt                               DATE;
        v_adm_appl_status               IGS_AD_APPL.adm_appl_status%TYPE;
        v_adm_fee_status                        IGS_AD_APPL.adm_fee_status%TYPE;
        v_unit_restriction_ind          VARCHAR2(1);
        v_unit_restriction_num          NUMBER;
        v_message_name varchar2(30);
        CURSOR c_apcs (
                cp_admission_cat                IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                cp_s_admission_process_type
                                        IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
        SELECT s_admission_step_type,
                step_type_restriction_num
        FROM    IGS_AD_PRCS_CAT_STEP
        WHERE   admission_cat = cp_admission_cat AND
                s_admission_process_type = cp_s_admission_process_type AND
                step_group_type <> 'TRACK'; --2402377
  BEGIN
        v_unit_restriction_ind := 'N';
        IF  p_inserting OR p_updating THEN
                IF p_inserting THEN
                        --
                        -- Get admission application details required for validation.
                        --
                        IGS_AD_GEN_002.ADMP_GET_AA_DTL(
                                new_references.person_id,
                                new_references.admission_appl_number,
                                v_admission_cat,
                                v_s_admission_process_type,
                                v_acad_cal_type,
                                v_aa_acad_ci_sequence_number,
                                v_aa_adm_cal_type,
                                v_aa_adm_ci_sequence_number,
                                v_appl_dt,
                                v_adm_appl_status,
                                v_adm_fee_status);
                        --
                        -- Determine the admission process category steps.
                        --
                        FOR v_apcs_rec IN c_apcs (
                                        v_admission_cat,
                                        v_s_admission_process_type)
                        LOOP
                                IF v_apcs_rec.s_admission_step_type = 'UNIT-RESTR' THEN
                                        v_unit_restriction_num := v_apcs_rec.step_type_restriction_num;
                                END IF;
                        END LOOP;
                END IF;
                IF      p_inserting THEN
                        -- Validate restriction number of admission course application instance unit.
                        IF IGS_AD_VAL_ACAIU.admp_val_acaiu_restr (
                                new_references.person_id,
                                new_references.admission_appl_number,
                                new_references.nominated_course_cd,
                                new_references.acai_sequence_number,
                                new_references.unit_cd,
                                v_unit_restriction_num,
                                v_message_name,
          new_references.uv_version_number,
          new_references.cal_type,
          new_references.ci_sequence_number,
          new_references.location_cd,
          new_references.unit_class ) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        Fnd_Message.Set_Token('UNIT_RSTR_NUM',IGS_GE_NUMBER.TO_CANN(v_unit_restriction_num));
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Save the rowid of the current row.
        END IF;
  END AfterRowInsertUpdate2;

  -- Trigger description :-
  -- "OSS_TST".trg_acaiu_ar_ud_hist
  -- AFTER DELETE OR UPDATE
  -- ON IGS_AD_PS_APLINSTUNT
  -- FOR EACH ROW

  PROCEDURE AfterRowUpdateDelete3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
   v_message_name                       varchar2(30);
   CURSOR c_acaiuh IS
                SELECT rowid,acaiuh.*
                FROM    IGS_AD_PS_APINTUNTHS    acaiuh
                WHERE   acaiuh.adm_ps_appl_inst_unit_id = old_references.adm_ps_appl_inst_unit_id
                FOR UPDATE OF acaiuh.person_id NOWAIT;
   v_acaiuh_rec c_acaiuh%ROWTYPE;
  BEGIN
        IF p_updating THEN
                -- Create admission course application instance unit history record.
                IGS_AD_GEN_010.ADMP_INS_ACAIU_HIST (
                        new_references.person_id,
                        new_references.admission_appl_number,
                        new_references.nominated_course_cd,
                        new_references.acai_sequence_number,
                        new_references.unit_cd,
                        new_references.adm_ps_appl_inst_unit_id,
                        new_references.uv_version_number,
                        old_references.uv_version_number,
                        new_references.cal_type,
                        old_references.cal_type,
                        new_references.ci_sequence_number,
                        old_references.ci_sequence_number,
                        new_references.location_cd,
                        old_references.location_cd,
                        new_references.unit_class,
                        old_references.unit_class,
                        new_references.unit_mode,
                        old_references.unit_mode,
                        new_references.adm_unit_outcome_status,
                        old_references.adm_unit_outcome_status,
                        new_references.ass_tracking_id,
                        old_references.ass_tracking_id,
                        TRUNC(new_references.rule_waived_dt),
                        TRUNC(old_references.rule_waived_dt),
                        new_references.rule_waived_person_id,
                        old_references.rule_waived_person_id,
                        new_references.sup_unit_cd,
                        old_references.sup_unit_cd,
                        new_references.sup_uv_version_number,
                        old_references.sup_uv_version_number,
                        new_references.last_updated_by,
                        old_references.last_updated_by,
                        new_references.last_update_date,
                        old_references.last_update_date);
        END IF;
        IF p_deleting THEN
                -- Delete admission course application instance unit history records.

            FOR v_acaiuh_rec IN c_acaiuh LOOP

                        IGS_AD_PS_APINTUNTHS_PKG.DELETE_ROW (
                            X_ROWID => v_acaiuh_rec.rowid );

                END LOOP;

        END IF;


  END AfterRowUpdateDelete3;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number) AND
         (old_references.nominated_course_cd = new_references.nominated_course_cd) AND
         (old_references.acai_sequence_number = new_references.acai_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL) OR
         (new_references.nominated_course_cd IS NULL) OR
         (new_references.acai_sequence_number IS NULL))) THEN
      NULL;
    ELSE

        IF NOT IGS_AD_PS_APPL_INST_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.nominated_course_cd,
        new_references.acai_sequence_number
        ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF (((old_references.adm_unit_outcome_status = new_references.adm_unit_outcome_status)) OR
        ((new_references.adm_unit_outcome_status IS NULL))) THEN
      NULL;
    ELSE
         IF NOT IGS_AD_UNIT_OU_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_unit_outcome_status , 'N'
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
         IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd , 'N'
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF (((old_references.rule_waived_person_id = new_references.rule_waived_person_id)) OR
        ((new_references.rule_waived_person_id IS NULL))) THEN
      NULL;
    ELSE
         IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.rule_waived_person_id
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF (((old_references.sup_unit_cd = new_references.sup_unit_cd) AND
         (old_references.sup_uv_version_number = new_references.sup_uv_version_number)) OR
        ((new_references.sup_unit_cd IS NULL) OR
         (new_references.sup_uv_version_number IS NULL))) THEN
      NULL;
    ELSE
         IF NOT IGS_PS_UNIT_VER_PKG.Get_PK_For_Validation (
        new_references.sup_unit_cd,
                new_references.sup_uv_version_number
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF (((old_references.ass_tracking_id = new_references.ass_tracking_id)) OR
        ((new_references.ass_tracking_id IS NULL))) THEN
      NULL;
    ELSE
         IF NOT IGS_TR_ITEM_PKG.Get_PK_For_Validation (
        new_references.ass_tracking_id
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF (((old_references.unit_class = new_references.unit_class)) OR
        ((new_references.unit_class IS NULL))) THEN
      NULL;
    ELSE
         IF NOT IGS_AS_UNIT_CLASS_PKG.Get_PK_For_Validation (
        new_references.unit_class
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF (((old_references.unit_mode= new_references.unit_mode)) OR
        ((new_references.unit_mode IS NULL))) THEN
      NULL;
    ELSE
         IF NOT IGS_AS_UNIT_MODE_PKG.Get_PK_For_Validation (
        new_references.unit_mode
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.uv_version_number = new_references.uv_version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.location_cd = new_references.location_cd) AND
         (old_references.unit_class = new_references.unit_class)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.uv_version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.location_cd IS NULL) OR
         (new_references.unit_class IS NULL))) THEN
      NULL;
    ELSE
         IF NOT IGS_PS_UNIT_OFR_OPT_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.uv_version_number,
        new_references.cal_type,
        new_references.ci_sequence_number,
        new_references.location_cd,
        new_references.unit_class
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.uv_version_number = new_references.uv_version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.uv_version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
         IF NOT IGS_PS_UNIT_OFR_PAT_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.uv_version_number,
        new_references.cal_type,
        new_references.ci_sequence_number
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
         END IF;
    END IF;

  END Check_Parent_Existance;

PROCEDURE Check_Constraints (
         Column_Name    IN      VARCHAR2        DEFAULT NULL,
         Column_Value   IN      VARCHAR2        DEFAULT NULL
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
 ELSIF upper(Column_name) = 'UNIT_CD' then
     new_references.unit_cd := column_value;
 ELSIF upper(Column_name) = 'UNIT_CLASS' then
     new_references.unit_class := column_value;
 ELSIF upper(Column_name) = 'UNIT_MODE' then
     new_references.unit_mode := column_value;
 ELSIF upper(Column_name) = 'SUP_UNIT_CD' then
     new_references.sup_unit_cd := column_value;
 ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
     new_references.ci_sequence_number := igs_ge_number.to_num(column_value);
 END IF;

IF upper(column_name) = 'ADM_UNIT_OUTCOME_STATUS' OR
     column_name is null Then
     IF new_references.adm_unit_outcome_status <> UPPER(new_references.adm_unit_outcome_status) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'CAL_TYPE' OR
     column_name is null Then
     IF new_references.cal_type <> UPPER(new_references.cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'LOCATION_CD' OR
     column_name is null Then
     IF new_references.location_cd <> UPPER(new_references.location_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.unit_cd <> UPPER(new_references.unit_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'UNIT_CLASS' OR
     column_name is null Then
     IF new_references.unit_class <> UPPER(new_references.unit_class) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'UNIT_MODE' OR
     column_name is null Then
     IF new_references.unit_mode <> UPPER(new_references.unit_mode) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'SUP_UNIT_CD' OR
     column_name is null Then
     IF new_references.sup_unit_cd <> UPPER(new_references.sup_unit_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.ci_sequence_number  < 1 OR
          new_references.ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
        END IF;
END IF;

END Check_Constraints;

FUNCTION Get_PK_For_Validation (
    x_adm_ps_appl_inst_unit_id IN NUMBER
    )
RETURN BOOLEAN
AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    adm_ps_appl_inst_unit_id = x_adm_ps_appl_inst_unit_id
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
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_acai_sequence_number IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_uv_version_number IN NUMBER ,
    x_cal_type IN VARCHAR2 ,
    x_ci_sequence_number IN NUMBER ,
    x_location_cd IN VARCHAR2 ,
    x_unit_class IN VARCHAR2
    )
RETURN BOOLEAN
AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
      AND      acai_sequence_number = x_acai_sequence_number
      AND      unit_cd = x_unit_cd
      AND      uv_version_number = x_uv_version_number
      AND      NVL(cal_type,'*') = NVL(x_cal_type,'*')
      AND      NVL(ci_sequence_number,-1) = NVL(x_ci_sequence_number,-1)
      AND      NVL(location_cd,'*') = NVL(x_location_cd,'*')
      AND      NVL(unit_class,'*') = NVL(x_unit_class,'*')
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

  PROCEDURE GET_FK_IGS_AD_PS_APPL_INST (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
      AND      acai_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAIU_ACAI_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
       Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_PS_APPL_INST;

  PROCEDURE GET_FK_IGS_AD_UNIT_OU_STAT (
    x_adm_unit_outcome_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    adm_unit_outcome_status = x_adm_unit_outcome_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAIU_AUOS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_UNIT_OU_STAT;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    location_cd = x_location_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAIU_LOC_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    rule_waived_person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAIU_PE_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    sup_unit_cd = x_unit_cd
      AND      sup_uv_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAIU_SUP_UV_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_VER;

  PROCEDURE GET_FK_IGS_TR_ITEM (
    x_tracking_id IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    ass_tracking_id = x_tracking_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAIU_TRI_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_TR_ITEM;

  PROCEDURE GET_FK_IGS_AS_UNIT_MODE (
    x_unit_mode IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    unit_mode = x_unit_mode ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAIU_UM_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_UNIT_MODE;

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_OPT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_unit_class IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      uv_version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      location_cd = x_location_cd
      AND      unit_class = x_unit_class ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAIU_UOO_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_OFR_OPT;

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_PAT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTUNT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      uv_version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
              Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAIU_UOP_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_OFR_PAT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
                x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_acai_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
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
    x_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL
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
      x_adm_ps_appl_inst_unit_id
    );

    igs_ad_gen_002.check_adm_appl_inst_stat(
      nvl(x_person_id,old_references.person_id),
      nvl(x_admission_appl_number,old_references.admission_appl_number),
      nvl(x_nominated_course_cd,old_references.nominated_course_cd),
      nvl(x_acai_sequence_number,old_references.acai_sequence_number)
      );

 IF (p_action = 'INSERT') THEN
     -- Call all the procedures related to Before Insert.
     BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
     IF Get_PK_For_Validation (new_references.adm_ps_appl_inst_unit_id) OR
        Get_UK_For_Validation (
            new_references.person_id,
            new_references.admission_appl_number,
            new_references.nominated_course_cd,
            new_references.acai_sequence_number,
            new_references.unit_cd,
            new_references.uv_version_number,
            new_references.cal_type,
            new_references.ci_sequence_number,
            new_references.location_cd,
            new_references.unit_class
         ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                    IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
     Check_Constraints;
     Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
     -- Call all the procedures related to Before Update.
     IF Get_UK_For_Validation (
            new_references.person_id,
            new_references.admission_appl_number,
            new_references.nominated_course_cd,
            new_references.acai_sequence_number,
            new_references.unit_cd,
            new_references.uv_version_number,
            new_references.cal_type,
            new_references.ci_sequence_number,
            new_references.location_cd,
            new_references.unit_class
         ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                    IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
     BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
     Check_Constraints;
     Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
     -- Call all the procedures related to Before Delete.
     BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
     IF Get_PK_For_Validation (new_references.adm_ps_appl_inst_unit_id) OR
        Get_UK_For_Validation (
            new_references.person_id,
            new_references.admission_appl_number,
            new_references.nominated_course_cd,
            new_references.acai_sequence_number,
            new_references.unit_cd,
            new_references.uv_version_number,
            new_references.cal_type,
            new_references.ci_sequence_number,
            new_references.location_cd,
            new_references.unit_class
         ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                    IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
     Check_Constraints;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
     IF Get_UK_For_Validation (
            new_references.person_id,
            new_references.admission_appl_number,
            new_references.nominated_course_cd,
            new_references.acai_sequence_number,
            new_references.unit_cd,
            new_references.uv_version_number,
            new_references.cal_type,
            new_references.ci_sequence_number,
            new_references.location_cd,
            new_references.unit_class
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

    IF (p_action = 'INSERT') THEN
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      AfterRowInsertUpdate2 ( p_updating => TRUE );
      AfterRowUpdateDelete3 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      AfterRowUpdateDelete3 ( p_deleting => TRUE );
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
        X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
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
  X_ADM_PS_APPL_INST_UNIT_ID in out NOCOPY NUMBER
  ) as
    cursor C is select ROWID, ADM_PS_APPL_INST_UNIT_ID from IGS_AD_PS_APLINSTUNT_ALL
      where PERSON_ID = X_PERSON_ID
      and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
      and NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD
      and ACAI_SEQUENCE_NUMBER = X_ACAI_SEQUENCE_NUMBER
      and UNIT_CD = X_UNIT_CD
      and NVL(UV_VERSION_NUMBER,-1) = NVL(X_UV_VERSION_NUMBER,-1)
      and NVL(CAL_TYPE,'*') = NVL(X_CAL_TYPE,'*')
      and NVL(CI_SEQUENCE_NUMBER,-1) = NVL(X_CI_SEQUENCE_NUMBER,-1)
      and NVL(LOCATION_CD,'*') = NVL(X_LOCATION_CD,'*')
      and NVL(UNIT_CLASS,'*') = NVL(X_UNIT_CLASS,'*');
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
  elsif (X_MODE IN ('R', 'S')) then
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

  Before_DML(p_action =>'INSERT',
  x_rowid =>X_ROWID,
        x_org_id => igs_ge_gen_003.get_org_id,
  x_person_id  =>X_PERSON_ID,
  x_admission_appl_number  =>X_ADMISSION_APPL_NUMBER,
  x_nominated_course_cd =>X_NOMINATED_COURSE_CD,
  x_acai_sequence_number =>X_ACAI_SEQUENCE_NUMBER,
  x_unit_cd =>X_UNIT_CD,
  x_uv_version_number =>X_UV_VERSION_NUMBER,
  x_cal_type =>X_CAL_TYPE ,
  x_ci_sequence_number =>X_CI_SEQUENCE_NUMBER,
  x_location_cd =>X_LOCATION_CD,
  x_unit_class =>X_UNIT_CLASS,
  x_unit_mode => X_UNIT_MODE,
  x_adm_unit_outcome_status => X_ADM_UNIT_OUTCOME_STATUS,
  x_ass_tracking_id  => X_ASS_TRACKING_ID,
  x_rule_waived_dt => X_RULE_WAIVED_DT,
  x_rule_waived_person_id  => X_RULE_WAIVED_PERSON_ID,
  x_sup_unit_cd => X_SUP_UNIT_CD,
  x_sup_uv_version_number => X_SUP_UV_VERSION_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_adm_ps_appl_inst_unit_id => X_ADM_PS_APPL_INST_UNIT_ID
  );
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_PS_APLINSTUNT_ALL (
                ORG_ID,
    PERSON_ID,
    ADMISSION_APPL_NUMBER,
    NOMINATED_COURSE_CD,
    ACAI_SEQUENCE_NUMBER,
    UNIT_CD,
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
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE ,
    ADM_PS_APPL_INST_UNIT_ID
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.NOMINATED_COURSE_CD,
    NEW_REFERENCES.ACAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.UNIT_CD,
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
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    IGS_AD_PS_APLINSTUNT_S.NEXTVAL
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  open c;
  fetch c into X_ROWID, X_ADM_PS_APPL_INST_UNIT_ID;
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
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
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
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
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
  X_ADM_PS_APPL_INST_UNIT_ID in NUMBER
) as
  cursor c1 is select
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
    from IGS_AD_PS_APLINSTUNT_ALL
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

  if ( (tlinfo.UV_VERSION_NUMBER = X_UV_VERSION_NUMBER)
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
      AND (tlinfo.ADM_UNIT_OUTCOME_STATUS = X_ADM_UNIT_OUTCOME_STATUS)
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
  X_ADM_PS_APPL_INST_UNIT_ID in NUMBER
  ) AS
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
        IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML(p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_person_id  =>X_PERSON_ID,
  x_admission_appl_number  =>X_ADMISSION_APPL_NUMBER,
  x_nominated_course_cd =>X_NOMINATED_COURSE_CD,
  x_acai_sequence_number =>X_ACAI_SEQUENCE_NUMBER,
  x_unit_cd =>X_UNIT_CD,
  x_uv_version_number =>X_UV_VERSION_NUMBER,
  x_cal_type =>X_CAL_TYPE ,
  x_ci_sequence_number =>X_CI_SEQUENCE_NUMBER,
  x_location_cd =>X_LOCATION_CD,
  x_unit_class =>X_UNIT_CLASS,
  x_unit_mode => X_UNIT_MODE,
  x_adm_unit_outcome_status => X_ADM_UNIT_OUTCOME_STATUS,
  x_ass_tracking_id => X_ASS_TRACKING_ID,
  x_rule_waived_dt => X_RULE_WAIVED_DT,
  x_rule_waived_person_id  => X_RULE_WAIVED_PERSON_ID,
  x_sup_unit_cd => X_SUP_UNIT_CD,
  x_sup_uv_version_number => X_SUP_UV_VERSION_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_adm_ps_appl_inst_unit_id => X_ADM_PS_APPL_INST_UNIT_ID
  );


  if (X_MODE IN ('R', 'S')) then
        X_REQUEST_ID :=FND_GLOBAL.CONC_REQUEST_ID;
        X_PROGRAM_ID :=FND_GLOBAL.CONC_PROGRAM_ID;
        X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
        if (X_REQUEST_ID = -1) then
                X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
                X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
                X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
        else
                X_PROGRAM_UPDATE_DATE := SYSDATE;
        end if;
  end if;
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_AD_PS_APLINSTUNT_ALL set
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
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID
  ;
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
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
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
  X_ADM_PS_APPL_INST_UNIT_ID in out NOCOPY NUMBER
  ) AS
  cursor c1 is select rowid from IGS_AD_PS_APLINSTUNT_ALL
     where ADM_PS_APPL_INST_UNIT_ID = X_ADM_PS_APPL_INST_UNIT_ID
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
     X_ADM_PS_APPL_INST_UNIT_ID);
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
   X_ADM_PS_APPL_INST_UNIT_ID);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin
Before_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
);
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_AD_PS_APLINSTUNT_ALL
  where ROWID = X_ROWID;
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
 p_action =>'DELETE',
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
end DELETE_ROW;

end IGS_AD_PS_APLINSTUNT_PKG;

/
