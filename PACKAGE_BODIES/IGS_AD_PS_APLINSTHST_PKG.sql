--------------------------------------------------------
--  DDL for Package Body IGS_AD_PS_APLINSTHST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PS_APLINSTHST_PKG" AS
/* $Header: IGSAI19B.pls 120.2 2005/09/21 00:32:55 appldev ship $*/
l_rowid VARCHAR2(25);
old_references IGS_AD_PS_APLINSTHST_ALL%RowType;
new_references IGS_AD_PS_APLINSTHST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
                x_org_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_preference_number IN NUMBER DEFAULT NULL,
    x_adm_doc_status IN VARCHAR2 DEFAULT NULL,
    x_adm_entry_qual_status IN VARCHAR2 DEFAULT NULL,
    x_late_adm_fee_status IN VARCHAR2 DEFAULT NULL,
    x_adm_outcome_status IN VARCHAR2 DEFAULT NULL,
    x_adm_otcm_status_auth_per_id IN NUMBER DEFAULT NULL,
    x_adm_outcome_status_auth_dt IN DATE DEFAULT NULL,
    x_adm_outcome_status_reason IN VARCHAR2 DEFAULT NULL,
    x_offer_dt IN DATE DEFAULT NULL,
    x_offer_response_dt IN DATE DEFAULT NULL,
    x_prpsd_commencement_dt IN DATE DEFAULT NULL,
    x_adm_cndtnl_offer_status IN VARCHAR2 DEFAULT NULL,
    x_cndtnl_offer_satisfied_dt IN DATE DEFAULT NULL,
    x_cndtnl_ofr_must_be_stsfd_ind IN VARCHAR2 DEFAULT NULL,
    x_adm_offer_resp_status IN VARCHAR2 DEFAULT NULL,
    x_actual_response_dt IN DATE DEFAULT NULL,
    x_adm_offer_dfrmnt_status IN VARCHAR2 DEFAULT NULL,
    x_deferred_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_deferred_adm_ci_sequence_num IN NUMBER DEFAULT NULL,
    x_deferred_tracking_id IN NUMBER DEFAULT NULL,
    x_ass_rank IN NUMBER DEFAULT NULL,
    x_secondary_ass_rank IN NUMBER DEFAULT NULL,
    x_intrntnl_accept_advice_num IN NUMBER DEFAULT NULL,
    x_ass_tracking_id IN NUMBER DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_expected_completion_yr IN NUMBER DEFAULT NULL,
    x_expected_completion_perd IN VARCHAR2 DEFAULT NULL,
    x_correspondence_cat IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_cndtnl_offer_cndtn IN VARCHAR2 DEFAULT NULL,
    x_applicant_acptnce_cndtn IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_hist_offer_round_number IN NUMBER DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_appl_inst_status IN VARCHAR2 DEFAULT NULL,					--arvsrini igsm
    X_DECISION_DATE                            DATE     DEFAULT NULL,	-- begin APADEGAL adtd001 igs.m
    X_DECISION_MAKE_ID                         NUMBER   DEFAULT NULL,
    X_DECISION_REASON_ID                       NUMBER   DEFAULT NULL,
    X_PENDING_REASON_ID                        NUMBER   DEFAULT NULL,
    X_WAITLIST_STATUS                          VARCHAR2 DEFAULT NULL,
    X_WAITLIST_RANK                            VARCHAR2 DEFAULT NULL,
    X_FUTURE_ACAD_CAL_TYPE                     VARCHAR2 DEFAULT NULL,
    X_FUTURE_ACAD_CI_SEQUENCE_NUM              NUMBER   DEFAULT NULL,
    X_FUTURE_ADM_CAL_TYPE                      VARCHAR2 DEFAULT NULL,
    X_FUTURE_ADM_CI_SEQUENCE_NUM               NUMBER   DEFAULT NULL,
    X_DEF_ACAD_CAL_TYPE                        VARCHAR2 DEFAULT NULL,
    X_DEF_ACAD_CI_SEQUENCE_NUM                 NUMBER   DEFAULT NULL,
    X_RECONSIDER_FLAG                          VARCHAR2 DEFAULT NULL,
    X_DECLINE_OFR_REASON                       VARCHAR2 DEFAULT NULL    -- end APADEGAL adtd001 igs.m
 ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PS_APLINSTHST_ALL
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
    new_references.course_cd := x_course_cd;
    new_references.crv_version_number := x_crv_version_number;
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.us_version_number := x_us_version_number;
    new_references.preference_number := x_preference_number;
    new_references.adm_doc_status := x_adm_doc_status;
    new_references.adm_entry_qual_status := x_adm_entry_qual_status;
    new_references.late_adm_fee_status := x_late_adm_fee_status;
    new_references.adm_outcome_status := x_adm_outcome_status;
    new_references.adm_otcm_status_auth_person_id := x_adm_otcm_status_auth_per_id;
    new_references.adm_outcome_status_auth_dt := TRUNC(x_adm_outcome_status_auth_dt);
    new_references.adm_outcome_status_reason := x_adm_outcome_status_reason;
    new_references.offer_dt := TRUNC(x_offer_dt);
    new_references.offer_response_dt := TRUNC(x_offer_response_dt);
    new_references.prpsd_commencement_dt := TRUNC(x_prpsd_commencement_dt);
    new_references.adm_cndtnl_offer_status := x_adm_cndtnl_offer_status;
    new_references.cndtnl_offer_satisfied_dt := TRUNC(x_cndtnl_offer_satisfied_dt);
    new_references.cndtnl_offer_must_be_stsfd_ind := x_cndtnl_ofr_must_be_stsfd_ind;
    new_references.adm_offer_resp_status := x_adm_offer_resp_status;
    new_references.actual_response_dt := TRUNC(x_actual_response_dt);
    new_references.adm_offer_dfrmnt_status := x_adm_offer_dfrmnt_status;
    new_references.deferred_adm_cal_type := x_deferred_adm_cal_type;
    new_references.deferred_adm_ci_sequence_num := x_deferred_adm_ci_sequence_num;
    new_references.deferred_tracking_id := x_deferred_tracking_id;
    new_references.ass_rank := x_ass_rank;
    new_references.secondary_ass_rank := x_secondary_ass_rank;
    new_references.intrntnl_acceptance_advice_num := x_intrntnl_accept_advice_num;
    new_references.ass_tracking_id := x_ass_tracking_id;
    new_references.fee_cat := x_fee_cat;
    new_references.hecs_payment_option := x_hecs_payment_option;
    new_references.expected_completion_yr := x_expected_completion_yr;
    new_references.expected_completion_perd := x_expected_completion_perd;
    new_references.correspondence_cat := x_correspondence_cat;
    new_references.enrolment_cat := x_enrolment_cat;
    new_references.funding_source := x_funding_source;
    new_references.cndtnl_offer_cndtn := x_cndtnl_offer_cndtn;
    new_references.applicant_acptnce_cndtn := x_applicant_acptnce_cndtn;
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.nominated_course_cd := x_nominated_course_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.hist_offer_round_number := x_hist_offer_round_number;
    new_references.adm_cal_type := x_adm_cal_type;
    new_references.adm_ci_sequence_number := x_adm_ci_sequence_number;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date  := x_last_update_date;
    new_references.last_updated_by   := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
    new_references.appl_inst_status  := x_appl_inst_status;				--arvsrini igsm

 -- begin apadegal td001 igsm
    new_references.decision_date                :=   X_DECISION_DATE;
    new_references.decision_make_id             :=   X_DECISION_MAKE_ID;
    new_references.decision_reason_id           :=   X_DECISION_REASON_ID;
    new_references.pending_reason_id            :=   X_PENDING_REASON_ID;
    new_references.waitlist_status              :=   X_WAITLIST_STATUS;
    new_references.waitlist_rank                :=   X_WAITLIST_RANK;
    new_references.future_acad_cal_type         :=   X_FUTURE_ACAD_CAL_TYPE;
    new_references.future_acad_ci_sequence_num  :=   X_FUTURE_ACAD_CI_SEQUENCE_NUM;
    new_references.future_adm_cal_type          :=   X_FUTURE_ADM_CAL_TYPE;
    new_references.future_adm_ci_sequence_num   :=   X_FUTURE_ADM_CI_SEQUENCE_NUM;
    new_references.def_acad_cal_type            :=   X_DEF_ACAD_CAL_TYPE;
    new_references.def_acad_ci_sequence_num    	:=   X_DEF_ACAD_CI_SEQUENCE_NUM;
    new_references.reconsider_flag              :=   X_RECONSIDER_FLAG;
    new_references.decline_ofr_reason           :=   X_DECLINE_OFR_REASON;
-- end apadegal td001 igsm


  END Set_Column_Values;

PROCEDURE Check_Constraints (
         Column_Name    IN      VARCHAR2        DEFAULT NULL,
         Column_Value   IN      VARCHAR2        DEFAULT NULL
) AS
/*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-May-2002   removed upper check constraint on fee_cat column.bug#2344826.
  ----------------------------------------------------------------------------*/
BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'CNDTNL_OFFER_MUST_BE_STSFD_IND' then
     new_references.cndtnl_offer_must_be_stsfd_ind := column_value;
 ELSIF upper(Column_name) = 'ASS_RANK' then
     new_references.ass_rank := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'INTRNTNL_ACCEPTANCE_ADVICE_NUM' then
     new_references.intrntnl_acceptance_advice_num := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'SECONDARY_ASS_RANK' then
     new_references.secondary_ass_rank := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'PREFERENCE_NUMBER' then
     new_references.preference_number := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' then
     new_references.sequence_number := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'DEFERRED_ADM_CI_SEQUENCE_NUM' then
     new_references.deferred_adm_ci_sequence_num := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'ADM_OUTCOME_STATUS_REASON' then
     new_references.adm_outcome_status_reason := column_value;
 ELSIF upper(Column_name) = 'CORRESPONDENCE_CAT' then
     new_references.correspondence_cat := column_value;
 ELSIF upper(Column_name) = 'EXPECTED_COMPLETION_PERD' then
     new_references.expected_completion_perd := column_value;
 ELSIF upper(column_name) = 'APPL_INST_STATUS' THEN					--arvsrini igsm
      new_references.appl_inst_status := column_value;
END IF;

