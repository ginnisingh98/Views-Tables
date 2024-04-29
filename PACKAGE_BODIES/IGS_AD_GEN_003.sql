--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_003" AS
/* $Header: IGSAD03B.pls 120.2 2005/08/18 07:46:55 appldev ship $ */
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --knag        29-Oct-02       Bug 2647482 : Created the function get_core_or_optional_unit
  --                                          to return CORE_ONLY/Y/N for CORE/CORE_OPTIONAL/no
  --                                          as unit enroll indicator to preenroll process
  --anwest      22-Jul-05       IGS.M (ADTD003): Created the function to act as
  --                                             a wrapper for the
  --                                             Admp_Get_Adm_Perd_Dt function
  --                                             when requiring a Submission
  --                                             Deadline or Offer Response date
-------------------------------------------------------------------------------------------

Function Admp_Get_Acai_Aos_Id(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_date OUT NOCOPY DATE )
RETURN NUMBER IS
BEGIN   -- admp_get_acai_aos_id
    -- This module gets the person id and date of the current
    -- IGS_AD_PS_APPL_INST. adm_outcome_status was set.
DECLARE
    v_person_id IGS_AD_PS_APPL_INST.person_id%TYPE;

    CURSOR  c_acai IS
        SELECT  acai.decision_date,
            acai.decision_make_id
        FROM    IGS_AD_PS_APPL_INST acai
        WHERE   acai.person_id          = p_person_id AND
            acai.admission_appl_number  = p_admission_appl_number AND
            acai.nominated_course_cd    = p_nominated_course_cd AND
            acai.sequence_number        = p_acai_sequence_number AND
            acai.adm_outcome_status IS NOT NULL
        ORDER BY decision_date DESC;
BEGIN
    v_person_id := NULL;
    p_date := NULL;
    OPEN c_acai;
    FETCH c_acai INTO p_date,
                    v_person_id;
    CLOSE c_acai;
    RETURN v_person_id;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_acai%ISOPEN) THEN
            CLOSE c_acai;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_003.admp_get_acai_aos_id');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_get_acai_aos_id;

Function Admp_Get_Acai_Crv(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_course_cd OUT NOCOPY VARCHAR2 ,
  p_crv_version_number OUT NOCOPY NUMBER )
RETURN VARCHAR2 IS
BEGIN   -- admp_get_acai_crv
    -- Description: This module gets
    -- IGS_AD_PS_APPL_INST.course_cd/crv_version_number
DECLARE
    CURSOR  c_acai IS
        SELECT  acai.course_cd,
            acai.crv_version_number
        FROM    IGS_AD_PS_APPL_INST acai
        WHERE   acai.person_id         = p_person_id AND
            acai.admission_appl_number = p_admission_appl_number AND
            acai.nominated_course_cd   = p_nominated_course_cd AND
            acai.sequence_number       = p_sequence_number;
    v_acai_recs     c_acai%ROWTYPE;
BEGIN
    OPEN c_acai;
    FETCH c_acai INTO v_acai_recs;
    IF (c_acai%NOTFOUND) THEN
        CLOSE c_acai;
        p_course_cd := NULL;
        p_crv_version_number := NULL;
    ELSE
        CLOSE c_acai;
        p_course_cd := v_acai_recs.course_cd;
        p_crv_version_number := v_acai_recs.crv_version_number;
    END IF;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_003.admp_get_acai_crv');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_get_acai_crv;

