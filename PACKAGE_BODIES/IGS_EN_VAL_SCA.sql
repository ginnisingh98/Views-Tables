--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SCA" AS
/* $Header: IGSEN61B.pls 120.12 2006/09/05 13:24:05 bdeviset ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --shtatiko    08-MAR-2004     Enh# 3167098, Removed finp_audit_fee_cat procedure.
  --prchandr    08-Jan-01       Enh Bug No: 2174101, As the Part of Change in IGSEN18B
  --                            Passing NULL as parameters  to ENRP_CLC_SUA_EFTSU
  --                            ENRP_CLC_EFTSU_TOTAL for Key course cd and version number
  --vchappid    28-Nov-01       Enh Bug No: 2122257, Added new procedure finp_audit_fee_cat
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function genp_val_sdtt_sess removed
  --kkillams    11-11-2002      As part of Legacy Build bug no:2661533,
  --                            New parameter p_legacy is added to following functions
  --                            enrp_val_sca_lapse,enrp_val_sca_dr,enrp_val_sca_discont.
  --amuthu      06-JAN-03       As part of Legacy Build bug no:2736125, changed the
  --                            the assignment of p_message_name in procedure enrp_val_sca_discont
  --                            also removed self reference in the package
  --sarakshi    24-Feb-2003     Enh#2797116,modified cursor c_coo in enrp_val_coo_att function to include delete_flag
  --                            check in the where clause
  --ptandon     18-Feb-2004     In the function resp_val_ca_dtl_comp, modified the call to function
  --                            igs_re_val_rsup.resp_val_rsup_perc to pass 'N' for the parameter
  --                            p_val_funding_perc_ind so that the validation for funding percentage
  --                            to be 100% doesn't take place. Bug# 3360665.
  -- smaddali                   modified procedure enrp_val_sca_comm For Bug 3853476
  -- amuthu      21-NOV-2004    Mofied the  enrp_val_sca_comm  as part of Program Transfer Build.
  --                            add logic to check if the commencement date is earlier than the
  --                            earlier end date of all term calendar in which there is an
  --                            an active unit attempt.
  -- bdeviset  22-Dec-2004   Modifed cursor c_sct and status_date is used instead of transfer_dt
  --                         in  enrp_val_sca_dr,enrp_val_sca_discont as part Bug#4083015.
  -- ctyagi    30-Aug-2005      Added function handle_rederive_prog_att as a part of EN319 Build
  --ckasu      02-May-2006     Modified as a part of bug#5191592
  -- bdeviset  22-Aug-2006      Bug# 5507279.In Procedure admp_val_ca_comm_val Made the error message
  --                            IGS_RE_COMEN_DT_GE_ADM_ST_DT to warning.
  -------------------------------------------------------------------------------------------
  --msrinivi 27 Aug,2001 Bug 1956374 Removed duplicate func finp_val_fc_closed
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed function ENRP_VAL_SCA_TRNSFR
  --

  FUNCTION enrf_val_sua_term_sca_comm(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_commencement_dt IN DATE,
  p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  -- Validate candidature proposed commencement date.
  FUNCTION admp_val_ca_comm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_min_submission_dt IN DATE ,
  p_parent IN VARCHAR2 ,
  p_ca_sequence_number IN OUT NOCOPY NUMBER ,
  p_candidature_exists_ind OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        -- admp_val_ca_comm
        -- This module validates IGS_AD_PS_APPL_INST.prpsd_commencement_dt
        -- in the context of research candidature.
  DECLARE
        cst_sca         CONSTANT VARCHAR2(10) := 'SCA';
        cst_acai        CONSTANT VARCHAR2(10) := 'ACAI';
        cst_ca          CONSTANT VARCHAR2(10) := 'CA';
        cst_research    CONSTANT VARCHAR2(10) := 'RESEARCH';
        cst_offer               CONSTANT VARCHAR2(10) := 'OFFER';
        cst_cond_offer  CONSTANT VARCHAR2(10) := 'COND-OFFER';
        v_message_name   varchar2(30) ;
        v_ca_sequence_number    IGS_RE_CANDIDATURE.sequence_number%TYPE;
        v_min_submission_dt     IGS_RE_CANDIDATURE.min_submission_dt%TYPE;
        v_s_adm_outcome_status  IGS_AD_PS_APPL_INST.adm_outcome_status%TYPE;
        CURSOR c_ca IS
                SELECT  ca.sequence_number,
                        ca.min_submission_dt
                FROM    IGS_RE_CANDIDATURE      ca
                WHERE   ca.person_id    = p_person_id AND (
                        (p_parent               = cst_SCA AND
                        ca.sca_course_cd        = p_course_cd) OR
                        (p_parent                       = cst_ACAI and
                        ca.acai_admission_appl_number   = p_acai_admission_appl_number AND
                        ca.acai_nominated_course_cd     = p_acai_nominated_course_cd AND
                        ca.acai_sequence_number         = p_acai_sequence_number));
        v_cty_res_typ_ind       IGS_PS_TYPE.research_type_ind%TYPE;
        CURSOR c_crv_cty IS
                SELECT  cty.research_type_ind
                FROM    IGS_PS_VER      crv,
                        IGS_PS_TYPE     cty
                WHERE   crv.course_cd           = p_course_cd AND
                        crv.version_number      = p_crv_version_number AND
                        crv.course_type         = cty.course_type;
        v_aa_apcs_exists        VARCHAR2(1);
        CURSOR c_aa_apcs IS
                SELECT  'x'
                FROM    IGS_AD_APPL             aa,
                        IGS_AD_PRCS_CAT_STEP    apcs
                WHERE   aa.person_id                    = p_person_id AND
                        aa.admission_appl_number        = p_acai_admission_appl_number AND
                        aa.admission_cat                = apcs.admission_cat AND
                        aa.s_admission_process_type     = apcs.s_admission_process_type AND
                        apcs.s_admission_step_type      = cst_research AND
                        apcs.mandatory_step_ind         = 'Y' AND
                        apcs.step_group_type <> 'TRACK'; --2402377
  BEGIN
        -- Set the defaults
        p_message_name := null;
        p_candidature_exists_ind := 'Y';
        IF p_parent IN(cst_sca,cst_acai) THEN
                OPEN c_ca;
                FETCH c_ca INTO v_ca_sequence_number,
                                v_min_submission_dt;
                IF c_ca%NOTFOUND THEN
                        CLOSE c_ca;
                        p_candidature_exists_ind := 'N';
                        RETURN TRUE;
                END IF;
                CLOSE c_ca;
                p_ca_sequence_number := v_ca_sequence_number;
        ELSE --p_parent N ...
                v_min_submission_dt := p_min_submission_dt;
                v_ca_sequence_number := p_ca_sequence_number;
        END IF; -- p_parent IN ...
        --Validate commencement date against minimum submission date
        IF p_commencement_dt >= v_min_submission_dt THEN
                p_message_name := 'IGS_RE_COMEN_DT_CANT_GE_SUBDT';
                RETURN FALSE;
        END IF;
        IF v_ca_sequence_number IS NOT NULL THEN
                -- Get system admission outcome status
                IF p_adm_outcome_status IS NULL THEN
                        v_s_adm_outcome_status := NULL;
                ELSE
                        v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS(
                                p_adm_outcome_status);
                END IF;
                IF p_parent = 'SCA' OR
                        (v_s_adm_outcome_status IS NOT NULL AND
                         v_s_adm_outcome_status IN (cst_offer,cst_cond_offer)) THEN
                        -- Validate that at least one research principal supervisor
                        --      exists on this date
                        -- If candidature is required by the course type
                        --       or admission course application offer
                        OPEN c_crv_cty;
                        FETCH c_crv_cty INTO v_cty_res_typ_ind;
                        IF c_crv_cty%NOTFOUND THEN
                                CLOSE c_crv_cty;
                                RETURN TRUE;
                        END IF;
                        CLOSE c_crv_cty;
                        IF v_cty_res_typ_ind = 'N' THEN
                                IF p_acai_admission_appl_number IS NOT NULL THEN
                                        OPEN c_aa_apcs;
                                        FETCH c_aa_apcs INTO v_aa_apcs_exists;
                                        IF c_aa_apcs%NOTFOUND THEN
                                                CLOSE c_aa_apcs;
                                                RETURN TRUE;
                                        END IF;
                                        CLOSE c_aa_apcs;
                                ELSE
                                        --Supervisor validation not required
                                        RETURN TRUE;
                                END IF;
                        END IF; -- v_cty_res_type_ind
                        IF IGS_RE_VAL_RSUP.resp_val_rsup_princ(
                                                p_person_id,
                                                v_ca_sequence_number,
                                                p_commencement_dt,
                                                p_commencement_dt,
                                                p_parent,
                                                v_message_name) = FALSE THEN
                                        p_message_name := v_message_name;
                                        RETURN FALSE;
                        END IF;
                END IF;
        END IF;-- v_ca_sequence_number
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_ca%ISOPEN THEN
                        CLOSE c_ca;
                END IF;
                IF c_crv_cty%ISOPEN THEN
                        CLOSE c_crv_cty;
                END IF;
                IF c_aa_apcs%ISOPEN THEN
                        CLOSE c_aa_apcs;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.admp_val_ca_comm');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END admp_val_ca_comm;
  --
  -- Validate candidature proposed commencement date value.
  FUNCTION admp_val_ca_comm_val(
  p_person_id IN NUMBER ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_course_start_dt IN DATE ,
  p_prpsd_commencement_dt IN DATE ,
  p_parent IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        -- admp_val_ca_comm_val
        -- This modules validates IGS_AD_PS_APPL_INST.prpsd_commencement_dt.
        -- Validations are:
        -- * Prpsd_commencement_dt must be greater than the earlier of the course
        --      start date or the admission academic period earliest research start date.
        -- * Warn if the Prpsd_commencement_dt is prior to passed census dates for
        --      the admission academic period.
  DECLARE
        cst_ca          CONSTANT        VARCHAR2(10):='CA';
        cst_teaching    CONSTANT        IGS_CA_TYPE.s_cal_cat%TYPE := 'TEACHING';
        v_course_start_dt               IGS_AD_PS_APPL_INST.prpsd_commencement_dt%TYPE;
        v_adm_cal_type                  IGS_AD_PS_APPL_INST_APLINST_V.adm_cal_type%TYPE;
        v_adm_ci_sequence_number        IGS_AD_PS_APPL_INST_APLINST_V.adm_ci_sequence_number%TYPE;
        CURSOR c_acaiv IS
                SELECT  acaiv.adm_cal_type,
                        acaiv.adm_ci_sequence_number
                FROM    IGS_AD_PS_APPL_INST_APLINST_V           acaiv
                WHERE   acaiv.person_id                 = p_person_id AND
                        acaiv.admission_appl_number     = p_acai_admission_appl_number AND
                        acaiv.nominated_course_cd       = p_acai_nominated_course_cd AND
                        acaiv.sequence_number           = p_acai_sequence_number;
        v_research_start_dt     IGS_CA_DA_INST_V.alias_val%TYPE;
        v_cal_type              IGS_CA_DA_INST_V.cal_type%TYPE;
        v_ci_sequence_number    IGS_CA_DA_INST_V.ci_sequence_number%TYPE;
        CURSOR c_cir_cat_daiv_srcc IS
                SELECT  daiv.alias_val,
                        daiv.cal_type,
                        daiv.ci_sequence_number
                FROM    IGS_CA_INST_REL cir,
                        IGS_CA_TYPE                     cat,
                        IGS_CA_DA_INST_V                daiv,
                        IGS_RE_S_RES_CAL_CON                    srcc
                WHERE   cir.sub_cal_type                = v_adm_cal_type AND
                        cir.sub_ci_sequence_number      = v_adm_ci_sequence_number AND
                        cir.sup_cal_type                = cat.cal_type AND
                        cat.s_cal_cat                   = cst_teaching AND
                        cir.sup_cal_type                = daiv.cal_type AND
                        cir.sup_ci_sequence_number      = daiv.ci_sequence_number AND
                        daiv.dt_alias                   = srcc.effective_strt_dt_alias AND
                        srcc.s_control_num              = 1
                ORDER BY daiv.alias_val ASC;
        v_ccds_exists           VARCHAR2(1);
        CURSOR c_cir_cat_daiv_sgcc IS
                SELECT 'x'
                FROM    IGS_CA_INST_REL cir,
                        IGS_CA_TYPE                     cat,
                        IGS_CA_DA_INST_V                daiv,
                        IGS_GE_S_GEN_CAL_CON                    sgcc
                WHERE   cir.sub_cal_type                = v_adm_cal_type AND
                        cir.sub_ci_sequence_number      = v_adm_ci_sequence_number AND
                        cir.sup_cal_type                = cat.cal_type AND
                        cat.s_cal_cat                   = cst_teaching AND
                        cir.sup_cal_type                = daiv.cal_type AND
                        cir.sup_ci_sequence_number      = daiv.ci_sequence_number AND
                        daiv.dt_alias                   = sgcc.census_dt_alias AND
                        sgcc.s_control_num              = 1 AND
                        daiv.alias_val                  < v_course_start_dt AND
                        daiv.alias_val                  > p_prpsd_commencement_dt;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        IF p_prpsd_commencement_dt IS NOT NULL THEN
                --Validate commencment_dt value
                IF p_parent = cst_ca THEN
                        -- get admission period details
                        OPEN c_acaiv;
                        FETCH c_acaiv INTO
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number;
                        IF c_acaiv%NOTFOUND THEN
                                CLOSE c_acaiv;
                                RETURN TRUE;
                        END IF;
                        CLOSE c_acaiv;
                ELSE -- p_parent
                        v_adm_cal_type := p_adm_cal_type;
                        v_adm_ci_sequence_number := p_adm_ci_sequence_number;
                END IF;--p_parent
                -- validate against course start date
                IF p_course_start_dt IS NULL THEN
                        v_course_start_dt := IGS_AD_GEN_005.ADMP_GET_CRV_STRT_DT(
                                                                v_adm_cal_type,
                                                                v_adm_ci_sequence_number);
                ELSE
                        v_course_start_dt := p_course_start_dt;
                END IF;
                IF p_prpsd_commencement_dt >= v_course_start_dt THEN
                        --proposed commencement date is valid
                        RETURN TRUE;
                END IF;
                IF v_course_start_dt IS NULL THEN
                        v_course_start_dt := TRUNC(SYSDATE);
                END IF;
                --Validate against earlist research start date
                OPEN c_cir_cat_daiv_srcc;
                FETCH c_cir_cat_daiv_srcc INTO  v_research_start_dt,
                                                v_cal_type,
                                                v_ci_sequence_number;
                IF (c_cir_cat_daiv_srcc%NOTFOUND) OR
                    (c_cir_cat_daiv_srcc%FOUND AND
                    v_research_start_dt IS NULL ) THEN
                        CLOSE c_cir_cat_daiv_srcc;
                        IF p_prpsd_commencement_dt < v_course_start_dt THEN
                                p_message_name := 'IGS_RE_COMEN_DT_GE_ADM_ST_DT';
                                RETURN TRUE;
                        END IF;
                ELSE -- %NOTFOUND
                        -- For the first record only
                        CLOSE c_cir_cat_daiv_srcc;
                        IF p_prpsd_commencement_dt < v_research_start_dt THEN
                                p_message_name := 'IGS_RE_COMEN_DT_CANT_LT_TEACH';
                                RETURN FALSE;
                        END IF;
                END IF; -- %NOTFOUND
                --Warn if commencement date prior to a passed census date
                OPEN c_cir_cat_daiv_sgcc;
                FETCH c_cir_cat_daiv_sgcc INTO v_ccds_exists;
                IF c_cir_cat_daiv_sgcc%FOUND THEN
                        CLOSE c_cir_cat_daiv_sgcc;
                        p_message_name := 'IGS_AD_COMDT_PRIOR_CENSUSDT';
                        RETURN TRUE;
                END IF;
                CLOSE c_cir_cat_daiv_sgcc;
        END IF;  -- p_prpsd_commencement_dt
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_acaiv%ISOPEN THEN
                        CLOSE c_acaiv;
                END IF;
                IF c_cir_cat_daiv_srcc%ISOPEN THEN
                        CLOSE c_cir_cat_daiv_srcc;
                END IF;
                IF c_cir_cat_daiv_sgcc%ISOPEN THEN
                        CLOSE c_cir_cat_daiv_sgcc;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.admp_val_ca_comm_val');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END admp_val_ca_comm_val;
  --
  -- Validate candidature attendance percentage
  FUNCTION resp_val_ca_att_perc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_percentage IN NUMBER ,
  p_candidature_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        -- resp_val_ca_att_perc
        -- This module validates IGS_RE_CANDIDATURE.attendance_percentage and
        -- IGS_EN_STDNT_PS_ATT.attendance_type.
        -- Validations are:
        -- * The load of the research at the nominated attendance percentage must be
        --   within the upper and lower load ranges for the attendance type in the
        --   load calendar targetted. This is a warning only.
        -- Assumption:
        -- * The student is only ever enrolled in one research unit attempt at any
        --   point in time. The calendar instance of the unit attempt is only linked
        --   to one load calendar instance.
  DECLARE
        cst_academic    CONSTANT        VARCHAR2(10) := 'ACADEMIC';
        v_attendance_percentage         IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
        v_attendance_type               IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
        v_student_confirmed_ind         IGS_EN_STDNT_PS_ATT.student_confirmed_ind%TYPE;
        v_load_cal_type                 IGS_CA_INST_REL.sup_cal_type%TYPE;
        v_load_ci_sequence_number
                                        IGS_CA_INST_REL.sup_ci_sequence_number%TYPE;
        v_acad_cal_type                 IGS_CA_INST_REL.sup_cal_type%TYPE;
        v_acad_ci_sequence_number
                                        IGS_CA_INST_REL.sup_ci_sequence_number%TYPE;
        v_teach_cal_type                IGS_EN_SU_ATTEMPT.cal_type%TYPE;
        v_research_eftsu                NUMBER;
        v_lower_enr_load_range          IGS_EN_ATD_TYPE_LOAD.lower_enr_load_range%TYPE;
        v_upper_enr_load_range          IGS_EN_ATD_TYPE_LOAD.upper_enr_load_range%TYPE;
        CURSOR c_sca IS
                SELECT  sca.attendance_type,
                        sca.student_confirmed_ind
                FROM    IGS_EN_STDNT_PS_ATT             sca
                WHERE   sca.person_id                   = p_person_id AND
                        sca.course_cd                   = p_course_cd;
        CURSOR c_ca IS
                SELECT  ca.attendance_percentage
                FROM    IGS_RE_CANDIDATURE                      ca
                WHERE   ca.person_id                    = p_person_id AND
                        ca.sca_course_cd                = p_course_cd;
        CURSOR c_cir_ci_cat_sua_uv IS
                SELECT  cir.sup_cal_type,
                        cir.sup_ci_sequence_number,
                        sua.cal_type
                FROM    IGS_EN_SU_ATTEMPT               sua,
                        IGS_CA_INST_REL cir,
                        IGS_CA_INST                     ci,
                        IGS_CA_TYPE                     cat,
                        IGS_PS_UNIT_VER                 uv
                WHERE   sua.person_id                   = p_person_id AND
                        sua.course_cd                   = p_course_cd AND
                        sua.unit_cd                     = uv.unit_cd AND
                        sua.version_number              = uv.version_number AND
                        uv.research_unit_ind            = 'Y' AND
                        sua.cal_type                    = ci.cal_type AND
                        sua.ci_sequence_number          = ci.sequence_number AND
                        ci.start_dt                     <= TRUNC(SYSDATE) AND
                        ci.end_dt                       > TRUNC(SYSDATE) AND
                        sua.cal_type                    = cir.sub_cal_type AND
                        sua.ci_sequence_number          = cir.sub_ci_sequence_number AND
                        cir.sup_cal_type                = cat.cal_type AND
                        cat.s_cal_cat                   = cst_academic;
        CURSOR c_cir (
                cp_acad_cal_type                IGS_CA_INST_REL.sup_cal_type%TYPE,
                cp_acad_ci_sequence_number
                                                IGS_CA_INST_REL.sup_ci_sequence_number%TYPE,
                cp_teach_cal_type               IGS_EN_SU_ATTEMPT.cal_type%TYPE) IS
                SELECT  dla.cal_type,
                        dla.ci_sequence_number
                FROM    IGS_CA_INST_REL cir,
                        IGS_ST_DFT_LOAD_APPO            dla
                WHERE   cir.sup_cal_type                = cp_acad_cal_type AND
                        cir.sup_ci_sequence_number      = cp_acad_ci_sequence_number AND
                        cir.sub_cal_type                = dla.cal_type AND
                        cir.sub_ci_sequence_number      = dla.ci_sequence_number AND
                        dla.teach_cal_type              = cp_teach_cal_type AND
                        dla.percentage                  = 100;
        CURSOR c_atl (
                cp_load_cal_type        IGS_CA_INST_REL.sup_cal_type%TYPE,
                cp_attendance_type      IGS_EN_STDNT_PS_ATT.attendance_type%TYPE) IS
                SELECT  atl.lower_enr_load_range,
                        atl.upper_enr_load_range
                FROM    IGS_EN_ATD_TYPE_LOAD            atl
                WHERE   atl.cal_type                    = cp_load_cal_type AND
                        atl.attendance_type             = cp_attendance_type;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        IF p_course_cd IS NOT NULL THEN
                IF p_candidature_ind = 'Y' THEN
                        v_attendance_percentage := p_attendance_percentage;
                        IF p_attendance_type IS NULL OR
                                        p_student_confirmed_ind IS NULL THEN
                                OPEN c_sca;
                                FETCH c_sca INTO
                                                v_attendance_type,
                                                v_student_confirmed_ind;
                                IF c_sca%NOTFOUND OR
                                                v_student_confirmed_ind = 'N' THEN
                                        -- Check is not required for unconfirmed course attempt or
                                        -- candidature that is still in application stage
                                        CLOSE c_sca;
                                        RETURN TRUE;
                                END IF;
                                CLOSE c_sca;
                        ELSE
                                v_attendance_type := p_attendance_type;
                                IF p_student_confirmed_ind = 'N' THEN
                                        -- Check is not required for unconfirmed course attempt
                                        RETURN TRUE;
                                END IF;
                        END IF;
                ELSE
                        IF p_student_confirmed_ind = 'N' THEN
                                -- Check is not required for unconfirmed course attempt
                                RETURN TRUE;
                        END IF;
                        v_attendance_type := p_attendance_type;
                        IF p_attendance_percentage IS NULL THEN
                                OPEN c_ca;
                                FETCH c_ca INTO v_attendance_percentage;
                                IF c_ca%NOTFOUND THEN
                                        -- Check is only for course attempt with research candidature
                                        CLOSE c_ca;
                                        RETURN TRUE;
                                ELSE -- RecordFOUND
                                        CLOSE c_ca;
                                        -- Check does not apply if attendance percentage is defaulting
                                        --      from IGS_EN_ATD_TYPE
                                        IF v_attendance_percentage IS NULL THEN
                                                RETURN TRUE;
                                        END IF;
                                END IF;
                        ELSE
                                v_attendance_percentage := p_attendance_percentage;
                        END IF;
                END IF;
                -- Get academic calendar of enrolled research unit attempt
                OPEN c_cir_ci_cat_sua_uv;
                FETCH c_cir_ci_cat_sua_uv INTO
                                                v_acad_cal_type,
                                                v_acad_ci_sequence_number,
                                                v_teach_cal_type;
                IF c_cir_ci_cat_sua_uv%NOTFOUND THEN
                        -- Cannot determine load
                        CLOSE c_cir_ci_cat_sua_uv;
                        RETURN TRUE;
                END IF;
                CLOSE c_cir_ci_cat_sua_uv;
                -- Get load calendar of academic calendar
                OPEN c_cir (
                                v_acad_cal_type,
                                v_acad_ci_sequence_number,
                                v_teach_cal_type);
                FETCH c_cir INTO
                                v_load_cal_type,
                                v_load_ci_sequence_number;
                IF c_cir%NOTFOUND THEN
                        -- Something is wrong, handled elsewhere
                        CLOSE c_cir;
                        RETURN TRUE;
                END IF;
                CLOSE c_cir;
                -- Determine research load
                v_research_eftsu := IGS_RE_GEN_001.RESP_CLC_LOAD_EFTSU (
                                                        v_acad_cal_type,
                                                        v_acad_ci_sequence_number,
                                                        v_load_cal_type,
                                                        v_load_ci_sequence_number) * (v_attendance_percentage/100);
                -- Get lower and upper load ranges for attendance type load
                OPEN c_atl(
                                v_load_cal_type,
                                v_attendance_type);
                FETCH c_atl INTO
                                v_lower_enr_load_range,
                                v_upper_enr_load_range;
                IF c_atl%NOTFOUND THEN
                        -- Something is wrong, handled elsewhere
                        CLOSE c_atl;
                        RETURN TRUE;
                END IF;
                CLOSE c_atl;
                IF v_research_eftsu > v_upper_enr_load_range OR
                                v_research_eftsu < v_lower_enr_load_range THEN
                        -- Research candidature attendance percentage in not within the
                        -- current attendance type load range
                        IF p_candidature_ind = 'Y' THEN
                                p_message_name := 'IGS_RE_CAND_%_INVALID';
                        ELSE
                                p_message_name := 'IGS_RE_CAND_EXISTS_WITH_ATT_%';
                        END IF;
                        RETURN TRUE;
                END IF;
        END IF;
        RETURN TRUE ;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                IF c_ca%ISOPEN THEN
                        CLOSE c_ca;
                END IF;
                IF c_cir_ci_cat_sua_uv%ISOPEN THEN
                        CLOSE c_cir_ci_cat_sua_uv;
                END IF;
                IF c_cir%ISOPEN THEN
                        CLOSE c_cir;
                END IF;
                IF c_atl%ISOPEN THEN
                        CLOSE c_atl;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.resp_val_ca_att_perc');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

  END resp_val_ca_att_perc;
  --
  -- Validate that conditional offer is valid for course enrolment.
  FUNCTION enrp_val_acai_cndtnl(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_cndtnl_off_must_be_stsfd_ind IN VARCHAR2,
  p_s_adm_cndtnl_offer_status OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        -- enrp_val_acai_cndtnl
        -- This module determines if the admission course application conditional
        -- offer can be accepted. The following is checked:
        -- ? Return TRUE if either the conditional offer has been satisfied or waived,
        --   or the conditional offer is still pending, but it is not a requirement
        --   that the condition be satisfied for acceptance ie.
        --      IGS_AD_PS_APPL_INST.cndtnl_offer_must_be_stsfd_ind is 'N'.
        -- ? Return FALSE if conditional offer is unsatisfactory, or the conditional
        --   offer is still pending and it is a requirement that the condition be
        --   satisfied for acceptance ie.
        --      IGS_AD_PS_APPL_INST.cndtnl_offer_must_be_stsfd_ind is 'Y'.
  DECLARE
        cst_not_applic  CONSTANT VARCHAR2(10) := 'NOT-APPLIC';
        cst_unsatisfac  CONSTANT VARCHAR2(10) := 'UNSATISFAC';
        cst_satisfied   CONSTANT VARCHAR2(9) := 'SATISFIED';
        cst_waived      CONSTANT VARCHAR2(6) := 'WAIVED';
        cst_pending     CONSTANT VARCHAR2(7) := 'PENDING';
        v_s_adm_cndtnl_offer_status
                        IGS_AD_PS_APPL_INST.adm_cndtnl_offer_status%TYPE;
  BEGIN
        -- Determine system conditional offer status
        v_s_adm_cndtnl_offer_status := IGS_AD_GEN_007.ADMP_GET_SACOS(
                                                p_adm_cndtnl_offer_status);
        p_s_adm_cndtnl_offer_status := v_s_adm_cndtnl_offer_status;
        IF v_s_adm_cndtnl_offer_status = cst_not_applic THEN
                -- Conditional offer does not apply
                p_message_name := null;
                RETURN TRUE;
        END IF;
        IF v_s_adm_cndtnl_offer_status = cst_unsatisfac THEN
                -- Unsatisfactory conditional offers cannot be accepted
                p_message_name := 'IGS_EN_STUD_PRGATT_NOTCONF';
                RETURN FALSE;
        END IF;
        IF v_s_adm_cndtnl_offer_status IN (
                                cst_satisfied,
                                cst_waived) THEN
                -- Satisfactory or waived conditional offers can be accepted
                p_message_name := null;
                RETURN TRUE;
        END IF;
        IF v_s_adm_cndtnl_offer_status = cst_pending THEN
                -- Pending can only be accepted if it is not a requirement that
                -- The conditional offer be satisfied
                IF p_cndtnl_off_must_be_stsfd_ind = 'N' THEN
                        p_message_name := null;
                        RETURN TRUE;
                ELSE
                        p_message_name := 'IGS_EN_STUD_PRG_NOTCONFIRM';
                        RETURN FALSE;
                END IF;
        END IF;
        p_message_name := null;
        RETURN TRUE;
  END;
/*
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_acai_cndtnl');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
*/
  END enrp_val_acai_cndtnl;
  --
  -- Validate that research detail is valid for enrolment.
  FUNCTION enrp_val_res_elgbl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        -- enrp_val_res_elgbl
        -- This module determines if research candidature details are required and
        -- completed for the person to be eligible to enrol in the nominated course.
        -- Validations are:
        -- . The course attempted is defined as a research course and no research
        --   candidature details exist, or the research candidature is incomplete.
  DECLARE
        v_cty_research_type_ind IGS_PS_TYPE.research_type_ind%TYPE;
        v_message_name          varchar2(30);
        CURSOR c_cty IS
                SELECT  cty.research_type_ind
                FROM    IGS_PS_VER crv,
                        IGS_PS_TYPE cty
                WHERE   crv.course_cd           = p_course_cd AND
                        crv.version_number      = p_crv_version_number AND
                        crv.course_type         = cty.course_type;
  BEGIN
        -- Set up the default message number
        p_message_name := null;
        -- Determine if the course attempt is a research course
        OPEN c_cty;
        FETCH c_cty INTO v_cty_research_type_ind;
        IF c_cty%NOTFOUND THEN
                -- Problems with course attempt, handled elsewhere
                CLOSE c_cty;
                RETURN TRUE;
        END IF;
        CLOSE c_cty;
        IF v_cty_research_type_ind = 'N' THEN
                -- course attempt is not a research course, validation is not required
                RETURN TRUE;
        END IF;
        -- Validate research candidature detail
        IF NOT resp_val_ca_dtl_comp(
                                        p_person_id,
                                        p_course_cd,
                                        NULL,
                                        NULL,
                                        NULL,
                                        'SCA',
                                        v_message_name) THEN
                IF (v_message_name = 'IGS_RE_CAND_DETAILS_INCOMPLET') THEN
                        -- Customise incomplete check message for enrolments
                        p_message_name := 'IGS_EN_PRG_ATT_DFN';
                ELSE
                        p_message_name := v_message_name;
                END IF;
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_cty %ISOPEN THEN
                        CLOSE c_cty;
                END IF;
                RAISE;
  END;