IF upper(column_name) = 'CNDTNL_OFFER_MUST_BE_STSFD_IND' OR
     column_name is null Then
     IF new_references.cndtnl_offer_must_be_stsfd_ind NOT IN ('Y','N') Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CND_OFR_STSFD_IND'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'ASS_RANK' OR
     column_name is null Then
     IF new_references.ass_rank  < 1 OR
        new_references.ass_rank > 999 Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ASSESSMENT_RANK'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'INTRNTNL_ACCEPTANCE_ADVICE_NUM' OR
     column_name is null Then
     IF new_references.intrntnl_acceptance_advice_num  < 1 OR
        new_references.intrntnl_acceptance_advice_num > 999999999999999 Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_INTRL_ACCPT_ADV_NUM'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'SECONDARY_ASS_RANK' OR
     column_name is null Then
     IF new_references.secondary_ass_rank  < 1 OR
        new_references.secondary_ass_rank > 999 Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SEC_ASS_RANK'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'PREFERENCE_NUMBER' OR
     column_name is null Then
     IF new_references.preference_number  < 1 OR
        new_references.preference_number > 99 Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PREFERANCE_NUM'));
         IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
        END IF;
END IF;


IF upper(column_name) = 'SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.sequence_number  < 1 OR
        new_references.sequence_number > 999999 Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SEQUENCE_NUM'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
END IF;


IF upper(column_name) = 'CORRESPONDENCE_CAT' OR
        column_name is null Then
        IF new_references.correspondence_cat <> UPPER(new_references.correspondence_cat) Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CRSPOND_CAT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'EXPECTED_COMPLETION_PERD' OR
        column_name is null Then
        IF new_references.expected_completion_perd <> UPPER(new_references.expected_completion_perd) Then
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_EXPCT_COMP_PRD'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
END IF;

IF upper(column_name) = 'APPL_INST_STATUS' OR								--arvsrini igsm
        column_name IS NULL THEN
        IF new_references.appl_inst_status <> UPPER(new_references.appl_inst_status) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_INST_STAT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
END IF;



END Check_Constraints;