Function Admp_Get_Acai_Status(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_adm_outcome_status OUT NOCOPY VARCHAR2 ,
  p_adm_offer_resp_status OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN   -- admp_get_acai_status
    -- This module gets the adm_outcome_status and adm_offer_resp_status
    -- for the specified IGS_AD_PS_APPL_INST. It returns the statuses
    -- formatted to be used by admission course application context blocks.
DECLARE
    CURSOR  c_acai IS
        SELECT  acai.adm_outcome_status,
            acai.adm_offer_resp_status,
            aors.s_adm_offer_resp_status
        FROM    IGS_AD_PS_APPL_INST     acai,
            IGS_AD_OFR_RESP_STAT        aors
        WHERE   aors.adm_offer_resp_status  = acai.adm_offer_resp_status AND
            acai.person_id          = p_person_id AND
            acai.admission_appl_number  = p_admission_appl_number AND
            acai.nominated_course_cd    = p_nominated_course_cd AND
            acai.sequence_number        = p_sequence_number;
    v_acai_recs     c_acai%ROWTYPE;
BEGIN
    OPEN c_acai;
    FETCH c_acai INTO v_acai_recs;
    IF (c_acai%NOTFOUND) THEN
        CLOSE c_acai;
        p_adm_offer_resp_status := NULL;
        p_adm_outcome_status := NULL;
        RETURN NULL;
    ELSE
        p_adm_offer_resp_status := v_acai_recs.adm_offer_resp_status;
        p_adm_outcome_status := v_acai_recs.adm_outcome_status;
    END IF;
    CLOSE c_acai;
    IF (v_acai_recs.s_adm_offer_resp_status = 'NOT-APPLIC') THEN
            RETURN(v_acai_recs.adm_outcome_status);
    ELSE
        RETURN(v_acai_recs.adm_outcome_status|| '/' ||
               v_acai_recs.adm_offer_resp_status);
    END IF;
    CLOSE c_acai;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_003.admp_get_acai_status');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_get_acai_status;

Function Admp_Get_Ac_Bfa(
  p_tac_admission_cd IN VARCHAR2 ,
  p_admission_cd OUT NOCOPY VARCHAR2 ,
  p_basis_for_admission_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
BEGIN   -- admp_get_ac_bfa
    -- This module finds the user defined admission code and basis for
    -- admission type from the admission code table.
DECLARE
    v_adm_cd        IGS_AD_CD.admission_cd%TYPE;
    v_basis_for_adm_type    IGS_AD_BASIS_FOR_AD.basis_for_admission_type%TYPE;
    CURSOR c_aco IS
        SELECT  admission_cd,
            basis_for_admission_type
        FROM    IGS_AD_CD
        WHERE   tac_admission_cd  = p_tac_admission_cd AND
            closed_ind   = 'N'
        ORDER BY basis_for_admission_type ASC;
BEGIN
    p_message_name := null;
    OPEN c_aco;
    FETCH c_aco INTO v_adm_cd,
             v_basis_for_adm_type;
    IF (c_aco%NOTFOUND) THEN
        CLOSE c_aco;
        p_message_name := 'IGS_AD_CANNOT_DERIVE_ADMCD';
        RETURN FALSE;
    ELSIF v_basis_for_adm_type IS NULL THEN
        CLOSE c_aco;
        p_message_name := 'IGS_AD_CANNOT_DERIVE_ADMTYPE';
        RETURN FALSE;
    END IF;
    p_admission_cd := v_adm_cd;
    p_basis_for_admission_type := v_basis_for_adm_type;
    CLOSE c_aco;
    RETURN TRUE;
END;
EXCEPTION
   WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_003.admp_get_ac_bfa');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_get_ac_bfa;

Function Admp_Get_Adm_Perd_Dt(
  p_dt_alias IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 )
RETURN DATE IS
BEGIN   --admp_get_adm_perd_dt
    --This module returns the date value for an admission period date alias.
DECLARE
    v_sacc_due_dt_alias     IGS_AD_CAL_CONF.adm_appl_due_dt_alias%TYPE;
    v_sacc_final_dt_alias       IGS_AD_CAL_CONF.adm_appl_final_dt_alias%TYPE;
    v_daiv_alias_val            DATE;
    v_dai_sequence_number       IGS_AD_PECRS_OFOP_DT.dai_sequence_number%TYPE;
    v_apcood_found          BOOLEAN;
    v_curr_component_ctr        NUMBER;
    v_high_component_ctr        NUMBER;
    CURSOR c_sacc IS
        SELECT  adm_appl_due_dt_alias,
            adm_appl_final_dt_alias
        FROM    IGS_AD_CAL_CONF sacc
        WHERE   s_control_num = 1;
    CURSOR c_daiv IS
        SELECT IGS_CA_GEN_001.calp_set_alias_value(absolute_val, IGS_CA_GEN_002.cals_clc_dt_from_dai(ci_sequence_number, CAL_TYPE, DT_ALIAS, sequence_number) ) alias_val
        FROM     IGS_CA_DA_INST daiv,
             IGS_AD_PERD_AD_CAT apac
        WHERE   daiv.dt_alias           = p_dt_alias            AND
            apac.adm_cal_type       = p_adm_cal_type        AND
            apac.adm_ci_sequence_number = p_adm_ci_sequence_number  AND
            apac.admission_cat      = p_admission_cat       AND
            apac.adm_cal_type       = daiv.cal_type         AND
            apac.adm_ci_sequence_number = daiv.ci_sequence_number   AND
            NOT EXISTS(
                SELECT 'x'
                FROM    IGS_AD_PECRS_OFOP_DT    apcood
                WHERE   apcood.adm_cal_type     = apac.adm_cal_type     AND
                    apcood.adm_ci_sequence_number   = apac.adm_ci_sequence_number   AND
                    apcood.dt_alias         = daiv.dt_alias         AND
                    apcood.dai_sequence_number  = daiv.sequence_number)
        ORDER BY 1 desc;
    CURSOR c_daiv2 IS
        SELECT IGS_CA_GEN_001.calp_set_alias_value(absolute_val, IGS_CA_GEN_002.cals_clc_dt_from_dai(ci_sequence_number, CAL_TYPE, DT_ALIAS, sequence_number) ) alias_val
        FROM     IGS_CA_DA_INST daiv
        WHERE   daiv.cal_type           = p_adm_cal_type        AND
            daiv.ci_sequence_number     = p_adm_ci_sequence_number  AND
            daiv.dt_alias           = p_dt_alias            AND
            daiv.sequence_number        = v_dai_sequence_number;
    CURSOR c_apcood IS
        SELECT  apcood.s_admission_process_type,
            apcood.course_cd,
            apcood.version_number,
            apcood.acad_cal_type,
            apcood.location_cd,
            apcood.attendance_mode,
            apcood.attendance_type,
            apcood.dai_sequence_number
        FROM    IGS_AD_PECRS_OFOP_DT    apcood
        WHERE   apcood.adm_cal_type     = p_adm_cal_type        AND
            apcood.adm_ci_sequence_number   = p_adm_ci_sequence_number  AND
            apcood.admission_cat        = p_admission_cat       AND
            apcood.dt_alias         = p_dt_alias;
BEGIN
    --Initialise variables
    v_apcood_found      := FALSE;
    v_curr_component_ctr    := 0;
    v_high_component_ctr    := 0;
    v_daiv_alias_val    := NULL;
    --Validate parameters, none can be null
    IF p_dt_alias IS NULL OR
            p_adm_cal_type          IS NULL OR
            p_adm_ci_sequence_number    IS NULL OR
            p_admission_cat         IS NULL THEN
        RETURN NULL;
    END IF;
    --Determine if date alias is allowed admission period date override
    OPEN c_sacc;
    FETCH c_sacc INTO   v_sacc_due_dt_alias,
                v_sacc_final_dt_alias;
    IF (c_sacc%NOTFOUND) THEN
        CLOSE c_sacc;
        RETURN NULL;
    END IF;
    CLOSE c_sacc;
    IF (           ((v_sacc_due_dt_alias IS NULL)               OR
            (v_sacc_due_dt_alias <> p_dt_alias))            AND
               ((v_sacc_final_dt_alias IS NULL)                 OR
            (v_sacc_final_dt_alias<> p_dt_alias)))          THEN
        --Get the date value straight from the dt_alias_instance linked to the
        -- admission
        --Period, the date alias passed cannot have admission period date overrides
        --applied
        OPEN c_daiv;
        FETCH c_daiv INTO v_daiv_alias_val;
        IF (c_daiv%NOTFOUND) THEN
            CLOSE c_daiv;
            RETURN NULL;
        END IF;
        CLOSE c_daiv;
        RETURN v_daiv_alias_val;
    END IF;
    IF p_s_admission_process_type IS NULL AND
            p_course_cd     IS NULL AND
            p_version_number    IS NULL AND
            p_acad_cal_type     IS NULL AND
            p_location_cd       IS NULL AND
            p_attendance_mode   IS NULL AND
            p_attendance_type   IS NULL THEN
        RETURN NULL;
    END IF;
    --Determine if date overrides exist for the date alias in the admission period
    FOR v_apcood_rec IN c_apcood LOOP
        v_apcood_found := TRUE;
        --Check that the record firstly is valid for the parameters
        IF ((v_apcood_rec.s_admission_process_type IS NULL  OR
                v_apcood_rec.s_admission_process_type = p_s_admission_process_type) AND
                (v_apcood_rec.course_cd IS NULL OR
                (v_apcood_rec.course_cd     = p_course_cd       AND
                v_apcood_rec.version_number     = p_version_number  AND
                v_apcood_rec.acad_cal_type  = p_acad_cal_type))         AND
                (v_apcood_rec.location_cd   IS NULL OR
                v_apcood_rec.location_cd    = p_location_cd)            AND
                (v_apcood_rec.attendance_mode   IS NULL OR
                v_apcood_rec.attendance_mode    = p_attendance_mode)            AND
                (v_apcood_rec.attendance_type   IS NULL OR
                v_apcood_rec.attendance_type    = p_attendance_type))   THEN
            --Match on the components and save the IGS_CA_DA_INST_V key for the
            --Record that matches with the highest number of components
            IF (v_apcood_rec.s_admission_process_type IS NOT NULL) THEN
                IF (v_apcood_rec.s_admission_process_type = p_s_admission_process_type) THEN
                    v_curr_component_ctr := v_curr_component_ctr + 1;
                END IF;
            END IF;
            IF (v_apcood_rec.course_cd IS NOT NULL) THEN
                IF (v_apcood_rec.course_cd = p_course_cd    AND
                        v_apcood_rec.version_number = p_version_number  AND
                        v_apcood_rec.acad_cal_type  = p_acad_cal_type) THEN
                    v_curr_component_ctr := v_curr_component_ctr + 1;
                END IF;
            END IF;
            IF (v_apcood_rec.location_cd IS NOT NULL) THEN
                IF (v_apcood_rec.location_cd = p_location_cd) THEN
                    v_curr_component_ctr := v_curr_component_ctr + 1;
                END IF;
            END IF;
            IF (v_apcood_rec.attendance_mode IS NOT NULL) THEN
                IF (v_apcood_rec.attendance_mode = p_attendance_mode) THEN
                    v_curr_component_ctr := v_curr_component_ctr + 1;
                END IF;
            END IF;
            IF (v_apcood_rec.attendance_type IS NOT NULL) THEN
                IF (v_apcood_rec.attendance_type = p_attendance_type) THEN
                    v_curr_component_ctr := v_curr_component_ctr + 1;
                END IF;
            END IF;
            --If this record has the most number of matches then we want to use
            --its dai_sequence_number
            IF (v_curr_component_ctr > v_high_component_ctr) THEN
                v_high_component_ctr := v_curr_component_ctr;
                v_dai_sequence_number := v_apcood_rec.dai_sequence_number;
            END IF;
            v_curr_component_ctr := 0;
        END IF;
    END LOOP;
    IF (NOT v_apcood_found) THEN
        --Get the date value straight from the dt_alias_instance
        --linked to the admission period
        OPEN c_daiv;
        FETCH c_daiv INTO v_daiv_alias_val;
        CLOSE c_daiv;
        RETURN v_daiv_alias_val;
    END IF;
    IF (v_dai_sequence_number IS NULL) THEN
        --Get the date value straight from the dt_alias_instance
        --linked to the admission Period, no override was found
        OPEN c_daiv;
        FETCH c_daiv INTO v_daiv_alias_val;
        CLOSE c_daiv;
        RETURN v_daiv_alias_val;
    END IF;
    OPEN c_daiv2;
    FETCH c_daiv2 INTO v_daiv_alias_val;
    IF (c_daiv2%NOTFOUND) THEN
        CLOSE c_daiv2;
        RETURN NULL;
    END IF;
    CLOSE c_daiv2;
    RETURN v_daiv_alias_val;
END;
END admp_get_adm_perd_dt;

Procedure Admp_Get_Adm_Pp(
  p_oracle_username IN VARCHAR2 ,
  p_adm_acad_cal_type OUT NOCOPY VARCHAR2 ,
  p_adm_acad_ci_sequence_number OUT NOCOPY NUMBER ,
  p_adm_acad_alternate_code OUT NOCOPY VARCHAR2 ,
  p_adm_acad_abbreviation OUT NOCOPY VARCHAR2 ,
  p_adm_adm_cal_type OUT NOCOPY VARCHAR2 ,
  p_adm_adm_ci_sequence_number OUT NOCOPY NUMBER ,
  p_adm_adm_alternate_code OUT NOCOPY VARCHAR2 ,
  p_adm_adm_abbreviation OUT NOCOPY VARCHAR2 ,
  p_adm_admission_cat OUT NOCOPY VARCHAR2 ,
  p_adm_s_admission_process_type OUT NOCOPY VARCHAR2 ,
  p_adm_ac_description OUT NOCOPY VARCHAR2 )
IS
BEGIN
  NULL;
END admp_get_adm_pp;

Procedure Admp_Get_Apcs_Mndtry(
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_mandatory_athletics OUT NOCOPY BOOLEAN,
  p_mandatory_alternate OUT NOCOPY BOOLEAN ,
  p_mandatory_address OUT NOCOPY BOOLEAN ,
  p_mandatory_disability OUT NOCOPY BOOLEAN ,
  p_mandatory_visa OUT NOCOPY BOOLEAN ,
  p_mandatory_finance OUT NOCOPY BOOLEAN ,
  p_mandatory_notes OUT NOCOPY BOOLEAN ,
  p_mandatory_statistics OUT NOCOPY BOOLEAN ,
  p_mandatory_alias OUT NOCOPY BOOLEAN ,
  p_mandatory_tertiary OUT NOCOPY BOOLEAN ,
  p_mandatory_aus_sec_ed OUT NOCOPY BOOLEAN ,
  p_mandatory_os_sec_ed OUT NOCOPY BOOLEAN ,
  p_mandatory_employment OUT NOCOPY BOOLEAN ,
  p_mandatory_membership OUT NOCOPY BOOLEAN ,
  p_mandatory_dob OUT NOCOPY BOOLEAN ,
  p_mandatory_title OUT NOCOPY BOOLEAN ,
  p_mandatory_referee OUT NOCOPY BOOLEAN ,
  p_mandatory_scholarship OUT NOCOPY BOOLEAN ,
  p_mandatory_lang_prof OUT NOCOPY BOOLEAN ,
  p_mandatory_interview OUT NOCOPY BOOLEAN ,
  p_mandatory_exchange OUT NOCOPY BOOLEAN ,
  p_mandatory_adm_test OUT NOCOPY BOOLEAN ,
  p_mandatory_fee_assess OUT NOCOPY BOOLEAN ,
  p_mandatory_cor_category OUT NOCOPY BOOLEAN ,
  p_mandatory_enr_category OUT NOCOPY BOOLEAN ,
  p_mandatory_research OUT NOCOPY BOOLEAN ,
  p_mandatory_rank_app OUT NOCOPY BOOLEAN ,
  p_mandatory_completion OUT NOCOPY BOOLEAN ,
  p_mandatory_rank_set OUT NOCOPY BOOLEAN ,
  p_mandatory_basis_adm OUT NOCOPY BOOLEAN ,
  p_mandatory_crs_international OUT NOCOPY BOOLEAN ,
  p_mandatory_ass_tracking OUT NOCOPY BOOLEAN ,
  p_mandatory_adm_code OUT NOCOPY BOOLEAN ,
  p_mandatory_fund_source OUT NOCOPY BOOLEAN ,
  p_mandatory_location OUT NOCOPY BOOLEAN ,
  p_mandatory_att_mode OUT NOCOPY BOOLEAN ,
  p_mandatory_att_type OUT NOCOPY BOOLEAN ,
  p_mandatory_unit_set OUT NOCOPY BOOLEAN ,
  p_mandatory_evaluation_tab OUT NOCOPY BOOLEAN ,
  p_mandatory_prog_approval OUT NOCOPY BOOLEAN ,
  p_mandatory_indices OUT NOCOPY BOOLEAN ,
  p_mandatory_tst_scores OUT NOCOPY BOOLEAN ,
  p_mandatory_outcome OUT NOCOPY BOOLEAN ,
  p_mandatory_override OUT NOCOPY BOOLEAN ,
  p_mandatory_spl_consider OUT NOCOPY BOOLEAN ,
  p_mandatory_cond_offer OUT NOCOPY BOOLEAN ,
  p_mandatory_offer_dead OUT NOCOPY BOOLEAN ,
  p_mandatory_offer_resp OUT NOCOPY BOOLEAN ,
  p_mandatory_offer_defer OUT NOCOPY BOOLEAN ,
  p_mandatory_offer_compl OUT NOCOPY BOOLEAN ,
  p_mandatory_transfer OUT NOCOPY BOOLEAN ,
  p_mandatory_other_inst OUT NOCOPY BOOLEAN ,
  p_mandatory_edu_goals OUT NOCOPY BOOLEAN ,
  p_mandatory_acad_interest OUT NOCOPY BOOLEAN ,
  p_mandatory_app_intent OUT NOCOPY BOOLEAN ,
  p_mandatory_spl_interest OUT NOCOPY BOOLEAN ,
  p_mandatory_spl_talents OUT NOCOPY BOOLEAN ,
  p_mandatory_miscell OUT NOCOPY BOOLEAN ,
  p_mandatory_fees OUT NOCOPY BOOLEAN ,
  p_mandatory_program OUT NOCOPY BOOLEAN ,
  p_mandatory_completness OUT NOCOPY BOOLEAN ,
  p_mandatory_creden OUT NOCOPY BOOLEAN ,
  p_mandatory_review_det OUT NOCOPY BOOLEAN ,
  p_mandatory_recomm_det OUT NOCOPY BOOLEAN ,
  p_mandatory_fin_aid OUT NOCOPY BOOLEAN ,
  p_mandatory_acad_honors OUT NOCOPY BOOLEAN ,
  p_mandatory_des_unitsets OUT NOCOPY BOOLEAN,
  p_mandatory_extrcurr     OUT NOCOPY BOOLEAN )
IS
BEGIN   -- admp_get_apcs_mndtry
    -- Return the steps for an admission process category
DECLARE
    v_unit_set_step     BOOLEAN DEFAULT FALSE;
    v_un_crs_us     BOOLEAN DEFAULT FALSE;
    CURSOR c_apcs IS
        SELECT  apcs.s_admission_step_type
        FROM    IGS_AD_PRCS_CAT_STEP    apcs
        WHERE   admission_cat           = p_admission_cat       AND
            s_admission_process_type    = p_s_admission_process_type    AND
            mandatory_step_ind      = 'Y' AND
            step_group_type <> 'TRACK'; -- 2402377
BEGIN
    -- Initialise the output parameters
    p_mandatory_athletics       := FALSE;
    p_mandatory_alternate       := FALSE;
    p_mandatory_address     := FALSE;
    p_mandatory_disability      := FALSE;
    p_mandatory_visa        := FALSE;
    p_mandatory_finance     := FALSE;
    p_mandatory_notes       := FALSE;
    p_mandatory_statistics      := FALSE;
    p_mandatory_alias       := FALSE;
    p_mandatory_tertiary        := FALSE;
    p_mandatory_aus_sec_ed      := FALSE;
    p_mandatory_os_sec_ed       := FALSE;
    p_mandatory_employment      := FALSE;
    p_mandatory_membership      := FALSE;
    p_mandatory_referee     := FALSE;
    p_mandatory_scholarship     := FALSE;
    p_mandatory_lang_prof       := FALSE;
    p_mandatory_interview       := FALSE;
    p_mandatory_exchange        := FALSE;
    p_mandatory_adm_test        := FALSE;
    p_mandatory_fee_assess      := FALSE;
    p_mandatory_cor_category    := FALSE;
    p_mandatory_enr_category    := FALSE;
    p_mandatory_research        := FALSE;
    p_mandatory_rank_app        := FALSE;
    p_mandatory_completion      := FALSE;
    p_mandatory_rank_set        := FALSE;
    p_mandatory_basis_adm       := FALSE;
    p_mandatory_crs_international   := FALSE;
    p_mandatory_ass_tracking    := FALSE;
    p_mandatory_adm_code        := FALSE;
    p_mandatory_fund_source     := FALSE;
    p_mandatory_unit_set        := FALSE;
    p_mandatory_dob         := TRUE;
    p_mandatory_title       := TRUE;
    p_mandatory_location        := TRUE;
    p_mandatory_att_mode        := TRUE;
    p_mandatory_att_type        := TRUE;

        p_mandatory_evaluation_tab  := FALSE;
    p_mandatory_prog_approval   := FALSE;
    p_mandatory_indices         := FALSE;
    p_mandatory_tst_scores      := FALSE;
    p_mandatory_outcome         := FALSE;
    p_mandatory_override        := FALSE;
    p_mandatory_spl_consider    := FALSE;
    p_mandatory_cond_offer      := FALSE;
    p_mandatory_offer_dead      := FALSE;
    p_mandatory_offer_resp      := FALSE;
    p_mandatory_offer_defer     := FALSE;
    p_mandatory_offer_compl     := FALSE;
    p_mandatory_transfer        := FALSE;
    p_mandatory_other_inst      := FALSE;
    p_mandatory_edu_goals       := FALSE;
    p_mandatory_acad_interest   := FALSE;
    p_mandatory_app_intent      := FALSE;
    p_mandatory_spl_interest    := FALSE;
    p_mandatory_spl_talents     := FALSE;
    p_mandatory_miscell     := FALSE;
    p_mandatory_fees        := FALSE;
    p_mandatory_program         := FALSE;
    p_mandatory_completness     := FALSE;
    p_mandatory_creden      := FALSE;
    p_mandatory_review_det      := FALSE;
    p_mandatory_recomm_det      := FALSE;
    p_mandatory_fin_aid         := FALSE;
    p_mandatory_acad_honors     := FALSE;
    p_mandatory_des_unitsets        := FALSE; -- added for 2382599
    p_mandatory_extrcurr            := FALSE;

    FOR v_apcs_rec IN c_apcs LOOP
        IF (v_apcs_rec.s_admission_step_type = 'ATHLETICS') THEN
            p_mandatory_athletics := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'PER-ALTERNATE') THEN
            p_mandatory_alternate := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'PER-ADDR') THEN
            p_mandatory_address := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'DISABILITY') THEN
            p_mandatory_disability := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'PER-INTL') THEN
            p_mandatory_visa := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'FINANCE') THEN
            p_mandatory_finance := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'PER-NOTES') THEN
            p_mandatory_notes := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'PER-STAT') THEN
            p_mandatory_statistics := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'PER-ALIASES') THEN
            p_mandatory_alias := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'TERT-EDN') THEN
            p_mandatory_tertiary := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'AUS-SEC-ED') THEN
            p_mandatory_aus_sec_ed := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'OS-SEC-ED') THEN
            p_mandatory_os_sec_ed := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'EMPLOYMENT') THEN
            p_mandatory_employment := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'PROFMEMBER') THEN
            p_mandatory_membership := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'REFEREE') THEN
            p_mandatory_referee := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'SCHOLRSHIP') THEN
            p_mandatory_scholarship := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'LANG-PROF') THEN
            p_mandatory_lang_prof := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'INTERVIEW') THEN
            p_mandatory_interview := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'EXCHANGE') THEN
            p_mandatory_exchange := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'ADM-TEST') THEN
            p_mandatory_adm_test := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'FEE-ASSESS') THEN
            p_mandatory_fee_assess := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'CORCATEGRY') THEN
            p_mandatory_cor_category := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'ENRCATEGRY') THEN
            p_mandatory_enr_category := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'RESEARCH') THEN
            p_mandatory_research := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'RANK-APP') THEN
            p_mandatory_rank_app := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'COMPLETION') THEN
            p_mandatory_completion := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'RANK-SET') THEN
            p_mandatory_rank_set := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'BASIS-ADM') THEN
            p_mandatory_basis_adm := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'CRS-INTERN') THEN
            p_mandatory_crs_international := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'ASS-TRACK') THEN
            p_mandatory_ass_tracking := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'ADM-CODE') THEN
            p_mandatory_adm_code := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'FUNDSOURCE') THEN
            p_mandatory_fund_source := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'UN-DOB') THEN
            p_mandatory_dob := FALSE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'UN-TITLE') THEN
            p_mandatory_title := FALSE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'UN-CRS-LOC') THEN
            p_mandatory_location := FALSE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'UN-CRS-MOD') THEN
            p_mandatory_att_mode := FALSE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'UN-CRS-TYP') THEN
            p_mandatory_att_type := FALSE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'UNIT-SET') THEN
            v_unit_set_step := TRUE;
        END IF;
        IF (v_apcs_rec.s_admission_step_type = 'UN-CRS-US') THEN
            v_un_crs_us := TRUE;
        END IF;

        IF (v_apcs_rec.s_admission_step_type = 'PGM-APPRV') THEN
                p_mandatory_prog_approval  := TRUE;
                END IF;
        IF (v_apcs_rec.s_admission_step_type = 'ACAD-HONORS') THEN
                p_mandatory_acad_honors  := TRUE;
                END IF;
            IF (v_apcs_rec.s_admission_step_type = 'ACAD-INTEREST') THEN
                p_mandatory_acad_interest  := TRUE;
                END IF;
        IF (v_apcs_rec.s_admission_step_type = 'ACAD-INTENT') THEN
                p_mandatory_app_intent  := TRUE;
                END IF;
        IF (v_apcs_rec.s_admission_step_type = 'EDU-GOALS') THEN
                p_mandatory_edu_goals    := TRUE;
                END IF;
        IF (v_apcs_rec.s_admission_step_type = 'OTH-INST-APPL') THEN
                p_mandatory_other_inst    := TRUE;
                END IF;
        IF (v_apcs_rec.s_admission_step_type = 'SPL-TALENT') THEN
                p_mandatory_spl_talents    := TRUE;
                END IF;
        IF (v_apcs_rec.s_admission_step_type = 'SPL-INTEREST') THEN
                p_mandatory_spl_talents    := TRUE;
                END IF;
        IF (v_apcs_rec.s_admission_step_type = 'MISC-DTL') THEN
                p_mandatory_miscell    := TRUE;
                END IF;
        IF (v_apcs_rec.s_admission_step_type = 'FINAID') THEN
                p_mandatory_fin_aid     := TRUE;
                END IF;

        IF (v_apcs_rec.s_admission_step_type = 'DES-UNITSETS') THEN -- added for 2382599
                p_mandatory_des_unitsets     := TRUE;
                END IF;

        IF (v_apcs_rec.s_admission_step_type = 'EXTRACURRI') THEN
                        p_mandatory_extrcurr := TRUE;
                END IF;


    END LOOP;
    IF (v_unit_set_step AND
            NOT v_un_crs_us) THEN
        p_mandatory_unit_set := TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_apcs%ISOPEN) THEN
            CLOSE c_apcs;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_003.admp_get_apcs_mndtry');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_get_apcs_mndtry;

