--------------------------------------------------------
--  DDL for Package Body IGS_AD_UPD_INITIALISE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_UPD_INITIALISE" AS
/* $Header: IGSAD16B.pls 120.6 2006/05/02 05:33:20 apadegal noship $ */

  --
  -- Update admission IGS_PS_COURSE application instance IGS_PS_UNIT initialisation.
  PROCEDURE admp_upd_acaiu_init(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offered_ind IN VARCHAR2 DEFAULT 'N',
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE )
  IS
  BEGIN -- admp_upd_acaiu_init
    -- This module updates IGS_AD_PS_APLINSTUNT when
    -- IGS_AD_PS_APPL_INST are updated when
    -- initialising an admission period as a result of reconsideration or deferment
    -- This module is called from IGS_AD_GEN_012.ADMP_UPD_ACAI_RECON and IGS_AD_GEN_012.ADMP_UPD_ACAI_DEFER.
  DECLARE
    e_resource_busy         EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_resource_busy, -54);
    v_init_process          VARCHAR2(125);
    v_adm_unit_outcome_status   VARCHAR2(125);
    v_log_message_name  Varchar2(30);
    v_message_name VARCHAR2(30);
    CURSOR c_acaiu_auos IS
        SELECT  acaiu.ROWID, acaiu.*
        FROM    IGS_AD_PS_APLINSTUNT    acaiu,
            IGS_AD_UNIT_OU_STAT     auos
        WHERE
            acaiu.person_id         = p_person_id           AND
            acaiu.admission_appl_number = p_admission_appl_number   AND
            acaiu.nominated_course_cd   = p_nominated_course_cd     AND
            acaiu.acai_sequence_number  = p_acai_sequence_number    AND
            acaiu.adm_unit_outcome_status   = auos.adm_unit_outcome_status  AND
            auos.s_adm_outcome_status IN ('PENDING', 'OFFER')
        FOR UPDATE OF person_id NOWAIT;
  BEGIN
    IF (p_s_log_type = 'ADM-RECON') THEN
        v_init_process := 'reconsideration';
    ELSE
        -- p_s_log_type must be 'ADM-DEFER'
        v_init_process := 'deferment';
    END IF;
    -- Get admission UNIT outcome status pending default
    v_adm_unit_outcome_status := IGS_AD_GEN_009.ADMP_GET_SYS_AUOS(
                            'PENDING');
    FOR v_acaiu_rec IN c_acaiu_auos LOOP
        v_log_message_name := NULL;
        -- Validate the UNIT offering option
        IF IGS_AD_VAL_ACAIU.admp_val_acaiu_uv(
                v_acaiu_rec.unit_cd,
                v_acaiu_rec.uv_version_number,
                p_s_admission_process_type,
                p_offered_ind,
                v_message_name) = FALSE THEN
            -- UNIT cannot remain, it is no longer valid
            v_log_message_name := v_message_name;

            IGS_AD_PS_APLINSTUNT_Pkg.Delete_Row (
                  v_acaiu_rec.RowId
            );

        ELSE
            -- Validate that the UNIT offering options
            IF IGS_AD_VAL_ACAIU.admp_val_acaiu_opt(
                    v_acaiu_rec.unit_cd,
                    v_acaiu_rec.uv_version_number,
                    v_acaiu_rec.cal_type,
                    v_acaiu_rec.ci_sequence_number,
                    v_acaiu_rec.location_cd,
                    v_acaiu_rec.unit_class,
                    v_acaiu_rec.unit_mode,
                    p_adm_cal_type,
                    p_adm_ci_sequence_number,
                    p_acad_cal_type,
                    p_acad_ci_sequence_number,
                    p_offered_ind,
                    v_message_name) = FALSE THEN
                -- UNIT options must be cleared
                v_log_message_name := v_message_name;
                -- Update this record (IGS_AD_PS_APLINSTUNT)

                IGS_AD_PS_APLINSTUNT_Pkg.Update_Row (
                    X_Mode                              => 'R',
                    X_RowId                             => v_acaiu_rec.RowId,
                    X_Person_Id                         => v_acaiu_rec.Person_Id,
                    X_Admission_Appl_Number             => v_acaiu_rec.Admission_Appl_Number,
                    X_Nominated_Course_Cd               => v_acaiu_rec.Nominated_Course_Cd,
                    X_Acai_Sequence_Number              => v_acaiu_rec.Acai_Sequence_Number,
                    X_Unit_Cd                           => v_acaiu_rec.Unit_Cd,
                    X_Uv_Version_Number                 => v_acaiu_rec.Uv_Version_Number,
                    X_Cal_Type                          => NULL,
                    X_Ci_Sequence_Number                => NULL,
                    X_Location_Cd                       => NULL,
                    X_Unit_Class                        => NULL,
                    X_Unit_Mode                         => NULL,
                    X_Adm_Unit_Outcome_Status           => v_adm_unit_outcome_status,
                    X_Ass_Tracking_Id                   => v_acaiu_rec.Ass_Tracking_Id,
                    X_Rule_Waived_Dt                    => v_acaiu_rec.Rule_Waived_Dt,
                    X_Rule_Waived_Person_Id             => v_acaiu_rec.Rule_Waived_Person_Id,
                    X_Sup_Unit_Cd                       => v_acaiu_rec.Sup_Unit_Cd,
                    X_Sup_Uv_Version_Number             => v_acaiu_rec.Sup_Uv_Version_Number,
                    X_adm_ps_appl_inst_unit_id          => v_acaiu_rec.adm_ps_appl_inst_unit_id
                );

            END IF;
        END IF;
        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            p_s_log_type,
            p_creation_dt,
            (v_acaiu_rec.person_id ||','|| v_acaiu_rec.admission_appl_number ||','||
             v_acaiu_rec.nominated_course_cd ||','|| v_acaiu_rec.acai_sequence_number ||
            ','|| v_acaiu_rec.unit_cd),
            v_log_message_name,
            '');
    END LOOP;
  EXCEPTION
    WHEN e_resource_busy THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_NO_ENOUGH_SYS_RESOURCE');
            App_Exception.Raise_Exception;
    WHEN OTHERS THEN
        App_Exception.Raise_Exception;
  END;
  EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_UPD_INITIALISE.admp_upd_acaiu_init');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
  END admp_upd_acaiu_init;


