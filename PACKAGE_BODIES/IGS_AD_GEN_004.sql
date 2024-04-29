--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_004" AS
/* $Header: IGSAD04B.pls 115.21 2003/12/05 11:11:53 rboddu ship $ */

/*
who       when         what
sarakshi  06-May-2003  Enh#2858431,modified admp_get_cricos_cd replaced system reference code of CRICOS to OTHER
*/
PROCEDURE Admp_Get_Apcs_Val(
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_apcs_pref_limit_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_app_fee_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_late_app_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_late_fee_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_chkpencumb_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_fee_assess_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_corcategry_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_enrcategry_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_chkcencumb_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_unit_set_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_un_crs_us_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_chkuencumb_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_unit_restr_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_unit_restriction_num OUT NOCOPY NUMBER ,
  p_apcs_un_dob_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_un_title_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_asses_cond_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_fee_cond_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_doc_cond_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_multi_off_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_multi_off_restrict_num OUT NOCOPY NUMBER ,
  p_apcs_set_otcome_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_override_o_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_defer_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_ack_app_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_outcome_lt_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_pre_enrol_ind OUT NOCOPY VARCHAR2 )
IS
 ----------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  --Purpose: BUG NO :
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------

BEGIN   -- admp_get_apcs_val
        -- Return the steps for an admission process category validation.
DECLARE
        -- Retrieve the admission process category steps.
        CURSOR c_apcs IS
                SELECT  s_admission_step_type,
                        step_type_restriction_num
                FROM    IGS_AD_PRCS_CAT_STEP
                WHERE   admission_cat            = p_admission_cat AND
                        s_admission_process_type = p_s_admission_process_type AND
                        step_group_type <> 'TRACK'; --2402377
BEGIN
        p_apcs_pref_limit_ind   :='N';
        p_apcs_app_fee_ind      :='N';
        p_apcs_late_app_ind     :='N';
        p_apcs_late_fee_ind     :='N';
        p_apcs_chkpencumb_ind   :='N';
        p_apcs_fee_assess_ind   :='N';
        p_apcs_corcategry_ind   :='N';
        p_apcs_enrcategry_ind   :='N';
        p_apcs_chkcencumb_ind   :='N';
        p_apcs_unit_set_ind     :='N';
        p_apcs_un_crs_us_ind    :='N';
        p_apcs_chkuencumb_ind   :='N';
        p_apcs_unit_restr_ind   :='N';
        p_apcs_unit_restriction_num := 0;
        p_apcs_asses_cond_ind   :='N';
        p_apcs_fee_cond_ind     :='N';
        p_apcs_doc_cond_ind     :='N';
        p_apcs_multi_off_ind    := 'N';
        p_apcs_multi_off_restrict_num := 0;
        p_apcs_set_otcome_ind   :='N';
        p_apcs_override_o_ind   :='N';
        p_apcs_defer_ind        :='N';
        p_apcs_ack_app_ind      :='N';
        p_apcs_outcome_lt_ind   :='N';
        p_apcs_pre_enrol_ind   :='N';
        p_apcs_un_dob_ind       :='N';
        p_apcs_un_title_ind     :='N';
        --Loop through each IGS_AD_PRCS_CAT_STEP record
        FOR v_apcs_rec IN c_apcs LOOP
                IF (v_apcs_rec.s_admission_step_type = 'PREF-LIMIT') THEN
                        p_apcs_pref_limit_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'APP-FEE') THEN
                        p_apcs_app_fee_ind :='Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'LATE-APP') THEN
                        p_apcs_late_app_ind :='Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'LATE-FEE') THEN
                        p_apcs_late_fee_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'CHKPENCUMB') THEN
                        p_apcs_chkpencumb_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'FEE-ASSESS') THEN
                        p_apcs_fee_assess_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'CORCATEGRY') THEN
                        p_apcs_corcategry_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'ENRCATEGRY') THEN
                        p_apcs_enrcategry_ind :='Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'CHKCENCUMB') THEN
                        p_apcs_chkcencumb_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'UNIT-SET') THEN
                        p_apcs_unit_set_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'UN-CRS-US') THEN
                        p_apcs_un_crs_us_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'CHKUENCUMB') THEN
                        p_apcs_chkuencumb_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'UNIT-RESTR') THEN
                        p_apcs_unit_restr_ind := 'Y';
                        p_apcs_unit_restriction_num := v_apcs_rec.step_type_restriction_num;
                ELSIF (v_apcs_rec.s_admission_step_type = 'ASSES-COND') THEN
                        p_apcs_asses_cond_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'FEE-COND') THEN
                        p_apcs_fee_cond_ind :='Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'DOC-COND') THEN
                        p_apcs_doc_cond_ind :='Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'MULTI-OFF') THEN
                        p_apcs_multi_off_ind := 'Y';
                        p_apcs_multi_off_restrict_num := v_apcs_rec.step_type_restriction_num;
                ELSIF (v_apcs_rec.s_admission_step_type = 'SET-OTCOME') THEN
                        p_apcs_set_otcome_ind :='Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'OVERRIDE-O') THEN
                        p_apcs_override_o_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'DEFER') THEN
                        p_apcs_defer_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'ACK-APP') THEN
                        p_apcs_ack_app_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'OUTCOME-LT') THEN
                        p_apcs_outcome_lt_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'PRE-ENROL') THEN
                        p_apcs_pre_enrol_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'UN-DOB') THEN
                        p_apcs_un_dob_ind := 'Y';
                ELSIF (v_apcs_rec.s_admission_step_type = 'UN-TITLE') THEN
                        p_apcs_un_title_ind :='Y';
                END IF;
        END LOOP;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_004.admp_get_apcs_val');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_get_apcs_val;