PROCEDURE get_entr_doc_apc (p_admission_cat IN IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                                   p_s_admission_process_type IN IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE,
                                   l_adm_doc_status OUT NOCOPY IGS_AD_PS_APPL_INST_ALL.adm_doc_status%TYPE,
                                   l_adm_entr_qual_status OUT NOCOPY IGS_AD_PS_APPL_INST_ALL.adm_entry_qual_status%TYPE) IS
/*****************************************************************************************
Created By: Tapash.Ray@oracle.com
Date Created : 09-SEP-2002
Purpose: 1.Returns the application completion status and entry qual status based on APC
Known limitations,enhancements,remarks:
Change History
Who        When          What
*****************************************************************************************/
CURSOR c_apcs_step (
                cp_admission_cat                IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                cp_s_admission_process_type     IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE,
                cp_s_admission_step_type        IGS_AD_PRCS_CAT_STEP.s_admission_step_type%TYPE) IS
        SELECT  apcs.s_admission_step_type
        FROM    IGS_AD_PRCS_CAT_STEP apcs
        WHERE   apcs.admission_cat = cp_admission_cat AND
                apcs.s_admission_process_type = cp_s_admission_process_type AND
                apcs.s_admission_step_type = cp_s_admission_step_type AND
        apcs.step_group_type = 'OUTCOME';
        l_s_admission_step_type IGS_AD_PRCS_CAT_STEP.s_admission_step_type%TYPE;