FUNCTION perform_pre_enrol (
        p_person_id IN igs_ad_ps_appl_inst. person_id%TYPE,
        p_admission_appl_number IN igs_ad_ps_appl_inst. admission_appl_number%TYPE,
        p_nominated_course_cd IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
        p_sequence_number  IN igs_ad_ps_appl_inst.sequence_number%TYPE,
        p_confirm_ind IN VARCHAR2,
        p_check_eligibility_ind  IN VARCHAR2,
    p_message_name OUT NOCOPY VARCHAR2
    )
  RETURN BOOLEAN IS
  ----------------------------------------------------------------
  --Created by  :  rghosh
  --Date created:   07-Apr-2003
  --
  --Purpose: To run the pre-enrolment job from admissions.(bug#2860860-UCAS Conditional Offer build)
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who        When            What
  --amuthu     10-JUN-2003     modified as per the UK Streaming and Repeat TD (bug 2829265)
  --svanukur 17-oct-2003      modified the declaration of v_message_name as part of placements build 3052438
  --ptandon    13-Feb-2004     Added Exception Handling section. Bug# 3360336.
 ----------------------------------------------------------------
    v_message_name    VARCHAR2(2000) ;
    v_warn_level        VARCHAR2(10);

    CURSOR c_pre_enrol (cp_person_id IN igs_ad_ps_appl_inst. person_id%TYPE,
                                                   cp_admission_appl_number IN igs_ad_ps_appl_inst. admission_appl_number%TYPE,
                                                   cp_nominated_course_cd IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                                                   cp_sequence_number IN igs_ad_ps_appl_inst.sequence_number%TYPE) IS
      SELECT a.enrolment_cat,b.acad_cal_type,b.acad_ci_sequence_number
      FROM igs_ad_ps_appl_inst a, igs_ad_appl b
      WHERE  a.person_id = cp_person_id
      AND a.admission_appl_number = cp_admission_appl_number
      AND a.nominated_course_cd = cp_nominated_course_cd
      AND a.sequence_number=cp_sequence_number
      AND a.person_id = b.person_id
      AND a.admission_appl_number = b.admission_appl_number;

    l_pre_enrol_rec   c_pre_enrol%ROWTYPE;
    l_encoded_message VARCHAR2(2000);
    l_app_short_name VARCHAR2(10);
    l_message_name VARCHAR2(100);

    CURSOR c_check_units (cp_person_id IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE,
                          cp_course_cd IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE) IS
      SELECT 'X'
      FROM IGS_EN_SU_ATTEMPT_ALL
      WHERE person_id = cp_person_id
      AND course_cd = cp_course_cd;

    l_check_units VARCHAR2(1);

    l_units_indicator igs_ad_prcs_cat_step_all.s_admission_step_type%TYPE;

  BEGIN

    OPEN c_pre_enrol(p_person_id,p_admission_appl_number,p_nominated_course_cd,p_sequence_number);
    FETCH c_pre_enrol INTO l_pre_enrol_rec;
    CLOSE c_pre_enrol;

    OPEN c_check_units(p_person_id,p_nominated_course_cd);
    FETCH c_check_units INTO l_check_units;
    CLOSE c_check_units;

    IF l_check_units IS NOT NULL THEN
      l_units_indicator := 'N';
    ELSE
      l_units_indicator := igs_ad_gen_003.get_core_or_optional_unit (p_person_id, p_admission_appl_number);
    END IF;

    IF igs_en_gen_010.enrp_ins_snew_prenrl (
                        p_person_id,
                        p_nominated_course_cd,
                        l_pre_enrol_rec.enrolment_cat,
                        l_pre_enrol_rec.acad_cal_type,
                        l_pre_enrol_rec.acad_ci_sequence_number,
                        l_units_indicator,
                        p_confirm_ind,
                        NULL,                   -- Input: Override Enrolment Form Due Date.
                        NULL,                   -- Input: Override Enrolment Package Production Date.
                        p_check_eligibility_ind,
                        p_admission_appl_number,
                        p_nominated_course_cd,
                        p_sequence_number,
                        NULL,                   -- Input: 1 - Unit Code
                        NULL,                   -- Input: 1 - Unit Teaching Calendar
                        NULL,                   -- Input: 1 - Unit Location Code
                        NULL,                   -- Input: 1 - Unit Class
                        NULL,                   -- Input: 2 - Unit Code
                        NULL,                   -- Input: 2 - Unit Teaching Calendar
                        NULL,                   -- Input: 2 - Unit Location Code
                        NULL,                   -- Input: 2 - Unit Class
                        NULL,                   -- Input: 3 - Unit Code
                        NULL,                   -- Input: 3 - Unit Teaching Calendar
                        NULL,                   -- Input: 3 - Unit Location Code
                        NULL,                   -- Input: 3 - Unit Class
                        NULL,                   -- Input: 4 - Unit Code
                        NULL,                   -- Input: 4 - Unit Teaching Calendar
                        NULL,                   -- Input: 4 - Unit Location Code
                        NULL,                   -- Input: 4 - Unit Class
                        NULL,                   -- Input: 5 - Unit Code
                        NULL,                   -- Input: 5 - Unit Teaching Calendar
                        NULL,                   -- Input: 5 - Unit Location Code
                        NULL,                   -- Input: 5 - Unit Class
                        NULL,                   -- Input: 6 - Unit Code
                        NULL,                   -- Input: 6 - Unit Teaching Calendar
                        NULL,                   -- Input: 6 - Unit Location Code
                        NULL,                   -- Input: 6 - Unit Class
                        NULL,                   -- Input: 7 - Unit Code
                        NULL,                   -- Input: 7 - Unit Teaching Calendar
                        NULL,                   -- Input: 7 - Unit Location Code
                        NULL,                   -- Input: 7 - Unit Class
                        NULL,                   -- Input: 8 - Unit Code
                        NULL,                   -- Input: 8 - Unit Teaching Calendar
                        NULL,                   -- Input: 8 - Unit Location Code
                        NULL,                   -- Input: 8 - Unit Class
                        NULL,                   -- Input: Batch Log Creation Date
                        v_warn_level,           -- Output: Warning Level.
                        v_message_name,
                        NULL,                   -- Input: 9 - Unit Code
                        NULL,                   -- Input: 9 - Unit Teaching Calendar
                        NULL,                   -- Input: 9 - Unit Location Code
                        NULL,                   -- Input: 9 - Unit Class
                        NULL,                   -- Input: 10 - Unit Code
                        NULL,                   -- Input: 10 - Unit Teaching Calendar
                        NULL,                   -- Input: 10 - Unit Location Code
                        NULL,                   -- Input: 10 - Unit Class
                        NULL,                   -- Input: 11 - Unit Code
                        NULL,                   -- Input: 11 - Unit Teaching Calendar
                        NULL,                   -- Input: 11 - Unit Location Code
                        NULL,                   -- Input: 11 - Unit Class
                        NULL,                   -- Input: 12 - Unit Code
                        NULL,                   -- Input: 12 - Unit Teaching Calendar
                        NULL,                   -- Input: 12 - Unit Location Code
                        NULL,                   -- Input: 12 - Unit Class
                        NULL,                   -- Input: Unit Set Cd1
                        NULL,                   -- Input: Unit Set Cd2
                        NULL,                   -- Input: p_progress_stat
                        NULL,                   -- Input: Enrollment Method
                        NULL,                   -- Input: Load Cal Type
                        NULL                    -- Input: Load Seq Number
                        ) =TRUE THEN
      RETURN TRUE;
    END IF;
    p_message_name := v_message_name;
    RETURN FALSE;

  EXCEPTION
    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
         IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_ad_upd_initialise.perform_pre_enrol.APP_EXP','Application Exception raised with code '||SQLCODE||' and error '||SQLERRM);
         END IF;
         l_encoded_message := FND_MESSAGE.GET_ENCODED;
         IF l_encoded_message IS NOT NULL THEN
            FND_MESSAGE.SET_ENCODED(l_encoded_message);
            FND_MESSAGE.PARSE_ENCODED(l_encoded_message,l_app_short_name,l_message_name);
            p_message_name := l_message_name;
         ELSE
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNEXPECTED_ERR');
            p_message_name := 'IGS_GE_UNEXPECTED_ERR';
         END IF;
         RETURN FALSE;
    WHEN OTHERS THEN
         IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_ad_upd_initialise.perform_pre_enrol.UNH_EXP','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
         END IF;
         l_encoded_message := FND_MESSAGE.GET_ENCODED;
         IF l_encoded_message IS NOT NULL THEN
            FND_MESSAGE.SET_ENCODED(l_encoded_message);
            FND_MESSAGE.PARSE_ENCODED(l_encoded_message,l_app_short_name,l_message_name);
            p_message_name := l_message_name;
         ELSE
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNEXPECTED_ERR');
            p_message_name := 'IGS_GE_UNEXPECTED_ERR';
         END IF;
         RETURN FALSE;
  END perform_pre_enrol;

  PROCEDURE perform_pre_enrol (
        p_person_id IN igs_ad_ps_appl_inst. person_id%TYPE,
        p_admission_appl_number IN igs_ad_ps_appl_inst. admission_appl_number%TYPE,
        p_nominated_course_cd IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
        p_sequence_number  IN igs_ad_ps_appl_inst.sequence_number%TYPE,
        p_confirm_ind IN VARCHAR2,
        p_check_eligibility_ind  IN VARCHAR2
    )
  IS
  ----------------------------------------------------------------
  --Created by  :  tray
  --Date created:   01-dec-2003
  --
  --Purpose: To run the pre-enrolment job from admissions, from Self Service
  --         This internally calls the function defined above.
  --         proc created since fucntion boolean return value raises error in jdbc call.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who        When            What
 ----------------------------------------------------------------
   l_message_name VARCHAR2(2000);

  BEGIN

        IF igs_ad_upd_initialise.perform_pre_enrol(
               P_PERSON_ID => p_person_id ,
               P_ADMISSION_APPL_NUMBER => p_admission_appl_number,
               P_NOMINATED_COURSE_CD => p_nominated_course_cd,
               P_SEQUENCE_NUMBER => p_sequence_number,
               P_CONFIRM_IND => p_confirm_ind,
               P_CHECK_ELIGIBILITY_IND => p_check_eligibility_ind,
               P_MESSAGE_NAME => l_message_name) = FALSE THEN

               FND_MESSAGE.SET_NAME('IGS',l_message_name);
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;

        END IF;
  END perform_pre_enrol;


  FUNCTION get_msg_name_mapping (
                      p_msg_name IN VARCHAR2)
    RETURN VARCHAR2 IS

    BEGIN

       IF p_msg_name = 'IGS_EN_UNABLE_TO_FND_ADM' THEN
         RETURN 'E457';
       ELSIF p_msg_name =  'IGS_EN_NOT_DETERMINE_CONDID' THEN
         RETURN 'E460';
       ELSIF p_msg_name = 'IGS_EN_CANDID_KEY_DETAIL' THEN
         RETURN 'E464';
       ELSIF p_msg_name =  'IGS_EN_STUD_PRG_REC_LOCKED'  THEN
         RETURN 'E459';
       ELSIF p_msg_name = 'IGS_EN_DISCONT_NOTLIFT'  THEN
         RETURN 'E463';
       ELSIF p_msg_name = 'IGS_EN_UNABLE_DETM_ENR_PERIOD' THEN
         RETURN 'E454';
       ELSIF p_msg_name =  'IGS_EN_UNABLE_DETM_ENRCAT' THEN
         RETURN 'E455';
       ELSIF p_msg_name = 'IGS_EN_STUD_PRG_LAPSE_USER' THEN
         RETURN 'E458';
       ELSIF p_msg_name =  'IGS_EN_UNABLE_LOCATE_UOO_MATC' THEN
         RETURN 'E456';
       ELSIF p_msg_name = 'IGS_EN_FEE_CONTRACT_NOT_CREAT' THEN
         RETURN 'E461';
       ELSIF p_msg_name ='IGS_EN_FEE_CONTRACT_NOTCREATE' THEN
         RETURN 'E462';
       ELSIF p_msg_name = 'IGS_AD_ADM_OUCOME_ST_CLOSED' THEN
     RETURN 'E529';
       ELSIF p_msg_name = 'IGS_AD_OFRST_VALUE_PENDING' THEN
         RETURN 'E530';
       ELSIF p_msg_name = 'IGS_AD_CONDOFR_NOT_MADE' THEN
     RETURN 'E531';
       ELSIF p_msg_name = 'IGS_AD_OUTCOME_STATUS_CHG' THEN
     RETURN 'E532';
       ELSIF p_msg_name = 'IGS_AD_OUTCOME_CANNOT_SETTO' THEN
     RETURN 'E533';
       ELSIF p_msg_name = 'IGS_AD_OUTCOME_FUTURE_TERM' THEN
     RETURN 'E534';
       ELSIF p_msg_name = 'IGS_AD_APPLFEES_OUTSTANDING' THEN
         RETURN 'E535';
       ELSIF p_msg_name = 'IGS_AD_INVALID_COND_OFFER' THEN
     RETURN 'E536';
       ELSIF p_msg_name = 'IGS_AD_ADMAPL_FEES_OUTSTANDIN' THEN
     RETURN 'E537';
       ELSIF p_msg_name = 'IGS_AD_NOTBE_PENDING_OFR_MADE' THEN
     RETURN 'E538';
       ELSIF p_msg_name = 'IGS_AD_NOTBE_NOTQUALIF_OFRMAD' THEN
         RETURN 'E539';
       ELSIF p_msg_name = 'IGS_AD_NOTBE_PENDNG_OFR_MADE' THEN
     RETURN 'E540';
       ELSIF p_msg_name = 'IGS_AD_NOTBE_INCOMPL_OFR_MADE' THEN
     RETURN 'E541';
       ELSIF p_msg_name = 'IGS_AD_ADMDOC_NOTBE_IMCOMPL' THEN
         RETURN 'E541';
       ELSIF p_msg_name = 'IGS_AD_NOTBE_INCOMP_OFR_MADE' THEN
     RETURN 'E541';
       ELSIF p_msg_name = 'IGS_AD_LATE_ADMFEE_NOTPENDING'THEN
     RETURN 'E542';
       ELSIF p_msg_name = 'IGS_AD_OFFER_CANNOT_MADE' THEN
     RETURN 'E543';
       ELSIF p_msg_name = 'IGS_AD_LATEFEE_CANNOT_ASSESS' THEN
     RETURN 'E544';
       ELSIF p_msg_name = 'IGS_AD_FEE_CANNOT_BE_OUTSTAND' THEN
     RETURN 'E545';
       ELSIF p_msg_name = 'IGS_AD_OFRST_NOTPENDING' THEN
     RETURN 'E546';
       ELSIF p_msg_name = 'IGS_AD_OFRST_NOTACCEPTED' THEN
     RETURN 'E547';
       ELSIF p_msg_name = 'IGS_AD_OFRST_NOTCHANGED' THEN
     RETURN 'E548';
       ELSIF p_msg_name = 'IGS_AD_OFR_RESP_NOTLAPSED' THEN
     RETURN 'E549';
       ELSIF p_msg_name = 'IGS_GE_UNHANDLED_EXP' THEN
     RETURN 'E518';
       ELSIF p_msg_name = 'IGS_GE_UNHANDLED_EXCEPTION' THEN
     RETURN 'E518';
       ELSIF p_msg_name = 'IGS_AD_ADMDOC_STATUS_CLOSED' THEN
     RETURN 'E507';
        ELSIF p_msg_name = 'IGS_AD_ADMDOC_STATUS' THEN
     RETURN 'E507';
       ELSIF p_msg_name = 'IGS_AD_ADM_DOC_STATUS' THEN
     RETURN 'E507';
        ELSIF p_msg_name = 'IGS_AD_NOTBE_PENDNG_OFR_MADE' THEN
     RETURN 'E507';
       ELSIF p_msg_name = 'IGS_AD_NOTBE_INCOMPL_OFR_MADE' THEN
     RETURN 'E507';
       ELSIF p_msg_name = 'IGS_AD_ADMDOC_NOTBE_IMCOMPL' THEN
     RETURN 'E507';
      ELSIF p_msg_name = 'IGS_AD_NOTBE_INCOMP_OFR_MADE' THEN
     RETURN 'E507';
      ELSIF p_msg_name = 'IGS_AD_ADM_ENTRY_CLS_ST_CLOSE' THEN
     RETURN 'E508';
      ELSIF p_msg_name = 'IGS_AD_ADMENTRY_QUALIFY_ST' THEN
     RETURN 'E508';
      ELSIF p_msg_name = 'IGS_AD_ADM_ENTRY_QUALIFYST' THEN
     RETURN 'E508';
      ELSIF p_msg_name = 'IGS_AD_NOTBE_PENDING_OFR_MADE' THEN
     RETURN 'E508';
      ELSIF p_msg_name = 'IGS_AD_NOTBE_NOTQUALIF_OFRMAD' THEN
     RETURN 'E508';
      ELSIF p_msg_name = 'IGS_AD_OFRST_NOTPENDING' THEN
     RETURN 'E511';
      ELSIF p_msg_name = 'IGS_AD_OFRST_NOTACCEPTED' THEN
     RETURN 'E511';
      ELSIF p_msg_name = 'IGS_AD_OFRST_NOTCHANGED' THEN
     RETURN 'E511';
      ELSIF p_msg_name = 'IGS_AD_OFR_RESP_NOTLAPSED' THEN
     RETURN 'E511';
      ELSIF p_msg_name = 'IGS_AD_OFR_RESP_NOTAPPLICABLE' THEN
     RETURN 'E511';
      ELSIF p_msg_name = 'IGS_AD_MULTIPLE_OFRS_NOTALLOW' THEN
     RETURN 'E511';
      ELSIF p_msg_name = 'IGS_AD_MULTIPLE_OFFER_LIMIT' THEN
     RETURN 'E511';
      ELSIF p_msg_name = 'IGS_AD_PRSN_CANNOTOFR_SAMEPRG' THEN
     RETURN 'E511';
      ELSIF p_msg_name = 'IGS_PS_LOC_CODE_CLOSED' THEN
     RETURN 'E589';
      ELSIF p_msg_name = 'IGS_PS_ATTEND_MODE_CLOSED' THEN
     RETURN 'E586';
      ELSIF p_msg_name = 'IGS_PS_ATTEND_TYPE_CLOSED' THEN
     RETURN 'E587';
       ELSIF p_msg_name = 'IGS_AD_OFR_RESP_NOTAPPLICABLE' THEN
     RETURN 'E550';
       ELSE
         RETURN NULL;
       END IF;

    END get_msg_name_mapping;

    -- procedure to update the person statistics (moved the code from IGSAI18 )
PROCEDURE update_per_stats (
     p_person_id  IN igs_ad_ps_appl_inst.person_id%TYPE,
     p_admission_appl_number IN igs_ad_ps_appl_inst.admission_appl_number%TYPE DEFAULT NULL,
     p_acptd_or_reopnd_ind  IN VARCHAR2  DEFAULT NULL
   )
 IS

	--Query to check if the current admission calendar is associated with exactly 1 load calendar
	CURSOR check_adm_load_rel
	IS
	SELECT count(*)
	FROM
	    igs_ca_inst_rel car ,                                        -- calendar relations table
	    igs_ca_inst_all ca ,                                          -- calendar instances table
	    igs_ca_type cat,                                               -- calendar types table
	    igs_ad_appl_all apl
	WHERE
	     apl.person_id = p_person_id 				    -- current person id
	 AND apl.admission_appl_number = p_admission_appl_number 	    -- current adm appl number
	 AND car.sup_cal_type = apl.adm_cal_type
	 AND car.sup_ci_sequence_number = apl.adm_ci_sequence_number
	 AND ca.cal_type = car.sub_cal_type
	 AND ca.sequence_number = car.sub_ci_sequence_number
	 AND ca.cal_type = cat.cal_type
	 AND cat.s_cal_cat = 'LOAD' ;

	l_adm_load_cnt NUMBER default 0;

	--Cursor to fetch load calendar associated with tthe
	-- given admission calendar
	CURSOR load_cal_cur (cp_adm_cal_type igs_ca_inst.cal_type%TYPE, cp_adm_ci_sequence_number igs_ca_inst.sequence_number%TYPE  )
	IS
	SELECT    ca.cal_type          load_cal_type ,
		  ca.sequence_number   load_cal_seq_num
	FROM
	     igs_ca_inst_rel car ,                    -- calendar relations table
	    igs_ca_inst_all ca ,                      -- calendar instances table
	    igs_ca_type cat                           -- calendar types table
	WHERE
		  ca.cal_type = car.sub_cal_type
	     AND ca.sequence_number = car.sub_ci_sequence_number
	     AND ca.cal_type = cat.cal_type
	     AND cat.s_cal_cat = 'LOAD'
	     AND car.sup_cal_type = cp_adm_cal_type
	     AND car.sup_ci_sequence_number = cp_adm_ci_sequence_number;

	CURSOR adm_cal_cur -- query to fetch all admission  calendars in which the applicant accepted offer
	IS
	    SELECT   apl.adm_cal_type,
		     apl.adm_ci_sequence_number ,
		     ca.start_dt
	    FROM igs_ad_appl_all         apl ,
		 igs_ad_ps_appl_inst_all inst,
		 igs_ca_inst_all         ca
	    WHERE apl.person_id =  P_PERSON_ID
		AND apl.person_id = inst.person_id
		AND apl.admission_appl_number = inst.admission_appl_number
		AND igs_ad_gen_008.admp_get_saors(inst.adm_offer_resp_status) = 'ACCEPTED'
		AND ca.cal_type =apl.adm_cal_type
		AND ca.sequence_number = apl.adm_ci_sequence_number
		ORDER BY ca.start_dt asc,inst.actual_response_dt asc;

	      --curor to check if User Hook package is in valid state.
	CURSOR chk_uhook_status_cur IS
	SELECT
		status
	FROM
		user_objects
	WHERE
		object_name = 'IGS_AD_UHK_PSTATS_PKG' AND
		object_type = 'PACKAGE BODY';

        CURSOR c_pe_stat  IS
        SELECT  psv.*
        FROM    igs_pe_stat_v psv
        WHERE   psv.person_id = p_person_id;

	l_user_hook_status VARCHAR2(20);


	l_init_cal_type            igs_ca_inst.cal_type%TYPE         DEFAULT NULL;
	l_init_cal_ci_seq_num      igs_ca_inst.sequence_number%TYPE  DEFAULT NULL;
	l_recent_cal_type          igs_ca_inst.cal_type%TYPE         DEFAULT NULL;
	l_recent_cal_ci_seq_num    igs_ca_inst.sequence_number%TYPE  DEFAULT NULL;
	l_adm_pe_stats_der_profile VARCHAR2(200) := FND_PROFILE.VALUE('IGS_AD_PER_STATS_DER_TYPE');
        cv_pe_stat c_pe_stat%ROWTYPE;
        l_most_recent_profile VARCHAR2(200) := FND_PROFILE.VALUE('IGS_PE_RECENT_TERM');
        l_catalog_profile VARCHAR2(200) := FND_PROFILE.VALUE('IGS_PE_CATALOG');


	v_party_last_update_date hz_person_profiles.last_update_date%TYPE;
	lv_perosn_profile_id hz_person_profiles.person_profile_id%TYPE;
	v_return_status VARCHAR2(5);
	v_msg_count NUMBER;
	v_msg_data VARCHAR2(2000);
	l_acpt_appl_exists BOOLEAN := FALSE;
	l_load_cal_exists BOOLEAN  := FALSE;

BEGIN


	OPEN c_pe_stat;
        FETCH c_pe_stat INTO cv_pe_stat;
        CLOSE c_pe_stat;

	IF NVL(l_adm_pe_stats_der_profile,'OFF')='OFF'			-- profile set to OFF
	THEN
		    RETURN;
	ELSIF NVL(l_adm_pe_stats_der_profile,'OFF') ='USER_HOOK'         -- profile set to User hook
	THEN
	    	OPEN chk_uhook_status_cur;
		FETCH chk_uhook_status_cur INTO l_user_hook_status;
		CLOSE chk_uhook_status_cur;

		-- If the status is INVALID then raise appropriate message
		-- If the status is VALID then call the user hook procedure
		--

		IF l_user_hook_status = 'INVALID' THEN
			FND_MESSAGE.SET_NAME('IGS','IGS_AD_UH_INVALID');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_UHK_PSTATS_PKG');
			igs_ge_msg_stack.add;
			APP_EXCEPTION.RAISE_EXCEPTION;
	        ELSE
   		        IGS_AD_UHK_PSTATS_PKG.Derive_Person_Stats(p_person_id,
			 				          l_init_cal_type,
								  l_init_cal_ci_seq_num,
								  l_recent_cal_type,
								  l_recent_cal_ci_seq_num);
     	        END IF;
	ELSIF NVL(l_adm_pe_stats_der_profile,'OFF') ='SYSTEM_DERIVE'	    -- profile set to System derive
	THEN

		     IF p_admission_appl_number IS  NOT NULL		      -- when procedure is invoked from TBH
		        AND NVL(p_acptd_or_reopnd_ind,'X') ='A'		      -- and only when offer is accepted
		     THEN

			     OPEN check_adm_load_rel;
			     FETCH check_adm_load_rel INTO l_adm_load_cnt;
			     CLOSE  check_adm_load_rel;

			     IF l_adm_load_cnt <> 1
			     THEN

				     FND_MESSAGE.SET_NAME('IGS','IGS_AD_PE_STATS_WARN');
				     IGS_GE_MSG_STACK.ADD;
				     app_exception.raise_exception;

			     END IF;

		     END IF;


		     FOR adm_cal_cur_rec IN adm_cal_cur
		     LOOP
			l_acpt_appl_exists := TRUE;
			FOR load_cal_cur_rec IN load_cal_cur(adm_cal_cur_rec.adm_cal_type,adm_cal_cur_rec.adm_ci_sequence_number)
			LOOP
			    l_load_cal_exists := TRUE;
			    IF l_init_cal_type IS NULL AND 	l_init_cal_ci_seq_num IS NULL
			    THEN

				    l_init_cal_type          :=     load_cal_cur_rec.load_cal_type;
				    l_init_cal_ci_seq_num    :=     load_cal_cur_rec.load_cal_seq_num;
			    END IF;
			    l_recent_cal_type        :=     load_cal_cur_rec.load_cal_type;
			    l_recent_cal_ci_seq_num  :=     load_cal_cur_rec.load_cal_seq_num;
			END LOOP;

		     END LOOP;


		     IF  l_acpt_appl_exists AND (NOT l_load_cal_exists)	-- accepted applicatin exists but not even one admission calendar has got subordinate load calendar
		     THEN
			     FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NO_LOAD_CAL');
			     IGS_GE_MSG_STACK.ADD;
			     app_exception.raise_exception;

		     END IF;

	 END IF;

	     cv_pe_stat.init_cal_type	           :=  l_init_cal_type;
	     cv_pe_stat.init_sequence_number	   :=  l_init_cal_ci_seq_num;

	     IF  l_catalog_profile = 'INITIAL_ADM_TERM'
	     THEN
		cv_pe_stat.catalog_cal_type	   :=  l_init_cal_type;
		cv_pe_stat.catalog_sequence_number :=  l_init_cal_ci_seq_num;
	     END IF;

             -- If the IGS:Person Most Recent Admittance Term is set to
	     -- Accepted Application Offer Only, then set the MRT
	     IF l_most_recent_profile = 'ACCPT_OFFER_ONLY'
	     THEN

		cv_pe_stat.recent_cal_type	   :=  l_recent_cal_type;
		cv_pe_stat.recent_sequence_number  :=  l_recent_cal_ci_seq_num;

		IF  l_catalog_profile = 'MR_ADM_TERM'
		THEN

                        cv_pe_stat.catalog_cal_type	   :=  l_recent_cal_type;
			cv_pe_stat.catalog_sequence_number :=  l_recent_cal_ci_seq_num;
		END IF;
	     END IF;


        IF cv_pe_stat.PERSON_ID IS NOT NULL THEN
          -- Call the IGS_PE_STAT_PKG.UPDATE_ROW
          BEGIN


                        igs_pe_stat_pkg.update_row(
                                x_action => 'UPDATE',
                                x_rowid =>  cv_pe_stat.row_id,
                                x_person_id =>  cv_pe_stat.person_id,
                                x_ethnic_origin_id =>  cv_pe_stat.ethnic_origin_id,
                                x_marital_status =>  cv_pe_stat.marital_status,
                                x_marital_stat_effect_dt =>  cv_pe_stat.marital_status_effective_date,
                                x_ann_family_income =>  cv_pe_stat.ann_family_income,
                                x_number_in_family =>  cv_pe_stat.number_in_family,
                                x_content_source_type =>  cv_pe_stat.content_source_type,
                                x_internal_flag =>  cv_pe_stat.internal_flag,
                                x_person_number =>  cv_pe_stat.person_number,
                                x_effective_start_date =>  cv_pe_stat.effective_start_date,
                                x_effective_end_date =>  cv_pe_stat.effective_end_date,
                                x_ethnic_origin =>  cv_pe_stat.ethnic_origin,
                                x_religion =>  cv_pe_stat.religion,
                                x_next_to_kin =>  cv_pe_stat.next_to_kin,
                                x_next_to_kin_meaning =>  cv_pe_stat.next_to_kin_meaning,
                                x_place_of_birth =>  cv_pe_stat.place_of_birth,
                                x_socio_eco_status =>  cv_pe_stat.socio_eco_status,
                                x_socio_eco_status_desc =>  cv_pe_stat.socio_eco_status_desc,
                                x_further_education =>  cv_pe_stat.further_education,
                                x_further_education_desc =>  cv_pe_stat.further_education_desc,
                                x_in_state_tuition =>  cv_pe_stat.in_state_tuition,
                                x_tuition_st_date =>  cv_pe_stat.tuition_st_date,
                                x_tuition_end_date =>  cv_pe_stat.tuition_end_date,
                                x_person_initials =>  cv_pe_stat.person_initials,
                                x_primary_contact_id =>  cv_pe_stat.primary_contact_id,
                                x_personal_income =>  cv_pe_stat.personal_income,
                                x_head_of_household_flag =>  cv_pe_stat.head_of_household_flag,
                                x_content_source_number =>  cv_pe_stat.content_source_number,
                                x_hz_parties_ovn => cv_pe_stat.object_version_number,
                                x_attribute_category =>  cv_pe_stat.attribute_category,
                                x_attribute1 =>  cv_pe_stat.attribute1,
                                x_attribute2 =>  cv_pe_stat.attribute2,
                                x_attribute3 =>  cv_pe_stat.attribute3,
                                x_attribute4 =>  cv_pe_stat.attribute4,
                                x_attribute5 =>  cv_pe_stat.attribute5,
                                x_attribute6 =>  cv_pe_stat.attribute6,
                                x_attribute7 =>  cv_pe_stat.attribute7,
                                x_attribute8 =>  cv_pe_stat.attribute8,
                                x_attribute9 =>  cv_pe_stat.attribute9,
                                x_attribute10 =>  cv_pe_stat.attribute10,
                                x_attribute11 =>  cv_pe_stat.attribute11,
                                x_attribute12 =>  cv_pe_stat.attribute12,
                                x_attribute13 =>  cv_pe_stat.attribute13,
                                x_attribute14 =>  cv_pe_stat.attribute14,
                                x_attribute15 =>  cv_pe_stat.attribute15,
                                x_attribute16 =>  cv_pe_stat.attribute16,
                                x_attribute17 =>  cv_pe_stat.attribute17,
                                x_attribute18 =>  cv_pe_stat.attribute18,
                                x_attribute19 =>  cv_pe_stat.attribute19,
                                x_attribute20 =>  cv_pe_stat.attribute20,
                                x_global_attribute_category =>  cv_pe_stat.global_attribute_category,
                                x_global_attribute1 =>  cv_pe_stat.global_attribute1,
                                x_global_attribute2 =>  cv_pe_stat.global_attribute2,
                                x_global_attribute3 =>  cv_pe_stat.global_attribute3,
                                x_global_attribute4 =>  cv_pe_stat.global_attribute4,
                                x_global_attribute5 =>  cv_pe_stat.global_attribute5,
                                x_global_attribute6 =>  cv_pe_stat.global_attribute6,
                                x_global_attribute7 =>  cv_pe_stat.global_attribute7,
                                x_global_attribute8 =>  cv_pe_stat.global_attribute8,
                                x_global_attribute9 =>  cv_pe_stat.global_attribute9,
                                x_global_attribute10=>  cv_pe_stat.global_attribute10,
                                x_global_attribute11 =>  cv_pe_stat.global_attribute11,
                                x_global_attribute12 =>  cv_pe_stat.global_attribute12,
                                x_global_attribute13 =>  cv_pe_stat.global_attribute13,
                                x_global_attribute14 =>  cv_pe_stat.global_attribute14,
                                x_global_attribute15 =>  cv_pe_stat.global_attribute15,
                                x_global_attribute16 =>  cv_pe_stat.global_attribute16,
                                x_global_attribute17 =>  cv_pe_stat.global_attribute17,
                                x_global_attribute18 =>  cv_pe_stat.global_attribute18,
                                x_global_attribute19 =>  cv_pe_stat.global_attribute19,
                                x_global_attribute20 =>  cv_pe_stat.global_attribute20,
                                x_party_last_update_date =>  v_party_last_update_date,
                                x_person_profile_id =>  lv_perosn_profile_id,
                                x_matr_cal_type =>  cv_pe_stat.matr_cal_type,
                                x_matr_sequence_number =>  cv_pe_stat.matr_sequence_number,
                                x_init_cal_type =>  cv_pe_stat.init_cal_type,
                                x_init_sequence_number =>  cv_pe_stat.init_sequence_number,
                                x_recent_cal_type =>  cv_pe_stat.recent_cal_type,
                                x_recent_sequence_number =>  cv_pe_stat.recent_sequence_number,
                                x_catalog_cal_type =>  cv_pe_stat.catalog_cal_type,
                                x_catalog_sequence_number =>  cv_pe_stat.catalog_sequence_number,
                                z_return_status =>  v_return_status,
                                z_msg_count =>  v_msg_count,
                                z_msg_data =>  v_msg_data
                        );
          EXCEPTION
            WHEN OTHERS THEN

              FND_MESSAGE.SET_NAME('IGS', SQLERRM);
              app_exception.raise_exception;
          END;
        END IF;

END update_per_stats;

END igs_ad_upd_initialise;

/
