--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_TEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_TEX" AS
/* $Header: IGSRE15B.pls 120.1 2006/07/25 15:05:40 sommukhe noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  --svenkata    9-APR-2002      FUNCTION RESP_VAL_TEX_SBMSN has been modified 'cos the Submitted On field can now accept Future dates .
  --                            The code has to be bypassed so that the procedure can still go ahead and validate if the value for Sumitted
  --                            on is greater than Max. Submission Date. Bug # 2030672 , 2028078
  --Nishikant   19NOV2002       Bug#2661533. The signature of the functions resp_val_tex_sbmsn got modified to add
  --                            two more parameer p_legacy and p_final_title_ind.
  --Nishikant   31DEC2002       Bug#2722106. If p_submission_dt is null and p_thesis_result_cd is
  --		                not null then log error message in the function RESP_VAL_TEX_SBMSN.
  --myoganat   24-Jun-2003	Bug# 2720102. Added validation to allow students with a program attempt status of 'COMPLETED'
  --							to update the thesis exam details. As part of this, constant variable cst_completed was added and included
  --							in the validation in procedure RESP_VAL_TEX_UPD
  -------------------------------------------------------------------------------------------
  -- Validate the deceased indicator for a person.
  FUNCTION GENP_VAL_PE_DECEASED(
  p_person_id IN NUMBER ,
  p_message_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- genp_val_pe_deceased
        -- Validate the person is not deceased.
  DECLARE
        CURSOR  c_pe IS
                SELECT  deceased_ind
                FROM    IGS_PE_PERSON
                WHERE   person_id = p_person_id;
        v_deceased_ind          VARCHAR2(1) DEFAULT NULL;
  BEGIN
        p_message_name := NULL;
        -- Validate that the correct value is passed in p_message_type.
        IF p_message_type NOT IN ('ERROR', 'WARN') THEN
                p_message_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        -- Determine if the person is deceased
        OPEN c_pe;
        FETCH c_pe INTO v_deceased_ind;
        IF (c_pe%NOTFOUND) THEN
                CLOSE c_pe;
                p_message_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        ELSE
                CLOSE c_pe;
                IF (v_deceased_ind = 'Y') THEN
                        -- Determine if warning or error message to be returned
                        IF p_message_type = 'ERROR' THEN
                                p_message_name := 'IGS_GE_PERSON_DECEASED';
                        ELSE
                                p_message_name := 'IGS_GE_WARN_PERSON_DECEASED';
                        END IF;
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_pe%ISOPEN) THEN
                        CLOSE c_pe;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END genp_val_pe_deceased;
  --
  -- To validate IGS_RE_THESIS examination submission date
  FUNCTION RESP_VAL_TEX_SBMSN(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_submission_dt IN DATE ,
  p_legacy  IN VARCHAR2,
  p_final_title_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*  Change History :
  Who             When            What
  (reverse chronological order - newest change first)

  Nishikant       15NOV2002       The function got modified to skip some validation in case
                                  It has been called from Legacy API. And if any error message then
                                  logs in the message stack and proceed further.
  Nishikant       31DEC2002       Bug#2722106. If p_submission_dt is null and p_thesis_result_cd is
				  not null then log error message.
  stutta          05-May-2004  Added c_awd_exists,c_incomp_awd cursors and modified logic to return false(Bug #3577988)
                           if a completed program attempt has all its awards completed. If atleast one
                           award is complete or no award assoicated for a completed program attempt return true.
  skpandey	  10-JUL-2006	  Bug#5343912, changed cursor c_cfos definition to include 'per fos_type_code' percentage check for all non CIP type
  */
 BEGIN  -- resp_val_tex_sbmsn
        -- Validate the thesis_examination.submission_dt, checking for :
        --  Cannot be cleared if the thesis_result_cd is set
        --  Cannot be cleared if any thesis_panel_member records exist
        --      with their thesis_result_cd set
        --  Cannot set if previous thesis_exam record exists which
        --      has been submitted but for which no result has been recorded
        --  Cannot set if parent IGS_RE_THESIS.final_title_ind = 'N'
        --  Cannot be set if the parent IGS_EN_STDNT_PS_ATT.course_attempt_status
        --      is not one of ENROLLED, INTERMIT or INACTIVE
        --  Cannot be deceased person
        --  Cannot be future dated
        --  Cannot be less than the IGS_EN_STDNT_PS_ATT.commencement_dt
        --  Cannot be prior to the submission date of a previous thesis_examination
        --  record
        --  Must have a principal supervisor
        --  Must have fields of study = 100%
        --  Must have socio-economic classifications = 100%
        --  Must have type of activity code set
        --  Cannot be prior to the minimum submission date
        --  Warn if greater than maximum submission date
        --  Cannot be set if the parent IGS_EN_STDNT_PS_ATT.course_attempt_status is
        --  COMPLETED and all its associated awards completed.

  DECLARE
        cst_enrolled            CONSTANT VARCHAR2(10) := 'ENROLLED';
        cst_inactive            CONSTANT VARCHAR2(10) := 'INACTIVE';
        cst_intermit            CONSTANT VARCHAR2(10) := 'INTERMIT';
        cst_no_result           CONSTANT VARCHAR2(10) := 'NORESULT';
        CURSOR c_the IS
                SELECT  thes.final_title_ind
                FROM    IGS_RE_THESIS thes
                WHERE   thes.person_id          = p_person_id AND
                        thes.ca_sequence_number = p_ca_sequence_number AND
                        thes.sequence_number    = p_the_sequence_number;
        v_the_rec       c_the%ROWTYPE;
        CURSOR c_sca IS
                SELECT  sca.course_attempt_status,
                        sca.commencement_dt,
                        ca.min_submission_dt,
                        ca.max_submission_dt,
                        ca.govt_type_of_activity_cd,
                        sca.person_id,
                        sca.course_cd
                FROM    IGS_RE_CANDIDATURE              ca,
                        IGS_EN_STDNT_PS_ATT     sca
                WHERE   ca.person_id            = p_person_id AND
                        ca.sequence_number      = p_ca_sequence_number AND
                        sca.person_id           = ca.person_id AND
                        sca.course_cd           = ca.sca_course_cd;
        v_sca_rec       c_sca%ROWTYPE;
        CURSOR c_tex IS
                SELECT  'x'
                FROM    IGS_RE_THESIS_EXAM tex
                WHERE   tex.person_id           = p_person_id AND
                        tex.ca_sequence_number  = p_ca_sequence_number AND
                        tex.the_sequence_number = p_the_sequence_number AND
                        tex.creation_dt         < p_creation_dt AND
                        tex.submission_dt       IS NOT NULL AND
                        tex.thesis_result_cd    IS NULL;
        v_tex_exists    VARCHAR2(1);
        CURSOR c_rsup IS
                SELECT  'x'
                FROM    IGS_RE_SPRVSR rsup,
                        IGS_RE_SPRVSR_TYPE rst
                WHERE   rsup.ca_person_id       = p_person_id AND
                        rsup.ca_sequence_number = p_ca_sequence_number AND
                        rsup.start_dt           <= SYSDATE AND
                        (rsup.end_dt            IS NULL OR
                        rsup.end_dt             > SYSDATE) AND
                        rst.research_supervisor_type = rsup.research_supervisor_type AND
                        rst.principal_supervisor_ind = 'Y';
        v_rsup_exists   VARCHAR2(1);
	CURSOR c_cfos IS
		SELECT NVL(Sum(cfos.percentage), 0) total, cfos.fos_type_code
		FROM   igs_re_cdt_fld_of_sy_v cfos
		WHERE  cfos.fos_type_code <> 'CIP'
                AND    cfos.person_id          = p_person_id
		AND    cfos.ca_sequence_number = p_ca_sequence_number
		GROUP BY cfos.fos_type_code
		HAVING Sum(cfos.percentage)<>100;
        v_cfos_rec      c_cfos%ROWTYPE;
        CURSOR c_csc IS
                SELECT  SUM(csc.percentage)     sum_percentage
                FROM    IGS_RE_CAND_SEO_CLS csc
                WHERE   csc.person_id           = p_person_id AND
                        csc.ca_sequence_number  = p_ca_sequence_number;
        v_csc_rec       c_csc%ROWTYPE;
        CURSOR c_tex2 IS
                SELECT  'x'
                FROM    IGS_RE_THESIS_EXAM tex
                WHERE   tex.person_id           = p_person_id AND
                        tex.ca_sequence_number  = p_ca_sequence_number AND
                        tex.the_sequence_number = p_the_sequence_number AND
                        tex.creation_dt         < p_creation_dt AND
                        tex.submission_dt       > p_submission_dt;
        v_tex2_exists   VARCHAR2(1);
        v_dummy VARCHAR2(1);
        CURSOR c_tpm IS
                SELECT  'x'
                FROM    IGS_RE_THS_PNL_MBR      tpm,
                        IGS_RE_THESIS_RESULT            thr
                WHERE   tpm.person_id           = p_person_id AND
                        tpm.ca_sequence_number  = p_ca_sequence_number AND
                        tpm.the_sequence_number = p_the_sequence_number AND
                        tpm.creation_dt         = p_creation_dt AND
                        tpm.confirmed_dt        IS NOT NULL AND
                        thr.thesis_result_cd    = tpm.thesis_result_cd AND
                        thr.s_thesis_result_cd  <> cst_no_result;
       CURSOR c_awd_exists(cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                           cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE) IS
       SELECT 'x'
       FROM igs_en_spa_awd_aim
       WHERE person_id = cp_person_id
       AND      course_cd = cp_course_cd
       AND  ( 	end_dt IS NULL OR
              	(end_dt IS NOT NULL AND complete_ind = 'Y')
            );
      CURSOR c_incomp_awd(cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                          cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE) IS
      SELECT 'x'
      FROM igs_en_spa_awd_aim
      WHERE person_id =  cp_person_id
      AND course_cd = cp_course_cd
      AND NVL(complete_ind,'N') = 'N'
      AND end_dt IS NULL;
        v_tpm_exists    VARCHAR2(1);
        v_min_submission        IGS_RE_CANDIDATURE.min_submission_dt%TYPE DEFAULT NULL;
        v_max_submission        IGS_RE_CANDIDATURE.max_submission_dt%TYPE DEFAULT NULL;
        v_message_name  VARCHAR2(30);
  BEGIN
        -- Set the default message number
        p_message_name := NULL;
        IF p_submission_dt IS NOT NULL THEN
                -- 1. Cannot set if thesis title hasn't been finalised.
             IF p_legacy <> 'Y' THEN  --for legacy this validation is not required
                OPEN c_the;
                FETCH c_the INTO v_the_rec;
                IF c_the%NOTFOUND THEN
                        CLOSE c_the;
                        -- Parameters are invalid, don't continue checking,
                        -- as the error will be picked up by the calling routine
                        RETURN TRUE;
                END IF;
                CLOSE c_the;
                IF v_the_rec.final_title_ind = 'N' THEN
                        p_message_name := 'IGS_RE_CANT_SUBMIT_THESIS';
                        RETURN FALSE;
                END IF;
             ELSE  --for legacy p_final_title_ind will have a value , hence no need to derive
                IF p_final_title_ind = 'N' THEN
                        FND_MESSAGE.SET_NAME('IGS','IGS_RE_CANT_SUBMIT_THESIS');
                        FND_MSG_PUB.ADD;
                END IF;
             END IF;

             IF p_legacy <> 'Y' THEN --for legacy this validation is not required
                -- Check for deceased person ; submission is not possible.
                IF IGS_RE_VAL_TEX.genp_val_pe_deceased(
                                                p_person_id,
                                                'ERROR',
                                                v_message_name) = FALSE THEN
                        p_message_name := v_message_name;
                        RETURN FALSE;
                END IF;
             END IF;
                -- 2. Can only be set for students with course attempt attempt statuses
                -- of ENROLLED, INTERMIT OR INACTIVE. If no course attempt attempt is
                -- linked to the candidature then it also cannot be set.
                OPEN c_sca;
                FETCH c_sca INTO v_sca_rec;
             IF p_legacy <> 'Y' THEN  --for legacy this validation is not required
               IF c_sca%NOTFOUND THEN
                    CLOSE c_sca;
                    p_message_name := 'IGS_RE_CANT_SUB_UNLES_CUR_ENR';
                    RETURN FALSE;
               ELSIF v_sca_rec.course_attempt_status = 'COMPLETED' THEN
               	OPEN c_awd_exists(v_sca_rec.person_id,v_sca_rec.course_cd);
                FETCH c_awd_exists INTO v_dummy;
               	IF c_awd_exists%FOUND THEN
                		OPEN c_incomp_awd(v_sca_rec.person_id,v_sca_rec.course_cd);
                        FETCH c_incomp_awd INTO v_dummy;
                 		IF c_incomp_awd%FOUND THEN
                              CLOSE c_sca;
                              CLOSE c_awd_exists;
                              CLOSE c_incomp_awd;
                              RETURN TRUE;
                    	ELSE
	                         p_message_name := 'IGS_RE_CANT_SUB_UNLES_CUR_ENR';
                              CLOSE c_sca;
               	          CLOSE c_awd_exists;
               	          CLOSE c_incomp_awd;
               	          RETURN FALSE;
               	     END IF;
                    ELSE
                         CLOSE c_sca;
                         CLOSE c_awd_exists;
                         RETURN TRUE;
                    END IF;
               ELSIF v_sca_rec.course_attempt_status NOT IN (   cst_enrolled,
                                                  cst_inactive,
                                                  cst_intermit) THEN
                    CLOSE c_sca;
                    p_message_name := 'IGS_RE_CANT_SUB_UNLES_CUR_ENR';
                    RETURN FALSE;
               END IF;
               CLOSE c_sca;
                -- 3. Cannot be set if previous submitted IGS_RE_THESIS examination
                -- records exist with no result.
                OPEN c_tex;
                FETCH c_tex INTO v_tex_exists;
                IF c_tex%FOUND THEN
                        CLOSE c_tex;
                        p_message_name := 'IGS_RE_CANT_SUB_IF_PREV_EXAM';
                        RETURN FALSE;
                END IF;
                CLOSE c_tex;
             END IF;
                -- 4. Must have a principal supervisor
                OPEN c_rsup;
                FETCH c_rsup INTO v_rsup_exists;
                IF c_rsup%NOTFOUND THEN
                        p_message_name := 'IGS_RE_CAND_MUST_HAVE_SUPERV';
                        IF p_legacy <> 'Y' THEN
                               RETURN FALSE;
                        ELSE
                               FND_MESSAGE.SET_NAME('IGS','IGS_RE_CAND_MUST_HAVE_SUPERV');
                               FND_MSG_PUB.ADD;
                        END IF;
                END IF;
                CLOSE c_rsup;
                -- 5. Current fields of study must total 100%
             IF p_legacy <> 'Y' THEN  --for legacy this validation is not required
                OPEN c_cfos;
                FETCH c_cfos INTO v_cfos_rec;
                CLOSE c_cfos;
                IF v_cfos_rec.total <> 100 THEN
                        p_message_name := 'IGS_RE_CAND_MUST_HAVE_STUDY';
                        RETURN FALSE;
                END IF;
                -- 6. Current socio-economic objectives must total 100%
                OPEN c_csc;
                FETCH c_csc INTO v_csc_rec;
                CLOSE c_csc;
                IF NVL(v_csc_rec.sum_percentage, 0) <> 100 THEN
                        p_message_name := 'IGS_RE_CAND_MUST_HAVE_CLASS';
                        RETURN FALSE;
                END IF;
             END IF;
                --  Must have type of activity code set.
                IF v_sca_rec.govt_type_of_activity_cd IS NULL THEN
                        p_message_name := 'IGS_RE_MUST_HAVE_GOV_TYPE';
                        IF p_legacy <> 'Y' THEN
                               RETURN FALSE;
                        ELSE
                               FND_MESSAGE.SET_NAME('IGS','IGS_RE_MUST_HAVE_GOV_TYPE');
                               FND_MSG_PUB.ADD;
                        END IF;
                END IF;

                -- 7. Cannot be future dated
                -- svenkata - The following code has been commeneted 'cos the Submitted On field can now accept Future dates .
                -- This code has to be bypassed so that the procedure can still go ahead and validate if the value for Sumitted
                -- on is greater than Max. Submission Date. The code is not yet removed with the idea that there might be a future
                -- requirement for this functionality . Bug # 2030672 , 2028078
                /*IF p_submission_dt > SYSDATE THEN
                        p_message_name := 'IGS_RE_SUB_DT_CANT_GT_FUT_DT';
                        RETURN FALSE;
                END IF;*/

                -- 8. Cannot be prior to course attempt commencement date.
                IF p_submission_dt < v_sca_rec.commencement_dt THEN
                        p_message_name := 'IGS_RE_SUBM_DT_CANT_LT_COM_DT';
			IF p_legacy = 'Y' THEN
                               FND_MESSAGE.SET_NAME('IGS',p_message_name);
                               FND_MSG_PUB.ADD;
			END IF;
                        RETURN FALSE;
                END IF;
                -- 9. Cannot be prior to the submission date of a prior examination.
                OPEN c_tex2;
                FETCH c_tex2 INTO v_tex2_exists;
                IF c_tex2%FOUND THEN
                        CLOSE c_tex2;
                        p_message_name := 'IGS_RE_SUB_DT_CANT_LT_PREV_DT';
                        RETURN FALSE;
                END IF;
                CLOSE c_tex2;
                -- 10. Cannot be prior to the override/derived submission date.
                IF v_sca_rec.min_submission_dt IS NOT NULL THEN
                        v_min_submission := v_sca_rec.min_submission_dt;
                ELSE
                        v_min_submission := NVL(IGS_RE_GEN_001.RESP_CLC_MIN_SBMSN(
                                                                p_person_id,
                                                                p_ca_sequence_number,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL), SYSDATE);
                END IF;
                IF p_submission_dt < v_min_submission THEN
                        p_message_name := 'IGS_RE_SUB_DT_CANT_LT_MIN_DT';
                        RETURN FALSE;
                END IF;
                -- 11. Warn IF past the maximum submission date.
                IF v_sca_rec.max_submission_dt IS NOT NULL THEN
                        v_max_submission := v_sca_rec.max_submission_dt;
                ELSE
                        v_max_submission := NVL(IGS_RE_GEN_001.RESP_CLC_MAX_SBMSN(
                                                                p_person_id,
                                                                p_ca_sequence_number,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL), SYSDATE);
                END IF;
                IF p_submission_dt > v_max_submission THEN
                        p_message_name := 'IGS_RE_CHK_SUB_DATE';
                        RETURN TRUE; -- Warning Only
                END IF;
        ELSE    -- p_submission_dt IS NULL
                -- 1. Cannot unset submission date once result has been entered.
                IF p_thesis_result_cd IS NOT NULL THEN
                        p_message_name := 'IGS_RE_CHK_UNSUB_RES_ENTERED';
			IF p_legacy = 'Y' THEN
			       --Different message will be logged if called from legacy procedure
                               FND_MESSAGE.SET_NAME('IGS','IGS_RE_SUB_DT_CNT_NULL');
                               FND_MSG_PUB.ADD;
			END IF;
                        RETURN FALSE;
                END IF;
		IF p_legacy <> 'Y' THEN
                      -- 2. Cannot be cleared IF any IGS_RE_THESIS panel records exist
                      -- which have results recorded.
                      OPEN c_tpm;
                      FETCH c_tpm INTO v_tpm_exists;
                      IF c_tpm%FOUND THEN
                              CLOSE c_tpm;
                              p_message_name := 'IGS_RE_CHK_UNSUB_RES_ENT_PAN';
                              RETURN FALSE;
                      END IF;
                      CLOSE c_tpm;
		END IF;
        END IF;
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_the%ISOPEN THEN
                        CLOSE c_the;
                END IF;
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                IF c_tex%ISOPEN THEN
                        CLOSE c_tex;
                END IF;
                IF c_rsup%ISOPEN THEN
                        CLOSE c_rsup;
                END IF;
                IF c_cfos%ISOPEN THEN
                        CLOSE c_cfos;
                END IF;
                IF c_csc%ISOPEN THEN
                        CLOSE c_csc;
                END IF;
                IF c_tex2%ISOPEN THEN
                        CLOSE c_tex2;
                END IF;
                IF c_tpm%ISOPEN THEN
                        CLOSE c_tpm;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_tex_sbmsn;
  --
  -- To validate the IGS_RE_THESIS examination update
  FUNCTION RESP_VAL_TEX_UPD(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_transaction_type IN VARCHAR2 ,
  p_submission_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        cst_insert      CONSTANT        VARCHAR2(10) := 'INSERT';
        cst_update      CONSTANT        VARCHAR2(10) := 'UPDATE';
        cst_delete      CONSTANT        VARCHAR2(10) := 'DELETE';
        cst_enrolled    CONSTANT
                                        IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'ENROLLED';
        cst_inactive    CONSTANT
                                        IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INACTIVE';
        cst_intermit    CONSTANT
                                        IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INTERMIT';
	cst_completed  CONSTANT
					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'COMPLETED';
        cst_examined    CONSTANT        IGS_RE_THESIS_V.thesis_status%TYPE := 'EXAMINED';
        cst_deleted     CONSTANT        IGS_RE_THESIS_V.thesis_status%TYPE := 'DELETED';
        v_sca_course_cd                 IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
        v_course_attempt_status         IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
        v_thesis_status                 IGS_RE_THESIS_V.thesis_status%TYPE;
        v_message_name                  VARCHAR2(30);
        CURSOR c_ca IS
                SELECT  ca.sca_course_cd
                FROM    IGS_RE_CANDIDATURE      ca
                WHERE   ca.person_id            = p_person_id AND
                        ca.sequence_number      = p_ca_sequence_number;
        CURSOR c_sca (
                cp_sca_course_cd        IGS_RE_CANDIDATURE.sca_course_cd%TYPE) IS
                SELECT  sca.course_attempt_status
                FROM    IGS_EN_STDNT_PS_ATT     sca
                WHERE   sca.person_id = p_person_id AND
                        sca.course_cd = cp_sca_course_cd;
        CURSOR c_thev IS
                SELECT  thev.thesis_status
                FROM    IGS_RE_THESIS_V thev
                WHERE   thev.person_id          = p_person_id AND
                        thev.ca_sequence_number = p_ca_sequence_number AND
                        thev.sequence_number    = p_the_sequence_number;
  BEGIN
        -- Check if person is dead.
        IF IGS_RE_VAL_TEX.genp_val_pe_deceased( p_person_id,
                                                'ERROR',
                                                v_message_name) = FALSE THEN
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        -- Select details from candidature
        OPEN c_ca;
        FETCH c_ca INTO v_sca_course_cd;
        IF (c_ca%NOTFOUND) THEN
                -- Invalid parameters
                CLOSE c_ca;
                p_message_name := NULL;
                RETURN TRUE;
        END IF;
        CLOSE c_ca;
        IF (p_transaction_type IN (
                                cst_insert,
                                cst_update,
                                cst_delete)) THEN
                -- 1. Not if the candidature is not linked to enrolments
                IF (v_sca_course_cd IS NULL) THEN
                        p_message_name := 'IGS_RE_CANT_IU_THESIS_EXM_DET';
                        RETURN FALSE;
                END IF;
                -- Select details from IGS_EN_STDNT_PS_ATT
                OPEN c_sca(v_sca_course_cd);
                FETCH c_sca INTO v_course_attempt_status;
                CLOSE c_sca;
                -- 2. Not if the course_attempt_status is not ENROLLED, INTERMIT, COMPLETED or INACTIVE
                IF (v_course_attempt_status NOT IN (
                                                cst_enrolled,
                                                cst_inactive,
                                                cst_intermit,
						cst_completed)) THEN
                        p_message_name := 'IGS_RE_CANT_IU_EXAM_DETAILS';
                        RETURN FALSE;
                END IF;
                -- 3. Not if the parent IGS_RE_THESIS is EXAMINED or DELETED
                OPEN c_thev;
                FETCH c_thev INTO v_thesis_status;
                IF (c_thev%FOUND AND
                                v_thesis_status IN (
                                                cst_examined,
                                                cst_deleted)) THEN
                        CLOSE c_thev;
                        p_message_name := 'IGS_RE_CANT_IU_EXAM_DETAIL';
                        RETURN FALSE;
                END IF;
                CLOSE c_thev;
        END IF;
        IF (p_transaction_type = cst_delete) THEN
                -- 1. Cannot delete if the examination has been submitted
                IF (p_submission_dt IS NOT NULL) THEN
                        p_message_name := 'IGS_RE_CANT_DEL_THESIS_EXAM';
                        RETURN FALSE;
                END IF;
        END IF;
        p_message_name := NULL;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_ca%ISOPEN) THEN
                        CLOSE c_ca;
                END IF;
                IF (c_sca%ISOPEN) THEN
                        CLOSE c_sca;
                END IF;
                IF (c_thev%ISOPEN) THEN
                        CLOSE c_thev;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_tex_upd;
  --
  -- To validate IGS_RE_THESIS examination type
  FUNCTION RESP_VAL_TEX_TET(
  p_thesis_exam_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_tex_tet
        -- Validate the thesis_examination.thesis_examination_type, checking for :
        --   Closed examination type
  DECLARE
        v_dummy         VARCHAR2(1);
        CURSOR  c_tet IS
                SELECT  'x'
                FROM    IGS_RE_THS_EXAM_TYPE tet
                WHERE   tet.thesis_exam_type    = p_thesis_exam_type    AND
                        tet.closed_ind          = 'Y';
  BEGIN
        -- set default value
        p_message_name := NULL;
        -- 1. Check for closed type
        OPEN c_tet;
        FETCH c_tet INTO v_dummy;
        IF c_tet%FOUND THEN
                CLOSE c_tet;
                p_message_name := 'IGS_RE_THESIS_EXAM_TYPE_CLOSE';
                RETURN FALSE;
        END IF;
        CLOSE c_tet;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_tet%ISOPEN THEN
                        CLOSE c_tet;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END; -- resp_val_tex_tet
  --
  -- To validate IGS_RE_THESIS examination result code
  FUNCTION RESP_VAL_TEX_THR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_submission_dt IN DATE ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_thesis_panel_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_tex_thr
        -- Validate IGS_RE_THESIS_EXAM.thesis_result_cd, checking for :
        --   Code cannot be closed
        --   Code cannot be specified if submission_dt is not set
        --   Warning if code does not match any of the panel members results
        --   (if any results exist)
        --   Cannot be cleared if IGS_RE_THESIS has been EXAMINED (ie. final result entered).
  DECLARE
        cst_examined            CONSTANT VARCHAR2(10) := 'EXAMINED';
        v_dummy                 VARCHAR2(1);
        v_closed_ind            IGS_RE_THESIS_RESULT.closed_ind%TYPE;
        v_records_found         BOOLEAN;
        v_result_match          BOOLEAN;
        v_record_count          NUMBER;
        v_confirmed_count               NUMBER;
        v_recommended_panel_size        IGS_RE_THS_PNL_TYPE.recommended_panel_size%TYPE;
        CURSOR  c_thr IS
                SELECT  thr.closed_ind
                FROM    IGS_RE_THESIS_RESULT thr
                WHERE   thr.thesis_result_cd = p_thesis_result_cd;
        CURSOR c_tpm IS
                SELECT  tpm.thesis_result_cd
                FROM    IGS_RE_THS_PNL_MBR tpm
                WHERE   tpm.ca_person_id                = p_person_id           AND
                        tpm.ca_sequence_number  = p_ca_sequence_number  AND
                        tpm.the_sequence_number = p_the_sequence_number AND
                        tpm.creation_dt         = p_creation_dt         AND
                        tpm.confirmed_dt        IS NOT NULL             AND
                        tpm.thesis_result_cd    IS NOT NULL;
        CURSOR c_tpt IS
                SELECT  tpt.recommended_panel_size
                FROM    IGS_RE_THS_PNL_TYPE tpt
                WHERE   tpt.thesis_panel_type   = p_thesis_panel_type;
        CURSOR  c_tpmc IS
                SELECT  confirmed_dt
                FROM    IGS_RE_THS_PNL_MBR tpm
                WHERE   tpm.ca_person_id                = p_person_id   AND
                        tpm.ca_sequence_number  = p_ca_sequence_number  AND
                        tpm.the_sequence_number = p_the_sequence_number AND
                        tpm.creation_dt         = p_creation_dt;
        CURSOR c_thev IS
                SELECT  'x'
                FROM    IGS_RE_THESIS_V thev
                WHERE   thev.person_id          = p_person_id           AND
                        thev.ca_sequence_number = p_ca_sequence_number  AND
                        thev.sequence_number    = p_the_sequence_number AND
                        thev.thesis_status      = cst_examined;
        CURSOR c_tex IS
                SELECT  'x'
                FROM    IGS_RE_THESIS_EXAM tex
                WHERE   tex.person_id   = p_person_id   AND
                        tex.ca_sequence_number  = p_ca_sequence_number  AND
                        tex.the_sequence_number = p_the_sequence_number AND
                        tex.creation_dt >       p_creation_dt   AND
                        tex.submission_dt       IS NOT NULL;
  BEGIN
        -- set default value
        p_message_name := NULL;
        v_records_found := FALSE;
        v_result_match  := FALSE;
        IF p_thesis_result_cd IS NOT NULL THEN
                -- 1. Cannot be specified if not a submitted IGS_RE_THESIS.
                IF p_submission_dt IS NULL THEN
                        p_message_name := 'IGS_RE_CANT_ENTER_RES_EXAM';
                        RETURN FALSE;
                END IF;
                -- 2. Cannot be closed.
                OPEN c_thr;
                FETCH c_thr INTO v_closed_ind;
                IF c_thr%NOTFOUND THEN
                        -- Invalid parameters - will be picked up by calling routine
                        CLOSE c_thr;
                        RETURN TRUE;
                END IF;
                CLOSE c_thr;
                IF v_closed_ind = 'Y' THEN
                        p_message_name := 'IGS_RE_THESIS_RESUILT_CLOSED';
                        RETURN FALSE;
                END IF;
                -- Validate that minimum panel size has been met.
                OPEN c_tpt;
                FETCH c_tpt INTO v_recommended_panel_size;
                IF c_tpt%NOTFOUND THEN
                        CLOSE c_tpt;
                        RETURN TRUE;
                END IF;
                CLOSE c_tpt;
                IF v_recommended_panel_size IS NOT NULL AND
                                v_recommended_panel_size <> 0 THEN
                        v_record_count := 0;
                        v_confirmed_count := 0;
                        FOR v_tpmc_rec IN c_tpmc
                        LOOP
                                v_record_count := v_record_count + 1;
                                IF v_tpmc_rec.confirmed_dt IS NOT NULL THEN
                                        v_confirmed_count := v_confirmed_count + 1;
                                END IF;
                        END LOOP;
                        IF v_record_count > 0   AND
                                        v_confirmed_count < v_recommended_panel_size THEN
                                p_message_name := 'IGS_RE_CANT_ENTER_RESULT';
                                RETURN FALSE;
                        END IF;
                END IF;
                -- 3. Warn if result doesn't match at least one of the IGS_RE_THESIS panel results.
                FOR v_tpm_rec IN c_tpm Loop
                        v_records_found := TRUE;
                        IF p_thesis_result_cd = v_tpm_rec.thesis_result_cd THEN
                                v_result_match := TRUE;
                        END IF;
                END LOOP;
                IF v_records_found = TRUE AND
                                v_result_match = FALSE THEN
                        -- warning only
                        p_message_name := 'IGS_RE_RES_DOES_NOT_MATCH';
                        RETURN TRUE;
                END IF;
        ELSE -- result code null
                --4. Cannot be cleared if the parent IGS_RE_THESIS status is EXAMINED.
                OPEN c_thev;
                FETCH c_thev INTO v_dummy;
                IF c_thev%FOUND THEN
                        CLOSE c_thev;
                        p_message_name := 'IGS_RE_RES_CANT_BE_REMOVED';
                        RETURN FALSE;
                END IF;
                CLOSE c_thev;
                -- Cannot be cleared if later submission exists.
                OPEN c_tex;
                FETCH c_tex INTO v_dummy;
                IF c_tex%FOUND THEN
                        CLOSE c_tex;
                        p_message_name := 'IGS_RE_CANT_CLEAR_RESULT_CODE';
                        RETURN FALSE;
                END IF;
                CLOSE c_tex;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_thr%ISOPEN THEN
                        CLOSE c_thr;
                END IF;
                IF c_tpm%ISOPEN THEN
                        CLOSE c_tpm;
                END IF;
                IF c_thev%ISOPEN THEN
                        CLOSE c_thev;
                END IF;
                IF c_tex%ISOPEN THEN
                        CLOSE c_tex;
                END IF;
                IF c_tpt%ISOPEN THEN
                        CLOSE c_tpt;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END; -- resp_val_tex_thr
  --
  -- To validate thesis_exam panel type
  FUNCTION RESP_VAL_TEX_TPT(
  p_thesis_panel_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
 BEGIN  -- resp_val_tex_tpt
        -- Validate the thesis_examination.thesis_panel_type, checking for :
        --   Closed examination panel type
  DECLARE
        v_dummy         VARCHAR2(1);
        CURSOR  c_tpt IS
                SELECT  'x'
                FROM    IGS_RE_THS_PNL_TYPE tpt
                WHERE   tpt.thesis_panel_type   = p_thesis_panel_type   AND
                        tpt.closed_ind          = 'Y';
  BEGIN
        -- set default value
        p_message_name := NULL;
        -- 1. Check for closed type
        OPEN c_tpt;
        FETCH c_tpt INTO v_dummy;
        IF c_tpt%FOUND THEN
                CLOSE c_tpt;
                p_message_name := 'IGS_RE_THESIS_EXAM_TYP_CLOSED';
                RETURN FALSE;
        END IF;
        CLOSE c_tpt;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_tpt%ISOPEN THEN
                        CLOSE c_tpt;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END; -- resp_val_tex_tpt
END IGS_RE_VAL_TEX;

/