BEGIN
  IF p_s_admission_process_type = 'NON-AWARD' THEN
     l_adm_entr_qual_status := IGS_AD_GEN_009.admp_get_sys_aeqs('NOT-APPLIC');
     l_adm_doc_status:= IGS_AD_GEN_009.admp_get_sys_ads('NOT-APPLIC');
  ELSE
     OPEN c_apcs_step(p_admission_cat,p_s_admission_process_type,'DFLT_ENTRY_QUAL');
       FETCH c_apcs_step INTO l_s_admission_step_type;
         IF c_apcs_step%FOUND AND l_s_admission_step_type = 'DFLT_ENTRY_QUAL' THEN
           l_adm_entr_qual_status := IGS_AD_GEN_009.admp_get_sys_aeqs('QUALIFIED');
         ELSE
           l_adm_entr_qual_status := IGS_AD_GEN_009.admp_get_sys_aeqs('PENDING');
     END IF;
     CLOSE c_apcs_step;

     OPEN c_apcs_step(p_admission_cat,p_s_admission_process_type,'DFLT_DOC_STATUS');
       FETCH c_apcs_step INTO l_s_admission_step_type;
         IF c_apcs_step%FOUND AND l_s_admission_step_type = 'DFLT_DOC_STATUS' THEN
           l_adm_doc_status:= IGS_AD_GEN_009.admp_get_sys_ads('SATISFIED');
         ELSE
           l_adm_doc_status:= IGS_AD_GEN_009.admp_get_sys_ads('PENDING');
     END IF;
     CLOSE c_apcs_step;
  END IF;
  END get_entr_doc_apc;

