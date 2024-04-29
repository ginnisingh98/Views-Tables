--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_CA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_CA" AS
/* $Header: IGSRE04B.pls 120.0 2005/06/01 21:14:09 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function genp_val_sdtt_sess removed
  --kkillams    11-11-2002      As part of Legacy Build bug no:2661533,
  --                            New parameter p_legacy is added to following functions
  --                            resp_val_ca_minsbmsn,resp_val_ca_maxsbmsn and resp_val_ca_topic
  -------------------------------------------------------------------------------------------
  --
/*****  Bug No :   1956374
        Task   :   Duplicated Procedures and functions
        PROCEDURE  admp_val_ca_comm is removed and reference is changed
||  Removed program unit (RESP_VAL_CA_ATT_PERC) - from the spec and body. -- kdande
        PROCEDURE  admp_val_ca_comm_val is removed and reference is changed *****/

  -- Validate adm IGS_PS_COURSE application proposed commencement date.

  FUNCTION admp_val_acai_comm(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_crv_version_number IN NUMBER ,

  p_acai_admission_appl_number IN NUMBER ,

  p_acai_nominated_course_cd IN VARCHAR2 ,

  p_acai_sequence_number IN NUMBER ,

  p_adm_cal_type IN VARCHAR2 ,

  p_adm_ci_sequence_number IN NUMBER ,

  p_adm_outcome_status IN VARCHAR2 ,

  p_prpsd_commencement_dt IN DATE ,

  p_min_submission_dt IN DATE ,

  p_ca_sequence_number IN OUT NOCOPY NUMBER ,

  p_parent IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN AS

  BEGIN -- admp_val_acai_comm

        -- This modules validates IGS_AD_PS_APPL_INST.prpsd_commencement_dt.

        -- Validations are:

        -- * IGS_RE_CANDIDATURE must exist for the IGS_AD_PS_APPL_INST.

        -- * Prpsd_commencement_dt must be greater than the earlier of the IGS_PS_COURSE

        --      start date or the admission academic period earliest research start date.

        -- * Warn if the Prpsd_commencement_dt is prior to passed census dates for

        --      the admission academic period.

  DECLARE

        v_ca_sequence_number            IGS_RE_CANDIDATURE.sequence_number%TYPE;

        v_candidature_exists_ind        VARCHAR(1);

        v_message_name                  VARCHAR2(30);

  BEGIN

        -- Set the default message number

        p_message_name := NULL;

        v_candidature_exists_ind := NULL;

        v_ca_sequence_number := p_ca_sequence_number;

        IF p_prpsd_commencement_dt IS NOT NULL THEN

                -- Validate research IGS_RE_CANDIDATURE details and commencemnt

                IF IGS_EN_VAL_SCA.admp_val_ca_comm(

                                                p_person_id,

                                                p_course_cd,

                                                p_crv_version_number,

                                                p_acai_admission_appl_number,

                                                p_acai_nominated_course_cd,

                                                p_acai_sequence_number,

                                                p_adm_outcome_status,

                                                p_prpsd_commencement_dt,

                                                p_min_submission_dt,

                                                p_parent,

                                                v_ca_sequence_number,

                                                v_candidature_exists_ind,

                                                v_message_name) = FALSE THEN

                        p_message_name := v_message_name;

                        RETURN FALSE;

                ELSE

                        IF v_candidature_exists_ind = 'N' THEN

                                RETURN TRUE;

                        END IF;

                END IF;

                --Validate commencement date value

                IF IGS_EN_VAL_SCA.admp_val_ca_comm_val(

                                                p_person_id,

                                                p_acai_admission_appl_number,

                                                p_acai_nominated_course_cd,

                                                p_acai_sequence_number,

                                                p_adm_cal_type,

                                                p_adm_ci_sequence_number,

                                                NULL, -- (IGS_PS_COURSE start date)

                                                p_prpsd_commencement_dt,

                                                p_parent,

                                                v_message_name) = FALSE THEN

                        p_message_name := v_message_name;

                        RETURN FALSE;

                ELSE

                        IF v_message_name IS NOT NULL THEN

                                p_message_name := v_message_name;

                                RETURN TRUE;

                        END IF;

                END IF;

        END IF;-- p_commencement_dt

        -- Return the default value

        RETURN TRUE;

  END;

  EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

  END admp_val_acai_comm;

  --

  -- Validate IGS_RE_CANDIDATURE proposed commencement date value.

    --

  -- Validate IGS_RE_CANDIDATURE proposed commencement date.


  -- Validate IGS_RE_CANDIDATURE update.

  FUNCTION resp_val_ca_upd(

  p_person_id IN NUMBER ,

  p_sca_course_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN AS

  --  Change History :
  --  Who       When            What
  -- stutta    05-May-2004   Added c_awd_exists,c_incomp_awd cursors and modified logic to return false
  --                         only if a completed program attempt has all its awards completed.
  --                         If atleast one award is incomplete or no award is associated, return true and
  --                         a warning message. (Bug #3577988)

  BEGIN -- resp_val_ca_upd

        -- This module validates the update of IGS_RE_CANDIDATURE details. Validations are:

        -- IGS_RE_CANDIDATURE cannot be updated if

        -- IGS_EN_STDNT_PS_ATT.course_attempt_status is 'COMPLETED' with all its awards completed.

        -- If atleast one award is incomplete or no award is associated, update is allowed but a

        -- message is returned.


  DECLARE

        cst_completed   CONSTANT        VARCHAR2(10) := 'COMPLETED';

        v_course_attempt_status         IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
        v_dummy VARCHAR2(10);
        CURSOR  c_sca IS

                SELECT  sca.course_attempt_status

                FROM    IGS_EN_STDNT_PS_ATT sca

                WHERE   sca.person_id = p_person_id AND

                        sca.course_cd = p_sca_course_cd;
	CURSOR c_awd_exists IS
	SELECT 'x'
	FROM igs_en_spa_awd_aim
	WHERE person_id = p_person_id
	AND      course_cd = p_sca_course_cd
	AND ( 	end_dt IS NULL OR
		(end_dt IS NOT NULL AND complete_ind = 'Y')
 	    );
	CURSOR c_incomp_awd IS
	SELECT 'x'
	FROM igs_en_spa_awd_aim
	WHERE person_id =  p_person_id
	AND course_cd = p_sca_course_cd
	AND NVL(complete_ind,'N') = 'N'
	AND end_dt IS NULL;

  BEGIN

        p_message_name := NULL;

        IF p_sca_course_cd IS NOT NULL THEN

                OPEN c_sca;

                FETCH c_sca INTO v_course_attempt_status;

                IF c_sca%NOTFOUND THEN

                        CLOSE c_sca;

                        --Invalid parameters, handled elsewhere

                        RETURN TRUE;

                END IF;

                CLOSE c_sca;

                IF v_course_attempt_status = cst_completed THEN
                    OPEN c_awd_exists;
                    FETCH c_awd_exists INTO v_dummy;
                    IF c_awd_exists%FOUND THEN
                    	OPEN c_incomp_awd;
                        FETCH c_incomp_awd INTO v_dummy;
                    	IF c_incomp_awd%FOUND THEN
                    		p_message_name := 'IGS_RE_STDNT_PRG_ATT_COMP';
                    		CLOSE c_awd_exists;
                    		CLOSE c_incomp_awd;
                    		RETURN TRUE;
                    	ELSE
                    		p_message_name :='IGS_RE_CANT_UPD_DET_WHEN_COUR';
                    		CLOSE c_awd_exists;
                    		CLOSE c_incomp_awd;
                    		RETURN FALSE;
                    	END IF;
                    ELSE
                    	p_message_name := 'IGS_RE_STDNT_PRG_ATT_COMP';
                    	CLOSE c_awd_exists;
                    	RETURN TRUE;
                    END IF;
                        END IF;

        END IF;

        RETURN TRUE;

  EXCEPTION

        WHEN OTHERS THEN

                IF (c_sca%ISOPEN) THEN

                        CLOSE c_sca;

                END IF;

                RAISE;

  END;

  EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_ca_upd;

  --

  FUNCTION resp_val_ca_topic(
  p_person_id                   IN NUMBER ,
  p_sca_course_cd               IN VARCHAR2 ,
  p_acai_admission_appl_number  IN NUMBER ,
  p_acai_nominated_course_cd    IN VARCHAR2 ,
  p_acai_sequence_number        IN NUMBER ,
  p_research_topic              IN VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2 ,
  p_legacy                      IN VARCHAR2 )
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : This module validates IGS_RE_CANDIDATURE.research_topic.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        11-11-2002      Modified function logic due to addition of new parameter p_legacy
  ||                                  if p_legacy set to 'Y' then error message should be stacked instead of
  ||                                  returning the function in the normal way else function should behave in
  ||                                  normal way.Legacy Build Bug no: 2661533
  ------------------------------------------------------------------------------*/
  BEGIN -- resp_val_ca_topic
  DECLARE
        v_test                  VARCHAR2(1);
        v_message_name          VARCHAR2(30);
        v_student_confirmed_ind IGS_EN_STDNT_PS_ATT.student_confirmed_ind%TYPE;
        v_s_adm_outcome_status  IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;
        cst_offer               CONSTANT IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'OFFER';
        cst_condoffer           CONSTANT IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'COND-OFFER';
        CURSOR c_sca IS
                SELECT  sca.student_confirmed_ind
                FROM    IGS_EN_STDNT_PS_ATT             sca
                WHERE   sca.person_id                   = p_person_id AND
                        sca.course_cd                   = p_sca_course_cd;
        CURSOR c_aos IS
                SELECT  aos.s_adm_outcome_status
                FROM    IGS_AD_PS_APPL_INST     acai,
                        IGS_AD_OU_STAT          aos
                WHERE   acai.person_id                  = p_person_id AND
                        acai.admission_appl_number      = p_acai_admission_appl_number AND
                        acai.nominated_course_cd        = p_acai_nominated_course_cd AND
                        acai.sequence_number            = p_acai_sequence_number AND
                        acai.adm_outcome_status         = aos.adm_outcome_status;
  BEGIN
        -- Setup the default message number value.
        p_message_name := null;
        IF p_research_topic IS NULL THEN
                -- Validate against student IGS_PS_COURSE attempt
                IF p_sca_course_cd IS NOT NULL THEN
                        OPEN c_sca;
                        FETCH c_sca INTO v_student_confirmed_ind;
                        -- Invalid parameters, handled elsewhere
                        IF c_sca%NOTFOUND THEN
                                CLOSE c_sca;
                                RETURN TRUE;
                        END IF;
                        CLOSE c_sca;
                        IF v_student_confirmed_ind = 'Y' THEN
                                p_message_name := 'IGS_RE_CAN_TOPIC_REQ_CRS_ATMP';
                                IF p_legacy ='Y' THEN
                                   fnd_message.set_name('IGS',p_message_name);
                                   fnd_msg_pub.add;
                                END IF;
                                RETURN FALSE;
                        END IF;
                END IF;
                IF p_legacy <> 'Y' THEN
                        --Validate against admission IGS_PS_COURSE application
                        IF p_acai_admission_appl_number IS NOT NULL THEN
                                OPEN c_aos;
                                FETCH c_aos INTO v_s_adm_outcome_status;
                                -- Invalid parameters, handled elsewhere
                                IF c_aos%NOTFOUND THEN
                                        CLOSE c_aos;
                                        RETURN TRUE;
                                END IF;
                                CLOSE c_aos;
                                IF v_s_adm_outcome_status IN (cst_offer,
                                                              cst_condoffer) THEN
                                        p_message_name := 'IGS_RE_CAN_TOPIC_REQ_AMD';
                                        RETURN FALSE;
                                END IF;
                        END IF;
                END IF; --p_legacy <> 'Y'
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                IF c_aos%ISOPEN THEN
                        CLOSE c_aos;
                END IF;
        RAISE;
  END;
  EXCEPTION
       WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_ca_topic;

  --
  -- Validate IGS_RE_CANDIDATURE ACAI link.
  FUNCTION resp_val_ca_acai(

  p_person_id IN NUMBER ,

  p_ca_sequence_number IN NUMBER ,

  p_sca_course_cd IN VARCHAR2 ,

  p_old_acai_admission_appl_num IN NUMBER ,

  p_old_acai_nominated_course_cd IN VARCHAR2 ,

  p_old_acai_sequence_number IN NUMBER ,

  p_acai_admission_appl_number IN NUMBER ,

  p_acai_nominated_course_cd IN VARCHAR2 ,

  p_acai_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN AS

  BEGIN -- resp_val_ca_acai

        -- This module validates the IGS_RE_CANDIDATURE link to an IGS_AD_PS_APPL_INST.

        -- The following is validated.

        -- * An existing IGS_AD_PS_APPL_INST

        --   (person_id/ acai_admission_appl_number/ acai_nominated_course_cd/

        --   acai_sequence_number) link cannot be removed if the new application is

        --   not re-admission and the IGS_PS_COURSE version of the admission application is

        --   a research IGS_PS_COURSE (defined by IGS_PS_VER.course_cd/ version_number

        --   mapping to IGS_PS_TYPE.research_type_ind set to 'Y') and

        --   IGS_AD_PS_APPL_INST.adm_outcome_status maps to

        --   IGS_AD_OU_STAT.s_adm_outcome_status 'OFFER' or 'COND-OFFER'.

        -- * An existing IGS_AD_PS_APPL_INST

        --   (person_id/ acai_admission_appl_number/ acai_nominated_course_cd/

        --   acai_sequence_number) link cannot be removed if the admission application

        --   is defined by an admission process category where research details are

        --   mandatory ie IGS_AD_PRCS_CAT_STEP.mandatory_step_ind 'Y' where for

        --   IGS_AD_PRCS_CAT_STEP.s_admission_step_type 'RESEARCH' and

        --   IGS_AD_PS_APPL_INST.adm_outcome_status maps to

        --   IGS_AD_OU_STAT.s_adm_outcome_status 'OFFER' or 'COND-OFFER'.

        -- * The new IGS_AD_PS_APPL_INST (person_id/ acai_admission_appl_number/

        --   acai_nominated_course_cd/ acai_sequence_number) does not already have a

        --   research IGS_RE_CANDIDATURE.

        -- * The new IGS_AD_PS_APPL_INST (person_id/ acai_admission_appl_number/

        --   acai_nominated_course_cd/ acai_sequence_number) must map to an admission

        --   application defined by an admission process category where research

        --   details are collected ie IGS_AD_PRCS_CAT_STEP.s_admission_step_type

        --  'RESEARCH' exists.

  DECLARE

        cst_readmit     CONSTANT        VARCHAR2(10) := 'RE-ADMIT';

        cst_research    CONSTANT        VARCHAR2(10) := 'RESEARCH';

        v_s_admission_process_type      IGS_AD_APPL.s_admission_process_type%TYPE;

        v_test                          VARCHAR2(1);

        v_message_name                  VARCHAR2(30);

        CURSOR c_aa

        IS

                SELECT  aa.s_admission_process_type

                FROM    IGS_AD_APPL                     aa

                WHERE   aa.person_id                    = p_person_id AND

                        aa.admission_appl_number        = p_acai_admission_appl_number;

        CURSOR c_ca

        IS

                SELECT  'x'

                FROM    IGS_RE_CANDIDATURE ca

                WHERE   ca.person_id                    = p_person_id AND

                        (p_ca_sequence_number           IS NULL OR

                        ca.sequence_number              <> p_ca_sequence_number) AND

                        ca.acai_admission_appl_number   = p_acai_admission_appl_number AND

                        ca.acai_nominated_course_cd     = p_acai_nominated_course_cd AND

                        ca.acai_sequence_number         = p_acai_sequence_number;

        CURSOR c_aa_apcs

        IS

                SELECT  'x'

                FROM    IGS_AD_APPL aa,

                        IGS_AD_PRCS_CAT_STEP apcs

                WHERE   aa.person_id                    = p_person_id AND

                        aa.admission_appl_number        = p_acai_admission_appl_number AND

                        aa.admission_cat                = apcs.admission_cat AND

                        aa.s_admission_process_type     = apcs.s_admission_process_type AND

                        apcs.s_admission_step_type      = cst_research AND

                        apcs.step_group_type            <> 'TRACK'; --2402377

  BEGIN

        -- Set the default message number

        p_message_name := null;

        IF p_acai_admission_appl_number IS NOT NULL THEN

                -- Determine if admission application details are being updated as a result

                -- of readmission.

                OPEN c_aa;

                FETCH c_aa INTO v_s_admission_process_type;

                IF c_aa%NOTFOUND THEN

                        CLOSE c_aa;

                        RETURN TRUE;

                END IF;

                CLOSE c_aa;

        END IF;

        IF p_old_acai_admission_appl_num IS NOT NULL THEN

                IF (p_acai_admission_appl_number IS NULL OR

                                (p_acai_admission_appl_number <>

                                                        p_old_acai_admission_appl_num OR

                                p_acai_nominated_course_cd <>

                                                        p_old_acai_nominated_course_cd OR

                                p_acai_sequence_number <>

                                                        p_old_acai_sequence_number)) AND

                                (v_s_admission_process_type <>

                                                        cst_readmit) THEN

                        -- Validate that a required research IGS_RE_CANDIDATURE link is not being broken.

                        IF IGS_RE_VAL_CA.resp_val_ca_acai_del(

                                                p_person_id,

                                                p_old_acai_admission_appl_num,

                                                p_old_acai_nominated_course_cd,

                                                p_old_acai_sequence_number,

                                                v_message_name) = FALSE THEN

                                p_message_name := v_message_name;

                                RETURN FALSE;

                        END IF;

                END IF;

        END IF;

        IF p_acai_admission_appl_number IS NOT NULL THEN

                -- Validate that admission IGS_PS_COURSE application does not already have a

                -- research IGS_RE_CANDIDATURE

                OPEN c_ca;

                FETCH c_ca INTO v_test;

                IF c_ca%FOUND THEN

                        CLOSE c_ca;

                        p_message_name := 'IGS_RE_CAND_ALREADY_EXIST_ADM';

                        RETURN FALSE;

                END IF;

                CLOSE c_ca;

                -- Validate that research step exists for admission application definition.

                IF v_s_admission_process_type <> cst_readmit THEN

                        OPEN c_aa_apcs;

                        FETCH c_aa_apcs INTO v_test;

                        IF c_aa_apcs%NOTFOUND THEN

                                CLOSE c_aa_apcs;

                                p_message_name := 'IGS_RE_CAND_DETAIL_NOT_REQR';

                                RETURN FALSE;

                        END IF;

                        CLOSE c_aa_apcs;

                END IF;

        END IF;

        RETURN TRUE;

  EXCEPTION

        WHEN OTHERS THEN

                IF c_aa%ISOPEN THEN

                        CLOSE c_aa;

                END IF;

                IF c_ca%ISOPEN THEN

                        CLOSE c_ca;

                END IF;

                IF c_aa_apcs%ISOPEN THEN

                        CLOSE c_aa_apcs;

                END IF;

        RAISE;

  END;

  EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

  END resp_val_ca_acai;

  --
  FUNCTION resp_val_ca_maxsbmsn(
  p_person_id                   IN NUMBER ,
  p_sca_course_cd               IN VARCHAR2 ,
  p_acai_admission_appl_number  IN NUMBER ,
  p_acai_nominated_course_cd    IN VARCHAR2 ,
  p_acai_sequence_number        IN NUMBER ,
  p_min_submission_dt           IN DATE ,
  p_max_submission_dt           IN DATE ,
  p_attendance_percentage       IN NUMBER ,
  p_commencement_dt             IN DATE ,
  p_message_name                OUT NOCOPY VARCHAR2 ,
  p_legacy                      IN VARCHAR2)
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : Validate IGS_RE_CANDIDATURE maximum submission date.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        11-11-2002      Modified function logic due to addition of new parameter p_legacy
  ||                                  if p_legacy set to 'Y' then error message should be stacked instead of
  ||                                  returning the function in the normal way else function should behave in
  ||                                  normal way.Legacy Build Bug no: 2661533
  ------------------------------------------------------------------------------*/

  BEGIN         -- resp_val_ca_maxsbmsn
  DECLARE

        cst_offer                       CONSTANT VARCHAR2(10) := 'OFFER';
        cst_cond_offer                  CONSTANT VARCHAR2(10) := 'COND-OFFER';
        v_min_submission_dt             IGS_RE_CANDIDATURE.min_submission_dt%TYPE;
        v_max_submission_dt             IGS_RE_CANDIDATURE.max_submission_dt%TYPE;
        v_commencement_dt               DATE;
        v_stdnt_confm_ind               IGS_EN_STDNT_PS_ATT.student_confirmed_ind%TYPE;
        v_s_adm_otcm_status             IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;

        CURSOR c_sca IS
                SELECT  sca.student_confirmed_ind
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   sca.person_id = p_person_id     AND
                        sca.course_cd = p_sca_course_cd;
        CURSOR c_aos_acai IS
                SELECT  aos.s_adm_outcome_status
                FROM    IGS_AD_PS_APPL_INST     acai,
                        IGS_AD_OU_STAT          aos
                WHERE   acai.person_id                  = p_person_id                   AND
                        acai.admission_appl_number      = p_acai_admission_appl_number  AND
                        acai.nominated_course_cd        = p_acai_nominated_course_cd    AND
                        acai.sequence_number            = p_acai_sequence_number        AND
                        acai.adm_outcome_status         = aos.adm_outcome_status;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        IF p_max_submission_dt IS NULL THEN
                -- Get derived maximum submission date
                v_max_submission_dt := IGS_RE_GEN_001.RESP_CLC_MAX_SBMSN(
                                                p_person_id,
                                                NULL,           --(ca.sequence_number)
                                                p_sca_course_cd,
                                                p_acai_admission_appl_number,
                                                p_acai_nominated_course_cd,
                                                p_acai_sequence_number,
                                                p_attendance_percentage,
                                                p_commencement_dt);
                IF v_max_submission_dt IS NULL THEN
                        -- Validate against student IGS_PS_COURSE attempt
                        IF p_sca_course_cd IS NOT NULL THEN
                                OPEN c_sca;
                                FETCH c_sca INTO v_stdnt_confm_ind;
                                IF c_sca%NOTFOUND THEN
                                        -- Invalid parameters, handled elsewhere
                                        CLOSE c_sca;
                                        RETURN TRUE;
                                END IF;
                                CLOSE c_sca;
                                IF v_stdnt_confm_ind = 'Y' THEN
                                        p_message_name := 'IGS_RE_MAX_SUB_DT_REQ_CRSATMP';
                                        IF p_legacy <> 'Y' THEN
                                           RETURN FALSE;
                                        ELSE
                                           fnd_message.set_name('IGS',p_message_name);
                                           fnd_msg_pub.add;
                                        END IF;
                                END IF;
                        END IF;
                        -- Validate against admission IGS_PS_COURSE application
                        IF p_acai_admission_appl_number IS NOT NULL THEN
                                OPEN c_aos_acai;
                                FETCH c_aos_acai INTO v_s_adm_otcm_status;
                                IF c_aos_acai%NOTFOUND THEN
                                        -- Invalid parameters, handled elsewhere
                                        CLOSE c_aos_acai;
                                        RETURN TRUE;
                                END IF;
                                CLOSE c_aos_acai;
                                IF v_s_adm_otcm_status IN ( cst_offer,
                                                            cst_cond_offer) THEN
                                        p_message_name := 'IGS_RE_MAX_SUB_DT_REQ_ADM';
                                        IF p_legacy <> 'Y' THEN
                                           RETURN FALSE;
                                        ELSE
                                           fnd_message.set_name('IGS',p_message_name);
                                           fnd_msg_pub.add;
                                        END IF;
                                END IF;
                        END IF;
                END IF; --IF v_max_submission_dt IS NUL
        ELSE
                -- Validate that maximum submission date is greater than or equal to the
                -- minimum submission date
                IF p_min_submission_dt IS NULL THEN
                        -- Validate against derived maximum submission date
                        v_min_submission_dt := IGS_RE_GEN_001.RESP_CLC_MIN_SBMSN(
                                                                p_person_id,
                                                                NULL,   -- ca.sequence_number
                                                                p_sca_course_cd,
                                                                p_acai_admission_appl_number,
                                                                p_acai_nominated_course_cd,
                                                                p_acai_sequence_number,
                                                                p_attendance_percentage,
                                                                p_commencement_dt);
                ELSE
                        v_min_submission_dt := p_min_submission_dt;
                END IF;
                IF v_min_submission_dt IS NOT NULL AND
                                p_max_submission_dt < v_min_submission_dt THEN
                                p_message_name := 'IGS_RE_MAX_SUB_DT_LT_MIN_DT';
                                IF p_legacy <> 'Y' THEN
                                   RETURN FALSE;
                                ELSE
                                   fnd_message.set_name('IGS',p_message_name);
                                   fnd_msg_pub.add;
                                END IF;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                IF c_aos_acai%ISOPEN THEN
                        CLOSE c_aos_acai;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
               Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
               IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_ca_maxsbmsn;

  --
  FUNCTION resp_val_ca_minsbmsn(
  p_person_id                   IN NUMBER ,
  p_sca_course_cd               IN VARCHAR2 ,
  p_acai_admission_appl_number  IN NUMBER ,
  p_acai_nominated_course_cd    IN VARCHAR2 ,
  p_acai_sequence_number        IN NUMBER ,
  p_min_submission_dt           IN DATE ,
  p_max_submission_dt           IN DATE ,
  p_attendance_percentage       IN NUMBER ,
  p_commencement_dt             IN DATE ,
  p_message_name                OUT NOCOPY VARCHAR2 ,
  p_legacy                      IN VARCHAR2)
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : Validate IGS_RE_CANDIDATURE minimum submission date.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        11-11-2002      Modified function logic due to addition of new parameter p_legacy
  ||                                  if p_legacy set to 'Y' then error message should be stacked instead of
  ||                                  returning the function in the normal way else function should behave in
  ||                                  normal way.Legacy Build Bug no: 2661533
  ------------------------------------------------------------------------------*/
  BEGIN         -- resp_val_ca_minsbmsn
  DECLARE

        cst_offer                       CONSTANT VARCHAR2(10) := 'OFFER';
        cst_cond_offer                  CONSTANT VARCHAR2(10) := 'COND-OFFER';
        v_min_submission_dt             IGS_RE_CANDIDATURE.min_submission_dt%TYPE;
        v_max_submission_dt             IGS_RE_CANDIDATURE.max_submission_dt%TYPE;
        v_commencement_dt               DATE;
        v_stdnt_confm_ind               IGS_EN_STDNT_PS_ATT.student_confirmed_ind%TYPE;
        v_s_adm_otcm_status             IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;
        CURSOR c_sca IS
                SELECT  sca.student_confirmed_ind
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   sca.person_id = p_person_id     AND
                        sca.course_cd = p_sca_course_cd;
        CURSOR c_aos_acai IS
                SELECT  aos.s_adm_outcome_status
                FROM    IGS_AD_PS_APPL_INST     acai,
                        IGS_AD_OU_STAT          aos
                WHERE   acai.person_id                  = p_person_id                   AND
                        acai.admission_appl_number      = p_acai_admission_appl_number  AND
                        acai.nominated_course_cd        = p_acai_nominated_course_cd    AND
                        acai.sequence_number            = p_acai_sequence_number        AND
                        acai.adm_outcome_status         = aos.adm_outcome_status;
  BEGIN

        -- Set the default message number
        p_message_name := null;
        IF p_min_submission_dt IS NULL THEN
                -- Get derived minimum submission date
                v_min_submission_dt := IGS_RE_GEN_001.RESP_CLC_MIN_SBMSN(
                                                p_person_id,
                                                NULL,   -- (ca.sequence_number)
                                                p_sca_course_cd,
                                                p_acai_admission_appl_number,
                                                p_acai_nominated_course_cd,
                                                p_acai_sequence_number,
                                                p_attendance_percentage,
                                                p_commencement_dt);

                IF v_min_submission_dt IS NULL THEN
                        -- Validate against student IGS_PS_COURSE attempt
                        IF p_sca_course_cd IS NOT NULL THEN
                                OPEN c_sca;
                                FETCH c_sca INTO v_stdnt_confm_ind;
                                IF c_sca%NOTFOUND THEN
                                        -- Invalid parameters, handled elsewhere
                                        CLOSE c_sca;
                                        RETURN TRUE;
                                END IF;
                                CLOSE c_sca;
                                IF v_stdnt_confm_ind = 'Y' THEN
                                        p_message_name := 'IGS_RE_MIN_SUB_DT_REQ_CRSATMP';
                                        IF p_legacy <> 'Y' THEN
                                           RETURN FALSE;
                                        ELSE
                                           fnd_message.set_name('IGS',p_message_name);
                                           fnd_msg_pub.add;
                                        END IF;
                                END IF;
                        END IF;
                        -- Validate against admission IGS_PS_COURSE application
                        IF p_acai_admission_appl_number IS NOT NULL THEN
                                OPEN c_aos_acai;
                                FETCH c_aos_acai INTO v_s_adm_otcm_status;
                                IF c_aos_acai%NOTFOUND THEN
                                        -- Invalid parameters, handled elsewhere
                                        CLOSE c_aos_acai;
                                        RETURN TRUE;
                                END IF;
                                CLOSE c_aos_acai;
                                IF v_s_adm_otcm_status IN (cst_offer,
                                                           cst_cond_offer) THEN
                                        p_message_name := 'IGS_RE_MIN_SUBM_DT_REQ_ADM';
                                        IF p_legacy <> 'Y' THEN
                                           RETURN FALSE;
                                        ELSE
                                           fnd_message.set_name('IGS',p_message_name);
                                           fnd_msg_pub.add;
                                        END IF;
                                END IF;
                        END IF;
                END IF; --IF v_min_submission_dt IS NULL
        ELSE
                -- Get IGS_RE_CANDIDATURE commencement date
                IF p_commencement_dt IS NULL THEN
                        v_commencement_dt := IGS_RE_GEN_001.RESP_GET_CA_COMM(
                                                        p_person_id,
                                                        p_sca_course_cd,
                                                        p_acai_admission_appl_number,
                                                        p_acai_nominated_course_cd,
                                                        p_acai_sequence_number);
                ELSE
                        v_commencement_dt := p_commencement_dt;
                END IF;
                IF p_min_submission_dt <= v_commencement_dt THEN
                        p_message_name := 'IGS_RE_MIN_SUB_DT_LT_CRS_COMM';
                        IF p_legacy <> 'Y' THEN
                           RETURN FALSE;
                        ELSE
                           fnd_message.set_name('IGS',p_message_name);
                           fnd_msg_pub.add;
                        END IF;
                END IF;
                -- Validate minimum submission date is less than or equal to maximum
                -- submission date
                IF p_max_submission_dt IS NULL THEN
                        -- Validate against derived maximum submission date
                        v_max_submission_dt := IGS_RE_GEN_001.RESP_CLC_MAX_SBMSN(
                                                                p_person_id,
                                                                NULL,   -- ca.sequence_number
                                                                p_sca_course_cd,
                                                                p_acai_admission_appl_number,
                                                                p_acai_nominated_course_cd,
                                                                p_acai_sequence_number,
                                                                p_attendance_percentage,
                                                                p_commencement_dt);
                ELSE
                        v_max_submission_dt := p_max_submission_dt;
                END IF;
                IF v_max_submission_dt IS NOT NULL AND
                      p_min_submission_dt > v_max_submission_dt THEN
                      p_message_name := 'IGS_RE_MIN_SUB_DT_GE_MAX_DT';
                      IF p_legacy <> 'Y' THEN
                         RETURN FALSE;
                      ELSE
                         fnd_message.set_name('IGS',p_message_name);
                         fnd_msg_pub.add;
                      END IF;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                IF c_aos_acai%ISOPEN THEN
                        CLOSE c_aos_acai;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_ca_minsbmsn;

  --

  -- Validate IGS_RE_CANDIDATURE SCA link.

  FUNCTION resp_val_ca_sca(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_old_sca_course_cd IN VARCHAR2 ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_ca_sca
        -- This module validates the IGS_RE_CANDIDATURE link to a IGS_EN_STDNT_PS_ATT.
  DECLARE
        v_message_name                  VARCHAR2(30);

        v_student_confirmed_ind         IGS_EN_STDNT_PS_ATT.student_confirmed_ind%TYPE;

        v_course_attempt_status         IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;

        v_test                          VARCHAR2(1);

        cst_discontin                   CONSTANT

                                                IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'DISCONTIN';

        cst_lapsed                      CONSTANT

                                                IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'LAPSED';

        cst_completed                   CONSTANT

                                                IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'COMPLETED';

        CURSOR c_sca (

                cp_course_cd    IGS_RE_CANDIDATURE.sca_course_cd%TYPE)

        IS

                SELECT  sca.student_confirmed_ind,

                        sca.course_attempt_status

                FROM    IGS_EN_STDNT_PS_ATT sca

                WHERE   sca.person_id   = p_person_id AND

                        sca.course_cd   = cp_course_cd;

        CURSOR c_ca

        IS

                SELECT  'x'

                FROM    IGS_RE_CANDIDATURE ca

                WHERE   ca.person_id    = p_person_id AND

                        (p_ca_sequence_number IS NULL OR

                        ca.sequence_number <> p_ca_sequence_number) AND

                        ca.sca_course_cd= p_sca_course_cd;

  BEGIN

        IF p_old_sca_course_cd IS NOT NULL THEN

                IF p_sca_course_cd IS NULL OR

                                (p_sca_course_cd <> p_old_sca_course_cd) THEN

                        -- Validate that a required research IGS_RE_CANDIDATURE link is not being broken

                        IF NOT IGS_RE_VAL_CA.resp_val_ca_sca_del(

                                                        p_person_id,

                                                        p_old_sca_course_cd,

                                                        v_message_name) THEN

                                p_message_name := v_message_name;

                                RETURN FALSE;

                        END IF;

                        IF p_sca_course_cd IS NOT NULL THEN

                                -- Validate that student IGS_PS_COURSE attempt is not being changed

                                -- When the existing IGS_PS_COURSE attempt link is confirmed.

                                OPEN c_sca(p_old_sca_course_cd);

                                FETCH c_sca INTO        v_student_confirmed_ind,

                                                        v_course_attempt_status;

                                IF c_sca%NOTFOUND THEN

                                        CLOSE c_sca;

                                        -- Parameters passed are invalid.

                                        p_message_name := 'IGS_RE_INVALID_PARAMETERS';

                                        RETURN FALSE;

                                END IF;

                                CLOSE c_sca;

                                IF v_student_confirmed_ind = 'Y' THEN

                                        p_message_name := 'IGS_RE_CAND_CANNOT_BE_LNKED';

                                        RETURN FALSE;

                                END IF;

                        END IF;

                END IF;

        END IF;

        IF p_sca_course_cd IS NOT NULL THEN

                -- Validate that student IGS_PS_COURSE attempt does not already have a

                -- research IGS_RE_CANDIDATURE.

                OPEN c_ca;

                FETCH c_ca INTO v_test;

                IF c_ca%FOUND THEN

                        CLOSE c_ca;

                        p_message_name := 'IGS_RE_CAND_ALREADY_EXISTS';

                        RETURN FALSE;

                END IF;

                CLOSE c_ca;

                -- Validate that the student IGS_PS_COURSE attempt is not discontinued, lapsed or

                -- completed.

                OPEN c_sca(p_sca_course_cd);

                FETCH c_sca INTO        v_student_confirmed_ind,

                                        v_course_attempt_status;

                IF c_sca%NOTFOUND THEN

                        CLOSE c_sca;

                        -- Invalid data, handled elsewhere

                        p_message_name := null;

                        RETURN TRUE;

                END IF;

                CLOSE c_sca;

                IF v_course_attempt_status IN (

                                                cst_discontin,

                                                cst_lapsed,

                                                cst_completed) THEN

                        p_message_name := 'IGS_RE_CANT_INS_IF_CATMP_DISC';

                        RETURN FALSE;

                END IF;

        END IF;

        p_message_name := null;

        RETURN TRUE;

  EXCEPTION

        WHEN OTHERS THEN

                IF c_sca%ISOPEN THEN

                        CLOSE c_sca;

                END IF;

                IF c_ca%ISOPEN THEN

                        CLOSE c_ca;

                END IF;

        RAISE;

  END;

  EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

  END resp_val_ca_sca;

  --

  -- Validate IGS_RE_CANDIDATURE deletion and ACAI link.

  FUNCTION resp_val_ca_acai_del(

  p_person_id IN NUMBER ,

  p_acai_admission_appl_number IN NUMBER ,

  p_acai_nominated_course_cd IN VARCHAR2 ,

  p_acai_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN AS

  BEGIN -- resp_val_ca_acai_del

        -- This module validates the removal of a IGS_RE_CANDIDATURE/

        -- IGS_AD_PS_APPL_INST link. This may be the result of deletion of

        -- IGS_RE_CANDIDATURE, or removal/change of IGS_RE_CANDIDATURE.acai_admission_appl_number/

        -- acai_nominated_course_cd/ acai_sequence_number which defines an existing

        -- admission IGS_PS_COURSE application relationship.

  DECLARE

        v_s_adm_outcome_status  IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;

        v_research_type_ind     IGS_PS_TYPE.research_type_ind%TYPE;

        v_mandatory_step_ind    IGS_AD_PRCS_CAT_STEP.mandatory_step_ind%TYPE;

        CURSOR c_acai IS

                SELECT  aos.s_adm_outcome_status,

                        cty.research_type_ind

                FROM    IGS_AD_PS_APPL_INST     acai,

                        IGS_AD_OU_STAT          aos,

                        IGS_PS_VER                      crv,

                        IGS_PS_TYPE                     cty

                WHERE   acai.person_id                  = p_person_id AND

                        acai.admission_appl_number      = p_acai_admission_appl_number AND

                        acai.nominated_course_cd        = p_acai_nominated_course_cd AND

                        acai.sequence_number            = p_acai_sequence_number AND

                        acai.course_cd                  = crv.course_cd AND

                        acai.crv_version_number         = crv.version_number AND

                        acai.adm_outcome_status         = aos.adm_outcome_status AND

                        crv.course_type                 = cty.course_type;

        CURSOR c_apcs IS

                SELECT  apcs.mandatory_step_ind

                FROM    IGS_AD_APPL                     aa,

                        IGS_AD_PRCS_CAT_STEP            apcs

                WHERE   aa.person_id                    = p_person_id AND

                        aa.admission_appl_number        = p_acai_admission_appl_number AND

                        aa.admission_cat                = apcs.admission_cat AND

                        aa.s_admission_process_type     = apcs.s_admission_process_type AND

                        apcs.s_admission_step_type      = 'RESEARCH' AND

                        apcs.step_group_type            <> 'TRACK'; --2402377

  BEGIN

        IF p_acai_admission_appl_number IS NOT NULL THEN

                OPEN c_acai;

                FETCH c_acai INTO       v_s_adm_outcome_status,

                                        v_research_type_ind;

                IF c_acai%NOTFOUND THEN

                        CLOSE c_acai;

                        -- Invalid Parameters, this will be handled by db constraints

                        p_message_name := null;

                        RETURN TRUE;

                END IF;

                CLOSE c_acai;

                IF v_s_adm_outcome_status = 'OFFER' OR

                                v_s_adm_outcome_status = 'COND-OFFER' THEN

                        IF v_research_type_ind = 'Y' THEN

                                -- Research IGS_RE_CANDIDATURE is required by research only IGS_PS_COURSEs

                                p_message_name := 'IGS_RE_CAND_REQ_WHEN_CRS_OFF';

                                RETURN FALSE;

                        END IF;

                        OPEN c_apcs;

                        FETCH c_apcs INTO v_mandatory_step_ind;

                        IF c_apcs%NOTFOUND THEN

                                CLOSE c_apcs;

                                p_message_name := null;

                                RETURN TRUE;

                        END IF;

                        CLOSE c_apcs;

                        IF v_mandatory_step_ind = 'Y' THEN

                                p_message_name := 'IGS_RE_CAND_REQ_AS_PRT_OF_ADM';

                                RETURN FALSE;

                        END IF;

                END IF;

        END IF;

        p_message_name := null;

        RETURN TRUE;

  EXCEPTION

        WHEN OTHERS THEN

                IF c_acai%ISOPEN THEN

                        CLOSE c_acai;

                END IF;

                IF c_apcs%ISOPEN THEN

                        CLOSE c_apcs;

                END IF;

        RAISE;

  END;

  EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

  END resp_val_ca_acai_del;

  --

  -- Validate IGS_RE_CANDIDATURE SCA link when deleting.

  FUNCTION resp_val_ca_sca_del(

  p_person_id IN NUMBER ,

  p_sca_course_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN AS

  BEGIN -- resp_val_ca_sca_del

        -- This module validates the removal of a IGS_RE_CANDIDATURE/IGS_EN_STDNT_PS_ATT

        --  link.

        -- This may be the result of deletion of IGS_RE_CANDIDATURE, or removal/change of

        -- IGS_RE_CANDIDATURE.sca_course_cd which defines an existing IGS_PS_COURSE attempt

        -- relationship.

  DECLARE

        v_student_confirmed_ind IGS_EN_STDNT_PS_ATT.student_confirmed_ind%TYPE;

        v_research_type_ind     IGS_PS_TYPE.research_type_ind%TYPE;

        CURSOR c_sca IS

                SELECT  sca.student_confirmed_ind,

                        cty.research_type_ind

                FROM    IGS_EN_STDNT_PS_ATT sca,

                        IGS_PS_VER crv,

                        IGS_PS_TYPE cty

                WHERE   sca.course_cd           = crv.course_cd AND

                        sca.version_number      = crv.version_number AND

                        crv.course_type         = cty.course_type AND

                        sca.person_id           = p_person_id AND

                        sca.course_cd           = p_sca_course_cd;

  BEGIN

        IF p_sca_course_cd IS NOT NULL THEN

                OPEN c_sca;

                FETCH c_sca INTO        v_student_confirmed_ind,

                                        v_research_type_ind;

                IF c_sca%NOTFOUND THEN

                        CLOSE c_sca;

                        -- Invalid Parameters, this will be handled by db constraints

                        p_message_name := null;

                        RETURN TRUE;

                END IF;

                CLOSE c_sca;

                IF v_student_confirmed_ind = 'Y' AND

                                v_research_type_ind = 'Y' THEN

                        -- Research IGS_RE_CANDIDATURE is required by research only courses.

                        p_message_name := 'IGS_RE_CAND_REQ_WHEN_CRS_DEF';

                        RETURN FALSE;

                END IF;

        END IF;

        p_message_name := null;

        RETURN TRUE;

  EXCEPTION

        WHEN OTHERS THEN

                IF c_sca%ISOPEN THEN

                        CLOSE c_sca;

                END IF;

        RAISE;

  END;

  EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

  END resp_val_ca_sca_del;

  --

  -- Validate if Government Type of Activity Classification Code is closed.

  FUNCTION resp_val_gtcc_closed(

  p_govt_toa_class_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN AS

  BEGIN -- resp_val_gtcc_closed

        -- Validate if IGS_RE_GV_TOA_CLS_CD.govt_toa_class_cd is closed.

  DECLARE

        v_gtcc_rec              VARCHAR2(1);

        CURSOR  c_gtcc IS

                SELECT  'X'

                FROM    IGS_RE_GV_TOA_CLS_CD

                WHERE   govt_toa_class_cd = p_govt_toa_class_cd AND

                        closed_ind = 'Y';

  BEGIN

        p_message_name := null;

        OPEN c_gtcc;

        FETCH c_gtcc INTO v_gtcc_rec;

        IF (c_gtcc%FOUND)  THEN

                CLOSE c_gtcc;

                p_message_name := 'IGS_RE_GOV_TYPE_CLASS_CD_CLOS';

                RETURN FALSE;

        END IF;

        CLOSE c_gtcc;

        RETURN TRUE;

  END;

  EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

  END resp_val_gtcc_closed;

  --

  -- Validate IGS_RE_CANDIDATURE SCA/ACAI link.

  FUNCTION resp_val_ca_sca_acai(

  p_person_id IN NUMBER ,

  p_sca_course_cd IN VARCHAR2 ,

  p_acai_admission_appl_number IN NUMBER ,

  p_acai_nominated_course_cd IN VARCHAR2 ,

  p_acai_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN AS

  BEGIN -- resp_val_ca_sca_acai

        -- This module validates IGS_RE_CANDIDATURE details are linked to either an

        -- admission IGS_PS_COURSE application or IGS_PS_COURSE attempt.  Both these are defined

        -- by optional IGS_RE_CANDIDATURE information that is determined by the process

        -- that initiates the research IGS_RE_CANDIDATURE (ADMF3240/ENRF3000).  This module

        -- will only be called from the database trigger.

        -- The following is validated:

        --      * One of sca_course_cd(IGS_EN_STDNT_PS_ATT) or acai_admission_appl_number

        --       / acai_nominated_course_cd/acai_sequence_number(IGS_AD_PS_APPL_INST)

        --        must be defined.

        --      * If sca_course_cd exists, then IGS_EN_STDNT_PS_ATT and IGS_RE_CANDIDATURE

        --        admission details must match.

  DECLARE

        CURSOR  c_sca IS

                SELECT  sca.adm_admission_appl_number,

                        sca.adm_nominated_course_cd,

                        sca.adm_sequence_number

                FROM    IGS_EN_STDNT_PS_ATT     sca

                WHERE   sca.person_id           = p_person_id AND

                        sca.course_cd           = p_sca_course_cd;

        v_sca_rec       c_sca%ROWTYPE;

  BEGIN

        p_message_name := null;

        IF p_sca_course_cd IS NULL AND

                        (p_acai_admission_appl_number IS NULL OR

                        p_acai_nominated_course_cd IS NULL OR

                        p_acai_sequence_number IS NULL) THEN

                p_message_name := 'IGS_RE_CHK_CANDIDATURE';

                RETURN FALSE;

        END IF;

        IF p_sca_course_cd IS NOT NULL THEN

                -- Validate that student IGS_PS_COURSE attempt and research

                -- IGS_RE_CANDIDATURE details match.

                OPEN c_sca;

                FETCH c_sca INTO v_sca_rec;

                IF c_sca%NOTFOUND THEN

                        CLOSE c_sca;

                        RETURN TRUE;

                END IF;

                CLOSE c_sca;

                IF (NVL(p_acai_admission_appl_number,0) <>

                                NVL(v_sca_rec.adm_admission_appl_number,0)) OR

                                (NVL(p_acai_nominated_course_cd, 'NULL') <>

                                NVL(v_sca_rec.adm_nominated_course_cd, 'NULL')) OR

                                (NVL(p_acai_sequence_number,0) <>

                                NVL(v_sca_rec.adm_sequence_number,0)) THEN

                        p_message_name := 'IGS_RE_CAND_STUD_DET_MISMATCH';

                        RETURN FALSE;

                END IF;

        END IF;

        RETURN TRUE;

  EXCEPTION

        WHEN OTHERS THEN

                IF c_sca%ISOPEN THEN

                        CLOSE c_sca;

                END IF;

                RAISE;

  END;

  EXCEPTION

        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;

  END resp_val_ca_sca_acai;

END IGS_RE_VAL_CA;

/