PROCEDURE Check_Parent_Existance IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smadathi       13-Feb-2002      Bug 2217104. Added foreign key references
                                  to IGS_CA_INST_ALL table
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    IF (((old_references.attendance_mode = new_references.attendance_mode)) OR
        ((new_references.attendance_mode IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_MODE_PKG.Get_PK_For_Validation (
        new_references.attendance_mode
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ATTENDANCE_MODE'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_offer_dfrmnt_status = new_references.adm_offer_dfrmnt_status)) OR
        ((new_references.adm_offer_dfrmnt_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_OFRDFRMT_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_offer_dfrmnt_status
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OFFER_DFRMNT_STATUS'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_offer_resp_status = new_references.adm_offer_resp_status)) OR
        ((new_references.adm_offer_resp_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_OFR_RESP_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_offer_resp_status
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OFFER_RESP_STATUS'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_outcome_status = new_references.adm_outcome_status)) OR
        ((new_references.adm_outcome_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_OU_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_outcome_status
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OUTCOME_STATUS'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
        new_references.attendance_type
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ATTENDANCE_TYPE'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.deferred_adm_cal_type = new_references.deferred_adm_cal_type) AND
         (old_references.deferred_adm_ci_sequence_num = new_references.deferred_adm_ci_sequence_num)) OR
        ((new_references.deferred_adm_cal_type IS NULL) OR
         (new_references.deferred_adm_ci_sequence_num IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.deferred_adm_cal_type,
        new_references.deferred_adm_ci_sequence_num
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEFERRED_ADM_CAL_TYPE'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.adm_cal_type,
        new_references.adm_ci_sequence_number
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_CAL'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.crv_version_number = new_references.crv_version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.crv_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.crv_version_number
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.enrolment_cat = new_references.enrolment_cat)) OR
        ((new_references.enrolment_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ENROLMENT_CAT_PKG.Get_PK_For_Validation (
        new_references.enrolment_cat
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENROLMENT_CAT'));
         IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.fee_cat = new_references.fee_cat)) OR
        ((new_references.fee_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_CAT_PKG.Get_PK_For_Validation (
        new_references.fee_cat
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FEE_CAT'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.funding_source = new_references.funding_source)) OR
        ((new_references.funding_source IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FUND_SRC_PKG.Get_PK_For_Validation (
        new_references.funding_source
        ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FUNDING_SOURCE'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.hecs_payment_option = new_references.hecs_payment_option)) OR
        ((new_references.hecs_payment_option IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_HECS_PAY_OPTN_PKG.Get_PK_For_Validation (
        new_references.hecs_payment_option
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_HECS_PAY_OPT'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_EN_LOCATION'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.ass_tracking_id = new_references.ass_tracking_id)) OR
        ((new_references.ass_tracking_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_TR_ITEM_PKG.Get_PK_For_Validation (
        new_references.ass_tracking_id
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ASS_TRACKING_ID'));
         IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.deferred_tracking_id = new_references.deferred_tracking_id)) OR
        ((new_references.deferred_tracking_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_TR_ITEM_PKG.Get_PK_For_Validation (
        new_references.deferred_tracking_id
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ASS_TRACKING_ID'));
         IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.us_version_number = new_references.us_version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.us_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.unit_set_cd,
        new_references.us_version_number
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_PS_UNIT_SET'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number) AND
         (old_references.nominated_course_cd = new_references.nominated_course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL) OR
         (new_references.nominated_course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_PS_APPL_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.nominated_course_cd
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM_APPL'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_cndtnl_offer_status = new_references.adm_cndtnl_offer_status)) OR
        ((new_references.adm_cndtnl_offer_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_CNDNL_OFRSTAT_PKG.Get_PK_For_Validation (
        new_references.adm_cndtnl_offer_status
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_COND_OFR_STATUS'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_doc_status = new_references.adm_doc_status)) OR
        ((new_references.adm_doc_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_DOC_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_doc_status
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_DOC_STAT'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_entry_qual_status = new_references.adm_entry_qual_status)) OR
        ((new_references.adm_entry_qual_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_ENT_QF_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_entry_qual_status
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_ENTRY_QUAL_STATUS'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.late_adm_fee_status = new_references.late_adm_fee_status)) OR
        ((new_references.late_adm_fee_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_FEE_STAT_PKG.Get_PK_For_Validation (
        new_references.late_adm_fee_status
        )THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_LATE_ADM_FEE_STATUS'));
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;


    IF (((old_references.appl_inst_status = new_references.appl_inst_status)) OR		--arvsrini igsm
        ((new_references.appl_inst_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_APPL_STAT_PKG.Get_PK_For_Validation (
        new_references.appl_inst_status ,'N'
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_INST_STAT'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

---************************************************* begin apadegal adtd001 IGS.M **********************************

     IF (((old_references.decision_make_id = new_references.decision_make_id)) OR
        ((new_references.decision_make_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
                        new_references.decision_make_id
        )  THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEC_MAKE'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.decision_reason_id = new_references.decision_reason_id)) OR
        ((new_references.decision_reason_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                        new_references.decision_reason_id,
                       'DECISION_REASON', 'N'
        )  THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEC_REASON'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.pending_reason_id = new_references.pending_reason_id)) OR
        ((new_references.pending_reason_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                        new_references.pending_reason_id,
                        'PENDING_REASON','N'
        )  THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PEND_REASON'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.future_acad_cal_type = new_references.future_acad_cal_type) AND
         (old_references.future_acad_ci_sequence_num = new_references.future_acad_ci_sequence_num)) OR
        ((new_references.future_acad_cal_type IS NULL) OR
         (new_references.future_acad_ci_sequence_num IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.future_acad_cal_type,
        new_references.future_acad_ci_sequence_num
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FUT_ACAD_CAL'));
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.future_adm_cal_type = new_references.future_adm_cal_type) AND
         (old_references.future_adm_ci_sequence_num = new_references.future_adm_ci_sequence_num)) OR
        ((new_references.future_adm_cal_type IS NULL) OR
         (new_references.future_adm_ci_sequence_num IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.future_adm_cal_type,
        new_references.future_adm_ci_sequence_num
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FUT_ADM_CAL'));
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
---************************************************* end apadegal adtd001 IGS.M **********************************



END Check_Parent_Existance;


 FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    )
RETURN BOOLEAN
AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APLINSTHST_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
                x_org_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_preference_number IN NUMBER DEFAULT NULL,
    x_adm_doc_status IN VARCHAR2 DEFAULT NULL,
    x_adm_entry_qual_status IN VARCHAR2 DEFAULT NULL,
    x_late_adm_fee_status IN VARCHAR2 DEFAULT NULL,
    x_adm_outcome_status IN VARCHAR2 DEFAULT NULL,
    x_adm_otcm_status_auth_per_id IN NUMBER DEFAULT NULL,
    x_adm_outcome_status_auth_dt IN DATE DEFAULT NULL,
    x_adm_outcome_status_reason IN VARCHAR2 DEFAULT NULL,
    x_offer_dt IN DATE DEFAULT NULL,
    x_offer_response_dt IN DATE DEFAULT NULL,
    x_prpsd_commencement_dt IN DATE DEFAULT NULL,
    x_adm_cndtnl_offer_status IN VARCHAR2 DEFAULT NULL,
    x_cndtnl_offer_satisfied_dt IN DATE DEFAULT NULL,
    x_cndtnl_ofr_must_be_stsfd_ind IN VARCHAR2 DEFAULT NULL,
    x_adm_offer_resp_status IN VARCHAR2 DEFAULT NULL,
    x_actual_response_dt IN DATE DEFAULT NULL,
    x_adm_offer_dfrmnt_status IN VARCHAR2 DEFAULT NULL,
    x_deferred_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_deferred_adm_ci_sequence_num IN NUMBER DEFAULT NULL,
    x_deferred_tracking_id IN NUMBER DEFAULT NULL,
    x_ass_rank IN NUMBER DEFAULT NULL,
    x_secondary_ass_rank IN NUMBER DEFAULT NULL,
    x_intrntnl_accept_advice_num IN NUMBER DEFAULT NULL,
    x_ass_tracking_id IN NUMBER DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_expected_completion_yr IN NUMBER DEFAULT NULL,
    x_expected_completion_perd IN VARCHAR2 DEFAULT NULL,
    x_correspondence_cat IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_cndtnl_offer_cndtn IN VARCHAR2 DEFAULT NULL,
    x_applicant_acptnce_cndtn IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_hist_offer_round_number IN NUMBER DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_appl_inst_status IN VARCHAR2 DEFAULT NULL,							--arvsrini igsm
    X_DECISION_DATE                            DATE     DEFAULT NULL,	-- begin APADEGAL adtd001 igs.m
    X_DECISION_MAKE_ID                         NUMBER   DEFAULT NULL,
    X_DECISION_REASON_ID                       NUMBER   DEFAULT NULL,
    X_PENDING_REASON_ID                        NUMBER   DEFAULT NULL,
    X_WAITLIST_STATUS                          VARCHAR2 DEFAULT NULL,
    X_WAITLIST_RANK                            VARCHAR2 DEFAULT NULL,
    X_FUTURE_ACAD_CAL_TYPE                     VARCHAR2 DEFAULT NULL,
    X_FUTURE_ACAD_CI_SEQUENCE_NUM              NUMBER   DEFAULT NULL,
    X_FUTURE_ADM_CAL_TYPE                      VARCHAR2 DEFAULT NULL,
    X_FUTURE_ADM_CI_SEQUENCE_NUM               NUMBER   DEFAULT NULL,
    X_DEF_ACAD_CAL_TYPE                        VARCHAR2 DEFAULT NULL,
    X_DEF_ACAD_CI_SEQUENCE_NUM                 NUMBER   DEFAULT NULL,
    X_RECONSIDER_FLAG                          VARCHAR2 DEFAULT NULL,
    X_DECLINE_OFR_REASON                       VARCHAR2 DEFAULT NULL    -- end APADEGAL adtd001 igs.m
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
                        x_org_id,
      x_course_cd,
      x_crv_version_number,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_unit_set_cd,
      x_us_version_number,
      x_preference_number,
      x_adm_doc_status,
      x_adm_entry_qual_status,
      x_late_adm_fee_status,
      x_adm_outcome_status,
      x_adm_otcm_status_auth_per_id,
      x_adm_outcome_status_auth_dt,
      x_adm_outcome_status_reason,
      x_offer_dt,
      x_offer_response_dt,
      x_prpsd_commencement_dt,
      x_adm_cndtnl_offer_status,
      x_cndtnl_offer_satisfied_dt,
      x_cndtnl_ofr_must_be_stsfd_ind,
      x_adm_offer_resp_status,
      x_actual_response_dt,
      x_adm_offer_dfrmnt_status,
      x_deferred_adm_cal_type,
      x_deferred_adm_ci_sequence_num,
      x_deferred_tracking_id,
      x_ass_rank,
      x_secondary_ass_rank,
      x_intrntnl_accept_advice_num,
      x_ass_tracking_id,
      x_fee_cat,
      x_hecs_payment_option,
      x_expected_completion_yr,
      x_expected_completion_perd,
      x_correspondence_cat,
      x_enrolment_cat,
      x_funding_source,
      x_cndtnl_offer_cndtn,
      x_applicant_acptnce_cndtn,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_hist_offer_round_number,
      x_adm_cal_type,
      x_adm_ci_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_appl_inst_status,								--arvsrini igsm
      x_decision_date               ,	-- begin APADEGAL adtd001 igs.m
      x_decision_make_id            ,
      x_decision_reason_id          ,
      x_pending_reason_id           ,
      x_waitlist_status             ,
      x_waitlist_rank               ,
      x_future_acad_cal_type        ,
      x_future_acad_ci_sequence_num ,
      x_future_adm_cal_type         ,
      x_future_adm_ci_sequence_num  ,
      x_def_acad_cal_type           ,
      x_def_acad_ci_sequence_num    ,
      x_reconsider_flag             ,
      x_decline_ofr_reason              -- end APADEGAL adtd001 igs.m
    );

    IF (p_action = 'INSERT') THEN
      IF  Get_PK_For_Validation (
                new_references.person_id,
        new_references.admission_appl_number,
              new_references.nominated_course_cd,
        new_references.sequence_number,
              new_references.hist_start_dt
        ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                 IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
       new_references.person_id,
       new_references.admission_appl_number,
       new_references.nominated_course_cd,
       new_references.sequence_number,
       new_references.hist_start_dt
        ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                 IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
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
        X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_APPLICANT_ACPTNCE_CNDTN in VARCHAR2,
  X_CNDTNL_OFFER_CNDTN in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_HIST_OFFER_ROUND_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_PREFERENCE_NUMBER in NUMBER,
  X_ADM_DOC_STATUS in VARCHAR2,
  X_ADM_ENTRY_QUAL_STATUS in VARCHAR2,
  X_LATE_ADM_FEE_STATUS in VARCHAR2,
  X_ADM_OUTCOME_STATUS in VARCHAR2,
  X_ADM_OTCM_STATUS_AUTH_PER_ID in NUMBER,
  X_ADM_OUTCOME_STATUS_AUTH_DT in DATE,
  X_ADM_OUTCOME_STATUS_REASON in VARCHAR2,
  X_OFFER_DT in DATE,
  X_OFFER_RESPONSE_DT in DATE,
  X_PRPSD_COMMENCEMENT_DT in DATE,
  X_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_CNDTNL_OFFER_SATISFIED_DT in DATE,
  X_CNDTNL_OFR_MUST_BE_STSFD_IND in VARCHAR2,
  X_ADM_OFFER_RESP_STATUS in VARCHAR2,
  X_ACTUAL_RESPONSE_DT in DATE,
  X_ADM_OFFER_DFRMNT_STATUS in VARCHAR2,
  X_DEFERRED_ADM_CAL_TYPE in VARCHAR2,
  X_DEFERRED_ADM_CI_SEQUENCE_NUM in NUMBER,
  X_DEFERRED_TRACKING_ID in NUMBER,
  X_ASS_RANK in NUMBER,
  X_SECONDARY_ASS_RANK in NUMBER,
  X_INTRNTNL_ACCEPT_ADVICE_NUM in NUMBER,
  X_ASS_TRACKING_ID in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_EXPECTED_COMPLETION_YR in NUMBER,
  X_EXPECTED_COMPLETION_PERD in VARCHAR2,
  X_CORRESPONDENCE_CAT in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_MODE in VARCHAR2,
  X_APPL_INST_STATUS IN VARCHAR2,							--arvsrini igsm
  X_DECISION_DATE                            DATE     DEFAULT NULL,	-- begin APADEGAL adtd001 igs.m
  X_DECISION_MAKE_ID                         NUMBER   DEFAULT NULL,
  X_DECISION_REASON_ID                       NUMBER   DEFAULT NULL,
  X_PENDING_REASON_ID                        NUMBER   DEFAULT NULL,
  X_WAITLIST_STATUS                          VARCHAR2 DEFAULT NULL,
  X_WAITLIST_RANK                            VARCHAR2 DEFAULT NULL,
  X_FUTURE_ACAD_CAL_TYPE                     VARCHAR2 DEFAULT NULL,
  X_FUTURE_ACAD_CI_SEQUENCE_NUM              NUMBER   DEFAULT NULL,
  X_FUTURE_ADM_CAL_TYPE                      VARCHAR2 DEFAULT NULL,
  X_FUTURE_ADM_CI_SEQUENCE_NUM               NUMBER   DEFAULT NULL,
  X_DEF_ACAD_CAL_TYPE                        VARCHAR2 DEFAULT NULL,
  X_DEF_ACAD_CI_SEQUENCE_NUM                 NUMBER   DEFAULT NULL,
  X_RECONSIDER_FLAG                          VARCHAR2 DEFAULT NULL,
  X_DECLINE_OFR_REASON                       VARCHAR2 DEFAULT NULL    -- end APADEGAL adtd001 igs.m
  ) as
    cursor C is select ROWID from IGS_AD_PS_APLINSTHST_ALL
      where PERSON_ID = X_PERSON_ID
      and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
      and NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD
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
  p_action =>'INSERT',
  x_rowid =>X_ROWID,
        x_org_id => igs_ge_gen_003.get_org_id,
  x_course_cd => X_COURSE_CD,
  x_crv_version_number => X_CRV_VERSION_NUMBER,
  x_location_cd =>  X_LOCATION_CD,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_unit_set_cd=>X_UNIT_SET_CD,
  x_us_version_number =>X_US_VERSION_NUMBER,
  x_preference_number =>X_PREFERENCE_NUMBER,
  x_adm_doc_status =>X_ADM_DOC_STATUS,
  x_adm_entry_qual_status =>X_ADM_ENTRY_QUAL_STATUS,
  x_late_adm_fee_status =>X_LATE_ADM_FEE_STATUS,
  x_adm_outcome_status =>X_ADM_OUTCOME_STATUS,
  x_adm_otcm_status_auth_per_id =>X_ADM_OTCM_STATUS_AUTH_PER_ID,
  x_adm_outcome_status_auth_dt =>X_ADM_OUTCOME_STATUS_AUTH_DT,
  x_adm_outcome_status_reason =>X_ADM_OUTCOME_STATUS_REASON,
  x_offer_dt =>X_OFFER_DT,
  x_offer_response_dt =>X_OFFER_RESPONSE_DT,
  x_prpsd_commencement_dt =>X_PRPSD_COMMENCEMENT_DT,
  x_adm_cndtnl_offer_status =>X_ADM_CNDTNL_OFFER_STATUS,
  x_cndtnl_offer_satisfied_dt =>X_CNDTNL_OFFER_SATISFIED_DT,
  x_cndtnl_ofr_must_be_stsfd_ind => NVL(X_CNDTNL_OFR_MUST_BE_STSFD_IND,'N'),
  x_adm_offer_resp_status => X_ADM_OFFER_RESP_STATUS,
  x_actual_response_dt => X_ACTUAL_RESPONSE_DT,
  x_adm_offer_dfrmnt_status =>X_ADM_OFFER_DFRMNT_STATUS,
  x_deferred_adm_cal_type =>X_DEFERRED_ADM_CAL_TYPE,
  x_deferred_adm_ci_sequence_num =>X_DEFERRED_ADM_CI_SEQUENCE_NUM,
  x_deferred_tracking_id =>X_DEFERRED_TRACKING_ID,
  x_ass_rank =>X_ASS_RANK,
  x_secondary_ass_rank =>X_SECONDARY_ASS_RANK,
  x_intrntnl_accept_advice_num =>X_INTRNTNL_ACCEPT_ADVICE_NUM,
  x_ass_tracking_id =>X_ASS_TRACKING_ID,
  x_fee_cat =>X_FEE_CAT,
  x_hecs_payment_option =>X_HECS_PAYMENT_OPTION,
  x_expected_completion_yr =>X_EXPECTED_COMPLETION_YR,
  x_expected_completion_perd =>X_EXPECTED_COMPLETION_PERD,
  x_correspondence_cat =>X_CORRESPONDENCE_CAT,
  x_enrolment_cat =>X_ENROLMENT_CAT,
  x_funding_source =>X_FUNDING_SOURCE,
  x_cndtnl_offer_cndtn =>X_CNDTNL_OFFER_CNDTN,
  x_applicant_acptnce_cndtn =>X_APPLICANT_ACPTNCE_CNDTN,
  x_person_id =>X_PERSON_ID,
  x_admission_appl_number =>X_ADMISSION_APPL_NUMBER,
  x_nominated_course_cd =>X_NOMINATED_COURSE_CD,
  x_sequence_number =>X_SEQUENCE_NUMBER,
  x_hist_start_dt =>X_HIST_START_DT,
  x_hist_end_dt =>X_HIST_END_DT,
  x_hist_who =>X_HIST_WHO,
  x_hist_offer_round_number=>X_HIST_OFFER_ROUND_NUMBER,
  x_adm_cal_type =>X_ADM_CAL_TYPE,
  x_adm_ci_sequence_number =>X_ADM_CI_SEQUENCE_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_appl_inst_status => X_APPL_INST_STATUS,						--arvsrini igsm
  x_decision_date                 =>	x_decision_date                ,    	        -- begin apadegal td001 igsm
  x_decision_make_id              =>	x_decision_make_id             ,
  x_decision_reason_id            =>	x_decision_reason_id           ,
  x_pending_reason_id             =>	x_pending_reason_id            ,
  x_waitlist_status               =>	x_waitlist_status              ,
  x_waitlist_rank                 =>	x_waitlist_rank                ,
  x_future_acad_cal_type          =>	x_future_acad_cal_type         ,
  x_future_acad_ci_sequence_num   =>	x_future_acad_ci_sequence_num  ,
  x_future_adm_cal_type           =>	x_future_adm_cal_type          ,
  x_future_adm_ci_sequence_num    =>	x_future_adm_ci_sequence_num   ,
  x_def_acad_cal_type             =>	x_def_acad_cal_type            ,
  x_def_acad_ci_sequence_num      =>	x_def_acad_ci_sequence_num     ,
  x_reconsider_flag               =>	x_reconsider_flag              ,
  x_decline_ofr_reason            => 	x_decline_ofr_reason              		-- end apadegal td001 igsm
);

  insert into IGS_AD_PS_APLINSTHST_ALL (
                ORG_ID,
    APPLICANT_ACPTNCE_CNDTN,
    CNDTNL_OFFER_CNDTN,
    PERSON_ID,
    ADMISSION_APPL_NUMBER,
    NOMINATED_COURSE_CD,
    SEQUENCE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    HIST_OFFER_ROUND_NUMBER,
    ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER,
    COURSE_CD,
    CRV_VERSION_NUMBER,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    UNIT_SET_CD,
    US_VERSION_NUMBER,
    PREFERENCE_NUMBER,
    ADM_DOC_STATUS,
    ADM_ENTRY_QUAL_STATUS,
    LATE_ADM_FEE_STATUS,
    ADM_OUTCOME_STATUS,
    ADM_OTCM_STATUS_AUTH_PERSON_ID,
    ADM_OUTCOME_STATUS_AUTH_DT,
    ADM_OUTCOME_STATUS_REASON,
    OFFER_DT,
    OFFER_RESPONSE_DT,
    PRPSD_COMMENCEMENT_DT,
    ADM_CNDTNL_OFFER_STATUS,
    CNDTNL_OFFER_SATISFIED_DT,
    CNDTNL_OFFER_MUST_BE_STSFD_IND,
    ADM_OFFER_RESP_STATUS,
    ACTUAL_RESPONSE_DT,
    ADM_OFFER_DFRMNT_STATUS,
    DEFERRED_ADM_CAL_TYPE,
    DEFERRED_ADM_CI_SEQUENCE_NUM,
    DEFERRED_TRACKING_ID,
    ASS_RANK,
    SECONDARY_ASS_RANK,
    INTRNTNL_ACCEPTANCE_ADVICE_NUM,
    ASS_TRACKING_ID,
    FEE_CAT,
    HECS_PAYMENT_OPTION,
    EXPECTED_COMPLETION_YR,
    EXPECTED_COMPLETION_PERD,
    CORRESPONDENCE_CAT,
    ENROLMENT_CAT,
    FUNDING_SOURCE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    APPL_INST_STATUS,								--arvsrini igsm
    DECISION_DATE                ,      -- BEGIN APADEGAL TD001 IGSM
    DECISION_MAKE_ID             ,
    DECISION_REASON_ID           ,
    PENDING_REASON_ID            ,
    WAITLIST_STATUS              ,
    WAITLIST_RANK                ,
    FUTURE_ACAD_CAL_TYPE         ,
    FUTURE_ACAD_CI_SEQUENCE_NUM  ,
    FUTURE_ADM_CAL_TYPE          ,
    FUTURE_ADM_CI_SEQUENCE_NUM   ,
    DEF_ACAD_CAL_TYPE            ,
    DEF_ACAD_CI_SEQUENCE_NUM     ,
    RECONSIDER_FLAG              ,
    DECLINE_OFR_REASON                -- end APADEGAL TD001 IGSM
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.APPLICANT_ACPTNCE_CNDTN,
    NEW_REFERENCES.CNDTNL_OFFER_CNDTN,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.NOMINATED_COURSE_CD,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.HIST_OFFER_ROUND_NUMBER,
    NEW_REFERENCES.ADM_CAL_TYPE,
    NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.CRV_VERSION_NUMBER,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.US_VERSION_NUMBER,
    NEW_REFERENCES.PREFERENCE_NUMBER,
    NEW_REFERENCES.ADM_DOC_STATUS,
    NEW_REFERENCES.ADM_ENTRY_QUAL_STATUS,
    NEW_REFERENCES.LATE_ADM_FEE_STATUS,
    NEW_REFERENCES.ADM_OUTCOME_STATUS,
    NEW_REFERENCES.ADM_OTCM_STATUS_AUTH_PERSON_ID,
    NEW_REFERENCES.ADM_OUTCOME_STATUS_AUTH_DT,
    NEW_REFERENCES.ADM_OUTCOME_STATUS_REASON,
    NEW_REFERENCES.OFFER_DT,
    NEW_REFERENCES.OFFER_RESPONSE_DT,
    NEW_REFERENCES.PRPSD_COMMENCEMENT_DT,
    NEW_REFERENCES.ADM_CNDTNL_OFFER_STATUS,
    NEW_REFERENCES.CNDTNL_OFFER_SATISFIED_DT,
    NEW_REFERENCES.CNDTNL_OFFER_MUST_BE_STSFD_IND,
    NEW_REFERENCES.ADM_OFFER_RESP_STATUS,
    NEW_REFERENCES.ACTUAL_RESPONSE_DT,
    NEW_REFERENCES.ADM_OFFER_DFRMNT_STATUS,
    NEW_REFERENCES.DEFERRED_ADM_CAL_TYPE,
    NEW_REFERENCES.DEFERRED_ADM_CI_SEQUENCE_NUM,
    NEW_REFERENCES.DEFERRED_TRACKING_ID,
    NEW_REFERENCES.ASS_RANK,
    NEW_REFERENCES.SECONDARY_ASS_RANK,
    NEW_REFERENCES.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
    NEW_REFERENCES.ASS_TRACKING_ID,
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.HECS_PAYMENT_OPTION,
    NEW_REFERENCES.EXPECTED_COMPLETION_YR,
    NEW_REFERENCES.EXPECTED_COMPLETION_PERD,
    NEW_REFERENCES.CORRESPONDENCE_CAT,
    NEW_REFERENCES.ENROLMENT_CAT,
    NEW_REFERENCES.FUNDING_SOURCE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.APPL_INST_STATUS,							--arvsrini igsm
    NEW_REFERENCES.DECISION_DATE                ,      -- BEGIN APADEGAL TD001 IGSM
    NEW_REFERENCES.DECISION_MAKE_ID             ,
    NEW_REFERENCES.DECISION_REASON_ID           ,
    NEW_REFERENCES.PENDING_REASON_ID            ,
    NEW_REFERENCES.WAITLIST_STATUS              ,
    NEW_REFERENCES.WAITLIST_RANK                ,
    NEW_REFERENCES.FUTURE_ACAD_CAL_TYPE         ,
    NEW_REFERENCES.FUTURE_ACAD_CI_SEQUENCE_NUM  ,
    NEW_REFERENCES.FUTURE_ADM_CAL_TYPE          ,
    NEW_REFERENCES.FUTURE_ADM_CI_SEQUENCE_NUM   ,
    NEW_REFERENCES.DEF_ACAD_CAL_TYPE            ,
    NEW_REFERENCES.DEF_ACAD_CI_SEQUENCE_NUM     ,
    NEW_REFERENCES.RECONSIDER_FLAG              ,
    NEW_REFERENCES.DECLINE_OFR_REASON                -- end APADEGAL TD001 IGSM
  );

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
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_APPLICANT_ACPTNCE_CNDTN in VARCHAR2,
  X_CNDTNL_OFFER_CNDTN in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_HIST_OFFER_ROUND_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_PREFERENCE_NUMBER in NUMBER,
  X_ADM_DOC_STATUS in VARCHAR2,
  X_ADM_ENTRY_QUAL_STATUS in VARCHAR2,
  X_LATE_ADM_FEE_STATUS in VARCHAR2,
  X_ADM_OUTCOME_STATUS in VARCHAR2,
  X_ADM_OTCM_STATUS_AUTH_PER_ID in NUMBER,
  X_ADM_OUTCOME_STATUS_AUTH_DT in DATE,
  X_ADM_OUTCOME_STATUS_REASON in VARCHAR2,
  X_OFFER_DT in DATE,
  X_OFFER_RESPONSE_DT in DATE,
  X_PRPSD_COMMENCEMENT_DT in DATE,
  X_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_CNDTNL_OFFER_SATISFIED_DT in DATE,
  X_CNDTNL_OFR_MUST_BE_STSFD_IND in VARCHAR2,
  X_ADM_OFFER_RESP_STATUS in VARCHAR2,
  X_ACTUAL_RESPONSE_DT in DATE,
  X_ADM_OFFER_DFRMNT_STATUS in VARCHAR2,
  X_DEFERRED_ADM_CAL_TYPE in VARCHAR2,
  X_DEFERRED_ADM_CI_SEQUENCE_NUM in NUMBER,
  X_DEFERRED_TRACKING_ID in NUMBER,
  X_ASS_RANK in NUMBER,
  X_SECONDARY_ASS_RANK in NUMBER,
  X_INTRNTNL_ACCEPT_ADVICE_NUM in NUMBER,
  X_ASS_TRACKING_ID in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_EXPECTED_COMPLETION_YR in NUMBER,
  X_EXPECTED_COMPLETION_PERD in VARCHAR2,
  X_CORRESPONDENCE_CAT in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_APPL_INST_STATUS IN VARCHAR2,								--arvsrini igsm
  X_DECISION_DATE                   DATE     DEFAULT NULL,	-- begin APADEGAL adtd001 igs.m
  X_DECISION_MAKE_ID                NUMBER   DEFAULT NULL,
  X_DECISION_REASON_ID              NUMBER   DEFAULT NULL,
  X_PENDING_REASON_ID               NUMBER   DEFAULT NULL,
  X_WAITLIST_STATUS                 VARCHAR2 DEFAULT NULL,
  X_WAITLIST_RANK                   VARCHAR2 DEFAULT NULL,
  X_FUTURE_ACAD_CAL_TYPE            VARCHAR2 DEFAULT NULL,
  X_FUTURE_ACAD_CI_SEQUENCE_NUM     NUMBER   DEFAULT NULL,
  X_FUTURE_ADM_CAL_TYPE             VARCHAR2 DEFAULT NULL,
  X_FUTURE_ADM_CI_SEQUENCE_NUM      NUMBER   DEFAULT NULL,
  X_DEF_ACAD_CAL_TYPE               VARCHAR2 DEFAULT NULL,
  X_DEF_ACAD_CI_SEQUENCE_NUM        NUMBER   DEFAULT NULL,
  X_RECONSIDER_FLAG                 VARCHAR2 DEFAULT NULL,
  X_DECLINE_OFR_REASON              VARCHAR2 DEFAULT NULL    -- end APADEGAL adtd001 igs.m
) as
  cursor c1 is select
      APPLICANT_ACPTNCE_CNDTN,
      CNDTNL_OFFER_CNDTN,
      HIST_END_DT,
      HIST_WHO,
      HIST_OFFER_ROUND_NUMBER,
      ADM_CAL_TYPE,
      ADM_CI_SEQUENCE_NUMBER,
      COURSE_CD,
      CRV_VERSION_NUMBER,
      LOCATION_CD,
      ATTENDANCE_MODE,
      ATTENDANCE_TYPE,
      UNIT_SET_CD,
      US_VERSION_NUMBER,
      PREFERENCE_NUMBER,
      ADM_DOC_STATUS,
      ADM_ENTRY_QUAL_STATUS,
      LATE_ADM_FEE_STATUS,
      ADM_OUTCOME_STATUS,
      ADM_OTCM_STATUS_AUTH_PERSON_ID,
      ADM_OUTCOME_STATUS_AUTH_DT,
      ADM_OUTCOME_STATUS_REASON,
      OFFER_DT,
      OFFER_RESPONSE_DT,
      PRPSD_COMMENCEMENT_DT,
      ADM_CNDTNL_OFFER_STATUS,
      CNDTNL_OFFER_SATISFIED_DT,
      CNDTNL_OFFER_MUST_BE_STSFD_IND,
      ADM_OFFER_RESP_STATUS,
      ACTUAL_RESPONSE_DT,
      ADM_OFFER_DFRMNT_STATUS,
      DEFERRED_ADM_CAL_TYPE,
      DEFERRED_ADM_CI_SEQUENCE_NUM,
      DEFERRED_TRACKING_ID,
      ASS_RANK,
      SECONDARY_ASS_RANK,
      INTRNTNL_ACCEPTANCE_ADVICE_NUM,
      ASS_TRACKING_ID,
      FEE_CAT,
      HECS_PAYMENT_OPTION,
      EXPECTED_COMPLETION_YR,
      EXPECTED_COMPLETION_PERD,
      CORRESPONDENCE_CAT,
      ENROLMENT_CAT,
      FUNDING_SOURCE,
      APPL_INST_STATUS,										--arvsrini igsm
      DECISION_DATE                 ,	-- begin APADEGAL adtd001 igs.m
      DECISION_MAKE_ID              ,
      DECISION_REASON_ID            ,
      PENDING_REASON_ID             ,
      WAITLIST_STATUS               ,
      WAITLIST_RANK                 ,
      FUTURE_ACAD_CAL_TYPE          ,
      FUTURE_ACAD_CI_SEQUENCE_NUM   ,
      FUTURE_ADM_CAL_TYPE           ,
      FUTURE_ADM_CI_SEQUENCE_NUM    ,
      DEF_ACAD_CAL_TYPE             ,
      DEF_ACAD_CI_SEQUENCE_NUM      ,
      RECONSIDER_FLAG               ,
      DECLINE_OFR_REASON                -- end APADEGAL adtd001 igs.m
    from IGS_AD_PS_APLINSTHST_ALL
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

      if ( ((tlinfo.APPLICANT_ACPTNCE_CNDTN = X_APPLICANT_ACPTNCE_CNDTN)
           OR ((tlinfo.APPLICANT_ACPTNCE_CNDTN is null)
               AND (X_APPLICANT_ACPTNCE_CNDTN is null)))
      AND ((tlinfo.CNDTNL_OFFER_CNDTN = X_CNDTNL_OFFER_CNDTN)
           OR ((tlinfo.CNDTNL_OFFER_CNDTN is null)
               AND (X_CNDTNL_OFFER_CNDTN is null)))
      AND (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.HIST_OFFER_ROUND_NUMBER = X_HIST_OFFER_ROUND_NUMBER)
           OR ((tlinfo.HIST_OFFER_ROUND_NUMBER is null)
               AND (X_HIST_OFFER_ROUND_NUMBER is null)))
      AND ((tlinfo.ADM_CAL_TYPE = X_ADM_CAL_TYPE)
           OR ((tlinfo.ADM_CAL_TYPE is null)
               AND (X_ADM_CAL_TYPE is null)))
      AND ((tlinfo.ADM_CI_SEQUENCE_NUMBER = X_ADM_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.ADM_CI_SEQUENCE_NUMBER is null)
               AND (X_ADM_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.COURSE_CD = X_COURSE_CD)
           OR ((tlinfo.COURSE_CD is null)
               AND (X_COURSE_CD is null)))
      AND ((tlinfo.CRV_VERSION_NUMBER = X_CRV_VERSION_NUMBER)
           OR ((tlinfo.CRV_VERSION_NUMBER is null)
               AND (X_CRV_VERSION_NUMBER is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
           OR ((tlinfo.ATTENDANCE_MODE is null)
               AND (X_ATTENDANCE_MODE is null)))
      AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
           OR ((tlinfo.ATTENDANCE_TYPE is null)
               AND (X_ATTENDANCE_TYPE is null)))
      AND ((tlinfo.UNIT_SET_CD = X_UNIT_SET_CD)
           OR ((tlinfo.UNIT_SET_CD is null)
               AND (X_UNIT_SET_CD is null)))
      AND ((tlinfo.US_VERSION_NUMBER = X_US_VERSION_NUMBER)
           OR ((tlinfo.US_VERSION_NUMBER is null)
               AND (X_US_VERSION_NUMBER is null)))
      AND ((tlinfo.PREFERENCE_NUMBER = X_PREFERENCE_NUMBER)
           OR ((tlinfo.PREFERENCE_NUMBER is null)
               AND (X_PREFERENCE_NUMBER is null)))
      AND ((tlinfo.ADM_DOC_STATUS = X_ADM_DOC_STATUS)
           OR ((tlinfo.ADM_DOC_STATUS is null)
               AND (X_ADM_DOC_STATUS is null)))
      AND ((tlinfo.ADM_ENTRY_QUAL_STATUS = X_ADM_ENTRY_QUAL_STATUS)
           OR ((tlinfo.ADM_ENTRY_QUAL_STATUS is null)
               AND (X_ADM_ENTRY_QUAL_STATUS is null)))
      AND ((tlinfo.LATE_ADM_FEE_STATUS = X_LATE_ADM_FEE_STATUS)
           OR ((tlinfo.LATE_ADM_FEE_STATUS is null)
               AND (X_LATE_ADM_FEE_STATUS is null)))
      AND ((tlinfo.ADM_OUTCOME_STATUS = X_ADM_OUTCOME_STATUS)
           OR ((tlinfo.ADM_OUTCOME_STATUS is null)
               AND (X_ADM_OUTCOME_STATUS is null)))
      AND ((tlinfo.ADM_OTCM_STATUS_AUTH_PERSON_ID = X_ADM_OTCM_STATUS_AUTH_PER_ID)
           OR ((tlinfo.ADM_OTCM_STATUS_AUTH_PERSON_ID is null)
               AND (X_ADM_OTCM_STATUS_AUTH_PER_ID is null)))
      AND ((TRUNC(tlinfo.ADM_OUTCOME_STATUS_AUTH_DT) = TRUNC(X_ADM_OUTCOME_STATUS_AUTH_DT))
           OR ((tlinfo.ADM_OUTCOME_STATUS_AUTH_DT is null)
               AND (X_ADM_OUTCOME_STATUS_AUTH_DT is null)))
      AND ((tlinfo.ADM_OUTCOME_STATUS_REASON = X_ADM_OUTCOME_STATUS_REASON)
           OR ((tlinfo.ADM_OUTCOME_STATUS_REASON is null)
               AND (X_ADM_OUTCOME_STATUS_REASON is null)))
      AND ((TRUNC(tlinfo.OFFER_DT) = TRUNC(X_OFFER_DT))
           OR ((tlinfo.OFFER_DT is null)
               AND (X_OFFER_DT is null)))
      AND ((TRUNC(tlinfo.OFFER_RESPONSE_DT) = TRUNC(X_OFFER_RESPONSE_DT))
           OR ((tlinfo.OFFER_RESPONSE_DT is null)
               AND (X_OFFER_RESPONSE_DT is null)))
      AND ((TRUNC(tlinfo.PRPSD_COMMENCEMENT_DT) = TRUNC(X_PRPSD_COMMENCEMENT_DT))
           OR ((tlinfo.PRPSD_COMMENCEMENT_DT is null)
               AND (X_PRPSD_COMMENCEMENT_DT is null)))
      AND ((tlinfo.ADM_CNDTNL_OFFER_STATUS = X_ADM_CNDTNL_OFFER_STATUS)
           OR ((tlinfo.ADM_CNDTNL_OFFER_STATUS is null)
               AND (X_ADM_CNDTNL_OFFER_STATUS is null)))
      AND ((TRUNC(tlinfo.CNDTNL_OFFER_SATISFIED_DT) = TRUNC(X_CNDTNL_OFFER_SATISFIED_DT))
           OR ((tlinfo.CNDTNL_OFFER_SATISFIED_DT is null)
               AND (X_CNDTNL_OFFER_SATISFIED_DT is null)))
      AND ((tlinfo.CNDTNL_OFFER_MUST_BE_STSFD_IND = X_CNDTNL_OFR_MUST_BE_STSFD_IND)
           OR ((tlinfo.CNDTNL_OFFER_MUST_BE_STSFD_IND is null)
               AND (X_CNDTNL_OFR_MUST_BE_STSFD_IND is null)))
      AND ((tlinfo.ADM_OFFER_RESP_STATUS = X_ADM_OFFER_RESP_STATUS)
           OR ((tlinfo.ADM_OFFER_RESP_STATUS is null)
               AND (X_ADM_OFFER_RESP_STATUS is null)))
      AND ((TRUNC(tlinfo.ACTUAL_RESPONSE_DT) = TRUNC(X_ACTUAL_RESPONSE_DT))
           OR ((tlinfo.ACTUAL_RESPONSE_DT is null)
               AND (X_ACTUAL_RESPONSE_DT is null)))
      AND ((tlinfo.ADM_OFFER_DFRMNT_STATUS = X_ADM_OFFER_DFRMNT_STATUS)
           OR ((tlinfo.ADM_OFFER_DFRMNT_STATUS is null)
               AND (X_ADM_OFFER_DFRMNT_STATUS is null)))
      AND ((tlinfo.DEFERRED_ADM_CAL_TYPE = X_DEFERRED_ADM_CAL_TYPE)
           OR ((tlinfo.DEFERRED_ADM_CAL_TYPE is null)
               AND (X_DEFERRED_ADM_CAL_TYPE is null)))
      AND ((tlinfo.DEFERRED_ADM_CI_SEQUENCE_NUM = X_DEFERRED_ADM_CI_SEQUENCE_NUM)
           OR ((tlinfo.DEFERRED_ADM_CI_SEQUENCE_NUM is null)
               AND (X_DEFERRED_ADM_CI_SEQUENCE_NUM is null)))
      AND ((tlinfo.DEFERRED_TRACKING_ID = X_DEFERRED_TRACKING_ID)
           OR ((tlinfo.DEFERRED_TRACKING_ID is null)
               AND (X_DEFERRED_TRACKING_ID is null)))
      AND ((tlinfo.ASS_RANK = X_ASS_RANK)
           OR ((tlinfo.ASS_RANK is null)
               AND (X_ASS_RANK is null)))
      AND ((tlinfo.SECONDARY_ASS_RANK = X_SECONDARY_ASS_RANK)
           OR ((tlinfo.SECONDARY_ASS_RANK is null)
               AND (X_SECONDARY_ASS_RANK is null)))
      AND ((tlinfo.INTRNTNL_ACCEPTANCE_ADVICE_NUM = X_INTRNTNL_ACCEPT_ADVICE_NUM)
           OR ((tlinfo.INTRNTNL_ACCEPTANCE_ADVICE_NUM is null)
               AND (X_INTRNTNL_ACCEPT_ADVICE_NUM is null)))
      AND ((tlinfo.ASS_TRACKING_ID = X_ASS_TRACKING_ID)
           OR ((tlinfo.ASS_TRACKING_ID is null)
               AND (X_ASS_TRACKING_ID is null)))
      AND ((tlinfo.FEE_CAT = X_FEE_CAT)
           OR ((tlinfo.FEE_CAT is null)
               AND (X_FEE_CAT is null)))
      AND ((tlinfo.HECS_PAYMENT_OPTION = X_HECS_PAYMENT_OPTION)
           OR ((tlinfo.HECS_PAYMENT_OPTION is null)
               AND (X_HECS_PAYMENT_OPTION is null)))
      AND ((tlinfo.EXPECTED_COMPLETION_YR = X_EXPECTED_COMPLETION_YR)
           OR ((tlinfo.EXPECTED_COMPLETION_YR is null)
               AND (X_EXPECTED_COMPLETION_YR is null)))
      AND ((tlinfo.EXPECTED_COMPLETION_PERD = X_EXPECTED_COMPLETION_PERD)
           OR ((tlinfo.EXPECTED_COMPLETION_PERD is null)
               AND (X_EXPECTED_COMPLETION_PERD is null)))
      AND ((tlinfo.CORRESPONDENCE_CAT = X_CORRESPONDENCE_CAT)
           OR ((tlinfo.CORRESPONDENCE_CAT is null)
               AND (X_CORRESPONDENCE_CAT is null)))
      AND ((tlinfo.ENROLMENT_CAT = X_ENROLMENT_CAT)
           OR ((tlinfo.ENROLMENT_CAT is null)
               AND (X_ENROLMENT_CAT is null)))
      AND ((tlinfo.FUNDING_SOURCE = X_FUNDING_SOURCE)
           OR ((tlinfo.FUNDING_SOURCE is null)
               AND (X_FUNDING_SOURCE is null)))
      AND ((tlinfo.APPL_INST_STATUS = X_APPL_INST_STATUS)					--arvsrini igsm
           OR ((tlinfo.APPL_INST_STATUS is null)
               AND (X_APPL_INST_STATUS is null)))

      AND ((tlinfo.decision_Make_Id = X_decision_Make_Id)         -- BEGIN APADEGAL TD001 IGSM
                 OR ((tlinfo.decision_Make_Id is null)
                     AND (X_decision_Make_Id is null)))

      AND ((tlinfo.decision_Date = X_decision_Date)
                 OR ((tlinfo.decision_Date is null)
                     AND (X_decision_Date is null)))

      AND ((tlinfo.decision_reason_id = X_decision_reason_id)
                 OR ((tlinfo.decision_reason_id is null)
                     AND (X_decision_reason_id is null)))

      AND ((tlinfo.pending_reason_id = X_pending_reason_id)
                 OR ((tlinfo.pending_reason_id is null)
                     AND (X_pending_reason_id is null)))

      AND ((tlinfo.waitlist_status = X_waitlist_status)
                 OR ((tlinfo.waitlist_status is null)
                     AND (X_waitlist_status is null)))

      AND ((tlinfo.waitlist_rank = X_waitlist_rank)
                 OR ((tlinfo.waitlist_rank is null)
                     AND (X_waitlist_rank is null)))

      AND ((tlinfo.Future_Acad_Cal_Type = X_Future_Acad_Cal_Type)
                 OR ((tlinfo.Future_Acad_Cal_Type is null)
                     AND (X_Future_Acad_Cal_Type is null)))

      AND ((tlinfo.Future_Acad_Ci_Sequence_Num = X_Future_Acad_Ci_Sequence_Num)
                 OR ((tlinfo.Future_Acad_Ci_Sequence_Num is null)
                     AND (X_Future_Acad_Ci_Sequence_Num is null)))

      AND ((tlinfo.Future_Adm_Cal_Type = X_Future_Adm_Cal_Type)
                 OR ((tlinfo.Future_Adm_Cal_Type is null)
                     AND (X_Future_Adm_Cal_Type is null)))

      AND ((tlinfo.Future_Adm_Ci_Sequence_Num = X_Future_Adm_Ci_Sequence_Num)
                 OR ((tlinfo.Future_Adm_Ci_Sequence_Num is null)
                     AND (X_Future_Adm_Ci_Sequence_Num is null)))

      AND ((tlinfo.Def_acad_cal_type = X_def_acad_cal_type)
                 OR ((tlinfo.Def_acad_cal_type is null)
                     AND (X_def_acad_cal_type is null)))

      AND ((tlinfo.def_Acad_Ci_Sequence_Num = X_Def_acad_Ci_Sequence_Num)
                 OR ((tlinfo.def_Acad_Ci_Sequence_Num is null)
                     AND (X_Def_acad_Ci_Sequence_Num is null)))

      AND ((tlinfo.RECONSIDER_FLAG = X_RECONSIDER_FLAG)
                 OR ((tlinfo.RECONSIDER_FLAG is null)
                     AND (X_RECONSIDER_FLAG is null)))

      AND ((tlinfo.DECLINE_OFR_REASON = X_DECLINE_OFR_REASON)
           OR ((tlinfo.DECLINE_OFR_REASON is null)
               AND (X_DECLINE_OFR_REASON is null)))          		     -- end APADEGAL TD001 IGSM


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
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_APPLICANT_ACPTNCE_CNDTN in VARCHAR2,
  X_CNDTNL_OFFER_CNDTN in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_HIST_OFFER_ROUND_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_PREFERENCE_NUMBER in NUMBER,
  X_ADM_DOC_STATUS in VARCHAR2,
  X_ADM_ENTRY_QUAL_STATUS in VARCHAR2,
  X_LATE_ADM_FEE_STATUS in VARCHAR2,
  X_ADM_OUTCOME_STATUS in VARCHAR2,
  X_ADM_OTCM_STATUS_AUTH_PER_ID in NUMBER,
  X_ADM_OUTCOME_STATUS_AUTH_DT in DATE,
  X_ADM_OUTCOME_STATUS_REASON in VARCHAR2,
  X_OFFER_DT in DATE,
  X_OFFER_RESPONSE_DT in DATE,
  X_PRPSD_COMMENCEMENT_DT in DATE,
  X_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_CNDTNL_OFFER_SATISFIED_DT in DATE,
  X_CNDTNL_OFR_MUST_BE_STSFD_IND in VARCHAR2,
  X_ADM_OFFER_RESP_STATUS in VARCHAR2,
  X_ACTUAL_RESPONSE_DT in DATE,
  X_ADM_OFFER_DFRMNT_STATUS in VARCHAR2,
  X_DEFERRED_ADM_CAL_TYPE in VARCHAR2,
  X_DEFERRED_ADM_CI_SEQUENCE_NUM in NUMBER,
  X_DEFERRED_TRACKING_ID in NUMBER,
  X_ASS_RANK in NUMBER,
  X_SECONDARY_ASS_RANK in NUMBER,
  X_INTRNTNL_ACCEPT_ADVICE_NUM in NUMBER,
  X_ASS_TRACKING_ID in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_EXPECTED_COMPLETION_YR in NUMBER,
  X_EXPECTED_COMPLETION_PERD in VARCHAR2,
  X_CORRESPONDENCE_CAT in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_MODE in VARCHAR2,									--arvsrini igsm
  X_APPL_INST_STATUS IN VARCHAR2,
  X_DECISION_DATE                            DATE     DEFAULT NULL,	-- begin APADEGAL adtd001 igs.m
  X_DECISION_MAKE_ID                         NUMBER   DEFAULT NULL,
  X_DECISION_REASON_ID                       NUMBER   DEFAULT NULL,
  X_PENDING_REASON_ID                        NUMBER   DEFAULT NULL,
  X_WAITLIST_STATUS                          VARCHAR2 DEFAULT NULL,
  X_WAITLIST_RANK                            VARCHAR2 DEFAULT NULL,
  X_FUTURE_ACAD_CAL_TYPE                     VARCHAR2 DEFAULT NULL,
  X_FUTURE_ACAD_CI_SEQUENCE_NUM              NUMBER   DEFAULT NULL,
  X_FUTURE_ADM_CAL_TYPE                      VARCHAR2 DEFAULT NULL,
  X_FUTURE_ADM_CI_SEQUENCE_NUM               NUMBER   DEFAULT NULL,
  X_DEF_ACAD_CAL_TYPE                        VARCHAR2 DEFAULT NULL,
  X_DEF_ACAD_CI_SEQUENCE_NUM                 NUMBER   DEFAULT NULL,
  X_RECONSIDER_FLAG                          VARCHAR2 DEFAULT NULL,
  X_DECLINE_OFR_REASON                       VARCHAR2 DEFAULT NULL    -- end APADEGAL adtd001 igs.m
  ) as
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
  p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_course_cd => X_COURSE_CD,
  x_crv_version_number => X_CRV_VERSION_NUMBER,
  x_location_cd =>  X_LOCATION_CD,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_unit_set_cd=>X_UNIT_SET_CD,
  x_us_version_number =>X_US_VERSION_NUMBER,
  x_preference_number =>X_PREFERENCE_NUMBER,
  x_adm_doc_status =>X_ADM_DOC_STATUS,
  x_adm_entry_qual_status =>X_ADM_ENTRY_QUAL_STATUS,
  x_late_adm_fee_status =>X_LATE_ADM_FEE_STATUS,
  x_adm_outcome_status =>X_ADM_OUTCOME_STATUS,
  x_adm_otcm_status_auth_per_id =>X_ADM_OTCM_STATUS_AUTH_PER_ID,
  x_adm_outcome_status_auth_dt =>X_ADM_OUTCOME_STATUS_AUTH_DT,
  x_adm_outcome_status_reason =>X_ADM_OUTCOME_STATUS_REASON,
  x_offer_dt =>X_OFFER_DT,
  x_offer_response_dt =>X_OFFER_RESPONSE_DT,
  x_prpsd_commencement_dt =>X_PRPSD_COMMENCEMENT_DT,
  x_adm_cndtnl_offer_status =>X_ADM_CNDTNL_OFFER_STATUS,
  x_cndtnl_offer_satisfied_dt =>X_CNDTNL_OFFER_SATISFIED_DT,
  x_cndtnl_ofr_must_be_stsfd_ind => X_CNDTNL_OFR_MUST_BE_STSFD_IND,
  x_adm_offer_resp_status => X_ADM_OFFER_RESP_STATUS,
  x_actual_response_dt => X_ACTUAL_RESPONSE_DT,
  x_adm_offer_dfrmnt_status =>X_ADM_OFFER_DFRMNT_STATUS,
  x_deferred_adm_cal_type =>X_DEFERRED_ADM_CAL_TYPE,
  x_deferred_adm_ci_sequence_num =>X_DEFERRED_ADM_CI_SEQUENCE_NUM,
  x_deferred_tracking_id =>X_DEFERRED_TRACKING_ID,
  x_ass_rank =>X_ASS_RANK,
  x_secondary_ass_rank =>X_SECONDARY_ASS_RANK,
  x_intrntnl_accept_advice_num =>X_INTRNTNL_ACCEPT_ADVICE_NUM,
  x_ass_tracking_id =>X_ASS_TRACKING_ID,
  x_fee_cat =>X_FEE_CAT,
  x_hecs_payment_option =>X_HECS_PAYMENT_OPTION,
  x_expected_completion_yr =>X_EXPECTED_COMPLETION_YR,
  x_expected_completion_perd =>X_EXPECTED_COMPLETION_PERD,
  x_correspondence_cat =>X_CORRESPONDENCE_CAT,
  x_enrolment_cat =>X_ENROLMENT_CAT,
  x_funding_source =>X_FUNDING_SOURCE,
  x_cndtnl_offer_cndtn =>X_CNDTNL_OFFER_CNDTN,
  x_applicant_acptnce_cndtn =>X_APPLICANT_ACPTNCE_CNDTN,
  x_person_id =>X_PERSON_ID,
  x_admission_appl_number =>X_ADMISSION_APPL_NUMBER,
  x_nominated_course_cd =>X_NOMINATED_COURSE_CD,
  x_sequence_number =>X_SEQUENCE_NUMBER,
  x_hist_start_dt =>X_HIST_START_DT,
  x_hist_end_dt =>X_HIST_END_DT,
  x_hist_who =>X_HIST_WHO,
  x_hist_offer_round_number=>X_HIST_OFFER_ROUND_NUMBER,
  x_adm_cal_type =>X_ADM_CAL_TYPE,
  x_adm_ci_sequence_number =>X_ADM_CI_SEQUENCE_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_appl_inst_status => X_APPL_INST_STATUS,					--arvsrini igsm
  x_decision_date                 =>	x_decision_date                ,    	        -- begin apadegal td001 igsm
  x_decision_make_id              =>	x_decision_make_id             ,
  x_decision_reason_id            =>	x_decision_reason_id           ,
  x_pending_reason_id             =>	x_pending_reason_id            ,
  x_waitlist_status               =>	x_waitlist_status              ,
  x_waitlist_rank                 =>	x_waitlist_rank                ,
  x_future_acad_cal_type          =>	x_future_acad_cal_type         ,
  x_future_acad_ci_sequence_num   =>	x_future_acad_ci_sequence_num  ,
  x_future_adm_cal_type           =>	x_future_adm_cal_type          ,
  x_future_adm_ci_sequence_num    =>	x_future_adm_ci_sequence_num   ,
  x_def_acad_cal_type             =>	x_def_acad_cal_type            ,
  x_def_acad_ci_sequence_num      =>	x_def_acad_ci_sequence_num     ,
  x_reconsider_flag               =>	x_reconsider_flag              ,
  x_decline_ofr_reason            => 	x_decline_ofr_reason              		-- end apadegal td001 igsm
  );

  update IGS_AD_PS_APLINSTHST_ALL set
    APPLICANT_ACPTNCE_CNDTN = NEW_REFERENCES.APPLICANT_ACPTNCE_CNDTN,
    CNDTNL_OFFER_CNDTN = NEW_REFERENCES.CNDTNL_OFFER_CNDTN,
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    HIST_OFFER_ROUND_NUMBER = NEW_REFERENCES.HIST_OFFER_ROUND_NUMBER,
    ADM_CAL_TYPE = NEW_REFERENCES.ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER = NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    CRV_VERSION_NUMBER = NEW_REFERENCES.CRV_VERSION_NUMBER,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    UNIT_SET_CD = NEW_REFERENCES.UNIT_SET_CD,
    US_VERSION_NUMBER = NEW_REFERENCES.US_VERSION_NUMBER,
    PREFERENCE_NUMBER = NEW_REFERENCES.PREFERENCE_NUMBER,
    ADM_DOC_STATUS = NEW_REFERENCES.ADM_DOC_STATUS,
    ADM_ENTRY_QUAL_STATUS = NEW_REFERENCES.ADM_ENTRY_QUAL_STATUS,
    LATE_ADM_FEE_STATUS = NEW_REFERENCES.LATE_ADM_FEE_STATUS,
    ADM_OUTCOME_STATUS = NEW_REFERENCES.ADM_OUTCOME_STATUS,
    ADM_OTCM_STATUS_AUTH_PERSON_ID = NEW_REFERENCES.ADM_OTCM_STATUS_AUTH_PERSON_ID,
    ADM_OUTCOME_STATUS_AUTH_DT = NEW_REFERENCES.ADM_OUTCOME_STATUS_AUTH_DT,
    ADM_OUTCOME_STATUS_REASON = NEW_REFERENCES.ADM_OUTCOME_STATUS_REASON,
    OFFER_DT = NEW_REFERENCES.OFFER_DT,
    OFFER_RESPONSE_DT = NEW_REFERENCES.OFFER_RESPONSE_DT,
    PRPSD_COMMENCEMENT_DT = NEW_REFERENCES.PRPSD_COMMENCEMENT_DT,
    ADM_CNDTNL_OFFER_STATUS = NEW_REFERENCES.ADM_CNDTNL_OFFER_STATUS,
    CNDTNL_OFFER_SATISFIED_DT = NEW_REFERENCES.CNDTNL_OFFER_SATISFIED_DT,
    CNDTNL_OFFER_MUST_BE_STSFD_IND = NEW_REFERENCES.CNDTNL_OFFER_MUST_BE_STSFD_IND,
    ADM_OFFER_RESP_STATUS = NEW_REFERENCES.ADM_OFFER_RESP_STATUS,
    ACTUAL_RESPONSE_DT = NEW_REFERENCES.ACTUAL_RESPONSE_DT,
    ADM_OFFER_DFRMNT_STATUS = NEW_REFERENCES.ADM_OFFER_DFRMNT_STATUS,
    DEFERRED_ADM_CAL_TYPE = NEW_REFERENCES.DEFERRED_ADM_CAL_TYPE,
    DEFERRED_ADM_CI_SEQUENCE_NUM = NEW_REFERENCES.DEFERRED_ADM_CI_SEQUENCE_NUM,
    DEFERRED_TRACKING_ID = NEW_REFERENCES.DEFERRED_TRACKING_ID,
    ASS_RANK = NEW_REFERENCES.ASS_RANK,
    SECONDARY_ASS_RANK = NEW_REFERENCES.SECONDARY_ASS_RANK,
    INTRNTNL_ACCEPTANCE_ADVICE_NUM = NEW_REFERENCES.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
    ASS_TRACKING_ID = NEW_REFERENCES.ASS_TRACKING_ID,
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
    HECS_PAYMENT_OPTION = NEW_REFERENCES.HECS_PAYMENT_OPTION,
    EXPECTED_COMPLETION_YR = NEW_REFERENCES.EXPECTED_COMPLETION_YR,
    EXPECTED_COMPLETION_PERD = NEW_REFERENCES.EXPECTED_COMPLETION_PERD,
    CORRESPONDENCE_CAT = NEW_REFERENCES.CORRESPONDENCE_CAT,
    ENROLMENT_CAT = NEW_REFERENCES.ENROLMENT_CAT,
    FUNDING_SOURCE = NEW_REFERENCES.FUNDING_SOURCE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    APPL_INST_STATUS =X_APPL_INST_STATUS,				--arvsrini igsm
    decision_date                 = new_references.decision_date                ,    	        -- begin apadegal td001 igsm
    decision_make_id              = new_references.decision_make_id             ,
    decision_reason_id            = new_references.decision_reason_id           ,
    pending_reason_id             = new_references.pending_reason_id            ,
    waitlist_status               = new_references.waitlist_status              ,
    waitlist_rank                 = new_references.waitlist_rank                ,
    future_acad_cal_type          = new_references.future_acad_cal_type         ,
    future_acad_ci_sequence_num   = new_references.future_acad_ci_sequence_num  ,
    future_adm_cal_type           = new_references.future_adm_cal_type          ,
    future_adm_ci_sequence_num    = new_references.future_adm_ci_sequence_num   ,
    def_acad_cal_type             = new_references.def_acad_cal_type            ,
    def_acad_ci_sequence_num      = new_references.def_acad_ci_sequence_num     ,
    reconsider_flag               = new_references.reconsider_flag              ,
    decline_ofr_reason            = new_references.decline_ofr_reason              		-- end apadegal td001 igsm
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_APPLICANT_ACPTNCE_CNDTN in VARCHAR2,
  X_CNDTNL_OFFER_CNDTN in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_HIST_OFFER_ROUND_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_PREFERENCE_NUMBER in NUMBER,
  X_ADM_DOC_STATUS in VARCHAR2,
  X_ADM_ENTRY_QUAL_STATUS in VARCHAR2,
  X_LATE_ADM_FEE_STATUS in VARCHAR2,
  X_ADM_OUTCOME_STATUS in VARCHAR2,
  X_ADM_OTCM_STATUS_AUTH_PER_ID in NUMBER,
  X_ADM_OUTCOME_STATUS_AUTH_DT in DATE,
  X_ADM_OUTCOME_STATUS_REASON in VARCHAR2,
  X_OFFER_DT in DATE,
  X_OFFER_RESPONSE_DT in DATE,
  X_PRPSD_COMMENCEMENT_DT in DATE,
  X_ADM_CNDTNL_OFFER_STATUS in VARCHAR2,
  X_CNDTNL_OFFER_SATISFIED_DT in DATE,
  X_CNDTNL_OFR_MUST_BE_STSFD_IND in VARCHAR2,
  X_ADM_OFFER_RESP_STATUS in VARCHAR2,
  X_ACTUAL_RESPONSE_DT in DATE,
  X_ADM_OFFER_DFRMNT_STATUS in VARCHAR2,
  X_DEFERRED_ADM_CAL_TYPE in VARCHAR2,
  X_DEFERRED_ADM_CI_SEQUENCE_NUM in NUMBER,
  X_DEFERRED_TRACKING_ID in NUMBER,
  X_ASS_RANK in NUMBER,
  X_SECONDARY_ASS_RANK in NUMBER,
  X_INTRNTNL_ACCEPT_ADVICE_NUM in NUMBER,
  X_ASS_TRACKING_ID in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_EXPECTED_COMPLETION_YR in NUMBER,
  X_EXPECTED_COMPLETION_PERD in VARCHAR2,
  X_CORRESPONDENCE_CAT in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_MODE in VARCHAR2,
  X_APPL_INST_STATUS IN VARCHAR2,					--arvsrini igsm
  X_DECISION_DATE                            DATE     DEFAULT NULL,	-- begin APADEGAL adtd001 igs.m
  X_DECISION_MAKE_ID                         NUMBER   DEFAULT NULL,
  X_DECISION_REASON_ID                       NUMBER   DEFAULT NULL,
  X_PENDING_REASON_ID                        NUMBER   DEFAULT NULL,
  X_WAITLIST_STATUS                          VARCHAR2 DEFAULT NULL,
  X_WAITLIST_RANK                            VARCHAR2 DEFAULT NULL,
  X_FUTURE_ACAD_CAL_TYPE                     VARCHAR2 DEFAULT NULL,
  X_FUTURE_ACAD_CI_SEQUENCE_NUM              NUMBER   DEFAULT NULL,
  X_FUTURE_ADM_CAL_TYPE                      VARCHAR2 DEFAULT NULL,
  X_FUTURE_ADM_CI_SEQUENCE_NUM               NUMBER   DEFAULT NULL,
  X_DEF_ACAD_CAL_TYPE                        VARCHAR2 DEFAULT NULL,
  X_DEF_ACAD_CI_SEQUENCE_NUM                 NUMBER   DEFAULT NULL,
  X_RECONSIDER_FLAG                          VARCHAR2 DEFAULT NULL,
  X_DECLINE_OFR_REASON                       VARCHAR2 DEFAULT NULL    -- end APADEGAL adtd001 igs.m
  ) as
  cursor c1 is select rowid from IGS_AD_PS_APLINSTHST_ALL
     where PERSON_ID = X_PERSON_ID
     and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
     and NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD
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
     X_ORG_ID,
     X_PERSON_ID,
     X_ADMISSION_APPL_NUMBER,
     X_NOMINATED_COURSE_CD,
     X_SEQUENCE_NUMBER,
     X_HIST_START_DT,
     X_APPLICANT_ACPTNCE_CNDTN,
     X_CNDTNL_OFFER_CNDTN,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_HIST_OFFER_ROUND_NUMBER,
     X_ADM_CAL_TYPE,
     X_ADM_CI_SEQUENCE_NUMBER,
     X_COURSE_CD,
     X_CRV_VERSION_NUMBER,
     X_LOCATION_CD,
     X_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_UNIT_SET_CD,
     X_US_VERSION_NUMBER,
     X_PREFERENCE_NUMBER,
     X_ADM_DOC_STATUS,
     X_ADM_ENTRY_QUAL_STATUS,
     X_LATE_ADM_FEE_STATUS,
     X_ADM_OUTCOME_STATUS,
     X_ADM_OTCM_STATUS_AUTH_PER_ID,
     X_ADM_OUTCOME_STATUS_AUTH_DT,
     X_ADM_OUTCOME_STATUS_REASON,
     X_OFFER_DT,
     X_OFFER_RESPONSE_DT,
     X_PRPSD_COMMENCEMENT_DT,
     X_ADM_CNDTNL_OFFER_STATUS,
     X_CNDTNL_OFFER_SATISFIED_DT,
     X_CNDTNL_OFR_MUST_BE_STSFD_IND,
     X_ADM_OFFER_RESP_STATUS,
     X_ACTUAL_RESPONSE_DT,
     X_ADM_OFFER_DFRMNT_STATUS,
     X_DEFERRED_ADM_CAL_TYPE,
     X_DEFERRED_ADM_CI_SEQUENCE_NUM,
     X_DEFERRED_TRACKING_ID,
     X_ASS_RANK,
     X_SECONDARY_ASS_RANK,
     X_INTRNTNL_ACCEPT_ADVICE_NUM,
     X_ASS_TRACKING_ID,
     X_FEE_CAT,
     X_HECS_PAYMENT_OPTION,
     X_EXPECTED_COMPLETION_YR,
     X_EXPECTED_COMPLETION_PERD,
     X_CORRESPONDENCE_CAT,
     X_ENROLMENT_CAT,
     X_FUNDING_SOURCE,
     X_MODE,
     X_APPL_INST_STATUS, 				--arvsrini igsm
     X_DECISION_DATE                ,	-- begin APADEGAL adtd001 igs.m
     X_DECISION_MAKE_ID             ,
     X_DECISION_REASON_ID           ,
     X_PENDING_REASON_ID            ,
     X_WAITLIST_STATUS              ,
     X_WAITLIST_RANK                ,
     X_FUTURE_ACAD_CAL_TYPE         ,
     X_FUTURE_ACAD_CI_SEQUENCE_NUM  ,
     X_FUTURE_ADM_CAL_TYPE          ,
     X_FUTURE_ADM_CI_SEQUENCE_NUM   ,
     X_DEF_ACAD_CAL_TYPE            ,
     X_DEF_ACAD_CI_SEQUENCE_NUM     ,
     X_RECONSIDER_FLAG              ,
     X_DECLINE_OFR_REASON               -- end APADEGAL adtd001 igs.m
   );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ADMISSION_APPL_NUMBER,
   X_NOMINATED_COURSE_CD,
   X_SEQUENCE_NUMBER,
   X_HIST_START_DT,
   X_APPLICANT_ACPTNCE_CNDTN,
   X_CNDTNL_OFFER_CNDTN,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_HIST_OFFER_ROUND_NUMBER,
   X_ADM_CAL_TYPE,
   X_ADM_CI_SEQUENCE_NUMBER,
   X_COURSE_CD,
   X_CRV_VERSION_NUMBER,
   X_LOCATION_CD,
   X_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_UNIT_SET_CD,
   X_US_VERSION_NUMBER,
   X_PREFERENCE_NUMBER,
   X_ADM_DOC_STATUS,
   X_ADM_ENTRY_QUAL_STATUS,
   X_LATE_ADM_FEE_STATUS,
   X_ADM_OUTCOME_STATUS,
   X_ADM_OTCM_STATUS_AUTH_PER_ID,
   X_ADM_OUTCOME_STATUS_AUTH_DT,
   X_ADM_OUTCOME_STATUS_REASON,
   X_OFFER_DT,
   X_OFFER_RESPONSE_DT,
   X_PRPSD_COMMENCEMENT_DT,
   X_ADM_CNDTNL_OFFER_STATUS,
   X_CNDTNL_OFFER_SATISFIED_DT,
   X_CNDTNL_OFR_MUST_BE_STSFD_IND,
   X_ADM_OFFER_RESP_STATUS,
   X_ACTUAL_RESPONSE_DT,
   X_ADM_OFFER_DFRMNT_STATUS,
   X_DEFERRED_ADM_CAL_TYPE,
   X_DEFERRED_ADM_CI_SEQUENCE_NUM,
   X_DEFERRED_TRACKING_ID,
   X_ASS_RANK,
   X_SECONDARY_ASS_RANK,
   X_INTRNTNL_ACCEPT_ADVICE_NUM,
   X_ASS_TRACKING_ID,
   X_FEE_CAT,
   X_HECS_PAYMENT_OPTION,
   X_EXPECTED_COMPLETION_YR,
   X_EXPECTED_COMPLETION_PERD,
   X_CORRESPONDENCE_CAT,
   X_ENROLMENT_CAT,
   X_FUNDING_SOURCE,
   X_MODE,
   X_APPL_INST_STATUS,
   X_DECISION_DATE                ,	-- begin APADEGAL adtd001 igs.m
   X_DECISION_MAKE_ID             ,
   X_DECISION_REASON_ID           ,
   X_PENDING_REASON_ID            ,
   X_WAITLIST_STATUS              ,
   X_WAITLIST_RANK                ,
   X_FUTURE_ACAD_CAL_TYPE         ,
   X_FUTURE_ACAD_CI_SEQUENCE_NUM  ,
   X_FUTURE_ADM_CAL_TYPE          ,
   X_FUTURE_ADM_CI_SEQUENCE_NUM   ,
   X_DEF_ACAD_CAL_TYPE            ,
   X_DEF_ACAD_CI_SEQUENCE_NUM     ,
   X_RECONSIDER_FLAG              ,
   X_DECLINE_OFR_REASON               -- end APADEGAL adtd001 igs.m
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

Before_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_AD_PS_APLINSTHST_ALL
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

end IGS_AD_PS_APLINSTHST_PKG;

/