FUNCTION get_core_or_optional_unit (
  p_person_id               igs_ad_appl_all.person_id%TYPE,
  p_admission_appl_number   igs_ad_appl_all.admission_appl_number%TYPE)
RETURN VARCHAR2 IS -- (Y, CORE_ONLY, N)
/*****************************************************************************************
Created By: knag
Date Created : 29-OCT-2002
Purpose: To return CORE_ONLY/Y/N for CORE/CORE_OPTIONAL/no as unit enrollment indicator
         to pre-enrollment process
Known limitations,enhancements,remarks:
Change History
Who        When          What
*****************************************************************************************/
  -- will fetch first CORE_OPTIONAL then CORE if both present
  CURSOR     c_get_core_or_optional_unit IS
    SELECT   apcs.s_admission_step_type
    FROM     igs_ad_prcs_cat_step_all apcs, igs_ad_appl_all appl
    WHERE    appl.person_id = p_person_id
    AND      appl.admission_appl_number = p_admission_appl_number
    AND      apcs.admission_cat = appl.admission_cat
    AND      apcs.s_admission_process_type = appl.s_admission_process_type
    AND      apcs.step_group_type = 'UNIT-VAL'
    AND      apcs.s_admission_step_type IN ('CORE','CORE_OPTIONAL')
    ORDER BY apcs.s_admission_step_type desc;

  l_s_admission_step_type igs_ad_prcs_cat_step_all.s_admission_step_type%TYPE;