FUNCTION Admp_Get_Archive_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2 IS
BEGIN   -- admp_get_archive_ind
        -- Determine whether or not a person is archived
DECLARE
        CURSOR c_pe(
                        cp_person_id    IGS_PE_PERSON.person_id%TYPE) IS
                SELECT  pd.archive_dt
                FROM    igs_pe_hz_parties pd
                WHERE   pd.party_id = cp_person_id ;

        cst_yes                 CONSTANT CHAR := 'Y';
        cst_no                  CONSTANT CHAR := 'N';
        v_pe_rec                c_pe%ROWTYPE;
BEGIN
        OPEN c_pe(
                        p_person_id);
        FETCH c_pe INTO v_pe_rec;
        IF c_pe%NOTFOUND THEN
                CLOSE c_pe;
                RETURN cst_no;
        END IF;
        CLOSE c_pe;
        IF v_pe_rec.archive_dt IS NOT NULL THEN
                RETURN cst_yes;
        END IF;
        RETURN cst_no;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_004.admp_get_archive_ind');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_get_archive_ind;

FUNCTION Admp_Get_Chg_Pref_Dt(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN VARCHAR2 IS
BEGIN   -- admp_get_chg_pref_dt
        -- This module retrieves the date instance for change of preferences.
DECLARE
        v_out_date              DATE;
        v_dt_alias              IGS_AD_CAL_CONF.adm_appl_chng_of_pref_dt_alias%TYPE;
        CURSOR c_sacc_dt_alias IS
                SELECT  sacc.adm_appl_chng_of_pref_dt_alias
                FROM    IGS_AD_CAL_CONF sacc
                WHERE   sacc.s_control_num = 1;
        CURSOR c_aa_acaiv IS
                SELECT  acaiv.adm_cal_type,
                        acaiv.adm_ci_sequence_number,
                        aa.admission_cat,
                        aa.s_admission_process_type,
                        acaiv.course_cd,
                        acaiv.crv_version_number,
                        aa.acad_cal_type,
                        acaiv.location_cd,
                        acaiv.attendance_mode,
                        acaiv.attendance_type
                FROM    igs_ad_ps_appl_inst   acaiv,  -- Replaced IGS_AD_PS_APPL_INST_APLINST_V with IGS_AD_PS_APPL Bug: 3150054
                        igs_ad_appl             aa
                WHERE   acaiv.admission_appl_number     = aa.admission_appl_number      AND
                        acaiv.person_id                 = aa.person_id                  AND
                        acaiv.person_id                 = p_person_id                   AND
                        acaiv.admission_appl_number     = p_admission_appl_number       AND
                        acaiv.nominated_course_cd       = p_nominated_course_cd         AND
                        acaiv.sequence_number           = p_acai_sequence_number;
                v_aa_acaiv_rec          c_aa_acaiv%ROWTYPE;
BEGIN
        OPEN c_sacc_dt_alias;
        FETCH c_sacc_dt_alias INTO v_dt_alias;
        CLOSE c_sacc_dt_alias;
        OPEN c_aa_acaiv;
        FETCH c_aa_acaiv INTO v_aa_acaiv_rec;
        CLOSE c_aa_acaiv;
        v_out_date := IGS_AD_GEN_003.admp_get_adm_perd_dt(
                                        v_dt_alias,
                                        v_aa_acaiv_rec.adm_cal_type,
                                        v_aa_acaiv_rec.adm_ci_sequence_number,
                                        v_aa_acaiv_rec.admission_cat,
                                        v_aa_acaiv_rec.s_admission_process_type,
                                        v_aa_acaiv_rec.course_cd,
                                        v_aa_acaiv_rec.crv_version_number,
                                        v_aa_acaiv_rec.acad_cal_type,
                                        v_aa_acaiv_rec.location_cd,
                                        v_aa_acaiv_rec.attendance_mode,
                                        v_aa_acaiv_rec.attendance_type);
        IF v_out_date IS NOT NULL THEN
                RETURN IGS_GE_DATE.IGSCHAR(v_out_date); -- IGS_GE_DATE.IGSCHAR(v_out_date, 'DD/MM/YYYY');
        ELSE
                RETURN NULL;
        END IF;
EXCEPTION
        WHEN OTHERS THEN
                IF c_sacc_dt_alias%ISOPEN THEN
                        CLOSE c_sacc_dt_alias;
                END IF;
                IF c_aa_acaiv%ISOPEN THEN
                        CLOSE c_aa_acaiv;
                END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_004.admp_get_chg_pref_dt');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_get_chg_pref_dt;

FUNCTION Admp_Get_Comm_Perd(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN VARCHAR2 IS
BEGIN   -- admp_get_comm_perd
        -- This module retrieves the commencement period
DECLARE
        v_commencement_period           IGS_AD_PS_APPL_INST_APLSUMR_V.commencement_period%TYPE;
        CURSOR c_aasv IS  --modified the cursor to use base tables instead of IGS_AD_PS_APPL_INST_APLSUMR_V. Bug: 3150054
              SELECT SUBSTR(IGS_AD_GEN_002.admp_get_acai_acadcd(
                       aav.person_id,
                       aav.admission_appl_number,
		       aav.acad_cal_type,
                       NVL(acai.adm_cal_type, aav.adm_cal_type),
                       NVL(acai.adm_ci_sequence_number, aav.adm_ci_sequence_number)),1,10) || '/' || ci.alternate_code commencement_period
              FROM igs_ad_ps_appl_inst acai,
		     igs_ad_appl aav,
		     igs_ca_inst ci
              WHERE aav.person_id = acai.person_id AND
                     aav.admission_appl_number = acai.admission_appl_number AND
                     ci.cal_type = NVL(acai.adm_cal_type, aav.adm_cal_type) AND
                     ci.sequence_number = NVL(acai.adm_ci_sequence_number,aav.adm_ci_sequence_number) AND
                     acai.person_id                = p_person_id AND
                     acai.admission_appl_number    = p_admission_appl_number AND
                     acai.nominated_course_cd      = p_nominated_course_cd AND
                     acai.sequence_number          = p_acai_sequence_number;
BEGIN
        OPEN c_aasv;
        FETCH c_aasv INTO v_commencement_period;
        IF (c_aasv%NOTFOUND) THEN
                CLOSE c_aasv;
                RETURN NULL;
        END IF;
        CLOSE c_aasv;
        RETURN v_commencement_period;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_aasv%ISOPEN) THEN
                        CLOSE c_aasv;
                END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_004.admp_get_comm_perd');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_get_comm_perd;

FUNCTION Admp_Get_Course_Det(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_record_number IN NUMBER ,
  p_extra_context OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN   -- admp_get_course_det
        -- This module retrieves course details from IGS_AD_PS_APPL_INST
        -- for use on letters.
DECLARE
        v_out_string            VARCHAR2(106)   DEFAULT NULL;
        v_alt_acad_cal          IGS_CA_INST.alternate_code%TYPE;
        CURSOR c_cv_acaiv IS
                SELECT  acaiv.preference_number,
                        acaiv.course_cd,
                        cv.short_title,
                        cv.title,
                        acaiv.location_cd,
                        acaiv.attendance_mode,
                        acaiv.attendance_type,
                        aav.acad_cal_type,
                        aav.acad_ci_sequence_number,
                        acaiv.sequence_number,
                        ci1.alternate_code || '/' || ci2.alternate_code commencement_period
                FROM    igs_ad_ps_appl_inst   acaiv, -- Replaced IGS_AD_APPL_ADMAPPL_V with igs_ad_appl_inst Bug: 3150054
	                igs_ad_appl aav,
			igs_ca_inst ci1,
			igs_ca_inst ci2,
                        igs_ps_ver              cv
                WHERE   acaiv.crv_version_number = cv.version_number    AND
                        acaiv.course_cd         = cv.course_cd  AND
                        acaiv.person_id         = p_person_id   AND
                        acaiv.admission_appl_number     = p_admission_appl_number        AND
                        aav.person_id           = acaiv.person_id       AND
                        aav.admission_appl_number       = acaiv.admission_appl_number AND
			ci1.cal_type = aav.acad_cal_type AND
			ci1.sequence_number = aav.acad_ci_sequence_number AND
			ci2.cal_type = NVL(acaiv.adm_cal_type, aav.adm_cal_type) AND
			ci2.sequence_number = NVL(acaiv.adm_cal_type, aav.adm_ci_sequence_number)
                ORDER BY acaiv.preference_number,
                        acaiv.course_cd;
BEGIN
        -- Set default value
        p_extra_context := NULL;
        FOR v_cv_acaiv_rec IN c_cv_acaiv LOOP
                IF c_cv_acaiv%ROWCOUNT = p_record_number THEN
                        -- create output return string and create p_extra_context string
                        IF p_s_letter_parameter_type = 'ADM_COURSE' THEN
                                IF v_cv_acaiv_rec.preference_number IS NULL THEN
                                        v_out_string :=
                                                RPAD(NVL(v_cv_acaiv_rec.course_cd, '-'),10)             || '    ' ||
                                                RPAD(NVL(v_cv_acaiv_rec.short_title, '-'),40)           || '    ' ||
                                                RPAD(NVL(v_cv_acaiv_rec.location_cd, '-'),10)           || '    ' ||
                                                RPAD(NVL(v_cv_acaiv_rec.attendance_mode, '-'),2)        || '    ' ||
                                                RPAD(NVL(v_cv_acaiv_rec.attendance_type, '-'),2)        || '    ' ||
                                                NVL(v_cv_acaiv_rec.commencement_period, '-');
                                ELSE
                                        v_out_string :=
                                                RPAD(NVL(IGS_GE_NUMBER.TO_CANN(v_cv_acaiv_rec.preference_number),'-'),2)      || '    ' ||
                                                RPAD(NVL(v_cv_acaiv_rec.course_cd, '-'),10)             || '    ' ||
                                                RPAD(NVL(v_cv_acaiv_rec.short_title, '-'),40)           || '    ' ||
                                                RPAD(NVL(v_cv_acaiv_rec.location_cd, '-'),10)           || '    ' ||
                                                RPAD(NVL(v_cv_acaiv_rec.attendance_mode, '-'),2)        || '    ' ||
                                                RPAD(NVL(v_cv_acaiv_rec.attendance_type, '-'),2)        || '    ' ||
                                                NVL(v_cv_acaiv_rec.commencement_period, '-');
                                END IF;
                        ELSIF p_s_letter_parameter_type = 'ADM_CRS_CD' THEN
                                v_out_string := NVL(v_cv_acaiv_rec.course_cd, '-');
                        ELSE
                                v_out_string := INITCAP(NVL(v_cv_acaiv_rec.title, '-'));
                        END IF;
                        p_extra_context := v_cv_acaiv_rec.course_cd || '|' ||
                                         v_cv_acaiv_rec.sequence_number;
                END IF;
        END LOOP;
        RETURN v_out_string;
EXCEPTION
        WHEN OTHERS THEN
                IF c_cv_acaiv%ISOPEN THEN
                        CLOSE c_cv_acaiv;
                END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_004.admp_get_course_det');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_get_course_det;

FUNCTION Admp_Get_Cricos_Cd(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN VARCHAR2 IS
BEGIN
DECLARE
        v_course_cd                     IGS_AD_PS_APPL_INST.course_cd%TYPE;
        v_crv_version_number            IGS_AD_PS_APPL_INST.crv_version_number%TYPE;
        v_reference_cd                  IGS_PS_REF_CD.reference_cd%TYPE;
        CURSOR c_acai IS
                SELECT  acai.course_cd,
                        acai.crv_version_number
                FROM    IGS_AD_PS_APPL_INST     acai
                WHERE   acai.person_id                  = p_person_id AND
                        acai.admission_appl_number      = p_admission_appl_number AND
                        acai.nominated_course_cd        = p_nominated_course_cd AND
                        acai.sequence_number            = p_acai_sequence_number;
        CURSOR c_crc_rct (
                cp_course_cd            IGS_AD_PS_APPL_INST.course_cd%TYPE,
                cp_crv_version_number   IGS_AD_PS_APPL_INST.crv_version_number%TYPE) IS
                SELECT  crc.reference_cd
                FROM    IGS_PS_REF_CD   crc,
                        IGS_GE_REF_CD_TYPE      rct
                WHERE   rct.s_reference_cd_type = 'OTHER' AND
                        crc.reference_cd_type   = rct.reference_cd_type AND
                        crc.course_cd           = cp_course_cd AND
                        crc.version_number      = cp_crv_version_number;
BEGIN
        IF (p_person_id IS NULL OR
                        p_admission_appl_number IS NULL OR
                        p_nominated_course_cd IS NULL OR
                        p_acai_sequence_number IS NULL) THEN
                RETURN NULL;
        END IF;
        OPEN c_acai;
        FETCH c_acai INTO       v_course_cd,
                                v_crv_version_number;
        IF (c_acai%NOTFOUND) THEN
                CLOSE c_acai;
                RETURN NULL;
        ELSE
                CLOSE c_acai;
                OPEN c_crc_rct (
                                v_course_cd,
                                v_crv_version_number);
                FETCH c_crc_rct INTO v_reference_cd;
                CLOSE c_crc_rct;
                RETURN v_reference_cd;
        END IF;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_acai%ISOPEN) THEN
                        CLOSE c_acai;
                END IF;
                IF (c_crc_rct%ISOPEN) THEN
                        CLOSE c_crc_rct;
                END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_004.admp_get_cricos_cd');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_get_cricos_cd;

PROCEDURE Admp_Get_Crs_Exists(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_check_referee IN BOOLEAN ,
  p_check_scholarship IN BOOLEAN ,
  p_check_lang_prof IN BOOLEAN ,
  p_check_interview IN BOOLEAN ,
  p_check_exchange IN BOOLEAN ,
  p_check_adm_test IN BOOLEAN ,
  p_check_research IN BOOLEAN ,
  p_referee_exists OUT NOCOPY BOOLEAN ,
  p_scholarship_exists OUT NOCOPY BOOLEAN ,
  p_lang_prof_exists OUT NOCOPY BOOLEAN ,
  p_interview_exists OUT NOCOPY BOOLEAN ,
  p_exchange_exists OUT NOCOPY BOOLEAN ,
  p_adm_test_exists OUT NOCOPY BOOLEAN ,
  p_research_exists OUT NOCOPY BOOLEAN ,
  p_error_message_research OUT NOCOPY VARCHAR2)

IS
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
rrengara   2-APR-2002    Added parameter P_error_message_research in procedure for the bug 2285677
hreddych   6-jan-2003    Remove cursor check for ADM TEST and
                         return FALSE for it # 2737932
*****************************************************************************************************/

BEGIN   -- admp_get_crs_exists
        -- Return output parameters indicating whether or not data exists
        -- on course level detail tables for the specified person id.
DECLARE
        cst_readmit             CONSTANT        VARCHAR2(10) := 'RE-ADMIT';
        v_check                                 VARCHAR2(1);
        v_message_name                  VARCHAR2(30) default null;
        v_out_admission_appl_number             IGS_AD_PS_APPL.admission_appl_number%TYPE;
        v_out_nominated_course_cd               IGS_AD_PS_APPL.nominated_course_cd%TYPE;
        v_out_acai_sequence_number              IGS_AD_PS_APPL_INST.sequence_number%TYPE;
        v_admission_appl_number                 IGS_AD_PS_APPL.admission_appl_number%TYPE;
        v_nominated_course_cd                   IGS_AD_PS_APPL.nominated_course_cd%TYPE;
        v_acai_sequence_number                  IGS_AD_PS_APPL_INST.sequence_number%TYPE;
        v_parent                                VARCHAR2(5);
BEGIN   -- Initialise output parameters
        p_referee_exists := FALSE;
        p_scholarship_exists := FALSE;
        p_lang_prof_exists := FALSE;
        p_interview_exists := FALSE;
        p_exchange_exists := FALSE;
        p_adm_test_exists := FALSE;
        p_research_exists := FALSE;

        IF p_check_research = TRUE THEN
                IF p_s_admission_process_type = cst_readmit THEN
                        --Determine the admission course application instance.
                        IGS_RE_GEN_002.resp_get_sca_ca_acai (
                                        p_person_id,
                                        p_course_cd,
                                        p_admission_appl_number,
                                        p_nominated_course_cd,
                                        p_acai_sequence_number,
                                        v_out_admission_appl_number,
                                        v_out_nominated_course_cd,
                                        v_out_acai_sequence_number);
                        IF v_out_admission_appl_number IS NULL THEN
                                v_parent := 'SCA';
                        ELSE
                                v_parent := 'ACAI';
                        END IF;
                        v_admission_appl_number := v_out_admission_appl_number;
                        v_nominated_course_cd := v_out_nominated_course_cd;
                        v_acai_sequence_number := v_out_acai_sequence_number;
                ELSE
                        v_parent := 'ACAI';
                        v_admission_appl_number := p_admission_appl_number;
                        v_nominated_course_cd := p_nominated_course_cd;
                        v_acai_sequence_number := p_acai_sequence_number;
                END IF;
                -- Check for existence of research details.
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Changed the reference of "IGS_AD_VAL_ACAI.RESP_VAL_CA_DTL_COMP" to program unit "IGS_EN_VAL_SCA.RESP_VAL_CA_DTL_COMP". -- kdande
*/
                IF IGS_EN_VAL_SCA.resp_val_ca_dtl_comp (
                                                p_person_id,
                                                p_course_cd,
                                                v_admission_appl_number,
                                                v_nominated_course_cd,
                                                v_acai_sequence_number,
                                                v_parent,
                                                v_message_name) = TRUE THEN
                        p_research_exists := TRUE;
                -- Added else part for the bug 2285677 by rrengara on 2-APR-2002
                -- Previously the message was not propagating to the calling procedure
                -- if the api fails.
                ELSE
                  p_error_message_research := v_message_name;
                END IF;
        END IF;
EXCEPTION
        WHEN OTHERS THEN
                App_Exception.Raise_Exception;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_004.admp_get_crs_exists');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_get_crs_exists;

PROCEDURE Admp_Get_Crv_Comp_Dt(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_expected_completion_yr IN OUT NOCOPY NUMBER ,
  p_expected_completion_perd IN OUT NOCOPY VARCHAR2 ,
  p_completion_dt OUT NOCOPY DATE,
  p_attendance_mode IN VARCHAR2 ,
  p_location_cd IN VARCHAR2)
 ----------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  --Purpose: BUG NO :
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --rboddu      29-OCT-2002     Calculating the Program Completion details based on
  --                           the Program Length and Program Length Measurement present
  --                           in the Program Offering Option record. Removed the code
  --                           related to the Standard Full time or Standard Part time
  --                           Completion. Enh bug : 2647482
  ----------------------------------------------------------------
IS
BEGIN   --admp_get_crv_comp_dt
        --Routine to return the course version expected completion date.
        --This can be determined from a start date or expected completeion details
DECLARE
        v_cal_type                              IGS_PS_OFR.cal_type%TYPE;
        v_att_gat                               IGS_EN_ATD_TYPE.govt_attendance_type%TYPE;
        v_comp_perd_dt_alias                    IGS_AD_CAL_CONF.adm_appl_e_comp_perd_dt_alias%TYPE;
        v_completion_time                       IGS_PS_VER.std_ft_completion_time%TYPE;
        v_completion_months                     IGS_PS_VER.std_ft_completion_time%TYPE;
        v_completion_dt                         DATE;
        v_start_dt_yyyy                         VARCHAR2(4);
        v_completion_dt_yyyy                    VARCHAR2(4);
        v_context_completion_dt                 DATE;
        v_dai2_alias_val_dd_mon                 VARCHAR2(7);
        v_dai2_alias_val_yyyy                   VARCHAR2(4);
        v_dai2_alias_val                        IGS_CA_DA_INST_V.alias_val%TYPE;
        v_dai2_dt_alias                         IGS_CA_DA_INST_V.dt_alias%TYPE;
        v_dai                                   IGS_CA_DA_INST_V.alias_val%TYPE;
        v_adm_e_perd_dt_alias                   IGS_AD_CAL_CONF.adm_appl_e_comp_perd_dt_alias%TYPE;
        v_adm_m_perd_dt_alias                   IGS_AD_CAL_CONF.adm_appl_m_comp_perd_dt_alias%TYPE;
        v_adm_s_perd_dt_alias                   IGS_AD_CAL_CONF.adm_appl_s_comp_perd_dt_alias%TYPE;
        v_rec_cnt                               NUMBER;
        v_completion_days                       NUMBER;
        CURSOR c_co IS
                SELECT  co.cal_type
                FROM    IGS_PS_OFR co
                WHERE   co.course_cd      = p_course_cd AND
                        co.version_number = p_crv_version_number;
        CURSOR c_sacco IS
                SELECT  adm_appl_e_comp_perd_dt_alias,
                        adm_appl_m_comp_perd_dt_alias,
                        adm_appl_s_comp_perd_dt_alias
                FROM    IGS_AD_CAL_CONF sacco
                WHERE   s_control_num = 1;

        --Following cursor is modified as part of bug 2715535, to pick up alias values which are greater than
	--the Context Completion Date such that the Year part of it is greater than or equal to Expected Completion Year.
	CURSOR c_dai IS
                SELECT  dai.alias_val
                FROM    IGS_CA_DA_INST_V dai
                WHERE   dt_alias    = v_comp_perd_dt_alias AND
                        cal_type    = v_cal_type AND
                        NVL(alias_val, IGS_GE_DATE.IGSDATE('1900/01/01')) >= v_context_completion_dt AND
                        SUBSTR(IGS_GE_DATE.IGSCHAR(alias_val),1,4) >= p_expected_completion_yr
                ORDER BY alias_val; -- Order is changed to Ascending. Bug :2647482

        CURSOR c_dai2 (
                        cp_adm_e_perd_dt_alias  IGS_AD_CAL_CONF.adm_appl_e_comp_perd_dt_alias%TYPE,
                        cp_adm_m_perd_dt_alias  IGS_AD_CAL_CONF.adm_appl_m_comp_perd_dt_alias%TYPE,
                        cp_adm_s_perd_dt_alias  IGS_AD_CAL_CONF.adm_appl_s_comp_perd_dt_alias%TYPE) IS
                SELECT  alias_val,
                        dt_alias
                FROM    IGS_CA_DA_INST_V dai
                WHERE   dt_alias IN(
                                NVL(cp_adm_e_perd_dt_alias, 'NONE'),
                                NVL(cp_adm_m_perd_dt_alias, 'NONE'),
                                NVL(cp_adm_s_perd_dt_alias, 'NONE')
                                ) AND
                        cal_type = v_cal_type AND
                        NVL(alias_val, IGS_GE_DATE.IGSDATE('1900/01/01')) >= v_context_completion_dt --Replaced '<' with '>'. Bug: 2647482
                ORDER BY alias_val; -- Order is changed to Ascending. Bug :2647482

        --Cursor to get the Program Length and Program Length Measurement for the Program Offering Option record. Bug:2647482
        CURSOR c_get_prg_mesr_dtls(
                                   cp_course_cd igs_ps_ofr_opt_all.course_cd%TYPE,
                                   cp_version_number igs_ps_ofr_opt_all.version_number%TYPE,
                                   cp_cal_type igs_ps_ofr_opt_all.cal_type%TYPE,
                                   cp_attendance_type igs_ps_ofr_opt_all.attendance_type%TYPE,
                                   cp_attendance_mode igs_ps_ofr_opt_all.attendance_mode%TYPE,
                                   cp_location_cd igs_ps_ofr_opt_all.location_cd%TYPE
                                   ) IS
          SELECT program_length,
                 program_length_measurement
          FROM igs_ps_ofr_opt_all
          WHERE course_cd       = p_course_cd AND
                version_number  = p_crv_version_number AND
                cal_type        = p_cal_type AND
                location_cd     = p_location_cd AND
                attendance_mode = p_attendance_mode AND
                attendance_type = p_attendance_type;

          c_get_prg_mesr_dtls_rec  c_get_prg_mesr_dtls%ROWTYPE;

BEGIN

       --Check if there is adequate information to identify the Program Offering Option record. Enh Bug: 2647482
        IF p_attendance_type IS NULL OR p_attendance_mode IS NULL OR p_location_cd IS NULL THEN
          p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
          RETURN;
        END IF;
        --Check for adequate information to continue processing
        IF (p_start_dt IS NULL AND
                        p_expected_completion_yr IS NULL AND
                        p_expected_completion_perd IS NULL) THEN
                p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
                RETURN;
        END IF;

         --Check that course start date is given, calculations cannot be
         --determined without it
        IF (p_start_dt IS NULL) THEN
                p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
                RETURN;
        ELSE
                 -- Determine course start date year
                 v_start_dt_yyyy := SUBSTR(IGS_GE_DATE.IGSCHAR(p_start_dt),1,4);
        END IF;


        --Get academic calendar type if not specified or validate calendar type
        -- specified
        OPEN c_co;
        FETCH c_co INTO v_cal_type;
        IF (c_co%NOTFOUND) THEN
                p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
                CLOSE c_co;
                RETURN;
        END IF;
        CLOSE c_co;
        v_rec_cnt := 0;

        FOR v_co_rec IN c_co LOOP
                IF (p_cal_type IS NULL) THEN
                        IF (v_rec_cnt = 0) THEN
                                v_cal_type := v_co_rec.cal_type;
                        ELSE
                                v_cal_type := NULL;
                                EXIT;
                        END IF;
                ELSE
                        IF (v_co_rec.cal_type = p_cal_type) THEN
                                v_cal_type := v_co_rec.cal_type;
                        END IF;
                END IF;
                v_rec_cnt := v_rec_cnt + 1;
        END LOOP;

        IF ( v_cal_type IS NULL) THEN
                p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
                RETURN;
        END IF;

        --Check for existence of completion period date alias
        --in calendar configuration table
        OPEN c_sacco;
        FETCH c_sacco INTO      v_adm_e_perd_dt_alias,
                                v_adm_m_perd_dt_alias,
                                v_adm_s_perd_dt_alias;
        IF (c_sacco%NOTFOUND) THEN
                p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
                CLOSE c_sacco;
                RETURN;
        END IF;
        CLOSE c_sacco;

   -- Removed the code related to the Government Attendance Type, which gives the course whether
   -- it's FULL / PART time. Now the completion details calculation is based on Program Length and
   -- Program Length Measurement details present at the Program Offering Option record.
   -- The following cursor c_get_prg_mesr_dtls gets the Program length details of the Offering Option record.
   -- Enh Bug : 2647482

        OPEN c_get_prg_mesr_dtls(p_course_cd,
                                 p_crv_version_number,
                                 p_cal_type,
                                 p_attendance_type,
                                 p_attendance_mode,
                                 p_location_cd
                                 );

        FETCH c_get_prg_mesr_dtls INTO c_get_prg_mesr_dtls_rec;
        IF c_get_prg_mesr_dtls%NOTFOUND THEN
          p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
	  CLOSE c_get_prg_mesr_dtls;
          RETURN;
        END IF;
	CLOSE c_get_prg_mesr_dtls;

   -- Convert the Program Length into Days, depending on the Program Length Measurement
   -- record for the Program Offering Option. Enh Bug: 2647482
        IF c_get_prg_mesr_dtls_rec.program_length_measurement = 'YEAR' THEN
          v_completion_days := c_get_prg_mesr_dtls_rec.program_length*365;
        ELSIF c_get_prg_mesr_dtls_rec.program_length_measurement = '10TH OF A YEAR' THEN
          v_completion_days := c_get_prg_mesr_dtls_rec.program_length*36.5;
        ELSIF c_get_prg_mesr_dtls_rec.program_length_measurement = 'MONTHS' THEN
          v_completion_days := c_get_prg_mesr_dtls_rec.program_length*30.4;
        ELSIF c_get_prg_mesr_dtls_rec.program_length_measurement = 'WEEKS' THEN
          v_completion_days := c_get_prg_mesr_dtls_rec.program_length*7;
        ELSIF c_get_prg_mesr_dtls_rec.program_length_measurement = 'DAYS' THEN
          v_completion_days := c_get_prg_mesr_dtls_rec.program_length;
        ELSIF c_get_prg_mesr_dtls_rec.program_length_measurement = 'HOURS' THEN
          v_completion_days := c_get_prg_mesr_dtls_rec.program_length/24;
        ELSIF c_get_prg_mesr_dtls_rec.program_length_measurement = 'MINUTES' THEN
          v_completion_days := c_get_prg_mesr_dtls_rec.program_length/1440;
        END IF;

        IF v_completion_days IS NULL THEN
          p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
          RETURN;
        END IF;

        --Add the Program Length (in Days) to the Program Start Date to get the Completion Date. Bug: 2647482
        v_context_completion_dt := p_start_dt + ROUND(v_completion_days) -1;

        -- Calculate the Completion Details for the given Expected Completion Period only if the Expected Completion Period and Completion Period Date alias are NOT NULL.
        IF (p_expected_completion_yr IS NOT NULL AND --replaced the OR condition here with the AND and removed the following redundant validation. Bug: 2647482
                p_expected_completion_perd IS NOT NULL) THEN

          -- Determine end date, expected completion details given
          IF (p_expected_completion_perd = 'E' AND
                        v_adm_e_perd_dt_alias IS NOT NULL) THEN
            v_comp_perd_dt_alias := v_adm_e_perd_dt_alias;
          ELSIF (p_expected_completion_perd = 'M' AND
                        v_adm_m_perd_dt_alias IS NOT NULL) THEN
            v_comp_perd_dt_alias := v_adm_m_perd_dt_alias;
          ELSIF (p_expected_completion_perd = 'S' AND
                        v_adm_s_perd_dt_alias IS NOT NULL) THEN
            v_comp_perd_dt_alias := v_adm_s_perd_dt_alias;
          END IF;

          IF (v_comp_perd_dt_alias IS NULL) THEN
            p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
            RETURN;
          END IF;

          -- get completion date, which is the closest date greater than the context completion date and year part is greater than
	  -- the Expected Completion Year. Bug : 2715535
          OPEN c_dai;
          FETCH c_dai INTO v_dai;
          IF (c_dai%NOTFOUND) THEN
                p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
                CLOSE c_dai;
                RETURN;
          END IF;
          CLOSE c_dai;

          -- Only process the first record found as it's the closest date greater than the Context Completion Date.
	  -- And also the returned alias value has the Year which is greater than or equal to the given Expected Completion Year. Bug: 2715535
          p_completion_dt := v_dai;
          RETURN;
        END IF;

        -- Move completion date into context of course start date
        v_completion_dt_yyyy := SUBSTR(IGS_GE_DATE.IGSCHAR(v_completion_dt),1,4);   --IGSCHAR returns date in 'YYYY/MM/DD' format

        --Determine expected completion details
        OPEN c_dai2 (   v_adm_e_perd_dt_alias,
                        v_adm_m_perd_dt_alias,
                        v_adm_s_perd_dt_alias );
        FETCH c_dai2 INTO v_dai2_alias_val,
                          v_dai2_dt_alias;

        IF (c_dai2%NOTFOUND) THEN
                p_completion_dt := IGS_GE_DATE.IGSDATE(NULL);
                CLOSE c_dai2;
                RETURN;
        END IF;
        CLOSE c_dai2;

        -- Only process the first record found because it's the nearest date greater than the Context Completion Date;
        v_dai2_alias_val_dd_mon := SUBSTR(IGS_GE_DATE.IGSCHAR(v_dai2_alias_val),5,10);  --IGSCHAR returns date in 'YYYY/MM/DD' format

        v_dai2_alias_val_yyyy := SUBSTR(IGS_GE_DATE.IGSCHAR(v_dai2_alias_val),1,4);  --IGSCHAR returns date in 'YYYY/MM/DD' format

        p_expected_completion_yr := IGS_GE_NUMBER.TO_NUM(v_dai2_alias_val_yyyy);

        p_completion_dt := IGS_GE_DATE.IGSDATE(IGS_GE_NUMBER.TO_CANN(p_expected_completion_yr)||v_dai2_alias_val_dd_mon);

        --Return the Completion Period associated with the calculated Completion date alias instance.
        IF (v_dai2_dt_alias = NVL(v_adm_e_perd_dt_alias, 'NONE')) THEN
                p_expected_completion_perd := 'E';
        ELSIF (v_dai2_dt_alias = NVL(v_adm_m_perd_dt_alias, 'NONE')) THEN
                p_expected_completion_perd := 'M';
        ELSIF (v_dai2_dt_alias = NVL(v_adm_s_perd_dt_alias, 'NONE')) THEN
                p_expected_completion_perd := 'S';
        END IF;
        RETURN;
END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_004.admp_get_crv_comp_dt');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
END admp_get_crv_comp_dt;

END igs_ad_gen_004;

/