/*
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_res_elgbl');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
*/
  END enrp_val_res_elgbl;
  --
  -- Validate if research candidature details are complete.
  FUNCTION resp_val_ca_dtl_comp(
  p_person_id IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_parent IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        -- resp_val_ca_dtl_comp
  DECLARE
        cst_acai                        CONSTANT VARCHAR2(4) := 'ACAI';
        v_min_submission_dt             IGS_RE_CANDIDATURE.min_submission_dt%TYPE := NULL;
        v_max_submission_dt             IGS_RE_CANDIDATURE.max_submission_dt%TYPE := NULL;
        v_supervision_start_dt          DATE;
        -- Check for the existence of research details.
        CURSOR c_ca IS
                SELECT  ca.sequence_number,
                        ca.attendance_percentage,
                        ca.max_submission_dt,
                        ca.min_submission_dt,
                        ca.research_topic
                FROM    IGS_RE_CANDIDATURE ca
                WHERE   ca.person_id                    = p_person_id AND
                        ((ca.acai_admission_appl_number = p_acai_admission_appl_number AND
                        ca.acai_nominated_course_cd =p_acai_nominated_course_cd AND
                        ca.acai_sequence_number         = p_acai_sequence_number) OR
                        (p_parent                       <> cst_acai AND
                        ca.sca_course_cd                = p_sca_course_cd)) AND
                        ca.research_topic               IS NOT NULL;
                v_ca_rec                        c_ca%ROWTYPE;
  BEGIN
        -- if research details are found then ensure that the minimum submission date
        -- has a value (actual or derived).
        OPEN c_ca;
        FETCH c_ca INTO v_ca_rec;
        IF c_ca%FOUND THEN
                IF v_ca_rec.min_submission_dt IS NOT NULL THEN
                        v_min_submission_dt := v_ca_rec.min_submission_dt;
                ELSE
                        v_min_submission_dt := IGS_RE_GEN_001.RESP_CLC_MIN_SBMSN (
                                                        p_person_id,
                                                        v_ca_rec.sequence_number,
                                                        p_sca_course_cd,
                                                        p_acai_admission_appl_number,
                                                        p_acai_nominated_course_cd,
                                                        p_acai_sequence_number,
                                                        v_ca_rec.attendance_percentage,
                                                        NULL); -- commencement date
                        IF v_min_submission_dt IS NULL THEN
                                p_message_name := 'IGS_RE_MIN_SUBMISSION_REQR';
                                RETURN FALSE;
                        END IF;
                END IF;
                -- If research details are found and the minimum submission date has a value
                -- then ensure that
                -- the maximum submission date has a value (actual or derived).
                IF v_ca_rec.max_submission_dt IS NOT NULL THEN
                        v_max_submission_dt := v_ca_rec.max_submission_dt;
                ELSE
                        v_max_submission_dt := IGS_RE_GEN_001.RESP_CLC_MAX_SBMSN (
                                                p_person_id,
                                                v_ca_rec.sequence_number,
                                                p_sca_course_cd,
                                                p_acai_admission_appl_number,
                                                p_acai_nominated_course_cd,
                                                p_acai_sequence_number,
                                                v_ca_rec.attendance_percentage,
                                                NULL); -- commencement date
                        IF v_max_submission_dt IS NULL THEN
                                p_message_name := 'IGS_RE_MAX_SUBMSIIION_REQR';
                                RETURN FALSE;
                        END IF;
                END IF;
                -- IF research details are found and the minimum and maximum
                -- submission dates have a value then ensure that the research
                -- supervisors are valid.
                IF NOT(IGS_RE_VAL_RSUP.resp_val_rsup_perc(
                                        p_person_id,
                                        v_ca_rec.sequence_number,
                                        p_sca_course_cd,
                                        p_acai_admission_appl_number,
                                        p_acai_nominated_course_cd,
                                        p_acai_sequence_number,
                                        'Y',    -- validate supervision percentage
                                        'N',    -- do not validate funding percentage
                                        p_parent,
                                        v_supervision_start_dt,
                                        p_message_name)) THEN
                                RETURN FALSE;
                END IF;
                IF NOT(IGS_RE_VAL_RSUP.resp_val_rsup_princ(
                                        p_person_id,
                                        v_ca_rec.sequence_number,
                                        v_supervision_start_dt,
                                        v_supervision_start_dt,
                                        p_parent,
                                        p_message_name)) THEN
                                RETURN FALSE;
                ELSE
                        p_message_name := null;
                        RETURN TRUE;
                END IF;
        ELSE
                CLOSE c_ca;
        END IF;
        -- If this point is reached, then the research candidature details are
        -- incomplete.
        p_message_name := 'IGS_RE_CAND_DETAILS_INCOMPLET';
        RETURN FALSE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_ca %ISOPEN THEN
                        CLOSE c_ca;
                END IF;
        RAISE;
  END;
/*
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                        FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.resp_val_ca_dtl_comp');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
*/
  END resp_val_ca_dtl_comp;
  --
  -- Routine to clear records saved in a PL/SQL RECORD from a prior commit.
  --
  -- To validate student course attempt enrolled units satisfy rules.
  FUNCTION enrp_val_unit_rule(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_rule_check_ind IN VARCHAR2,
  p_unit_cd OUT NOCOPY VARCHAR2 ,
  p_uv_version_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_message_text OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN        -- enrp_val_unit_rule
        -- This module validates that the IGS_EN_STDNT_PS_ATT enrolled units satisfy
        -- unit rules. This routine is to be called when all changes have been posted.
  DECLARE
        cst_enrolled    CONSTANT
                                        IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'ENROLLED';
        v_message_text                  VARCHAR2(2000);
        l_failed_rule  igs_en_su_attempt_all.failed_unit_rule%TYPE;
        CURSOR c_sua IS
                SELECT  sua.unit_cd,
                        sua.version_number,
                        sua.cal_type,
                        sua.ci_sequence_number,
                        sua.rule_waived_dt,
                        sua.uoo_id
                FROM    IGS_EN_SU_ATTEMPT       sua
                WHERE   sua.person_id = p_person_id AND
                        sua.course_cd = p_course_cd AND
                        sua.unit_attempt_status = cst_enrolled;
  BEGIN
        IF (p_rule_check_ind = 'Y') THEN
                -- Validate all enrolled student unit attempts for the student course attempt
                FOR v_sua_rec IN c_sua LOOP
                        IF v_sua_rec.rule_waived_dt IS  NULL THEN
                                -- Determine if unit does not satisfy IGS_RU_RULE checks if
                                -- rules checking has not benn waived for the student unit attempt
                                IF (IGS_RU_VAL_UNIT_RULE.rulp_val_enrol_unit(
                                                                p_person_id,
                                                                p_course_cd,
                                                                NULL,
                                                                v_sua_rec.unit_cd,
                                                                v_sua_rec.version_number,
                                                                v_sua_rec.cal_type,
                                                                v_sua_rec.ci_sequence_number,
                                                                v_message_text,
                                                                v_sua_rec.uoo_id,
                                                                l_failed_rule) = FALSE) THEN
                                        p_message_name := null;
                                        p_message_text := v_message_text;
                                        p_unit_cd := v_sua_rec.unit_cd;
                                        p_uv_version_number := v_sua_rec.version_number;
                                        RETURN FALSE;
                                END IF;
                        END IF;
                END LOOP;
        END IF;
        p_message_name := null;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_sua%ISOPEN) THEN
                        CLOSE c_sua;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_unit_rule');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_unit_rule;
  --
  -- To validate sca unit calendars against academic calendar type
  FUNCTION ENRP_VAL_SCA_CAT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
   BEGIN        -- enrp_val_sca_cat
        -- Validate whether the nominated course attempt has UNCONFIRMED, ENROLLED,
        -- or INVALID unit attempts which aren't linked to an instance of their
        -- enrolled course academic calendar type.
        -- This is the result of a change of course offering option calendar type
        -- where there were units of these statuses.
  DECLARE
        cst_enrolled    CONSTANT        VARCHAR2(10) := 'ENROLLED';
        cst_invalid     CONSTANT        VARCHAR2(10) := 'INVALID';
        cst_unconfirm   CONSTANT        VARCHAR2(10) := 'UNCONFIRM';
        v_alternate_cd                  IGS_CA_INST.alternate_code%TYPE;
        v_acad_cal_type                 IGS_CA_INST.cal_type%TYPE;
        v_acad_ci_sequence_number       IGS_CA_INST.sequence_number%TYPE;
        v_acad_ci_start_dt              IGS_CA_INST.start_dt%TYPE;
        v_acad_ci_end_dt                IGS_CA_INST.end_dt%TYPE;
        v_message_name                  varchar2(30);
        v_unconfirm_flag                BOOLEAN := FALSE;
        v_enrolled_flag                 BOOLEAN := FALSE;
        CURSOR c_sua IS
                SELECT  sua.cal_type,
                        sua.ci_sequence_number,
                        sua.unit_attempt_status
                FROM    IGS_EN_SU_ATTEMPT sua
                WHERE   sua.person_id   = p_person_id AND
                        sua.course_cd   = p_course_cd AND
                        sua.unit_attempt_status IN (
                                                cst_invalid,
                                                cst_enrolled,
                                                cst_unconfirm);
  BEGIN
        p_message_name := null;
        FOR v_sua_record IN c_sua LOOP
                v_alternate_cd := IGS_EN_GEN_002.ENRP_GET_ACAD_ALT_CD(
                                                v_sua_record.cal_type,
                                                v_sua_record.ci_sequence_number,
                                                v_acad_cal_type,
                                                v_acad_ci_sequence_number,
                                                v_acad_ci_start_dt,
                                                v_acad_ci_end_dt,
                                                v_message_name);
                IF v_acad_cal_type <> p_cal_type THEN
                        IF v_sua_record.unit_attempt_status = cst_unconfirm THEN
                                v_unconfirm_flag := TRUE;
                        ELSE
                                v_enrolled_flag := TRUE;
                        END IF;
                END IF;
                IF v_unconfirm_flag = TRUE AND
                                v_enrolled_flag = TRUE THEN
                        -- Exit loop - no point continuing processing.
                        EXIT;
                END IF;
        END LOOP;
        IF v_enrolled_flag = TRUE THEN
                p_message_name := 'IGS_EN_ENR_UNITATT_NOTLINKED';
        ELSIF v_unconfirm_flag = TRUE THEN
                p_message_name := 'IGS_EN_UNCONF_UA_EXISTS';
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_sua%ISOPEN) THEN
                        CLOSE c_sua;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_sca_cat');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sca_cat;
  --
  -- To validate the IGS_EN_STDNT_PS_ATT.lapse_dt
  FUNCTION enrp_val_sca_lapse(
  p_course_attempt_status       IN VARCHAR2 ,
  p_lapse_dt                    IN DATE ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2)
  RETURN boolean  AS
  /*-------------------------------------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : validate the setting of lapse date against other enrolment details
  ||  (mostly within the IGS_EN_STDNT_PS_ATT table).
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        11-11-2002      Modified function logic due to addition of new parameter p_legacy
  ||                                  if p_legacy set to 'Y' then error message should be stacked instead of
  ||                                  returning the function in the normal way else function should behave in
  ||                                  normal way.Legacy Build Bug no: 2661533
  ------------------------------------------------------------------------------------------------------------*/
   BEGIN
   DECLARE
        cst_inactive                    CONSTANT VARCHAR2(10) := 'INACTIVE';
        cst_lapsed                      CONSTANT VARCHAR2(10) := 'LAPSED';
        cst_unconfirm                   CONSTANT VARCHAR2(10) := 'UNCONFIRM';
        cst_completed                   CONSTANT VARCHAR2(10) := 'COMPLETED';
   BEGIN
        p_message_name := null;
        IF (p_lapse_dt IS NULL) THEN
                RETURN TRUE;
        END IF;
        IF p_legacy <> 'Y' THEN
                IF (p_course_attempt_status NOT IN (cst_inactive,cst_lapsed)) THEN
                        p_message_name  := 'IGS_EN_LAPSEDT_SET_INACTIVE';
                        RETURN FALSE;
                END IF;
                IF (p_lapse_dt <> TRUNC(SYSDATE)) THEN
                        p_message_name := 'IGS_EN_LAPSEDT_SET_CURRDT';
                        RETURN FALSE;
                END IF;
        END IF;
        IF p_legacy = 'Y' THEN
            IF p_course_attempt_status  IN (cst_unconfirm,cst_completed) THEN
                       p_message_name := 'IGS_EN_SCA_NO_LP_DT_UNCOMFIRM';
                       fnd_message.set_name('IGS','IGS_EN_SCA_NO_LP_DT_UNCOMFIRM');
                       fnd_msg_pub.add;
            END IF;
        END IF;
        RETURN TRUE ;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_sca_lapse');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END enrp_val_sca_lapse;
  --
  --
  -- To validate acceptance of admission course transfer.
  FUNCTION enrp_val_trnsfr_acpt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        -- enrp_val_trnsfr_acpt
        -- This module validates that acceptance of an admission course transfer
        -- application can only occur when matching IGS_PS_STDNT_TRN details
        -- exist.
        -- This validation routine will be called from ENRF3000, ADMF3240,
        -- IGS_EN_STDNT_PS_ATT and IGS_AD_PS_APPL_INST database triggers,
        -- and the pre-enrolment process.
  DECLARE
        v_s_adm_offer_resp_status       IGS_AD_PS_APPL_INST.adm_offer_resp_status%TYPE;
        v_s_admission_process_type      IGS_AD_APPL.s_admission_process_type%TYPE;
        v_dummy                         VARCHAR2(1);
        CURSOR  c_aa IS
                SELECT  s_admission_process_type
                FROM    IGS_AD_APPL
                WHERE   person_id               = p_person_id AND
                        admission_appl_number   = p_admission_appl_number;
        CURSOR  c_aca_sct IS
                SELECT  'x'
                FROM    IGS_AD_PS_APPL  aca,
                        IGS_PS_STDNT_TRN        sct
                WHERE   aca.person_id                   = p_person_id AND
                        aca.admission_appl_number       = p_admission_appl_number AND
                        aca.nominated_course_cd         = p_nominated_course_cd AND
                        sct.person_id                   = aca.person_id AND
                        sct.course_cd                   = p_course_cd AND
                        sct.transfer_course_cd          = aca.transfer_course_cd;
  BEGIN
        IF p_admission_appl_number IS NULL OR
                        p_nominated_course_cd IS NULL THEN
                -- This is not a IGS_EN_STDNT_PS_ATT inserted as a result of an admission
                -- application
                p_message_name := null;
                RETURN TRUE;
        END IF;
        -- determine system admission offer response status
        IF p_adm_offer_resp_status IS NULL THEN
                v_s_adm_offer_resp_status := NULL;
        ELSE
                v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS(p_adm_offer_resp_status);
        END IF;
        IF p_student_confirmed_ind = 'Y' OR
                        v_s_adm_offer_resp_status = 'ACCEPTED' THEN
                -- determine if the admission_appilication is a course transfer
                OPEN c_aa;
                FETCH c_aa INTO v_s_admission_process_type;
                CLOSE c_aa;
                IF v_s_admission_process_type = 'TRANSFER' THEN
                        -- Determine if student course transfer detail exists
                        -- matching admission course application details
                        OPEN c_aca_sct;
                        FETCH c_aca_sct INTO v_dummy;
                        IF (c_aca_sct%NOTFOUND) THEN
                                IF (p_student_confirmed_ind = 'Y') THEN
                                        -- return_message for confirmation of
                                        -- IGS_EN_STDNT_PS_ATT
                                        p_message_name := 'IGS_EN_STUD_PRG_ATTEMPT';
                                ELSE
                                        -- return message for acceptance of
                                        -- IGS_AD_PS_APPL_INST
                                        p_message_name := 'IGS_EN_APPL_PRG_TRANSFER';
                                END IF;
                                CLOSE c_aca_sct;
                                RETURN FALSE;
                        END IF;
                        CLOSE c_aca_sct;
                END IF;
        END IF;
        p_message_name := null;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_aa%ISOPEN) THEN
                        CLOSE c_aa;
                END IF;
                IF (c_aca_sct%ISOPEN) THEN
                        CLOSE c_aca_sct;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_trnsfr_acpt');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_trnsfr_acpt;
  --
  -- To validate whether a change of course offering option is allowed
  FUNCTION ENRP_VAL_CHGO_ALWD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
  --  Change History :
  --  Who             When            What
  -- stutta        01-NOV-2004  Returning TRUE when program attempt status
  --                            is completed. Enh #3959306
   BEGIN        -- enrp_val_chgo_alwd
        -- Validate that the change of course offering option is allowed.
  DECLARE
        v_ret_val       BOOLEAN := TRUE;
        CURSOR  c_student_course_attempt (
                        cp_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                        cp_course_cd    IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
                SELECT  course_attempt_status,
                        version_number
                FROM
                        IGS_EN_STDNT_PS_ATT
                WHERE
                        person_id = cp_person_id AND
                        course_cd = cp_course_cd;
  BEGIN
        p_message_name := null;
        FOR v_sca_rec IN c_student_course_attempt(p_person_id,  p_course_cd) LOOP
                IF (v_sca_rec.course_attempt_status = 'DISCONTIN') THEN
                        p_message_name := 'IGS_EN_CHG_OPT_NOTALLOW_DISCN';
                        v_ret_val := FALSE;
                ELSIF (v_sca_rec.course_attempt_status = 'LAPSED') THEN
                        p_message_name := 'IGS_EN_CHG_OPT_NOTALLOW_LAPSE';
                        v_ret_val := FALSE;
                ELSIF (v_sca_rec.course_attempt_status = 'DELETED') THEN
                        p_message_name := 'IGS_EN_CHG_OPT_NOTALLOW_DEL';
                        v_ret_val := FALSE;
                ELSIF (v_sca_rec.course_attempt_status = 'COMPLETED') THEN
                        p_message_name := 'IGS_EN_CHG_OPT_NOTALLOW_COMPL';
                        v_ret_val := TRUE;
                END IF;
                IF (v_ret_val = FALSE) THEN
                        EXIT;
                END IF;
        END LOOP;
        RETURN v_ret_val;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_chgo_alwd');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_chgo_alwd;
  --
  -- To validate all sua records against coo cross restrictions
  FUNCTION ENRP_VAL_SUA_COO(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_coo_id IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_message_name1 OUT NOCOPY VARCHAR2,
  p_message_name2 OUT NOCOPY VARCHAR2,
  p_message_name3 OUT NOCOPY VARCHAR2,
  p_load_or_teach_cal_type IN VARCHAR2,
  p_load_or_teach_seq_number IN NUMBER)
  RETURN boolean  AS
   BEGIN
  DECLARE
        -- Need to declare p_mess1 and p_mess2 because an 'IF' statement
        -- cannot be performed on an 'OUT' parameter.
        p_mess1                         varchar2(30);
        p_mess2                         varchar2(30);
        p_mess3                         varchar2(30);
        v_message_name                  varchar2(30);
        v_attendance_types                      VARCHAR2(100);
        CURSOR c_sua (
                cp_person_id            IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_course_cd            IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                cp_cal_type             IGS_EN_SU_ATTEMPT.cal_type%TYPE,
                cp_ci_sequence_number   IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE) IS
                SELECT  sua.location_cd,
                        sua.unit_class
                FROM    IGS_EN_SU_ATTEMPT sua
                WHERE   sua.person_id = cp_person_id AND
                        sua.course_cd = cp_course_cd AND
                        sua.unit_attempt_status = 'ENROLLED' AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                        cp_cal_type,
                                        cp_ci_sequence_number,
                                        sua.cal_type,
                                        sua.ci_sequence_number,
                                        'N') = 'Y';
  BEGIN
        p_mess1 := NULL;
        p_mess2 := NULL;
        p_mess3 := NULL;
        IF enrp_val_coo_att(p_person_id,
                                p_coo_id,
                                p_cal_type,
                                p_sequence_number,
                                v_message_name,
                                v_attendance_types,
                                p_load_or_teach_cal_type,
                                p_load_or_teach_seq_number) = FALSE THEN
                p_mess1 := v_message_name;
        END IF;
        FOR     v_sua_row       IN      c_sua(
                        p_person_id,
                        p_course_cd,
                        p_cal_type,
                        p_sequence_number)      LOOP
                -- 1.1 If the cross-LOCATION check hasn't already
                -- failed then apply it.
                IF (p_mess2 is NULL) THEN
                        IF (IGS_EN_VAL_SUA.enrp_val_coo_loc(
                                        p_coo_id,
                                        v_sua_row.location_cd,
                                        v_message_name) = FALSE) THEN
                                p_mess2 := 'IGS_EN_UNITLOC_CONFLICTS';
                        END IF;
                END IF;
                -- 1.2 If the cross-mode check hasn't already
                -- failed then apply it.
                IF (p_mess3 is NULL) THEN
                        IF (IGS_EN_VAL_SUA.enrp_val_coo_mode(
                                        p_coo_id,
                                        v_sua_row.unit_class,
                                        v_message_name) = FALSE) THEN
                                p_mess3 := 'IGS_EN_UNITMODE_CONFLICTS';
                        END IF;
                END IF;
                -- 1.3 If the student has failed both checks there
                -- is no point in continuing - exit loop
                IF ((p_mess2 is not NULL) AND
                                (p_mess3 is not NULL)) THEN
                        EXIT;
                END IF;
        END LOOP;
        p_message_name1 := p_mess1;
        p_message_name2 := p_mess2;
        p_message_name3 := p_mess3;
        IF ((p_mess1 is not NULL) OR
                        (p_mess2 is not NULL) OR
                        (p_mess3 is not NULL)) THEN
                RETURN FALSE;
        ELSE
                RETURN TRUE;
        END IF;
  END;