BEGIN
  IF p_person_id IS NOT NULL AND p_admission_appl_number IS NOT NULL THEN
    OPEN c_get_core_or_optional_unit;
    FETCH c_get_core_or_optional_unit INTO l_s_admission_step_type;
    CLOSE c_get_core_or_optional_unit;
  END IF;
  IF l_s_admission_step_type IS NOT NULL THEN
    IF l_s_admission_step_type = 'CORE_OPTIONAL' THEN
      l_s_admission_step_type := 'Y';
    ELSIF l_s_admission_step_type = 'CORE' THEN
      l_s_admission_step_type := 'CORE_ONLY';
    END IF;
  ELSE
    l_s_admission_step_type := 'N';
  END IF;
  RETURN l_s_admission_step_type;
EXCEPTION
  WHEN OTHERS THEN
    IF c_get_core_or_optional_unit%ISOPEN THEN
      CLOSE c_get_core_or_optional_unit;
    END IF;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igs_ad_gen_003.get_core_or_optional_unit');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END get_core_or_optional_unit;


Function get_apc_date(p_date_type IN VARCHAR2 ,
            p_adm_cal_type IN VARCHAR2 ,
            p_adm_ci_sequence_number IN NUMBER ,
            p_admission_cat IN VARCHAR2 ,
            p_s_admission_process_type IN VARCHAR2 ,
            p_course_cd IN VARCHAR2 ,
            p_version_number IN NUMBER ,
            p_acad_cal_type IN VARCHAR2 ,
            p_location_cd IN VARCHAR2 ,
            p_attendance_mode IN VARCHAR2 ,
            p_attendance_type IN VARCHAR2 )
