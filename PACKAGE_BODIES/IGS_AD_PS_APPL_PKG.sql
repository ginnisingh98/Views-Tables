--------------------------------------------------------
--  DDL for Package Body IGS_AD_PS_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PS_APPL_PKG" as
/* $Header: IGSAI16B.pls 120.1 2005/07/14 00:57:40 appldev ship $ */

l_rowid VARCHAR2(25);
old_references IGS_AD_PS_APPL_ALL%RowType;
new_references IGS_AD_PS_APPL_ALL%RowType;


PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
                x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_basis_for_admission_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cd IN VARCHAR2 DEFAULT NULL,
    x_course_rank_set IN VARCHAR2 DEFAULT NULL,
    x_course_rank_schedule IN VARCHAR2 DEFAULT NULL,
    x_req_for_reconsideration_ind IN VARCHAR2 DEFAULT NULL,
    x_req_for_adv_standing_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PS_APPL_ALL
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
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.nominated_course_cd := x_nominated_course_cd;
    new_references.transfer_course_cd := x_transfer_course_cd;
    new_references.basis_for_admission_type := x_basis_for_admission_type;
    new_references.admission_cd := x_admission_cd;
    new_references.course_rank_set := x_course_rank_set;
    new_references.course_rank_schedule := x_course_rank_schedule;
    new_references.req_for_reconsideration_ind := x_req_for_reconsideration_ind;
    new_references.req_for_adv_standing_ind := x_req_for_adv_standing_ind;
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

PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
        v_message_name                  VARCHAR2(30);
        v_return_type                   VARCHAR2(1);
        v_admission_cat                 IGS_AD_APPL.admission_cat%TYPE;
        v_s_admission_process_type      IGS_AD_APPL.s_admission_process_type%TYPE;
        v_acad_cal_type                 IGS_AD_APPL.acad_cal_type%TYPE;
        v_acad_ci_sequence_number       IGS_AD_APPL.acad_ci_sequence_number%TYPE;
        v_adm_cal_type                  IGS_AD_APPL.adm_cal_type%TYPE;
        v_adm_ci_sequence_number        IGS_AD_APPL.adm_ci_sequence_number%TYPE;
        v_appl_dt                               IGS_AD_APPL.appl_dt%TYPE;
        v_adm_appl_status                     IGS_AD_APPL.adm_appl_status%TYPE;
        v_adm_fee_status                        IGS_AD_APPL.adm_fee_status%TYPE;
        v_crv_version_number            IGS_PS_VER.version_number%TYPE;
        v_pref_limit                    NUMBER;
        v_check_course_encumb_ind       VARCHAR2(1);
        v_late_appl_allowed_ind         VARCHAR2(1);
        v_req_reconsider_allowed_ind    VARCHAR2(1);
        v_req_adv_standing_allowed_ind  VARCHAR2(1);


        CURSOR c_apcs (
                cp_admission_cat                IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                cp_s_admission_process_type
                                        IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
        SELECT  s_admission_step_type,
                step_type_restriction_num
        FROM    IGS_AD_PRCS_CAT_STEP
        WHERE   admission_cat = cp_admission_cat AND
                s_admission_process_type = cp_s_admission_process_type AND
                step_group_type <> 'TRACK'; --2402377
        cst_error                               CONSTANT        VARCHAR2(1):= 'E';
  BEGIN

        v_check_course_encumb_ind       := 'N';
        v_late_appl_allowed_ind         := 'N';
        v_req_reconsider_allowed_ind    := 'N';
        v_req_adv_standing_allowed_ind  := 'N';

        --
        -- Get admission application details required for validation
        --
        IGS_AD_GEN_002.ADMP_GET_AA_DTL(
                new_references.person_id,
                new_references.admission_appl_number,
                v_admission_cat,
                v_s_admission_process_type,
                v_acad_cal_type,
                v_acad_ci_sequence_number,
                v_adm_cal_type,
                v_adm_ci_sequence_number,
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
                IF v_apcs_rec.s_admission_step_type = 'PREF-LIMIT' THEN
                        v_pref_limit := v_apcs_rec.step_type_restriction_num;
                ELSIF v_apcs_rec.s_admission_step_type = 'CHKCENCUMB' THEN
                        v_check_course_encumb_ind := 'Y';
                ELSIF v_apcs_rec.s_admission_step_type = 'LATE-APP' THEN
                        v_late_appl_allowed_ind := 'Y';
                ELSIF v_apcs_rec.s_admission_step_type = 'RECONSIDER' THEN
                        v_req_reconsider_allowed_ind := 'Y';
                ELSIF v_apcs_rec.s_admission_step_type = 'ADVSTAND' THEN
                        v_req_adv_standing_allowed_ind := 'Y';
                END IF;
        END LOOP;
        IF p_inserting THEN
                --
                -- Validate preference limit.
                --
                IF IGS_AD_VAL_ACA.admp_val_pref_limit (
                                new_references.person_id,
                                new_references.admission_appl_number,
                                new_references.nominated_course_cd,
                                -1,     -- ACAI sequence number, not known yet.
                                v_s_admission_process_type,
                                v_pref_limit,
                                v_message_name) = FALSE THEN
                        --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
                -- Validate the nominated IGS_PS_COURSE code.
                IF IGS_AD_VAL_ACAI.admp_val_acai_course (
                                new_references.nominated_course_cd,
                                NULL,
                                v_admission_cat,
                                v_s_admission_process_type,
                                v_acad_cal_type,
                                v_acad_ci_sequence_number,
                                v_adm_cal_type,
                                v_adm_ci_sequence_number,
                                v_appl_dt,
                                v_late_appl_allowed_ind,
                                'N',
                                v_crv_version_number,
                                v_message_name,
                                v_return_type) = FALSE THEN
                        IF NVL(v_return_type, '-1') = cst_error THEN
                                --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate IGS_PS_COURSE encumbrances.
                --
                IF v_check_course_encumb_ind = 'Y' THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_encmb (
                                        new_references.person_id,
                                        new_references.nominated_course_cd,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_check_course_encumb_ind,
                                        'N',    -- Offer indicator.
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate against current student IGS_PS_COURSE attempt.
                --
                IF IGS_AD_VAL_ACAI.admp_val_aca_sca (
                                new_references.person_id,
                                new_references.nominated_course_cd,
                                v_appl_dt,
                                v_admission_cat,
                                v_s_admission_process_type,
                                NULL,   -- Fee Category.
                                NULL,   -- Correspondence Category.
                                NULL,   -- Enrolment Category.
                                'N',    -- Offer indicator.
                                v_message_name,
                                v_return_type) = FALSE THEN
                        IF NVL(v_return_type, '-1') = cst_error THEN
                                --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate transfer IGS_PS_COURSE code.
                --
                IF IGS_AD_VAL_ACA.admp_val_aca_trnsfr (
                                new_references.person_id,
                                new_references.nominated_course_cd,
                                v_crv_version_number,
                                new_references.transfer_course_cd,
                                v_s_admission_process_type,
                                v_check_course_encumb_ind,
                                v_adm_cal_type,
                                v_adm_ci_sequence_number,
                                v_message_name,
                                v_return_type) = FALSE THEN
                        IF NVL(v_return_type, '-1') = cst_error THEN
                                --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
        END IF; -- p_inserting
        IF p_updating THEN
                --
                -- Cannot update the Transfer IGS_PS_COURSE Code.
                --
                IF (NVL(old_references.transfer_course_cd, '-1') <>
                                NVL(new_references.transfer_course_cd, '-1')) THEN
                        --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(3161));
                        FND_MESSAGE.SET_NAME('IGS','IGS_AD_UPD_TRNSFRCD_NOT_ALLOW');
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
                --
                -- Save the admission application key.
                -- For processing in the after statement trigger
                -- to derive the admission application status.
                -- Only save if the request for reconsideration indicator has changed.
                --

        END IF; -- p_updating
        IF v_s_admission_process_type = 'TRANSFER' THEN
               /* Include here validation for course transfer */
                   IF  Igs_Ad_Val_Aca.admp_val_aca_trnsfr(
                                           new_references.person_id,
                                           new_references.nominated_course_cd,
                                           v_crv_version_number,
                                           new_references.transfer_course_cd,
                                           v_s_admission_process_type,
                                           'N',
                                           v_adm_cal_type,
                                           v_adm_ci_sequence_number,
                                           v_message_name,
                                           v_return_type) = FALSE THEN
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;
           END IF;

        --
        -- Validate basis for admission type closed indicator.
        --
        IF (new_references.basis_for_admission_type IS NOT NULL AND
                        (NVL(old_references.basis_for_admission_type, '-1') <>
                        new_references.basis_for_admission_type)) THEN
                IF IGS_AD_VAL_ACA.admp_val_bfa_closed (
                                new_references.basis_for_admission_type,
                                v_message_name) = FALSE THEN
                        --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;
        --
        -- Validate admission code closed indicator.
        --
        IF (new_references.admission_cd IS NOT NULL AND
                        (NVL(old_references.admission_cd, '-1') <> new_references.admission_cd)) THEN
                IF IGS_AD_VAL_ACA.admp_val_aco_closed (
                                new_references.admission_cd,
                                v_message_name) = FALSE THEN
                        --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;
        --
        -- Validate request for reconsideration indicator.
        --
        IF (old_references.req_for_reconsideration_ind <> new_references.req_for_reconsideration_ind) THEN
                IF IGS_AD_VAL_ACA.admp_val_aca_req_rec (
                                new_references.req_for_reconsideration_ind,
                                v_req_reconsider_allowed_ind,
                                v_message_name) = FALSE THEN
                        --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;
        --
        -- Validate request for advanced standing indicator.
        --
        IF (old_references.req_for_adv_standing_ind <> new_references.req_for_adv_standing_ind) THEN
                IF IGS_AD_VAL_ACA.admp_val_aca_req_adv (
                                new_references.req_for_adv_standing_ind,
                                v_req_adv_standing_allowed_ind,
                                v_message_name) = FALSE THEN
                        --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;



  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_aca_ar_ud_hist
  -- AFTER DELETE OR UPDATE
  -- ON IGS_AD_PS_APPL
  -- FOR EACH ROW

  PROCEDURE AfterRowUpdateDelete2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
        v_message_name                  VARCHAR2(30);

        v_person_id                             IGS_AD_APPL.person_id%TYPE;
        v_admission_appl_number         IGS_AD_APPL.admission_appl_number%TYPE;
        v_derived_adm_appl_status       IGS_AD_APPL.adm_appl_status%TYPE;
        v_adm_appl_status           IGS_AD_APPL.adm_appl_status%TYPE;

   -- cursor to get the old admission application status from the
   -- database by rrengara on 9-APR-2002 for bug no 2298840

   CURSOR c_adm_appl_status (cp_person_id igs_ad_appl.person_id%TYPE,
                              cp_admission_appl_number igs_ad_appl.admission_appl_number%TYPE) IS
      SELECT adm_appl_status
      FROM igs_ad_appl
      WHERE person_id = cp_person_id
      AND   admission_appl_number= cp_admission_appl_number;

  BEGIN
        IF p_updating THEN
                -- Create admission IGS_PS_COURSE application history record.
                IGS_AD_GEN_011.ADMP_INS_ACA_HIST (
                        new_references.person_id,
                        new_references.admission_appl_number,
                        new_references.nominated_course_cd,
                        new_references.transfer_course_cd,
                        old_references.transfer_course_cd,
                        new_references.basis_for_admission_type,
                        old_references.basis_for_admission_type,
                        new_references.admission_cd,
                        old_references.admission_cd,
                        new_references.course_rank_set,
                        old_references.course_rank_set,
                        new_references.course_rank_schedule,
                        old_references.course_rank_schedule,
                        new_references.req_for_reconsideration_ind,
                        old_references.req_for_reconsideration_ind,
                        new_references.req_for_adv_standing_ind,
                        old_references.req_for_adv_standing_ind,
                        new_references.last_updated_by,
                        old_references.last_updated_by,
                        new_references.last_update_date,
                        old_references.last_update_date);

                    -- added to handle mutation
                        -- Get the saved Admission Application details.
                                v_person_id := old_references.person_id;
                                v_admission_appl_number := old_references.admission_appl_number;

                 -- Added the cursor to get the old admission appl status
                 -- by rrengara on 9-apr-2002 bug no : 2298840

                  OPEN c_adm_appl_status (
                           v_person_id,
                           v_admission_appl_number);
                  FETCH c_adm_appl_status INTO v_adm_appl_status;
                  CLOSE c_adm_appl_status;


                  -- Derive the Admission Application status.
                  v_derived_adm_appl_status := IGS_AD_GEN_002.ADMP_GET_AA_AAS (
                                                                v_person_id,
                                                                v_admission_appl_number,
                                                                v_adm_appl_status);
                  -- Update the admission application status.

                IF v_derived_adm_appl_status IS NOT NULL AND v_derived_adm_appl_status <> v_adm_appl_status THEN
                  UPDATE
                    IGS_AD_APPL
                  SET
                    adm_appl_status = v_derived_adm_appl_status
                  WHERE person_id = v_person_id AND
                        admission_appl_number = v_admission_appl_number;
                END IF;
         END IF;


        IF p_deleting THEN
                -- Delete admission IGS_PS_COURSE application history records.
                IF IGS_AD_GEN_001.ADMP_DEL_ACA_HIST (
                                old_references.person_id,
                                old_references.admission_appl_number,
                                old_references.nominated_course_cd,
                                v_message_name) = FALSE THEN
                        --raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
        END IF;


  END AfterRowUpdateDelete2;

  -- Trigger description :-
  -- "OSS_TST".trg_aca_as_u
  -- AFTER UPDATE
  -- ON IGS_AD_PS_APPL


PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_APPL_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.admission_appl_number
        ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL'));
        IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.admission_cd = new_references.admission_cd)) OR
        ((new_references.admission_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_CD_PKG.Get_PK_For_Validation (
        new_references.admission_cd , 'N'
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_CD'));
        IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.basis_for_admission_type = new_references.basis_for_admission_type)) OR
        ((new_references.basis_for_admission_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_BASIS_FOR_AD_PKG.Get_PK_For_Validation (
        new_references.basis_for_admission_type , 'N'
        )THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_AD_BASIS_ADM_TYPE_CLOSED');
      IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    -- Removed the GET_PK call for IGS_PS_COURSE_PKG
    -- Nominated course code and sequence number will be validated
    -- at IGS_AD_PS_APPL_INST level
    -- Bug no 2380815 by rrengara on 8-JAN-2003


    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.transfer_course_cd = new_references.transfer_course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.transfer_course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.transfer_course_cd
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON_TRANSFER_CD'));
      IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_AD_PS_APPL (
      old_references.person_id,
      old_references.admission_appl_number,
      old_references.nominated_course_cd
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return TRUE;
    ELSE
      Close cur_rowid;
      Return FALSE;
    END IF;


  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_AD_APPL (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACA_AA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_APPL;

  PROCEDURE GET_FK_IGS_AD_CD (
    x_admission_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_ALL
      WHERE    admission_cd = x_admission_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACA_ACO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_CD;

  PROCEDURE GET_FK_IGS_AD_BASIS_FOR_AD (
    x_basis_for_admission_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_ALL
      WHERE    basis_for_admission_type = x_basis_for_admission_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACA_BFA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_BASIS_FOR_AD;

  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_ALL
      WHERE    nominated_course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACA_CRS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_COURSE;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_ALL
      WHERE    person_id = x_person_id
      AND      transfer_course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACA_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  -- procedure to check constraints
  PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
  ) as
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'ADMISSION_CD' THEN
      new_references.admission_cd := column_value;
     ELSIF upper(column_name) = 'BASIS_FOR_ADMISSION_TYPE' THEN
      new_references.basis_for_admission_type := column_value;
     ELSIF upper(column_name) = 'COURSE_RANK_SCHEDULE' THEN
      new_references.course_rank_schedule := column_value;
     ELSIF upper(column_name) = 'COURSE_RANK_SET' THEN
      new_references.course_rank_set := column_value;
     ELSIF upper(column_name) = 'NOMINATED_COURSE_CD' THEN
      new_references.nominated_course_cd := column_value;
     ELSIF upper(column_name) = 'REQ_FOR_ADV_STANDING_IND' THEN
      new_references.req_for_adv_standing_ind := column_value;
     ELSIF upper(column_name) = 'REQ_FOR_RECONSIDERATION_IND' THEN
      new_references.req_for_reconsideration_ind := column_value;
     ELSIF upper(column_name) = 'TRANSFER_COURSE_CD' THEN
      new_references.transfer_course_cd := column_value;
     END IF;

     IF upper(column_name) = 'COURSE_RANK_SCHEDULE' OR column_name IS NULL THEN
      IF new_references.course_rank_schedule <> UPPER(new_references.course_rank_schedule) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'COURSE_RANK_SET' OR column_name IS NULL THEN
      IF new_references.course_rank_set <> UPPER(new_references.course_rank_set) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_COURSE_RANK_DTLS'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'NOMINATED_COURSE_CD' OR column_name IS NULL THEN
      IF new_references.nominated_course_cd <> UPPER(new_references.nominated_course_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'REQ_FOR_ADV_STANDING_IND' OR column_name IS NULL THEN
      IF new_references.req_for_adv_standing_ind <> UPPER(new_references.req_for_adv_standing_ind) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_REQ_ADV_STD_IND'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'REQ_FOR_RECONSIDERATION_IND' OR column_name IS NULL THEN
      IF new_references.req_for_reconsideration_ind <> UPPER(new_references.req_for_reconsideration_ind) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_REQ_RECONS_IND'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'TRANSFER_COURSE_CD' OR column_name IS NULL THEN
      IF new_references.transfer_course_cd <> UPPER(new_references.transfer_course_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TRANSFER_CD'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;

  END CHECK_CONSTRAINTS;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
                x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_basis_for_admission_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cd IN VARCHAR2 DEFAULT NULL,
    x_course_rank_set IN VARCHAR2 DEFAULT NULL,
    x_course_rank_schedule IN VARCHAR2 DEFAULT NULL,
    x_req_for_reconsideration_ind IN VARCHAR2 DEFAULT NULL,
    x_req_for_adv_standing_ind IN VARCHAR2 DEFAULT NULL,
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
                        x_org_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_transfer_course_cd,
      x_basis_for_admission_type,
      x_admission_cd,
      x_course_rank_set,
      x_course_rank_schedule,
      x_req_for_reconsideration_ind,
      x_req_for_adv_standing_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.nominated_course_cd
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF ( p_action = 'VALIDATE_INSERT') THEN
     IF GET_PK_FOR_VALIDATION(
       new_references.person_id,
       new_references.admission_appl_number,
       new_references.nominated_course_cd
     )THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
       Check_Constraints;
    ELSIF ( p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF ( p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

   IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdateDelete2 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowUpdateDelete2 ( p_deleting => TRUE );
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
        X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_AD_PS_APPL_ALL
      where PERSON_ID = X_PERSON_ID
      and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
      and NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD;
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
  x_person_id => X_PERSON_ID,
  x_admission_appl_number => X_ADMISSION_APPL_NUMBER,
  x_nominated_course_cd => X_NOMINATED_COURSE_CD,
  x_transfer_course_cd => X_TRANSFER_COURSE_CD,
  x_basis_for_admission_type => X_BASIS_FOR_ADMISSION_TYPE,
  x_admission_cd  => X_ADMISSION_CD,
  x_course_rank_set  => X_COURSE_RANK_SET,
  x_course_rank_schedule  => X_COURSE_RANK_SCHEDULE,
  x_req_for_reconsideration_ind  => NVL(X_REQ_FOR_RECONSIDERATION_IND,'N'),
  x_req_for_adv_standing_ind  => NVL(X_REQ_FOR_ADV_STANDING_IND,'N'),
  x_creation_date =>X_LAST_UPDATE_DATE,
  x_created_by =>X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by =>X_LAST_UPDATED_BY,
  x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_PS_APPL_ALL (
                ORG_ID,
    PERSON_ID,
    ADMISSION_APPL_NUMBER,
    NOMINATED_COURSE_CD,
    TRANSFER_COURSE_CD,
    BASIS_FOR_ADMISSION_TYPE,
    ADMISSION_CD,
    COURSE_RANK_SET,
    COURSE_RANK_SCHEDULE,
    REQ_FOR_RECONSIDERATION_IND,
    REQ_FOR_ADV_STANDING_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.NOMINATED_COURSE_CD,
    NEW_REFERENCES.TRANSFER_COURSE_CD,
    NEW_REFERENCES.BASIS_FOR_ADMISSION_TYPE,
    NEW_REFERENCES.ADMISSION_CD,
    NEW_REFERENCES.COURSE_RANK_SET,
    NEW_REFERENCES.COURSE_RANK_SCHEDULE,
    NEW_REFERENCES.REQ_FOR_RECONSIDERATION_IND,
    NEW_REFERENCES.REQ_FOR_ADV_STANDING_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
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
 p_action =>'INSERT',
 x_rowid => X_ROWID
);

EXCEPTION
  WHEN OTHERS THEN
   IF (x_mode = 'S') THEN
      igs_sc_gen_001.unset_ctx('R');
   END IF;
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
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2
) as
  cursor c1 is select
      TRANSFER_COURSE_CD,
      BASIS_FOR_ADMISSION_TYPE,
      ADMISSION_CD,
      COURSE_RANK_SET,
      COURSE_RANK_SCHEDULE,
      REQ_FOR_RECONSIDERATION_IND,
      REQ_FOR_ADV_STANDING_IND
    from IGS_AD_PS_APPL_ALL
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

      if ( ((tlinfo.TRANSFER_COURSE_CD = X_TRANSFER_COURSE_CD)
           OR ((tlinfo.TRANSFER_COURSE_CD is null)
               AND (X_TRANSFER_COURSE_CD is null)))
      AND ((tlinfo.BASIS_FOR_ADMISSION_TYPE = X_BASIS_FOR_ADMISSION_TYPE)
           OR ((tlinfo.BASIS_FOR_ADMISSION_TYPE is null)
               AND (X_BASIS_FOR_ADMISSION_TYPE is null)))
      AND ((tlinfo.ADMISSION_CD = X_ADMISSION_CD)
           OR ((tlinfo.ADMISSION_CD is null)
               AND (X_ADMISSION_CD is null)))
      AND ((tlinfo.COURSE_RANK_SET = X_COURSE_RANK_SET)
           OR ((tlinfo.COURSE_RANK_SET is null)
               AND (X_COURSE_RANK_SET is null)))
      AND ((tlinfo.COURSE_RANK_SCHEDULE = X_COURSE_RANK_SCHEDULE)
           OR ((tlinfo.COURSE_RANK_SCHEDULE is null)
               AND (X_COURSE_RANK_SCHEDULE is null)))
      AND (tlinfo.REQ_FOR_RECONSIDERATION_IND = X_REQ_FOR_RECONSIDERATION_IND)
      AND (tlinfo.REQ_FOR_ADV_STANDING_IND = X_REQ_FOR_ADV_STANDING_IND)
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
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2,
  X_MODE in VARCHAR2
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
  x_person_id => X_PERSON_ID,
  x_admission_appl_number => X_ADMISSION_APPL_NUMBER,
  x_nominated_course_cd => X_NOMINATED_COURSE_CD,
  x_transfer_course_cd => X_TRANSFER_COURSE_CD,
  x_basis_for_admission_type => X_BASIS_FOR_ADMISSION_TYPE,
  x_admission_cd  => X_ADMISSION_CD,
  x_course_rank_set  => X_COURSE_RANK_SET,
  x_course_rank_schedule  => X_COURSE_RANK_SCHEDULE,
  x_req_for_reconsideration_ind  => X_REQ_FOR_RECONSIDERATION_IND,
  x_req_for_adv_standing_ind  => X_REQ_FOR_ADV_STANDING_IND,
  x_creation_date =>X_LAST_UPDATE_DATE,
  x_created_by =>X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by =>X_LAST_UPDATED_BY,
  x_last_update_login =>X_LAST_UPDATE_LOGIN
  );


  if (X_MODE IN ('R', 'S')) then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
   if (X_REQUEST_ID = -1) then
    X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
    X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
    X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
   else
    X_PROGRAM_UPDATE_DATE := SYSDATE;
   end if;
  end if;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_AD_PS_APPL_ALL set
    TRANSFER_COURSE_CD = NEW_REFERENCES.TRANSFER_COURSE_CD,
    BASIS_FOR_ADMISSION_TYPE = NEW_REFERENCES.BASIS_FOR_ADMISSION_TYPE,
    ADMISSION_CD = NEW_REFERENCES.ADMISSION_CD,
    COURSE_RANK_SET = NEW_REFERENCES.COURSE_RANK_SET,
    COURSE_RANK_SCHEDULE = NEW_REFERENCES.COURSE_RANK_SCHEDULE,
    REQ_FOR_RECONSIDERATION_IND = NEW_REFERENCES.REQ_FOR_RECONSIDERATION_IND,
    REQ_FOR_ADV_STANDING_IND = NEW_REFERENCES.REQ_FOR_ADV_STANDING_IND,
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
     IF (x_mode = 'S') THEN
        igs_sc_gen_001.unset_ctx('R');
     END IF;
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
    IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
    END IF;
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
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_AD_PS_APPL_ALL
     where PERSON_ID = X_PERSON_ID
     and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
     and NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD
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
     X_TRANSFER_COURSE_CD,
     X_BASIS_FOR_ADMISSION_TYPE,
     X_ADMISSION_CD,
     X_COURSE_RANK_SET,
     X_COURSE_RANK_SCHEDULE,
     X_REQ_FOR_RECONSIDERATION_IND,
     X_REQ_FOR_ADV_STANDING_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ADMISSION_APPL_NUMBER,
   X_NOMINATED_COURSE_CD,
   X_TRANSFER_COURSE_CD,
   X_BASIS_FOR_ADMISSION_TYPE,
   X_ADMISSION_CD,
   X_COURSE_RANK_SET,
   X_COURSE_RANK_SCHEDULE,
   X_REQ_FOR_RECONSIDERATION_IND,
   X_REQ_FOR_ADV_STANDING_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) as
begin

  BEFORE_DML(
   p_action =>'DELETE',
   x_rowid => X_ROWID
  );

   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_AD_PS_APPL_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
     END IF;
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
    IF (x_mode = 'S') THEN
      igs_sc_gen_001.unset_ctx('R');
    END IF;
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

end IGS_AD_PS_APPL_PKG;

/