/*  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_sua_coo');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;*/
  END enrp_val_sua_coo;
  --
  -- To validate confirmed indicator on student course attempt
  FUNCTION enrp_val_sca_confirm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2,
  p_course_attempt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        -- enrp_val_sca_confirm.
        -- Validate the student_confirmed_ind from the
        -- IGS_EN_STDNT_PS_ATT :
        --      * course_attempt_status must be 'ENROLLED',
        --        'INACTIVE' or 'UNCONFIRM' to unset the
        --        student_confrimed_ind.
        --      * student_confirmed_ind must not be unset
        --        when student_unit_attempts exist that are
        --        not unconfirmed.
  DECLARE
        cst_discontin           CONSTANT VARCHAR2(10) := 'DISCONTIN';
        cst_complete            CONSTANT VARCHAR2(10) := 'COMPLETE';
        cst_intermit            CONSTANT VARCHAR2(10) := 'INTERMIT';
        cst_unconfirm           CONSTANT VARCHAR2(10) := 'UNCONFIRM';
        cst_accepted            CONSTANT VARChar2(10) := 'ACCEPTED';
        v_sua_found                     VARCHAR2(1);
        v_acai_status                   VARCHAR2(30);
        v_adm_outcome_status            VARCHAR2(10);
        v_adm_offer_resp_status         VARCHAR2(10);
        v_s_adm_offer_resp_status       VARCHAR2(10);
        CURSOR c_sua IS
                SELECT  'x'
                FROM    IGS_EN_SU_ATTEMPT
                WHERE   person_id               = p_person_id AND
                        course_cd               = p_course_cd AND
                        unit_attempt_status     <> cst_unconfirm;
  BEGIN
        -- check the course attempt status
        IF p_course_attempt_status IN (cst_discontin,
                                        cst_complete,
                                        cst_intermit) THEN
                p_message_name := 'IGS_EN_CONF_IND_ONLY_BE_CHANG';
                RETURN FALSE;
        END IF;
        -- check student unit attempts
        IF p_student_confirmed_ind = 'N' THEN
                OPEN  c_sua;
                FETCH c_sua INTO v_sua_found;
                -- check if a record was found
                IF c_sua%FOUND THEN
                        CLOSE c_sua;
                        p_message_name := 'IGS_EN_PRG_ATT_CONF_ENR';
                        RETURN FALSE;
                END IF;
                CLOSE c_sua;
                IF p_admission_appl_number IS NOT NULL THEN
                        -- Get admission application response
                        -- status.
                        v_acai_status := IGS_AD_GEN_003.ADMP_GET_ACAI_STATUS (
                                                p_person_id,
                                                p_admission_appl_number,
                                                p_nominated_course_cd,
                                                p_acai_sequence_number,
                                                v_adm_outcome_status,
                                                v_adm_offer_resp_status);
                        -- Get systemp offer response status
                        IF v_adm_offer_resp_status IS NOT NULL THEN
                                v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS(
                                                                v_adm_offer_resp_status);
                                IF v_s_adm_offer_resp_status = cst_accepted THEN
                                        p_message_name := 'IGS_EN_ASSOCIATE_ADMPRG_APPL';
                                        RETURN TRUE;
                                END IF;
                        END IF;
                END IF;
        END IF;
        -- set the default message number and return type
        p_message_name := null;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sua%ISOPEN THEN
                        CLOSE c_sua;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_sca_confirm');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sca_confirm;
  --
  -- To validate the sca attendance type against the coo restriction
  FUNCTION ENRP_VAL_COO_ATT(
  p_person_id IN NUMBER ,
  p_coo_id IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_attendance_types OUT NOCOPY VARCHAR2,
  p_load_or_teach_cal_type IN VARCHAR2,
  p_load_or_teach_seq_number IN NUMBER)
  RETURN boolean  AS
  /******************************************************************
  Created By        : knaraset
  Date Created By   : 12-Nov-2001
  Purpose           : This procedure updates Enrolled_Cp and achieveable_Cp in SUA record
                      when Approved Credit Points is created.
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who         When            What
  ckasu      24-APR-2006    Modified as a part of bug#5191592 inorder to consider passed in Term Calendar
                            alone during efstu caluculation  when Term calendar or Teach calendar is passed
                            else earlier logic of getting all the load calendar associated to the academic
                            calendar is remained intact.
  *********************************************************************/
  BEGIN
  DECLARE
        cst_active              CONSTANT VARCHAR2(10) := 'ACTIVE';
        cst_load                        CONSTANT VARCHAR2(10) := 'LOAD';
        v_course_cd             IGS_PS_OFR_OPT.course_cd%TYPE;
        v_coo_attendance_type   IGS_PS_OFR_OPT.attendance_type%TYPE;
        v_forced_att_type_ind   IGS_PS_OFR_OPT.forced_att_type_ind%TYPE;
        v_lower_enr_load_range  IGS_EN_ATD_TYPE.lower_enr_load_range%TYPE;
        v_upper_enr_load_range  IGS_EN_ATD_TYPE.upper_enr_load_range%TYPE;
        v_validation_failed             BOOLEAN;
        v_concat_attendance_type        VARCHAR2(100);
        v_attendance_type               IGS_EN_ATD_TYPE.attendance_type%TYPE;
        v_period_load           IGS_EN_ATD_TYPE_LOAD.lower_enr_load_range%TYPE;
        v_credit_points         NUMBER;
        v_other_detail  VARCHAR(255);
        CURSOR  c_coo(
                        cp_coo_id IGS_PS_OFR_OPT.coo_id%TYPE) IS
                SELECT  COO.course_cd,
                        COO.attendance_type,
                        COO.forced_att_type_ind
                FROM    IGS_PS_OFR_OPT COO
                WHERE   COO.coo_id = cp_coo_id
                AND     COO.delete_flag = 'N';
        CURSOR  c_attendance_type(
                        cp_attendance_type IGS_EN_ATD_TYPE.attendance_type%TYPE) IS
                SELECT  ATT.lower_enr_load_range,
                        ATT.upper_enr_load_range
                FROM    IGS_EN_ATD_TYPE ATT
                WHERE   ATT.attendance_type = cp_attendance_type;
        CURSOR  c_cal_type_instance(
                        cp_cal_type IGS_CA_INST.cal_type%TYPE,
                        cp_sequence_number IGS_CA_INST.sequence_number%TYPE)IS
                SELECT  CI.cal_type,
                        CI.sequence_number,
                        CI.start_dt
                FROM    IGS_CA_INST_REL CIR,
                        IGS_CA_INST CI,
                        IGS_CA_TYPE CT,
                        IGS_CA_STAT CS
                WHERE   CT.closed_ind = 'N' AND
                        CT.s_cal_cat = cst_load AND
                        CS.s_cal_status = cst_active AND
                        CI.cal_status = CS.cal_status AND
                        CI.cal_type = CT.cal_type AND
                        CIR.sup_cal_type = cp_cal_type AND
                        CIR.sup_ci_sequence_number = cp_sequence_number AND
                        CIR.sub_cal_type = CI.cal_type AND
                        CIR.sub_ci_sequence_number = CI.sequence_number
                ORDER BY CI.start_dt;
       CURSOR c_is_cal_load_or_teach(cp_cal_type   IGS_CA_INST.cal_type%TYPE,
                                     cp_seq_number IGS_CA_INST.sequence_number%TYPE) IS
                SELECT ct.s_cal_cat
                FROM igs_ca_inst ci,
                     igs_ca_type ct
                WHERE ci.cal_type = ct.cal_type
                AND   ct.closed_ind = 'N'
                AND   ci.cal_type = cp_cal_type
                AND   ci.sequence_number = cp_seq_number;

       CURSOR c_get_teach_to_load_cal(cp_cal_type   IGS_CA_INST.cal_type%TYPE,
                                      cp_seq_number IGS_CA_INST.sequence_number%TYPE) IS
                SELECT load_cal_type,load_ci_sequence_number
                FROM   igs_ca_teach_to_load_v
                WHERE  teach_cal_type = cp_cal_type
                AND    teach_ci_sequence_number = cp_seq_number
                ORDER BY load_start_dt;

  l_cal_category    IGS_CA_TYPE.s_cal_cat%TYPE;
  l_load_cal_type   IGS_CA_INST.cal_type%TYPE;
  l_load_seq_number IGS_CA_INST.sequence_number%TYPE;

  BEGIN
        -- Validate the nominated attendance type against IGS_PS_OFR_OPT
        -- IGS_AD_LOCATION code for the students enrolled course.
        -- The check is only done if :
        --      o the IGS_PS_OFR_OPT.forced_location_ind is set.
        --      o one of the attendance type load range values in the IGS_EN_ATD_TYPE table
        --         are set
        -- NOTE: This validation is reliant on the student unit attempts being checked
        -- against- having been committed to the database and having had the "unit
        -- attempt statuses" derived.
        p_message_name := null;
        p_attendance_types := NULL;
        -- Check that the attendance type for the course offering option is forced.
        OPEN    c_coo(
                   p_coo_id);
        FETCH   c_coo INTO v_course_cd,
                           v_coo_attendance_type,
                           v_forced_att_type_ind;
        IF(c_coo%NOTFOUND) THEN
                CLOSE c_coo;
                RETURN TRUE;
        END IF;
        CLOSE c_coo;
        IF(v_forced_att_type_ind = 'N') THEN
                RETURN TRUE;
        END IF;
        -- Check whether any load ranges have been specified; if not the attendance
        -- type in which the student has enrolled if effectively an "unspecified"
        -- option,
        -- so no check is possible.
        OPEN    c_attendance_type(
                                v_coo_attendance_type);
        FETCH   c_attendance_type INTO v_lower_enr_load_range,
                                       v_upper_enr_load_range;
        IF(c_attendance_type%NOTFOUND) THEN
                CLOSE c_attendance_type;
                RETURN TRUE;
        END IF;
        CLOSE c_attendance_type;
        IF((v_lower_enr_load_range = 0 OR v_lower_enr_load_range IS NULL) AND
           (v_upper_enr_load_range = 0 OR v_upper_enr_load_range IS NULL)) THEN
                RETURN TRUE;
        END IF;
        -- Loop through the load periods for the academic period and call the
        -- routines to get the effective load for that period.
        v_validation_failed := FALSE;
        v_concat_attendance_type := NULL;


        IF p_load_or_teach_cal_type IS NULL OR p_load_or_teach_seq_number IS NULL THEN

                FOR v_cal_type_instance_rec IN c_cal_type_instance(
                                        p_cal_type,
                                        p_ci_sequence_number)
                LOOP
                        -- Call ENRP_CLC_LOAD_TOTAL routine to get the load incurred within the
                        -- current load period
                        v_period_load := IGS_EN_PRC_LOAD.ENRP_CLC_EFTSU_TOTAL(
                                                        p_person_id,
                                                        v_course_cd,
                                                        p_cal_type,
                                                        p_ci_sequence_number,
                                                        v_cal_type_instance_rec.cal_type,
                                                        v_cal_type_instance_rec.sequence_number,
                                                        'Y',
                                                        'Y',
                                                        NULL,
                                                        NULL,
                                                        v_credit_points);
                        -- Call routine to determine the attendance type for the calculated load
                        -- figure within the current load calendar
                        v_attendance_type := IGS_EN_PRC_LOAD.ENRP_GET_LOAD_ATT(
                                                        v_cal_type_instance_rec.cal_type,
                                                        v_period_load);
                        -- Concatenate the attendance type onto the variable.
                        IF v_concat_attendance_type IS NULL THEN
                                v_concat_attendance_type := NVL(v_attendance_type,'-');
                        ELSE
                                v_concat_attendance_type := v_concat_attendance_type || ',' ||
                                                                NVL(v_attendance_type,'-');
                        END IF;
                        IF v_attendance_type IS NOT NULL THEN
                                -- If the attendance type is different then set a flag indicating that the
                                -- validation has failed. This will be picked up after the loop has
                                -- completed.
                                IF (v_attendance_type <> v_coo_attendance_type) THEN
                                        v_validation_failed := TRUE;
                                END IF;
                        END IF;
                END LOOP;
        ELSE

                        OPEN c_is_cal_load_or_teach(p_load_or_teach_cal_type,p_load_or_teach_seq_number);
                        FETCH c_is_cal_load_or_teach INTO l_cal_category;
                        CLOSE c_is_cal_load_or_teach;

                        IF  l_cal_category = 'TEACHING' THEN

                                OPEN c_get_teach_to_load_cal( p_load_or_teach_cal_type,p_load_or_teach_seq_number);
                                FETCH c_get_teach_to_load_cal INTO l_load_cal_type,l_load_seq_number;
                                CLOSE c_get_teach_to_load_cal;

                        ELSE

                                l_load_cal_type   := p_load_or_teach_cal_type;
                                l_load_seq_number := p_load_or_teach_seq_number;

                        END IF; -- l_cal_category = 'TEACH' THEN

                        -- Call ENRP_CLC_LOAD_TOTAL routine to get the load incurred within the
                        -- current load period
                        v_period_load := IGS_EN_PRC_LOAD.ENRP_CLC_EFTSU_TOTAL(
                                                        p_person_id,
                                                        v_course_cd,
                                                        p_cal_type,
                                                        p_ci_sequence_number,
                                                        l_load_cal_type,
                                                        l_load_seq_number,
                                                        'Y',
                                                        'Y',
                                                        NULL,
                                                        NULL,
                                                        v_credit_points);
                        -- Call routine to determine the attendance type for the calculated load
                        -- figure within the current load calendar
                        v_attendance_type := IGS_EN_PRC_LOAD.ENRP_GET_LOAD_ATT(
                                                        l_load_cal_type,
                                                        v_period_load);
                        -- Concatenate the attendance type onto the variable.
                        IF v_concat_attendance_type IS NULL THEN
                                v_concat_attendance_type := NVL(v_attendance_type,'-');
                        ELSE
                                v_concat_attendance_type := v_concat_attendance_type || ',' ||
                                                                NVL(v_attendance_type,'-');
                        END IF;
                        IF v_attendance_type IS NOT NULL THEN
                                -- If the attendance type is different then set a flag indicating that the
                                -- validation has failed. This will be picked up after the loop has
                                -- completed.
                                IF (v_attendance_type <> v_coo_attendance_type) THEN
                                        v_validation_failed := TRUE;
                                END IF;
                        END IF;

        END IF;-- end of IF l_cal_category = 'ACADEMIC' THEN
        -- Set the OUT NOCOPY parameter
        p_attendance_types := v_concat_attendance_type;
        IF v_validation_failed THEN
                p_message_name := 'IGS_EN_STUD_OUTSIDE_ENRATT_TY';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  /*EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_coo_att');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;*/
  END;
  END enrp_val_coo_att;
  --
  -- To validate the SCA discontinuation reason code
  FUNCTION enrp_val_sca_dr(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_discontinuation_reason_cd   IN VARCHAR2 ,
  p_discontinued_dt             IN DATE ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2)
  RETURN BOOLEAN  AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : validate the IGS_EN_DCNT_REASONCD from the IGS_EN_STDNT_PS_ATT table
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        11-11-2002      Modified function logic due to addition of new parameter p_legacy
  ||                                  if p_legacy set to 'Y' then error message should be stacked instead of
  ||                                  returning the function in the normal way else function should behave in
  ||                                  normal way.Legacy Build Bug no: 2661533
  || pradhakr         27-Dec-2002     The validation related to transfer discontinuation reason codes
  ||                                  should not be done as part of Legacy API, as this cannot be tested
  ||                                  at the import stage itself. Added a condition p_legacy <> 'Y' to display
  ||                                  the error message 'IGS_EN_PRG_TRSF_DISCONT' if it is called from any other
  ||                                  package other than the legacy API. Changes wrt Bug# 2728123
  || bdeviset  22-Dec-2004            Modifed cursor c_sct in  enrp_val_sca_dr as part Bug#4083015.
  ------------------------------------------------------------------------------*/
   BEGIN
   DECLARE
        cst_transfer                    CONSTANT VARCHAR2(10) := 'TRANSFER';
        v_dummy                         VARCHAR2(1);
        CURSOR c_sca IS
                SELECT  dr.closed_ind,
                        dr.s_discontinuation_reason_type
                FROM    IGS_EN_DCNT_REASONCD dr
                WHERE   dr.discontinuation_reason_cd = p_discontinuation_reason_cd;

        -- Modifed cursor to consider the status_flag while finding the transfer records
        CURSOR c_sct IS
                SELECT  'X'
                FROM    IGS_PS_STDNT_TRN sct
                WHERE   sct.person_id           = p_person_id   AND
                        sct.transfer_course_cd  = p_course_cd   AND
                        (sct.status_date         >= p_discontinued_dt OR
                        sct.status_flag = 'U');
        v_sca_rec                       c_sca%ROWTYPE;
   BEGIN
        p_message_name := null;
        IF (p_discontinuation_reason_cd IS NOT NULL) THEN
                OPEN c_sca;
                FETCH c_sca INTO v_sca_rec;
                IF (c_sca%FOUND) THEN
                        CLOSE c_sca;
                        IF (v_sca_rec.closed_ind = 'Y') AND (p_legacy <> 'Y') THEN
                                p_message_name := 'IGS_EN_DISCONT_REAS_CD_CLOS';
                                RETURN FALSE;
                        END IF;

                        IF (v_sca_rec.s_discontinuation_reason_type = cst_transfer AND p_legacy <> 'Y' ) THEN
                            OPEN c_sct;
                            FETCH c_sct INTO v_dummy;
                            IF (c_sct%NOTFOUND) THEN
                              CLOSE c_sct;
                              p_message_name := 'IGS_EN_PRG_TRSF_DISCONT';
                              RETURN FALSE;
                            ELSE
                              CLOSE c_sct;
                            END IF;
                        END IF;

                END IF;
                IF (c_sca%ISOPEN) THEN
                        CLOSE c_sca;
                END IF;
                IF (p_discontinued_dt IS NULL) THEN
                        p_message_name := 'IGS_EN_CANT_SET_DISCONT_REASO';
                        IF p_legacy <> 'Y' THEN
                           RETURN FALSE;
                        ELSE
                           fnd_message.set_name('IGS',p_message_name);
                           fnd_msg_pub.add;
                        END IF;
                END IF;
        ELSIF (p_discontinued_dt IS NOT NULL) THEN
                p_message_name := 'IGS_EN_CANT_SET_DISCONT_DATE';
                IF p_legacy <> 'Y' THEN
                   RETURN FALSE;
                ELSE
                   fnd_message.set_name('IGS',p_message_name);
                   fnd_msg_pub.add;
                END IF;
        END IF;
        RETURN TRUE;
   EXCEPTION
        WHEN OTHERS THEN
                IF (c_sca%ISOPEN) THEN
                        CLOSE c_sca;
                END IF;
                IF (c_sct%ISOPEN) THEN
                        CLOSE c_sct;
                END IF;
                RAISE;
   END;
   EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_sca_dr');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
   END enrp_val_sca_dr;
  --
  -- To validate the course attempt against funding source restrictions
  FUNCTION ENRP_VAL_SCA_FSR(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
  BEGIN
  DECLARE
        v_rec_found     BOOLEAN;
        v_other_detail  VARCHAR2(255);
        CURSOR  c_fund_source_rest(
                        cp_course_cd IGS_PS_VER.course_cd%TYPE,
                        cp_version_number IGS_PS_VER.version_number%TYPE) IS
                SELECT  funding_source,
                        restricted_ind
                FROM    IGS_FI_FND_SRC_RSTN
                WHERE   course_cd = cp_course_cd AND
                        version_number = cp_version_number AND
                        restricted_ind = 'Y';
  BEGIN
        -- validates the funding source for a student course attempt according
        -- to the IGS_FI_FND_SRC_RSTN table held against the course
        p_message_name := null;
        v_rec_found := FALSE;
        FOR v_fund_source_rest_rec IN c_fund_source_rest(
                                                p_course_cd,
                                                p_version_number)
        LOOP
               v_rec_found := TRUE;
               IF(p_funding_source = v_fund_source_rest_rec.funding_source)THEN
                     RETURN TRUE;
               END IF;
        END LOOP;
        IF(v_rec_found = FALSE) THEN
                RETURN TRUE;
        END IF;
        p_message_name := 'IGS_AD_FUNDING_SRC_RESTRICTIO';
        RETURN FALSE;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_sca_fsr');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END;
  END enrp_val_sca_fsr;
  --
  -- To validate the discontinuation date and the reason cd
  FUNCTION enrp_val_sca_discont(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_version_number              IN NUMBER ,
  p_course_attempt_status       IN VARCHAR2 ,
  p_discontinuation_reason_cd   IN VARCHAR2 ,
  p_discontinued_dt             IN DATE ,
  p_commencement_dt             IN DATE ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2)
  RETURN BOOLEAN  AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : Validate the IGS_EN_DCNT_REASONCD and discontinued_dt
  ||   from the IGS_EN_STDNT_PS_ATT :
  ||   * If the discontinuation_reason code is set it must not be closed
  ||   * If both discontinued_dt and commencement_dt are set then
  ||     discontinued_dt must be >= commencement_dt
  ||   * If either reason or date are set then both must be set
  ||   * If the discontinued date is not set then course version must
  ||     be active.
  ||   * If the discontinued date is set then the course attempt status
  ||     must have been enrolled, inactive, suspended, intermitted or
  ||     discontinued. NOTE: course attempt status will be set to
  ||     DISCONTIN prior to update.
  ||   * If the discontinued date is set then it must be less than or equal to
  ||     the transfer date if the cours attempt has been transferred
  ||   * If the discontinued date is set and <= today?s date then there
  ||     should be no student unit attempts enrolled.
  ||   * If the discontinued date is set, then it must be greater than the
  ||     outcome date of any completed student unit attempts.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        11-11-2002      Modified function logic due to addition of new parameter p_legacy
  ||                                  if p_legacy set to 'Y' then error message should be stacked instead of
  ||                                  returning the function in the normal way else function should behave in
  ||                                  normal way.Legacy Build Bug no: 2661533
  ||  kkillams        29-04-2003      Modified the c_sua_comp cursor where clause due to change in the pk of
  ||                                  student unit attempt w.r.t. bug number 2829262
  ||  bdeviset  22-Dec-2004           Modifed cursor c_sct in enrp_val_sca_discont as part Bug#4083015.
  ------------------------------------------------------------------------------*/
   BEGIN
   DECLARE
        cst_active              CONSTANT IGS_PS_STAT.s_course_status%TYPE :='ACTIVE';
        cst_discontin           CONSTANT IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE :='DISCONTIN';
        cst_enrolled            CONSTANT IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'ENROLLED';
        cst_inactive            CONSTANT IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INACTIVE';
        cst_intermit            CONSTANT IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INTERMIT';
        cst_lapsed              CONSTANT IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'LAPSED';
        cst_completed           CONSTANT IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'COMPLETED';
        l_dummy_boolean         BOOLEAN;
        CURSOR  c_cv IS
                SELECT  'x'
                FROM    IGS_PS_VER      cv,
                        IGS_PS_STAT     cs
                WHERE   cv.course_cd            = p_course_cd AND
                        cv.version_number       = p_version_number AND
                        cs.course_status        = cv.course_status AND
                        cs.s_course_status      <> cst_active;
        v_cv_exists             VARCHAR2(1);
        CURSOR  c_sua_enr IS
                SELECT  'x'
                FROM    IGS_EN_SU_ATTEMPT       sua
                WHERE   sua.person_id           = p_person_id AND
                        sua.course_cd           = p_course_cd AND
                        sua.unit_attempt_status = cst_enrolled;
        v_sua_enr_exists        VARCHAR2(1);
        CURSOR c_sua_comp IS
                SELECT  'x'
                FROM    IGS_AS_SU_STMPTOUT suao,
                        IGS_EN_SU_ATTEMPT sua
                WHERE   sua.person_id           = p_person_id AND
                        sua.course_cd           = p_course_cd AND
                        sua.unit_attempt_status = cst_completed AND
                        suao.person_id          = sua.person_id AND
                        suao.course_cd          = sua.course_cd AND
                        suao.uoo_id             = sua.uoo_id AND
                        TRUNC(suao.outcome_dt)  > TRUNC(p_discontinued_dt) AND
                        suao.finalised_outcome_ind = 'Y';
        v_sua_comp_exists       VARCHAR2(1);

        -- Modified cursor to consider status_date instead of transfer_dt and
        -- status_flag is set to 'T'
        CURSOR c_sct IS
                SELECT  sct.transfer_course_cd,
                        sct.status_date
                FROM    IGS_PS_STDNT_TRN sct
                WHERE   sct.person_id           = p_person_id AND
                        (sct.course_cd          = p_course_cd OR
                        sct.transfer_course_cd  = p_course_cd) AND
                        sct.status_flag         = 'T'
                ORDER BY sct.status_date desc;
        v_sct_transfer_actual_dt               IGS_PS_STDNT_TRN.status_date%TYPE;
        v_sct_transfer_course_cd               IGS_PS_STDNT_TRN.transfer_course_cd%TYPE;
        v_message_name                         varchar2(30);
   BEGIN
        p_message_name := null;
        IF p_discontinued_dt IS NOT NULL THEN
                -- Validate that student course attempt has status that can be discontinued
                IF p_course_attempt_status NOT IN (cst_discontin,
                                                   cst_enrolled,
                                                   cst_intermit,
                                                   cst_inactive,
                                                   cst_lapsed) THEN
                        p_message_name := 'IGS_EN_ONLY_SPA_ST_ENROLLED';
                        IF p_legacy <> 'Y'  THEN
                           RETURN FALSE;
                        ELSE
                           fnd_message.set_name('IGS',p_message_name);
                           fnd_msg_pub.add;
                        END IF;
                END IF;
                -- Validate that discontinued date is not prior to course commencement
                IF p_discontinued_dt < p_commencement_dt THEN
                        p_message_name := 'IGS_EN_DISCONT_DT_LT_COMM_DT';
                        IF p_legacy <> 'Y'  THEN
                           RETURN FALSE;
                        ELSE
                           fnd_message.set_name('IGS',p_message_name);
                           fnd_msg_pub.add;
                        END IF;
                END IF;
                IF p_legacy <> 'Y' THEN
                        -- Validate that discontinued date is not greater than the course transfer
                        -- date if the course attempt has been transferred
                        OPEN c_sct;
                        FETCH c_sct INTO v_sct_transfer_course_cd, v_sct_transfer_actual_dt;
                        IF (c_sct%FOUND) THEN
                                IF v_sct_transfer_course_cd = p_course_cd THEN -- this indicates transfer
                                        IF v_sct_transfer_actual_dt < p_discontinued_dt THEN
                                                CLOSE c_sct;
                                                p_message_name := 'IGS_EN_DISCONT_DATE_NOT_AFTER';
                                                Return FALSE;
                                        END IF;
                                END IF;
                        END IF;
                        CLOSE c_sct;
                END IF; --p_legacy
        END IF;
        -- Validate discontinuation reason code
        IF p_legacy <> 'Y' THEN
                IF NOT enrp_val_sca_dr(
                          p_person_id,
                          p_course_cd,
                          p_discontinuation_reason_cd,
                          p_discontinued_dt,
                          v_message_name,
                          p_legacy) THEN
                        p_message_name := v_message_name;
                        RETURN FALSE;
                END IF;
        ELSE
                --In legacy mode, error message is stacked instead of returning false.
                --So there is no significance for the return values.
                v_message_name := null;
                l_dummy_boolean:=enrp_val_sca_dr(
                                   p_person_id,
                                   p_course_cd,
                                   p_discontinuation_reason_cd,
                                   p_discontinued_dt,
                                   v_message_name,
                                   p_legacy);
                 p_message_name := NVL(v_message_name,p_message_name);
        END IF;
        IF p_legacy <> 'Y' THEN
                IF p_discontinued_dt IS NULL THEN
                        -- Validate that the course version is still active
                        OPEN c_cv;
                        FETCH c_cv INTO v_cv_exists;
                        IF c_cv%FOUND THEN
                                CLOSE c_cv;
                                p_message_name := 'IGS_EN_PRG_VERSION_INACTIVE';
                                RETURN FALSE;
                        END IF;
                        CLOSE c_cv;
                        -- Validate course transfer links
                        -- NOTE: Comment out NOCOPY for now because of mutuating trigger issue
                        -- This module will be called in ENRF3000 when unit discontinuation is cleared
                        --IF IGS_AD_VAL_SCA.enrp_val_sca_trnsfr(
                        --                              p_person_id,
                        --                              p_course_cd,
                        --                              p_discontinued_dt,
                        --                              'E',
                        --                              v_message_name) = FALSE THEN
                        --      p_message_name := v_message_name;
                        --      RETURN FALSE;
                        --END IF;
                ELSE    -- p_discontinued_dt IS NOT NULL
                        -- Validate that discontinued is not prior to COMPLETED IGS_EN_SU_ATTEMPTs
                        OPEN c_sua_comp;
                        FETCH c_sua_comp INTO v_sua_comp_exists;
                        IF c_sua_comp%FOUND THEN
                                CLOSE c_sua_comp;
                                p_message_name := 'IGS_EN_SPA_NOTDISCONT_PRIOR';
                                RETURN FALSE;
                        END IF;
                        CLOSE c_sua_comp;
                        IF p_discontinued_dt <= SYSDATE THEN
                                -- Validate that there are no enrolled student unit attempts
                                -- *** NOTE: this must be the last validation as the form
                                -- ENRF3000 acts on this error code
                                OPEN c_sua_enr;
                                FETCH c_sua_enr INTO v_sua_enr_exists;
                                IF c_sua_enr%FOUND THEN
                                        CLOSE c_sua_enr;
                                        p_message_name := 'IGS_EN_SPA_NOTDISCONT_SUA';
                                        RETURN FALSE;
                                END IF;
                                CLOSE c_sua_enr;
                        END IF;
                END IF;
        END IF;  --p_legacy
        --- Return default value
        RETURN TRUE;
   EXCEPTION
        WHEN OTHERS THEN
                IF c_cv%ISOPEN THEN
                        CLOSE c_cv;
                END IF;
                IF c_sua_comp%ISOPEN THEN
                        CLOSE c_sua_comp;
                END IF;
                IF c_sua_enr%ISOPEN THEN
                        CLOSE c_sua_enr;
                END IF;
                RAISE;
   END;
   EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_sca_discont');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
   END enrp_val_sca_discont;
  --
  -- Validate the course commencement date against the students birth date
  FUNCTION enrp_val_sca_comm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        -- enrp_val_sca_comm
        -- Validate the student course attempt commencement date, checking for:
        -- Warn if the commencement_dt would make the student < 16 years old
        -- or > 100 years old
        -- Validate that commencement_dt is not after the end date of student unit
        -- attempts with unit_attempt_status other than 'UNCONFIRM', 'DUPLICATE'.
        -- If the course attempt originates from an offer other than process
        -- type TRANSFER, the date cannot be prior to the course start date of the
        -- students admission period OR the if research candidature is mandatory part
        -- of the offer, prior to the valid values for
        -- IGS_AD_PS_APPL_INST.prpsd_commencement_dt.
        -- If the course attempt is the result of a course transfer from a generic
        -- course, then the date can be no earlier than the commencement date of the
        -- originating course attempt.
        -- If the course attempt is a result of a course transfer from a IGS_PS_COURSE
        -- attempt with research candidature, then the date can be no earlier than
        -- the commencement date of the transfer course attempt.
        -- If the course attempt doesn't originate from an offer, the date cannot be
        -- prior to the academic period commencement date if date of processing
        -- is after academic period commencement date, otherwise cannot be prior
        -- to current date
        -- If the course attempt has a research candidature, then commencement_dt
        -- must comply with the candidature minimum submission date
        -- and supervisor requirements.
        --  Change History :
        --  Who             When            What
        -- stutta       07-02-2006   Modified c_person for performance bug#5023479
  DECLARE
        --Constants
        cst_low_months          CONSTANT NUMBER := 192; -- 16 years in months
        cst_high_months         CONSTANT NUMBER := 1200;-- 100 years in months
        cst_transfer            CONSTANT VARCHAR2(10) := 'TRANSFER';
        cst_enrolled            CONSTANT VARCHAR2(10) := 'ENROLLED';
        cst_discontin           CONSTANT VARCHAR2(10) := 'DISCONTIN';
        cst_invalid             CONSTANT VARCHAR2(10) := 'INVALID';
        cst_completed           CONSTANT VARCHAR2(10) := 'COMPLETED';
        cst_sca                 CONSTANT VARCHAR2(4) := 'SCA';
        -- Variables
        v_commencement_dt               IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
        v_course_start_dt               IGS_CA_DA_INST_V.alias_val%TYPE;
        v_birth_dt                      IGS_PE_PERSON.birth_dt%TYPE;
        v_candidature_exists_ind        VARCHAR2(1);
        v_ca_sequence_number            IGS_RE_CANDIDATURE.sequence_number%TYPE;
        v_message_name                  varchar2(30);
        -- Temporary variables
        v_dt_diff                       NUMBER;
        v_alias_val                     IGS_CA_DA_INST_V.alias_val%TYPE;
        v_only_one_rec_found            BOOLEAN := FALSE;
        v_commencement_dt_validated     BOOLEAN;
        CURSOR  c_sct_sca_crv IS
                SELECT  sca.commencement_dt
                FROM    IGS_PS_STDNT_TRN sct,
                        IGS_EN_STDNT_PS_ATT     sca,
                        IGS_PS_VER              crv
                WHERE   sct.person_id           = p_person_id AND
                        sca.person_id           = sct.person_id AND
                        sct.course_cd           = p_course_cd AND
                        sca.course_cd           = sct.transfer_course_cd AND
                        crv.course_cd           = sca.course_cd AND
                        crv.version_number      = sca.version_number AND
                        crv.generic_course_ind  = 'Y'
                ORDER BY sca.commencement_dt ASC;
        CURSOR  c_sca IS
                SELECT  sca.version_number,
                        sca.person_id,
                        sca.adm_admission_appl_number,
                        sca.adm_nominated_course_cd,
                        sca.adm_sequence_number
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   sca.person_id   = p_person_id AND
                        sca.course_cd   = p_course_cd;
        v_sca_rec       c_sca%ROWTYPE;
        CURSOR  c_acaiv (
                cp_person_id            IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_adm_adm_appl_num     IGS_EN_STDNT_PS_ATT.adm_admission_appl_number%TYPE,
                cp_adm_nom_course_cd    IGS_EN_STDNT_PS_ATT.adm_nominated_course_cd%TYPE,
                cp_adm_sequence_number  IGS_EN_STDNT_PS_ATT.adm_sequence_number%TYPE) IS
                SELECT  acaiv.admission_appl_number,
                        acaiv.nominated_course_cd,
                        acaiv.sequence_number,
                        acaiv.adm_cal_type,
                        acaiv.adm_ci_sequence_number
                FROM    IGS_AD_PS_APPL_INST_APLINST_V           acaiv
                WHERE   acaiv.person_id                 = cp_person_id AND
                        acaiv.admission_appl_number     = cp_adm_adm_appl_num AND
                        acaiv.nominated_course_cd       = cp_adm_nom_course_cd AND
                        acaiv.sequence_number           = cp_adm_sequence_number;
        v_acaiv_rec     c_acaiv%ROWTYPE;
        CURSOR  c_person IS
                SELECT birth_date date_of_birth
                FROM   igs_pe_person_base_v
                WHERE   person_id = p_person_id;
        CURSOR  c_daiv_secc IS
                SELECT  daiv.alias_val
                FROM    IGS_CA_DA_INST_V        daiv,
                        IGS_EN_CAL_CONF         secc
                WHERE   daiv.cal_type           = p_acad_cal_type AND
                        daiv.ci_sequence_number = p_acad_ci_sequence_number AND
                        secc.commencement_dt_alias = daiv.dt_alias AND
                        secc.s_control_num      = 1;
        CURSOR c_aa (
                cp_person_id                    IGS_AD_APPL.person_id%TYPE,
                cp_adm_admission_appl_number    IGS_AD_APPL.admission_appl_number%TYPE) IS
                SELECT  aa.s_admission_process_type
                FROM    IGS_AD_APPL             aa
                WHERE   aa.person_id            = cp_person_id AND
                        aa.admission_appl_number = cp_adm_admission_appl_number;
        v_aa_rec        c_aa%ROWTYPE;
        CURSOR c_sua_ci IS
                SELECT  'x'
                FROM    IGS_EN_SU_ATTEMPT       sua,
                        IGS_CA_INST             ci
                WHERE   sua.person_id           = p_person_id AND
                        sua.course_cd           = p_course_cd AND
                        sua.unit_attempt_status IN(
                                                cst_enrolled,
                                                cst_discontin,
                                                cst_invalid,
                                                cst_completed) AND
                        sua.cal_type            = ci.cal_type AND
                        sua.ci_sequence_number  = ci.sequence_number AND
                        sua.ci_end_dt           < p_commencement_dt;
        v_sua_ci_exists VARCHAR2(1);
        CURSOR c_sct_ca_sca IS
                SELECT  sca.commencement_dt
                FROM    IGS_PS_STDNT_TRN        sct,
                        IGS_RE_CANDIDATURE              ca,
                        IGS_EN_STDNT_PS_ATT     sca
                WHERE   sct.person_id           = p_person_id AND
                        sct.course_cd           = p_course_cd AND
                        sct.person_id           = ca.person_id AND
                        sct.transfer_course_cd  = ca.sca_course_cd AND
                        ca.person_id            = sca.person_id AND
                        ca.sca_course_cd        = sca.course_cd
                ORDER BY sct.status_date desc; -- (use latest record)
        FUNCTION enrpl_val_ca_start_dt
        RETURN BOOLEAN
         AS
        BEGIN --enrpl_val_ca_start_dt
                -- Validate candidature start date
                -- Validate against candidature commencement if candidature exists for the
                -- course attempt created via pre-enrolment
        DECLARE
        BEGIN
                IF NOT admp_val_ca_comm_val(
                                        p_person_id,
                                        v_acaiv_rec.admission_appl_number,
                                        v_acaiv_rec.nominated_course_cd,
                                        v_acaiv_rec.sequence_number,
                                        v_acaiv_rec.adm_cal_type,
                                        v_acaiv_rec.adm_ci_sequence_number,
                                        v_course_start_dt,
                                        p_commencement_dt,
                                        cst_sca,
                                        v_message_name) THEN
                        p_message_name := v_message_name;
                        RETURN FALSE;
                ELSE
                        IF v_message_name IS NOT NULL THEN
                                p_message_name := v_message_name;
                                RETURN TRUE;
                        END IF;
                END IF;
                RETURN TRUE;
        END;
        EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrpl_val_ca_start_dt');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
        END enrpl_val_ca_start_dt;
  BEGIN
        p_message_name := null;
        IF p_commencement_dt is NULL THEN
                RETURN TRUE;
        END IF;
        OPEN c_sca;
        FETCH c_sca INTO v_sca_rec;
        IF c_sca%NOTFOUND THEN
                CLOSE c_sca;
                RETURN TRUE;
        END IF;
        CLOSE c_sca;
        -- Validate that commencement date is not after the end date of any enrolled
        -- student unit attempts.
        OPEN c_sua_ci;
        FETCH c_sua_ci INTO v_sua_ci_exists;
        IF c_sua_ci%FOUND THEN
                CLOSE c_sua_ci;
                p_message_name := 'IGS_EN_COMMENC_DT_NOTBE_AFTER';
                RETURN FALSE;
        END IF;
        CLOSE c_sua_ci;
        --Validate research candidature details, if they exists
        v_candidature_exists_ind := 'N';
        IF admp_val_ca_comm(
                                        p_person_id,
                                        p_course_cd,
                                        v_sca_rec.version_number,
                                        v_sca_rec.adm_admission_appl_number,
                                        v_sca_rec.adm_nominated_course_cd,
                                        v_sca_rec.adm_sequence_number,
                                        NULL, -- admission outcome status
                                        p_commencement_dt,
                                        NULL, -- (minimun submission date)
                                        cst_sca,-- (indicates context is student course attempt)
                                        v_ca_sequence_number,
                                        v_candidature_exists_ind,
                                        v_message_name) = FALSE THEN
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        -- Check whether the course attempt has resulted in a transfer from a generic
        -- course.
        v_commencement_dt_validated := FALSE;
        OPEN c_sct_sca_crv;
        FETCH c_sct_sca_crv INTO v_commencement_dt;
        IF c_sct_sca_crv%FOUND THEN
                CLOSE c_sct_sca_crv;
                IF p_commencement_dt < v_commencement_dt THEN
                        p_message_name := 'IGS_EN_COMDT_NOTEARLIER_COMDT';
                        RETURN FALSE;
                ELSE
                        v_commencement_dt_validated := TRUE;
                END IF;
        ELSE
                CLOSE c_sct_sca_crv;
        END IF;
        -- Check whether course attempt is the result of a course transfer that has
        -- associated research candidature
        IF NOT v_commencement_dt_validated  AND
                        v_candidature_exists_ind = 'Y' THEN
                OPEN c_sct_ca_sca;
                FETCH c_sct_ca_sca INTO v_commencement_dt;
                IF c_sct_ca_sca%FOUND THEN
                        CLOSE c_sct_ca_sca;
                        IF p_commencement_dt < v_commencement_dt THEN
                                p_message_name := 'IGS_EN_PRG_COMMENCE_DT';
                                RETURN FALSE;
                        ELSE
                                v_commencement_dt_validated := TRUE;
                        END IF;
                ELSE
                        CLOSE c_sct_ca_sca;
                END IF;
        END IF;
        IF NOT v_commencement_dt_validated THEN
                IF v_sca_rec.adm_admission_appl_number IS NOT NULL THEN
                        -- The enrolment has originated from an admissions offer, so it cannot be
                        -- earlier than the course start date.
                        OPEN c_acaiv(
                                        v_sca_rec.person_id,
                                        v_sca_rec.adm_admission_appl_number,
                                        v_sca_rec.adm_nominated_course_cd,
                                        v_sca_rec.adm_sequence_number);
                        FETCH c_acaiv INTO v_acaiv_rec;
                        CLOSE c_acaiv;
                        v_course_start_dt:= IGS_AD_GEN_005.ADMP_GET_CRV_STRT_DT(
                                                                v_acaiv_rec.adm_cal_type,
                                                                v_acaiv_rec.adm_ci_sequence_number);
                        IF v_course_start_dt IS NOT NULL THEN
                                IF p_commencement_dt < v_course_start_dt THEN
                                        -- Determine if admission application is a course transfer
                                        OPEN c_aa(
                                                v_sca_rec.person_id,
                                                v_sca_rec.adm_admission_appl_number);
                                        FETCH c_aa INTO v_aa_rec;
                                        CLOSE c_aa;
                                        IF v_aa_rec.s_admission_process_type = cst_transfer THEN
                                                IF p_commencement_dt < TRUNC(SYSDATE) THEN
                                                        IF v_candidature_exists_ind ='Y' THEN
                                                                -- validate candidature start date
                                                                RETURN enrpl_val_ca_start_dt;
								-- comparison between current date and spa commencement date removed for Bug 3853476
								                        ELSE
														     RETURN enrf_val_sua_term_sca_comm(
															         p_person_id,
																	 p_course_cd,
																	 p_commencement_dt,
																	 p_message_name);

                                                        END IF;
                                                END IF;
                                        ELSE
                                                IF v_candidature_exists_ind ='Y' THEN
                                                        -- validate candidature start date
                                                        RETURN enrpl_val_ca_start_dt;
                                                ELSE
                                                		-- For Bug 3853476 this message has to be shown as warning....hence the function shall return true henceforth
                                                        p_message_name := 'IGS_EN_COMDT_NOTEARLIER_STDT';
                                                        RETURN TRUE;
                                                END IF;
                                        END IF;
                                END IF;
                        ELSIF p_commencement_dt < TRUNC(SYSDATE) THEN
                                IF v_candidature_exists_ind = 'Y' THEN
                                                --validate cadidature start date
                                        RETURN enrpl_val_ca_start_dt;
					-- comparison between current date and spa commencement date removed for Bug 3853476
					            ELSE
								     RETURN enrf_val_sua_term_sca_comm(
									         p_person_id,
											 p_course_cd,
											 p_commencement_dt,
											 p_message_name);
                                END IF;
                        END IF;
                ELSE
				        -- check if the earliest term calendar in which there is a unit attempt
						-- has an end dt after the commencement date.
				        IF NOT enrf_val_sua_term_sca_comm(
									         p_person_id,
											 p_course_cd,
											 p_commencement_dt,
											 p_message_name) THEN
                          RETURN FALSE;
						END IF;
				        -- v_sca_rec.adm_admission_appl_number IS NULL
                        -- Check that the commencement date is not prior to the academic
                        -- period commencement date if date of processing is after the
                        -- academic period commencement date, otherwise must be >= current date.
                        v_only_one_rec_found := FALSE;
                        FOR v_daiv_secc_rec IN c_daiv_secc LOOP
                                v_only_one_rec_found := TRUE;
                                IF c_daiv_secc%ROWCOUNT > 1 THEN
                                        v_only_one_rec_found := FALSE;
                                        EXIT;
                                END IF;
                                v_alias_val := v_daiv_secc_rec.alias_val;
                        END LOOP;
                        IF v_only_one_rec_found AND  v_alias_val < TRUNC(SYSDATE) AND p_commencement_dt < v_alias_val THEN
							-- For Bug 3853476 this message has to be shown as warning....hence the function shall return true henceforth
                                                        p_message_name := 'IGS_EN_SPA_COMMEN_DT';
                                                        RETURN TRUE;
                         END IF;
                END IF; -- v_adm_adm_appl_number IS NOT NULL
        END IF; -- v_commencement_dt_validated
        --Retrieve the birth_dt from IGS_PE_PERSON where person_id = p_person_id
        OPEN c_person;
        FETCH c_person INTO v_birth_dt;
        CLOSE c_person;
        IF v_birth_dt IS NULL THEN
                RETURN TRUE;
        END IF;
        v_dt_diff := MONTHS_BETWEEN(p_commencement_dt, v_birth_dt);
        IF v_dt_diff < cst_low_months  THEN
                p_message_name := 'IGS_EN_STUDENT_LT_16YRS';
                RETURN TRUE;
        END IF;
        IF v_dt_diff > cst_high_months THEN
                p_message_name := 'IGS_EN_STUDENT_GT_100YRS';
                RETURN TRUE;
        END IF;
        RETURN TRUE; -- NOTE: no false return as its only a warning
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sct_sca_crv%ISOPEN THEN
                        CLOSE c_sct_sca_crv;
                END IF;
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                IF c_acaiv%ISOPEN THEN
                        CLOSE c_acaiv;
                END IF;
                IF c_person%ISOPEN THEN
                        CLOSE c_person;
                END IF;
                IF c_daiv_secc%ISOPEN THEN
                        CLOSE c_daiv_secc;
                END IF;
                IF c_aa%ISOPEN THEN
                        CLOSE c_aa;
                END IF;
                IF c_sua_ci%ISOPEN THEN
                        CLOSE c_sua_ci;
                END IF;
                IF c_sct_ca_sca%ISOPEN THEN
                        CLOSE c_sct_ca_sca;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_sca_comm');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END enrp_val_sca_comm;
  --
  -- To validate the student course attempt funding source
  FUNCTION ENRP_VAL_SCA_FS(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN
  DECLARE
        v_closed_ind            IGS_FI_FUND_SRC.closed_ind%TYPE;
        v_fsr_fs_exists         VARCHAR2(1)     := 'N';
        v_fsr_cv_exists         VARCHAR2(1)     := 'N';
        CURSOR  c_fs_closed_ind IS
                SELECT  closed_ind
                FROM    IGS_FI_FUND_SRC
                WHERE   funding_source  = p_funding_source;
        CURSOR  c_chk_fsr_fs IS
                SELECT  'Y'
                FROM    IGS_FI_FND_SRC_RSTN
                WHERE   course_cd = p_course_cd                 AND
                        version_number = p_version_number       AND
                        funding_source = p_funding_source       AND
                        restricted_ind = 'Y';
        CURSOR  c_chk_fsr_cv IS
                SELECT  'Y'
                FROM    IGS_FI_FND_SRC_RSTN
                WHERE   course_cd = p_course_cd                 AND
                        version_number = p_version_number       AND
                        restricted_ind = 'Y';
  BEGIN
        -- This module validates the IGS_FI_FUND_SRC
        -- from the IGS_EN_STDNT_PS_ATT.
        -- checking if p_funding_source is not set
        IF (p_funding_source IS NULL) THEN
                p_message_name := null;
                RETURN TRUE;
        END IF;
        -- checking whether the IGS_FI_FUND_SRC is
        -- closed in the IGS_FI_FUND_SRC table
        OPEN  c_fs_closed_ind;
        FETCH c_fs_closed_ind INTO v_closed_ind;
        CLOSE c_fs_closed_ind;
        IF (v_closed_ind = 'Y') THEN
                p_message_name := 'IGS_PS_FUND_SOURCE_CLOSED';
                RETURN FALSE;
        END IF;
        -- the IGS_FI_FUND_SRC isn't closed in
        -- the IGS_FI_FUND_SRC table so
        -- check that the IGS_FI_FUND_SRC in the
        -- IGS_FI_FND_SRC_RSTN table
        -- doesn't breach existing restrictions
        OPEN  c_chk_fsr_cv;
        FETCH c_chk_fsr_cv INTO v_fsr_cv_exists;
        CLOSE c_chk_fsr_cv;
        -- If any restrictions exist for this course version, then one of them must
        -- be for the given funding source.
        IF v_fsr_cv_exists = 'Y' THEN
                OPEN  c_chk_fsr_fs;
                FETCH c_chk_fsr_fs INTO v_fsr_fs_exists;
                CLOSE c_chk_fsr_fs;
                IF v_fsr_fs_exists = 'N' THEN
                        p_message_name := 'IGS_EN_FUND_SOURCE_NOT_ALLOWD';
                        RETURN FALSE;
                END IF;
        END IF;
        -- there were no closed_inds, and no IGS_FI_FUND_SRC
        -- restrictions
        p_message_name := null;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_fs_closed_ind%ISOPEN THEN
                        CLOSE c_fs_closed_ind;
                END IF;
                IF c_chk_fsr_fs%ISOPEN THEN
                        CLOSE c_chk_fsr_fs;
                END IF;
                IF c_chk_fsr_cv%ISOPEN THEN
                        CLOSE c_chk_fsr_cv;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.ENRP_VAL_SCA_FS');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
  END ENRP_VAL_SCA_FS;
  --
  -- Validate the IGS_PS_OFR_PAT for a IGS_EN_STDNT_PS_ATT
  FUNCTION enrp_val_sca_cop(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
    BEGIN
    DECLARE
        v_other_detail          VARCHAR2(255);
        v_cop_rec               IGS_PS_OFR_PAT%ROWTYPE;
        v_ci_rec                IGS_CA_INST%ROWTYPE;
        v_cs_scs                IGS_CA_STAT.s_cal_status%TYPE;
        cst_active              CONSTANT VARCHAR2(8):= 'ACTIVE';
        CURSOR  c_cop_rec IS
                SELECT  *
                FROM    IGS_PS_OFR_PAT
                WHERE   course_cd          = p_course_cd        AND
                        version_number     = p_version_number   AND
                        location_cd        = p_location_cd      AND
                        attendance_mode    = p_attendance_mode  AND
                        attendance_type    = p_attendance_type  AND
                        cal_type           = p_cal_type         AND
                        ci_sequence_number = p_ci_sequence_number;
        CURSOR  c_ci_rec IS
                SELECT  *
                FROM    IGS_CA_INST
                WHERE   cal_type = p_cal_type AND
                        sequence_number = p_ci_sequence_number;
        CURSOR  c_cs_scs IS
                SELECT  s_cal_status
                FROM    IGS_CA_STAT,
                        IGS_CA_INST
                WHERE   IGS_CA_STAT.cal_status = v_ci_rec.cal_status;
                -- WHERE        IGS_CA_STAT.cal_status = IGS_CA_INST.cal_status;
    BEGIN
        -- This module validates the IGS_PS_OFR_PAT
        -- for the curent IGS_EN_STDNT_PS_ATT.
        -- checking if the IGS_PS_OFR_PAT
        -- offered_ind is set to 'N'
        OPEN  c_cop_rec;
        FETCH c_cop_rec INTO v_cop_rec;
        -- a record has been found
        IF (c_cop_rec%FOUND) THEN
                -- if the IGS_PS_OFR_PAT offered_ind
                -- is set to 'N'
                IF (v_cop_rec.offered_ind = 'N') THEN
                        CLOSE c_cop_rec;
                        p_message_name := 'IGS_EN_INVALID_STUD_CRS_OFFER';
                        RETURN FALSE;
                -- if the IGS_PS_OFR_PAT offered_ind
                -- is set to 'Y'
                ELSE
                        IF (v_cop_rec.offered_ind = 'Y') THEN
                                OPEN  c_ci_rec;
                                FETCH c_ci_rec INTO v_ci_rec;
                                OPEN  c_cs_scs;
                                FETCH c_cs_scs INTO v_cs_scs;
                                -- the offered_ind for IGS_PS_OFR_PAT was
                                -- set to 'Y' and the s_cal_status is not set to 'ACTIVE'
                                IF (v_cs_scs <> 'ACTIVE') THEN
                                        CLOSE c_cs_scs;
                                        CLOSE c_ci_rec;
                                        CLOSE c_cop_rec;
                                        p_message_name := 'IGS_EN_CAL_INST_NOT_ACTIVE';
                                        RETURN FALSE;
                                ELSE
                                        IF (v_cs_scs = 'ACTIVE') THEN
                                                -- the offered_ind for IGS_PS_OFR_PAT was
                                                -- set to 'Y' and the s_cal_status is set to 'ACTIVE'
                                                CLOSE c_cs_scs;
                                                CLOSE c_ci_rec;
                                                CLOSE c_cop_rec;
                                                p_message_name := null;
                                                RETURN TRUE;
                                        END IF;
                                END IF;
                        END IF;
                END IF;
        ELSE
                -- a record hasn't been found
                CLOSE c_cop_rec;
                p_message_name := 'IGS_EN_INVALID_STUD_CRS_OFFER';
                RETURN FALSE;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.enrp_val_sca_cop');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
    END;
    END enrp_val_sca_cop;
  END;
  --

  -- A FUNCTION enrp_val_sca_fc in this package has been removed as this will not be invoked
  -- as per the build changes for the Fee clac Build (Bug 1851586)
  -- This function validates whether the Student Program Attempt had an assessment
  -- record with the specified Fee Category.
  -- was invoked from  IGS_EN_STDNT_PS_ATT_PKG.

  --
  -- Validate if IGS_FI_FEE_CAT.fee_cat is closed.
  FUNCTION finp_val_fc_closed(
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN        --FINP_VAL_FC_CLOSED
        --Validate if IGS_FI_FEE_CAT.fee_cat is closed
  DECLARE
        v_closed_ind IGS_FI_FEE_CAT.closed_ind%type;
        CURSOR c_fc IS
                SELECT  fc.closed_ind
                FROM    IGS_FI_FEE_CAT fc
                WHERE   fc.fee_cat = p_fee_cat;
  BEGIN
        --- Set the default message number
        p_message_name := null;
        OPEN c_fc;
        FETCH c_fc INTO v_closed_ind;
        IF (c_fc%FOUND)THEN
                IF (v_closed_ind = 'Y') THEN
                        p_message_name := 'IGS_FI_FEECAT_CLOSED';
                        CLOSE c_fc;
                        RETURN FALSE;
                END IF;
        END IF;
        CLOSE c_fc;
        RETURN TRUE;
  END;
/*
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCA.finp_val_fc_closed');
                IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
*/
  END finp_val_fc_closed;

  FUNCTION enrf_val_sua_term_sca_comm(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_commencement_dt IN DATE,
  p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS

    CURSOR c_sua_term (cp_person_id IGS_EN_STDNT_PS_ATT.PERSON_ID%TYPE,
	                   cp_course_cd IGS_EN_STDNT_PS_ATT.COURSE_CD%TYPE) IS
	SELECT tlv.LOAD_END_DT
    From igs_ca_teach_to_load_V tlv,
	     igs_en_su_attempt sua
    Where sua.person_id = cp_person_id
	AND sua.course_cd = cp_course_cd
	AND sua.unit_attempt_status NOT IN ('DROPPED','UNCONFIRM')
	AND teach_cal_type = sua.cal_type
    And teach_ci_sequence_number = sua.ci_sequence_number
    Order by LOAD_START_DT asc;

	v_load_end_dt IGS_CA_INST.END_DT%TYPE;

  BEGIN
    -- cursor selects the earlier term calendar in which there is an
	-- active unit attempt for the passed in person and program.
    OPEN c_sua_term(p_person_id, p_course_cd);
	FETCH c_sua_term INTO v_load_end_dt;
	IF c_sua_term%FOUND THEN
	  CLOSE c_sua_term;
	  -- if the commencement date is greater than the end date
	  -- of the earliest term calendar then return false
	  IF p_commencement_dt > v_load_end_dt THEN
	    p_message_name := 'IGS_EN_COMM_LESS_SUA_TERM';
		RETURN FALSE;
	  END IF;
	ELSE
	  CLOSE c_sua_term;
	END IF;

    RETURN TRUE;

  END enrf_val_sua_term_sca_comm;

  FUNCTION del_unconfirm_sua_for_reopen(
   p_person_id  IN    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
   p_course_cd   IN  IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
   RETURN BOOLEAN
   AS
 CURSOR c_sua IS
    SELECT  uoo_id
    FROM  IGS_EN_SU_ATTEMPT sua
    WHERE sua.person_id = p_person_id
    AND   sua.course_cd = p_course_cd
    AND   sua.unit_attempt_status = 'UNCONFIRM' ;
    returnFlag  BOOLEAN  := TRUE;
  BEGIN
  FOR v_sua_rec IN c_sua LOOP

        IF IGS_EN_FUTURE_DT_TRANS.del_sua_for_reopen(p_person_id,p_course_cd,v_sua_rec.uoo_id) <> TRUE THEN
            returnFlag := FALSE;

           EXIT ;
        END IF;
  END LOOP;

  RETURN  returnFlag ;
END del_unconfirm_sua_for_reopen;

FUNCTION validate_unconfirm_program(
  cp_rowid ROWID)
  RETURN BOOLEAN
  IS
  --cursor to fetch the program attempts for the admission application in context
   Cursor cur_spa(cp_rowid ROWID) IS
    Select spa.rowid,spa.*
    from igs_en_stdnt_ps_att_all spa
    where spa.rowid = cp_rowid;

  --cursor to check if any unit attempts other than unconfirmed unit attempts
  --exist for a program attempt
   Cursor cur_sua(cp_person_id NUMBER,
                  cp_course_cd VARCHAR2) IS
    Select 'x'
    from IGS_EN_SU_ATTEMPT_ALL sua
    where sua.person_id=cp_person_id
    and   sua.course_cd=cp_course_cd
    and   sua.unit_attempt_status <> 'UNCONFIRM';

    --cursor to fetch unit set attempts for the admission application in context
    Cursor cur_susa(cp_person_id NUMBER,
                    cp_course_cd VARCHAR2) IS
    Select susa.rowid,susa.*
    from  igs_as_su_setatmpt susa
    where susa.person_id=cp_person_id
    and   susa.course_cd=cp_course_cd;

    --cursor to check unconfirm unit attempts exist
    Cursor cur_sua_unconfirm(cp_person_id NUMBER,
                  cp_course_cd VARCHAR2) IS
    Select 'x'
    from IGS_EN_SU_ATTEMPT_ALL sua
    where sua.person_id=cp_person_id
    and   sua.course_cd=cp_course_cd
    and   sua.unit_attempt_status = 'UNCONFIRM';

    --cursor to find course type
    Cursor cur_ps_ctype(cp_course_cd VARCHAR2,
                  cp_version_number NUMBER,
                  cp_person_id      NUMBER) IS
    Select ps.course_type
    from igs_ps_ver ps,
    igs_en_stdnt_ps_att  sca
    where  ps.course_cd=cp_course_cd
    and    ps.version_number = cp_version_number
    and    sca.course_cd = ps.course_cd
    and    sca.version_number = ps.version_number
    and    sca.person_id = cp_person_id;

    --Cursor to check secondary prgoram exist for a career
    Cursor cur_ps_sec(cp_person_id  NUMBER,
                      cp_course_type VARCHAR2) IS
    SELECT spa.course_cd
    FROM   igs_en_stdnt_ps_att spa,
            igs_ps_ver pv
    WHERE  spa.person_id = cp_person_id
    AND    spa.primary_program_type = 'SECONDARY'
    AND    spa.STUDENT_CONFIRMED_IND = 'Y'
    AND    spa.course_cd = pv.course_cd
    AND    spa.version_number = pv.version_number
    AND    pv.course_type = cp_course_type;

    -- Cursor to check secondry program is destination of a future
    CURSOR cur_term_cal(cp_person_id  NUMBER,
                        cp_course_cd VARCHAR2) IS
    SELECT effective_term_cal_type,effective_term_sequence_num
    FROM IGS_PS_STDNT_TRN  trnsf
    WHERE trnsf.person_id = cp_person_id
    AND trnsf.course_cd = cp_course_cd
    AND trnsf.STATUS_FLAG = 'U' ;

     CURSOR cur_pri_prg(cp_person_id  NUMBER,
                       cp_course_type VARCHAR2) IS
     SELECT 'x'
    FROM   igs_en_stdnt_ps_att spa,
           igs_ps_ver pv
    WHERE  spa.person_id = cp_person_id
    AND    spa.primary_program_type = 'PRIMARY'
    AND    spa.course_cd = pv.course_cd
    AND    spa.version_number = pv.version_number
    AND    pv.course_type <> cp_course_type;

    CURSOR cur_confirm_prg(cp_person_id NUMBER,
                          cp_course_cd  VARCHAR2) IS
    SELECT 'x'
    FROM   igs_en_stdnt_ps_att spa
    WHERE  spa.person_id = cp_person_id
    AND    spa.course_cd <> cp_course_cd
    AND    spa.student_confirmed_ind = 'Y' ;


    l_sua_check VARCHAR2(1);
    l_sua_unconfirm_check VARCHAR2(1);
    l_career  igs_ps_ver.course_type%TYPE;
    l_sec_courseCD igs_en_stdnt_ps_att.course_cd%TYPE;
    l_primaryInd     igs_en_stdnt_ps_att.primary_program_type%TYPE;
    l_pri_prg  VARCHAR2(1);

    BEGIN
      -- fetch all program attempts using the application context parameters passed.
      --loop through the program attempts found
      FOR vcur_spa IN cur_spa(cp_rowid) LOOP

         l_primaryInd := vcur_spa.primary_program_type;
        -- check if any unit attempts exist for the student and program
        -- which are in a status other than Unconfirmed.
        OPEN cur_sua(vcur_spa.person_id,vcur_spa.course_cd);
        FETCH cur_sua INTO l_sua_check;
        -- if unit attempts in status other than in UNCONFIRM status exist
        IF cur_sua%FOUND THEN
            -- program attempt status cannot be changed
            -- have to pass back program code as part of error message to be displayed in admissions

            CLOSE cur_sua;

            FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_PROG_FAIL');
            FND_MESSAGE.SET_TOKEN('PROGRAM_CD',vcur_spa.course_cd);
            IGS_GE_MSG_STACK.ADD;

	        RETURN FALSE;
        ELSE
            -- only unit attempts in status UNCONFIRM or no unit attempts exist
            CLOSE cur_sua;

            --do program attempt processing
            --check if system is in career mode
             IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y' THEN

           	    -- perform logic for primary and secondary programs
                -- if program being processed is primary and confirmed
                IF NVL(vcur_spa.PRIMARY_PROGRAM_TYPE,'SECONDARY') = 'PRIMARY'
                   AND vcur_spa.STUDENT_CONFIRMED_IND = 'Y' THEN

                   OPEN cur_ps_ctype(vcur_spa.course_cd,vcur_spa.VERSION_NUMBER,vcur_spa.person_id);
                   FETCH  cur_ps_ctype into l_career;
                   CLOSE cur_ps_ctype;


                   IF vcur_spa.key_program = 'Y' THEN
                      OPEN cur_pri_prg(vcur_spa.person_id,l_career);
                      FETCH cur_pri_prg INTO l_pri_prg;
                      IF cur_pri_prg%FOUND THEN
                        CLOSE cur_pri_prg;
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_KEYPRG_FAIL');
                        FND_MESSAGE.SET_TOKEN('PROGRAM_CD',vcur_spa.course_cd);
                        IGS_GE_MSG_STACK.ADD;

                        RETURN FALSE;
                      END IF;
                      CLOSE cur_pri_prg;
                   END IF;

                   OPEN cur_sua_unconfirm(vcur_spa.person_id,vcur_spa.course_cd);
                   FETCH cur_sua_unconfirm into l_sua_unconfirm_check;


                   OPEN cur_ps_sec(vcur_spa.person_id,l_career);

                   FETCH  cur_ps_sec into l_sec_courseCD;
                   --unconfirm unit exist and secondary program also exist
                   IF cur_sua_unconfirm%FOUND AND cur_ps_sec%FOUND THEN
                      CLOSE cur_sua_unconfirm;
                      CLOSE cur_ps_sec;

                      FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_PROGPRIM_FAIL');
                      FND_MESSAGE.SET_TOKEN('PROGRAM_CD',vcur_spa.course_cd);
                      IGS_GE_MSG_STACK.ADD;


                      RETURN FALSE;

                   END IF;
                   --Only unconfirm unit exist


                   IF del_unconfirm_sua_for_reopen(vcur_spa.person_id,vcur_spa.course_cd) <> TRUE THEN
                          FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_DELUNIT_FAIL');
                          FND_MESSAGE.SET_TOKEN('PROGRAM_CD',vcur_spa.course_cd);
                          IGS_GE_MSG_STACK.ADD;
                          IF  cur_sua_unconfirm%ISOPEN  THEN
                               CLOSE cur_sua_unconfirm;
                          END IF;

                          IF cur_ps_sec%ISOPEN THEN
                              CLOSE cur_ps_sec;
                          END IF;
                          RETURN FALSE;
                    END IF ;
                      l_primaryInd := null;


                     IF  cur_sua_unconfirm%ISOPEN  THEN
                            CLOSE cur_sua_unconfirm;
                     END IF;

                     IF cur_ps_sec%ISOPEN THEN
                           CLOSE cur_ps_sec;
                     END IF;

                 ELSIF  NVL(vcur_spa.PRIMARY_PROGRAM_TYPE,'SECONDARY') = 'PRIMARY'
                        AND vcur_spa.STUDENT_CONFIRMED_IND <> 'Y' THEN
                  --program is primary in career and unconfirmed
                         IF del_unconfirm_sua_for_reopen(vcur_spa.person_id,vcur_spa.course_cd) <> TRUE THEN
                            FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_DELUNIT_FAIL');
                            FND_MESSAGE.SET_TOKEN('PROGRAM_CD',vcur_spa.course_cd);
                            IGS_GE_MSG_STACK.ADD;


                            RETURN FALSE;
                          END IF ;
                        l_primaryInd := null;

                 ELSIF  NVL(vcur_spa.PRIMARY_PROGRAM_TYPE,'SECONDARY') = 'SECONDARY'   THEN
                 --program type is null or secondary in the career
                         IF del_unconfirm_sua_for_reopen(vcur_spa.person_id,vcur_spa.course_cd) <> TRUE THEN
                            FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_DELUNIT_FAIL');
                            FND_MESSAGE.SET_TOKEN('PROGRAM_CD',vcur_spa.course_cd);
                            IGS_GE_MSG_STACK.ADD;

                           RETURN FALSE;
                         END IF ;
                        l_primaryInd := vcur_spa.primary_program_type;

                           -- delete future dated transfer
                           FOR vcur_termcal IN cur_term_cal(vcur_spa.person_id,vcur_spa.course_cd)
                              LOOP
                                   IGS_EN_FUTURE_DT_TRANS.cleanup_dest_program(vcur_spa.person_id,
                                                                               vcur_spa.course_cd,
                                                                               vcur_termcal.effective_term_cal_type,
                                                                               vcur_termcal.effective_term_sequence_num,
                                                                               'CLEANUP');

                           END LOOP;

                  END IF;  -- end of check for primary confirmed program
         ELSE --  system is in program mode
               IF vcur_spa.key_program = 'Y' THEN
                      OPEN cur_confirm_prg(vcur_spa.person_id,vcur_spa.course_cd);
                      FETCH cur_confirm_prg INTO l_pri_prg;
                      IF cur_confirm_prg%FOUND THEN
                        CLOSE cur_confirm_prg;
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_KEYPRG_FAIL');
                        FND_MESSAGE.SET_TOKEN('PROGRAM_CD',vcur_spa.course_cd);
                        IGS_GE_MSG_STACK.ADD;

                        RETURN FALSE;
                      END IF;
                      CLOSE cur_confirm_prg;
                   END IF;

              IF del_unconfirm_sua_for_reopen(vcur_spa.person_id,vcur_spa.course_cd) <> TRUE THEN
                          FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_DELUNIT_FAIL');
                          FND_MESSAGE.SET_TOKEN('PROGRAM_CD',vcur_spa.course_cd);
                          IGS_GE_MSG_STACK.ADD;
                          RETURN FALSE;
              END IF ;
             l_primaryInd := vcur_spa.primary_program_type;

        END IF; -- end of check for career mode


                -- if the Pre-Enrollment Year profile option is set to Y
                   IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN

                                      -- do unit set processing
                                       --loop through the unit sets attempts for the program attempt
                                       FOR vcur_susa IN cur_susa(vcur_spa.person_id,vcur_spa.course_cd) LOOP

                                           IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW(
                                            X_ROWID                     => vcur_susa.rowid,
                                            X_PERSON_ID                 => vcur_susa.person_id        ,
                                            X_COURSE_CD                 => vcur_susa.course_cd        ,
                                            X_UNIT_SET_CD               => vcur_susa.unit_set_cd      ,
                                            X_SEQUENCE_NUMBER           => vcur_susa.sequence_number,
                                            X_US_VERSION_NUMBER         => vcur_susa.us_version_number,
                                            X_SELECTION_DT              => NULL,
                                            X_STUDENT_CONFIRMED_IND     => 'N',
                                            X_END_DT                    => NULL                   ,
                                            X_PARENT_UNIT_SET_CD        => vcur_susa.parent_unit_set_cd       ,
                                            X_PARENT_SEQUENCE_NUMBER    => vcur_susa.parent_sequence_number   ,
                                            X_PRIMARY_SET_IND           => vcur_susa.primary_set_ind          ,
                                            X_VOLUNTARY_END_IND         => 'N'        ,
                                            X_AUTHORISED_PERSON_ID      => vcur_susa.authorised_person_id     ,
                                            X_AUTHORISED_ON             => vcur_susa.authorised_on            ,
                                            X_OVERRIDE_TITLE            => vcur_susa.override_title           ,
                                            X_RQRMNTS_COMPLETE_IND      => vcur_susa.rqrmnts_complete_ind     ,
                                            X_RQRMNTS_COMPLETE_DT       => NULL      ,
                                            X_S_COMPLETED_SOURCE_TYPE   => vcur_susa.s_completed_source_type  ,
                                            X_CATALOG_CAL_TYPE          => NULL   ,
                                            X_CATALOG_SEQ_NUM           => NULL    ,
                                            X_ATTRIBUTE_CATEGORY        => vcur_susa.attribute_category ,
                                            X_ATTRIBUTE1                => vcur_susa.attribute1          ,
                                            X_ATTRIBUTE2                => vcur_susa.attribute2          ,
                                            X_ATTRIBUTE3                => vcur_susa.attribute3          ,
                                            X_ATTRIBUTE4                => vcur_susa.attribute4          ,
                                            X_ATTRIBUTE5                => vcur_susa.attribute5          ,
                                            X_ATTRIBUTE6                => vcur_susa.attribute6          ,
                                            X_ATTRIBUTE7                => vcur_susa.attribute7          ,
                                            X_ATTRIBUTE8                => vcur_susa.attribute8          ,
                                            X_ATTRIBUTE9                => vcur_susa.attribute9          ,
                                            X_ATTRIBUTE10               => vcur_susa.attribute10         ,
                                            X_ATTRIBUTE11               => vcur_susa.attribute11         ,
                                            X_ATTRIBUTE12               => vcur_susa.attribute12         ,
                                            X_ATTRIBUTE13               => vcur_susa.attribute13         ,
                                            X_ATTRIBUTE14               => vcur_susa.attribute14         ,
                                            X_ATTRIBUTE15               => vcur_susa.attribute15         ,
                                            X_ATTRIBUTE16               => vcur_susa.attribute16         ,
                                            X_ATTRIBUTE17               => vcur_susa.attribute17         ,
                                            X_ATTRIBUTE18               => vcur_susa.attribute18         ,
                                            X_ATTRIBUTE19               => vcur_susa.attribute19         ,
                                            X_ATTRIBUTE20               => vcur_susa.attribute20         ,
                                            X_MODE                      => 'R');

                                       END LOOP;  -- end of looping through unit sets attempts
                   END IF; --end of pre-enrollment year check

               IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                   X_ROWID => vcur_spa.rowid,
                   X_PERSON_ID  => vcur_spa.PERSON_ID,
                   X_COURSE_CD => vcur_spa.COURSE_CD,
                   X_ADVANCED_STANDING_IND => vcur_spa.ADVANCED_STANDING_IND,
                   X_FEE_CAT => vcur_spa.FEE_CAT,
                   X_CORRESPONDENCE_CAT => vcur_spa.CORRESPONDENCE_CAT,
                   X_SELF_HELP_GROUP_IND => vcur_spa.SELF_HELP_GROUP_IND,
                   X_LOGICAL_DELETE_DT  => vcur_spa.LOGICAL_DELETE_DT,
                   X_ADM_ADMISSION_APPL_NUMBER  => vcur_spa.ADM_ADMISSION_APPL_NUMBER,
                   X_ADM_NOMINATED_COURSE_CD => vcur_spa.ADM_NOMINATED_COURSE_CD,
                   X_ADM_SEQUENCE_NUMBER  => vcur_spa.ADM_SEQUENCE_NUMBER,
                   X_VERSION_NUMBER  => vcur_spa.VERSION_NUMBER,
                   X_CAL_TYPE => vcur_spa.CAL_TYPE,
                   X_LOCATION_CD => vcur_spa.LOCATION_CD,
                   X_ATTENDANCE_MODE => vcur_spa.ATTENDANCE_MODE,
                   X_ATTENDANCE_TYPE => vcur_spa.ATTENDANCE_TYPE,
                   X_COO_ID  => vcur_spa.COO_ID,
                   X_STUDENT_CONFIRMED_IND => 'N',
                   X_COMMENCEMENT_DT  =>  NULL,
                   X_COURSE_ATTEMPT_STATUS => 'UNCONFIRM',
                   X_PROGRESSION_STATUS => vcur_spa.PROGRESSION_STATUS,
                   X_DERIVED_ATT_TYPE => vcur_spa.DERIVED_ATT_TYPE,
                   X_DERIVED_ATT_MODE => vcur_spa.DERIVED_ATT_MODE,
                   X_PROVISIONAL_IND => vcur_spa.PROVISIONAL_IND  ,
                   X_DISCONTINUED_DT  => vcur_spa.DISCONTINUED_DT,
                   X_DISCONTINUATION_REASON_CD => vcur_spa.DISCONTINUATION_REASON_CD,
                   X_LAPSED_DT  => vcur_spa.LAPSED_DT,
                   X_FUNDING_SOURCE => vcur_spa.FUNDING_SOURCE,
                   X_EXAM_LOCATION_CD => vcur_spa.EXAM_LOCATION_CD,
                   X_DERIVED_COMPLETION_YR  => vcur_spa.DERIVED_COMPLETION_YR,
                   X_DERIVED_COMPLETION_PERD => vcur_spa.DERIVED_COMPLETION_PERD,
                   X_NOMINATED_COMPLETION_YR  => vcur_spa.nominated_completion_yr,
                   X_NOMINATED_COMPLETION_PERD => vcur_spa.NOMINATED_COMPLETION_PERD,
                   X_RULE_CHECK_IND => vcur_spa.RULE_CHECK_IND,
                   X_WAIVE_OPTION_CHECK_IND => vcur_spa.WAIVE_OPTION_CHECK_IND,
                   X_LAST_RULE_CHECK_DT  => vcur_spa.LAST_RULE_CHECK_DT,
                   X_PUBLISH_OUTCOMES_IND => vcur_spa.PUBLISH_OUTCOMES_IND,
                   X_COURSE_RQRMNT_COMPLETE_IND => vcur_spa.COURSE_RQRMNT_COMPLETE_IND,
                   X_COURSE_RQRMNTS_COMPLETE_DT  => vcur_spa.COURSE_RQRMNTS_COMPLETE_DT,
                   X_S_COMPLETED_SOURCE_TYPE => vcur_spa.S_COMPLETED_SOURCE_TYPE,
                   X_OVERRIDE_TIME_LIMITATION  => vcur_spa.OVERRIDE_TIME_LIMITATION,
                   X_MODE =>  'R',
                   x_last_date_of_attendance => vcur_spa.LAST_DATE_OF_ATTENDANCE,
                   x_dropped_by     => vcur_spa.DROPPED_BY,
                   X_IGS_PR_CLASS_STD_ID => vcur_spa.IGS_PR_CLASS_STD_ID,
                   x_primary_program_type      => l_primaryInd,
                   x_primary_prog_type_source  => vcur_spa.PRIMARY_PROG_TYPE_SOURCE,
                   x_catalog_cal_type          => NULL,
                   x_catalog_seq_num           => NULL,
                   x_key_program               => 'N',
                   x_override_cmpl_dt  => vcur_spa.OVERRIDE_CMPL_DT,
                   x_manual_ovr_cmpl_dt_ind  =>  vcur_spa.MANUAL_OVR_CMPL_DT_IND,
                   X_ATTRIBUTE_CATEGORY                => vcur_spa.ATTRIBUTE_CATEGORY,
                   X_ATTRIBUTE1                        => vcur_spa.ATTRIBUTE1,
                   X_ATTRIBUTE2                        => vcur_spa.ATTRIBUTE2,
                   X_ATTRIBUTE3                        => vcur_spa.ATTRIBUTE3,
                   X_ATTRIBUTE4                        => vcur_spa.ATTRIBUTE4,
                   X_ATTRIBUTE5                        => vcur_spa.ATTRIBUTE5,
                   X_ATTRIBUTE6                        => vcur_spa.ATTRIBUTE6,
                   X_ATTRIBUTE7                        => vcur_spa.ATTRIBUTE7,
                   X_ATTRIBUTE8                        => vcur_spa.ATTRIBUTE8,
                   X_ATTRIBUTE9                        => vcur_spa.ATTRIBUTE9,
                   X_ATTRIBUTE10                       => vcur_spa.ATTRIBUTE10,
                   X_ATTRIBUTE11                       => vcur_spa.ATTRIBUTE11,
                   X_ATTRIBUTE12                       => vcur_spa.ATTRIBUTE12,
                   X_ATTRIBUTE13                       => vcur_spa.ATTRIBUTE13,
                   X_ATTRIBUTE14                       => vcur_spa.ATTRIBUTE14,
                   X_ATTRIBUTE15                       => vcur_spa.ATTRIBUTE15,
                   X_ATTRIBUTE16                       => vcur_spa.ATTRIBUTE16,
                   X_ATTRIBUTE17                       => vcur_spa.ATTRIBUTE17,
                   X_ATTRIBUTE18                       => vcur_spa.ATTRIBUTE18,
                   X_ATTRIBUTE19                       => vcur_spa.ATTRIBUTE19,
                   X_ATTRIBUTE20                       => vcur_spa.ATTRIBUTE20,
       X_FUTURE_DATED_TRANS_FLAG           => vcur_spa.FUTURE_DATED_TRANS_FLAG);







             END IF;  --   end  of check for unconfirmed unit attempts


      END LOOP;    -- end of looping through the program attempts

      RETURN TRUE;
    END validate_unconfirm_program; --end of function

FUNCTION handle_rederive_prog_att(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER,
  p_message OUT NOCOPY  VARCHAR2)
  RETURN BOOLEAN
  IS

  --cursor to fetch the program attempts for the admission application in context
   Cursor cur_spa(cp_person_id NUMBER,
                  cp_adm_appl_number NUMBER,
                  cp_adm_nom_course_cd VARCHAR2,
                  cp_adm_sequence_num NUMBER) IS
    Select spa.rowid
    from igs_en_stdnt_ps_att_all spa
    where spa.person_id=cp_person_id
    and  spa.adm_admission_appl_number=cp_adm_appl_number
    and  spa.adm_nominated_course_cd=cp_adm_nom_course_cd
    and spa.adm_sequence_number = cp_adm_sequence_num;

    -- Get the details of
    CURSOR cur_spa_en IS
      SELECT spa.rowid
        FROM igs_en_stdnt_ps_att_all spa
       WHERE spa.person_id = p_person_id
         AND spa.course_cd = p_nominated_course_cd;

   l_message VARCHAR2(200);
    BEGIN
      -- fetch all program attempts using the application context parameters passed.
      --loop through the program attempts found

      IF p_admission_appl_number IS NULL AND p_sequence_number IS NULL THEN
	      FOR vcur_spa_en IN cur_spa_en LOOP
		 IF NOT validate_unconfirm_program(vcur_spa_en.rowid) THEN
	            RETURN FALSE;
                 END IF;
	      END LOOP;
      ELSE
	      FOR vcur_spa IN cur_spa(p_person_id,
				    p_admission_appl_number,
				    p_nominated_course_cd,
				    p_sequence_number) LOOP

		IF NOT validate_unconfirm_program(vcur_spa.rowid) THEN
			RETURN FALSE;
		END IF;

	      END LOOP;    -- end of looping through the program attempts
      END IF;
      RETURN TRUE;
    END handle_rederive_prog_att; --end of function




END IGS_EN_VAL_SCA;

/