RETURN DATE IS

/******************************************************************************
Created By:     anwest
Date Created:   22-JUL-2005
Purpose:        To act as a wrapper for the Admp_Get_Adm_Perd_Dt function when
                requiring a Submission Deadline or Offer Response date
Known limitations,enhancements,remarks:
Change History
Who        When          What
******************************************************************************/

BEGIN

DECLARE

    l_apc_step_exists       VARCHAR2(1);
    l_due_dt_alias          IGS_AD_CAL_CONF.adm_appl_due_dt_alias%TYPE;
    l_final_dt_alias        IGS_AD_CAL_CONF.adm_appl_final_dt_alias%TYPE;
    l_offer_resp_dt_alias   IGS_AD_CAL_CONF.adm_appl_offer_resp_dt_alias%TYPE;
    l_dt_alias              IGS_AD_CAL_CONF.adm_appl_offer_resp_dt_alias%TYPE;
    l_out_dt                DATE;

    CURSOR c_apc_step IS
        SELECT  'X'
        FROM    IGS_AD_PRCS_CAT_STEP
        WHERE   admission_cat = p_admission_cat AND
                s_admission_process_type = p_s_admission_process_type AND
                s_admission_step_type = 'LATE-APP' AND
                step_group_type <> 'TRACK';

    CURSOR c_dt_alias IS
        SELECT  adm_appl_due_dt_alias, adm_appl_final_dt_alias, adm_appl_offer_resp_dt_alias
        FROM   IGS_AD_CAL_CONF
        WHERE  s_control_num = '1';

