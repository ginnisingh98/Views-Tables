--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SCA" AS
/* $Header: IGSPR08B.pls 115.5 2002/11/29 02:45:39 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_SCA_CMPLT) - from the spec and body. -- kdande
*/
  --
  -- Validate the Student IGS_PS_UNIT Set Attempts.
  FUNCTION prgp_val_susa_cmplt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- prgp_val_susa_cmplt
        -- Validate IGS_EN_STDNT_PS_ATT.course_rqrmnt_complete_ind
        -- and the IGS_PS_STDNT_APV_ALT.rqrmnts_complete_ind
        --      * Cannot be set if any IGS_AS_SU_SETATMPT records
        --        are incomplete or unended for the IGS_PS_COURSE attempt.
  DECLARE
        v_susa_rec_found        VARCHAR2(1);
        CURSOR c_susa IS
                SELECT  'x'
                FROM    IGS_AS_SU_SETATMPT      susa
                WHERE   susa.person_id                  = p_person_id AND
                        susa.course_cd                  = p_course_cd AND
                        susa.student_confirmed_ind      = 'Y' AND
                        susa.rqrmnts_complete_ind       = 'N' AND
                        susa.end_dt                     IS NULL;
  BEGIN
        p_message_name := null;
        -- Check parameters.
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL THEN
                RETURN TRUE;
        END IF;
        -- Check if any IGS_AS_SU_SETATMPT records are incomplete
        -- or unended.
        OPEN c_susa;
        FETCH c_susa INTO v_susa_rec_found;
        IF c_susa%FOUND THEN
                CLOSE c_susa;
                p_message_name := 'IGS_PR_CANT_SET_COMPL_IND';
                RETURN FALSE;
        END IF;
        CLOSE c_susa;
        -- Return no error.
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_susa%ISOPEN THEN
                        CLOSE c_susa;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCA.PRGP_VAL_SUSA_CMPLT');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_susa_cmplt;
  --
  -- Validate the Student IGS_PS_COURSE Attempt Status.
  FUNCTION prgp_val_sca_status(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- prgp_val_sca_status
        -- Validate IGS_EN_STDNT_PS_ATT.course_attempt_status when setting the
        --student_course_attepmt.course_rqrmnt_complete_ind or the
        --IGS_PS_STDNT_APV_ALT.rqrmnts_complete_ind.
        --? Cannot be set if course_attempt_status is 'COMPLETED' or 'UNCONFIRM'.
        --
        -- Modified 28/01/99 to only test for UNCONFIRM (Greg White).
  DECLARE
        cst_unconfirm           CONSTANT
                                                IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'UNCONFIRM';
        v_sca_course_attempt_status
                                                IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
        CURSOR c_sca IS
                SELECT  sca.course_attempt_status
                FROM    IGS_EN_STDNT_PS_ATT     sca
                WHERE   sca.person_id   = p_person_id And
                        sca.course_cd   = p_course_cd And
                        sca.course_attempt_status = cst_unconfirm;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        --1. Check parameters :
        IF p_person_id IS NULL OR
                                p_course_cd IS NULL THEN
                RETURN TRUE;
        END IF;
        --2. Get the IGS_PS_COURSE attempt status.
        OPEN c_sca;
        FETCH c_sca INTO v_sca_course_attempt_status;
        IF c_sca%FOUND THEN
                CLOSE c_sca;
                p_message_name := 'IGS_PR_CANNOT_SET_COMPL_IND';
                RETURN FALSE;
        END IF;
        CLOSE c_sca;
        -- Return the default value
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
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCA.PRGP_VAL_SCA_STATUS');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_sca_status;
  --
  -- Validate the Student IGS_PS_COURSE complete indicator.
  FUNCTION prgp_val_undo_cmpltn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_exit_course_cd IN VARCHAR2 ,
  p_exit_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- prgp_val_undo_cmpltn
  DECLARE
        v_gr_graduand_status                    IGS_GR_GRADUAND.graduand_status%TYPE;
        cst_graduated           CONSTANT        IGS_GR_STAT.s_graduand_status%TYPE := 'GRADUATED';
        cst_surrender           CONSTANT        IGS_GR_STAT.s_graduand_status%TYPE := 'SURRENDER';
        CURSOR c_gr IS
                SELECT  gr.graduand_status
                FROM    IGS_GR_GRADUAND gr,
                        IGS_GR_STAT gst
                WHERE   gr.person_id                    = p_person_id AND
                        gr.course_cd                    = p_course_cd AND
                        gr.award_course_cd              = p_course_cd AND
                        gr.award_crs_version_number     = p_version_number AND
                        gr.graduand_status              = gst.graduand_status AND
                        gst.s_graduand_status IN (
                                                cst_graduated,
                                                cst_surrender);
        CURSOR c_gr1 IS
                SELECT  gr.graduand_status
                FROM    IGS_GR_GRADUAND gr,
                        IGS_GR_STAT gst
                WHERE   gr.person_id                    = p_person_id AND
                        gr.course_cd                    = p_course_cd AND
                        gr.award_course_cd              = p_exit_course_cd AND
                        gr.award_crs_version_number     = p_exit_version_number AND
                        gr.graduand_status              = gst.graduand_status AND
                        gst.s_graduand_status IN (
                                                cst_graduated,
                                                cst_surrender);
  BEGIN
        -- Set the default message number
        p_message_name := null;
        -- 1. Check mandatory parameters :
        IF p_person_id IS NULL OR
                                p_course_cd IS NULL OR
                                p_version_number IS NULL THEN
                RETURN TRUE;
        END IF;
        IF p_exit_course_cd IS NULL THEN
                OPEN c_gr;
                FETCH c_gr INTO v_gr_graduand_status;
                IF c_gr%FOUND THEN
                        CLOSE c_gr;
                        p_message_name := 'IGS_PR_CANNOT_CLEA_COMPL_IND';
                        RETURN FALSE;
                END IF;
                CLOSE c_gr;
        END IF;
        IF p_exit_course_cd IS NOT NULL THEN
                OPEN c_gr1;
                FETCH c_gr1 INTO v_gr_graduand_status;
                IF c_gr1%FOUND THEN
                        CLOSE c_gr1;
                        p_message_name := 'IGS_PR_CANNOT_CLEA_COMPL_IND';
                        RETURN FALSE;
                END IF;
                CLOSE c_gr1;
        END IF;
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_gr%ISOPEN THEN
                        CLOSE c_gr;
                END IF;
                IF c_gr1%ISOPEN THEN
                        CLOSE c_gr1;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCA.PRGP_VAL_UNDO_CMPLTN');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_undo_cmpltn;
  --
  -- Validate the Student IGS_PS_COURSE complete indicator.
  FUNCTION prgp_val_cmplt_ind(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_complete_ind IN VARCHAR2 ,
  p_exit_course_complete_ind IN VARCHAR2,
  p_call_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- prgp_val_cmplt_ind
        -- Validate IGS_EN_STDNT_PS_ATT.course_rqrmnt_complete_ind and the
        -- IGS_PS_STDNT_APV_ALT.rqrmnts_complete_ind.
        --* Both cannot be set for the same IGS_PS_COURSE attempt
  DECLARE
        cst_course              CONSTANT        VARCHAR2(11) := 'COURSE';
        cst_exit_course         CONSTANT        VARCHAR2(11) := 'EXIT_COURSE';
        v_scaae_rec             IGS_PS_STDNT_APV_ALT.rqrmnts_complete_ind%TYPE;
        v_sca_rec               IGS_EN_STDNT_PS_ATT.course_rqrmnt_complete_ind%TYPE;
        CURSOR c_scaae IS
                SELECT  'X'
                FROM    IGS_PS_STDNT_APV_ALT    scaae
                WHERE   scaae.person_id                 = p_person_id AND
                        scaae.course_cd                 = p_course_cd AND
                        scaae.rqrmnts_complete_ind      = 'Y';
        CURSOR c_sca IS
                SELECT  'X'
                FROM    IGS_EN_STDNT_PS_ATT             sca
                WHERE   sca.person_id                   = p_person_id AND
                        sca.course_cd                   = p_course_cd AND
                        sca.course_rqrmnt_complete_ind  = 'Y';
  BEGIN
        -- Set the default message number
        p_message_name := null;
        --1. Check parameters :
        IF p_person_id IS NULL OR
                                p_course_cd IS NULL OR
                                p_call_type IS NULL THEN
                RETURN TRUE;
        END IF;
        IF p_call_type = cst_course THEN
                IF p_course_complete_ind = 'Y' THEN
                        OPEN c_scaae;
                        FETCH c_scaae INTO v_scaae_rec;
                        IF (c_scaae%FOUND) THEN
                                CLOSE c_scaae;
                                p_message_name := 'IGS_PR_COMPL_IND_SET_ALT_EXIT';
                                RETURN FALSE;
                        END IF;
                        CLOSE c_scaae;
                END IF;
        END IF;
        IF p_call_type = cst_exit_course THEN
                IF p_exit_course_complete_ind = 'Y' THEN
                        OPEN c_sca;
                        FETCH c_sca INTO v_sca_rec;
                        IF (c_sca%FOUND) THEN
                                CLOSE c_sca;
                                p_message_name := 'IGS_PR_COMPL_IND_SET_COUR_AT';
                                RETURN FALSE;
                        END IF;
                        CLOSE c_sca;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_scaae%ISOPEN) THEN
                        CLOSE c_scaae;
                END IF;
                IF (c_sca%ISOPEN) THEN
                        CLOSE c_sca;
                END IF;
        RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCA.PRGP_VAL_CMPLT_IND');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_cmplt_ind;
  --
  -- Validate that rqrmnts complete dt and source set if IGS_PS_COURSE complete.
  FUNCTION prgp_val_sca_crcd(
  p_course_rqrmnt_complete_ind IN VARCHAR2,
  p_course_rqrmnts_complete_dt IN DATE ,
  p_s_completed_source_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- prgp_val_sca_crcd
        -- This module validates that if the indicator is set the IGS_PS_COURSE
        -- requirements complete date and completion source are set.
  DECLARE
  BEGIN
        IF p_course_rqrmnt_complete_ind = 'Y' THEN
                IF p_course_rqrmnts_complete_dt IS NULL OR
                                p_s_completed_source_type IS NULL THEN
                        p_message_name := 'IGS_PR_SET_CRS_REQ_COMPL_SORC';
                        RETURN FALSE;
                END IF;
        ELSE
                IF p_course_rqrmnts_complete_dt IS NOT NULL OR
                                p_s_completed_source_type IS NOT NULL THEN
                        p_message_name := 'IGS_PR_CANT_SET_CRS_REQ_SORCE';
                        RETURN FALSE;
                END IF;
        END IF;
        p_message_name := null;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCA.PRGP_VAL_SCA_CRCD');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_sca_crcd;
  --
  -- To validate the IGS_EN_STDNT_PS_ATT.course_rqrmnts_complete_dt
  FUNCTION prgp_val_sca_cmpl_dt(
  p_person_id                   IN NUMBER,
  p_course_cd                   IN VARCHAR2,
  p_commencement_dt             IN DATE,
  p_course_rqrmnts_complete_dt  IN DATE,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2  )
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : Validate the IGS_EN_STDNT_PS_ATT.course_rqrmnts_complete_dt,
  ||           checking for:
  ||                       cannot be a future date
  ||                       cannot be a future date
  ||                       cannot pre-date the IGS_EN_STDNT_PS_ATT.commencement_dt
  ||                       warn if pre-dates the outcome date of the students last enteredn outcome
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        11-11-2002      Modified function logic due to addition of new parameter p_legacy
  ||                                  if p_legacy set to 'Y' then error message should be concatenated instead of
  ||                                  return the function in the normal way. Else function should behave in
  ||                                  normal way.Legacy Build Bug no: 2661533
  ------------------------------------------------------------------------------*/
        gv_other_detail         VARCHAR2(255);
  BEGIN
  DECLARE
        v_max_outcome_dt        IGS_AS_SUAO_V.outcome_dt%TYPE;
        CURSOR c_suaov IS
                SELECT  MAX(suaov.outcome_dt)
                FROM    IGS_AS_SUAO_V   suaov
                WHERE   suaov.person_id                 = p_person_id AND
                        suaov.course_cd                 = p_course_cd AND
                        suaov.finalised_outcome_ind     = 'Y';
  BEGIN
        p_message_name := null;
        IF p_course_rqrmnts_complete_dt IS NOT NULL THEN
                IF p_course_rqrmnts_complete_dt > TRUNC(SYSDATE) THEN
                        IF p_legacy <> 'Y' THEN
                             p_message_name := 'IGS_PR_CHK_COMPL_DATE';
                             RETURN FALSE;
                        ELSE
                             p_message_name := 'IGS_PR_CHK_COMPL_DATE';
                        END IF;
                END IF;
                IF p_course_rqrmnts_complete_dt < p_commencement_dt THEN
                        IF p_legacy <> 'Y' THEN
                             p_message_name := 'IGS_PR_CHK_COURS_COMPL_DT';
                             RETURN FALSE;
                        ELSE
                             IF p_message_name IS NULL THEN
                                p_message_name := 'IGS_PR_CHK_COURS_COMPL_DT';
                             ELSE
                                p_message_name := p_message_name||'*'||'IGS_PR_CHK_COURS_COMPL_DT';
                             END IF;
                        END IF;
                END IF;
                IF p_legacy <> 'Y' THEN
                        OPEN c_suaov;
                        FETCH c_suaov INTO v_max_outcome_dt;
                        CLOSE c_suaov;
                        IF p_course_rqrmnts_complete_dt < v_max_outcome_dt THEN
                                -- Warning only
                                p_message_name := 'IGS_PR_CHECK_CRS_COMPL_DT';
                        END IF;
               END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_suaov%ISOPEN) THEN
                        CLOSE c_suaov;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCA.PRGP_VAL_SCA_CMPL_DT');
                --IGS_GE_MSG_STACK.ADD;
  END prgp_val_sca_cmpl_dt;
END IGS_PR_VAL_SCA;

/