BEGIN

    OPEN c_dt_alias;
    FETCH c_dt_alias INTO l_due_dt_alias, l_final_dt_alias, l_offer_resp_dt_alias;
    CLOSE c_dt_alias;

    IF p_date_type = 'SUBMISSION_DEADLINE' THEN

        OPEN c_apc_step;
        FETCH c_apc_step INTO l_apc_step_exists;
        CLOSE c_apc_step;

        IF l_apc_step_exists IS NOT NULL THEN
            l_dt_alias:= l_final_dt_alias;
        ELSE
            l_dt_alias:= l_due_dt_alias;
        END IF;

    ELSIF p_date_type = 'OFFER_RESPONSE_DATE' THEN

        l_dt_alias:= l_offer_resp_dt_alias;

    ELSE

        l_dt_alias:= NULL;

    END IF;

    RETURN Admp_Get_Adm_Perd_Dt(
                            l_dt_alias,
                            p_adm_cal_type,
                            p_adm_ci_sequence_number,
                            p_admission_cat,
                            p_s_admission_process_type,
                            p_course_cd,
                            p_version_number,
                            p_acad_cal_type,
                            p_location_cd,
                            p_attendance_mode,
                            p_attendance_type );

END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_003.get_apc_date');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END get_apc_date;

END IGS_AD_GEN_003;

/
