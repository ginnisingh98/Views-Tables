--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_THE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_THE" AS
/* $Header: IGSRE16B.pls 115.6 2002/11/29 10:56:22 pradhakr ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  --svenkata    8-MAR-2002      Bug # 2146848. A cursor in the function RESP_VAL_THE_THR was modified .
  --Nishikant   19NOV2002       Bug#2661533. The functions resp_val_the_expct, resp_val_the_embrg, resp_val_the_thr
  --                            got modified to skip some validation in case It has been called from Legacy API.
  --                            Three more functions get_candidacy_dtls, check_dup_thesis, eval_min_sub_dt are added.
  -- pradhakr   29-Nov-2002     Added the hint NOCOPY to all the OUT parameters. Replaced all
  --				the OUT parameter with OUT NOCOPY. Bug# 2683043
  -------------------------------------------------------------------------------------------
   -- To valdate IGS_RE_THESIS citation fiels
  FUNCTION RESP_VAL_THE_CTN(
  p_thesis_status IN VARCHAR2 ,
  p_citation IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_the_ctn
  BEGIN
        p_message_name := NULL;
        IF NVL(p_thesis_status,' ') NOT IN (
                                'EXAMINED',
                                'SUBMITTED') AND
           p_citation IS NOT NULL THEN
                p_message_name := 'IGS_RE_CANT_ENTER_GRAD_CITAT';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_the_ctn;
  --
  -- Validate IGS_RE_THESIS logical deletion date
  FUNCTION RESP_VAL_THE_DEL_DT(
  p_old_logical_delete_dt IN DATE ,
  p_new_logical_delete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_the_del_dt
  DECLARE
  BEGIN
        p_message_name := NULL;
        -- 1. Date cannot be changed once set.
        IF p_new_logical_delete_dt IS NOT NULL AND
           p_old_logical_delete_dt IS NOT NULL AND
           p_new_logical_delete_dt <> p_old_logical_delete_dt  THEN
                p_message_name := 'IGS_RE_LOGICA_DEL_DT_CANT_UPD';
                RETURN FALSE;
        END IF;
        -- 2. If date being set, then must be equal to today.
        IF p_old_logical_delete_dt IS NULL AND
            p_new_logical_delete_dt IS NOT NULL AND
           TRUNC(p_new_logical_delete_dt) <> TRUNC(SYSDATE) THEN
                p_message_name := 'IGS_RE_SET_LOGICALDT_TO_CURR';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_the_del_dt;
  --
  -- To validate the IGS_RE_THESIS expected submission date
  FUNCTION RESP_VAL_THE_EXPCT(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_expected_submission_dt IN DATE ,
  p_legacy IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*  Change History :
  Who             When            What
  (reverse chronological order - newest change first)

  Nishikant       15NOV2002       The function got modified to skip some validation in case
                                  It has been called from Legacy API. And if any error message then
                                  logs in the message stack and proceed further.
  */
  BEGIN -- resp_val_the_expct
        -- Description: Validate the IGS_RE_THESIS.expected_submission_dt, checking for
        -- * Cannot be backdated.
        -- * Cannot be prior to the derived/override minimum submission date
        -- * Cannot be beyond the derived/override maximum submission date
  DECLARE
        v_max_sub_dt            IGS_RE_CANDIDATURE.max_submission_dt%TYPE := NULL;
        v_min_sub_dt            IGS_RE_CANDIDATURE.min_submission_dt%TYPE := NULL;
        CURSOR  c_ca IS
                SELECT  ca.max_submission_dt,
                        ca.min_submission_dt
                FROM    IGS_RE_CANDIDATURE      ca
                WHERE   ca.person_id            = p_person_id AND
                        ca.sequence_number      = p_ca_sequence_number;
  BEGIN
        p_message_name := NULL;
        IF p_legacy <> 'Y' THEN  --this validation is not required for legacy
                IF TRUNC(p_expected_submission_dt) < TRUNC(SYSDATE) THEN
                        p_message_name := 'IGS_RE_SUBM_DT_CANT_BACKDATED';
                        RETURN FALSE;
                END IF;
        END IF;
        OPEN c_ca;
        FETCH c_ca INTO v_max_sub_dt,
                        v_min_sub_dt;
        IF (c_ca%NOTFOUND) THEN
                CLOSE c_ca;
                RETURN TRUE;
        END IF;
        CLOSE c_ca;
        -- Check whether > maximum submission date
        IF v_min_sub_dt IS NULL THEN
                v_min_sub_dt := NVL(IGS_RE_GEN_001.RESP_CLC_MIN_SBMSN(
                                        p_person_id,
                                        p_ca_sequence_number,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL), SYSDATE);
        END IF;
        IF TRUNC(p_expected_submission_dt) < TRUNC(v_min_sub_dt) THEN
                p_message_name := 'IGS_RE_SUB_DT_CANT_BEF_MIN_DT';
                IF p_legacy <> 'Y' THEN
                      RETURN FALSE;
                ELSE
                      FND_MESSAGE.SET_NAME ('IGS',p_message_name);
                      FND_MSG_PUB.ADD;
                END IF;
        END IF;
        -- Check whether > maximum submission date
        IF v_max_sub_dt IS NULL THEN
                v_max_sub_dt := NVL(IGS_RE_GEN_001.RESP_CLC_MAX_SBMSN(
                                        p_person_id,
                                        p_ca_sequence_number,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL), SYSDATE);
        END IF;
        IF TRUNC(p_expected_submission_dt) > TRUNC(v_max_sub_dt) THEN
                p_message_name := 'IGS_RE_SUB_DT_CANT_BEF_MAX_DT';
                IF p_legacy <> 'Y' THEN
                      RETURN FALSE;
                ELSE
                      FND_MESSAGE.SET_NAME ('IGS',p_message_name);
                      FND_MSG_PUB.ADD;
                      RETURN FALSE;
                END IF;
        END IF;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_the_expct;
  --
  -- To validate thesis embargo details
  FUNCTION RESP_VAL_THE_EMBRG(
  p_embargo_details IN VARCHAR2 ,
  p_old_embargo_expiry_dt IN DATE ,
  p_new_embargo_expiry_dt IN DATE ,
  p_thesis_status IN VARCHAR2 ,
  p_legacy IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*  Change History :
  Who             When            What
  (reverse chronological order - newest change first)

  Nishikant       15NOV2002       The function got modified to skip some validation in case
                                  It has been called from Legacy API. And if any error message then
                                  logs in the message stack and proceed further.
  */
  BEGIN -- resp_val_the_embrg
        -- Validate thesis embargo fields (embargo_details, embargo_expiry_dt),
        -- checking for :
        -- Cannot enter details unless SUBMITTED or EXAMINED
        -- That the expiry date cannot be set if the details aren't set
        -- That the details cannot be unset if the expiry date is set
        -- The expiry date cannot be backdated
  DECLARE
  BEGIN
        -- Cannot enter details unless SUBMITTED or EXAMINED
        IF NVL(p_thesis_status,' ') NOT IN ('SUBMITTED','EXAMINED') AND
                                (p_new_embargo_expiry_dt IS NOT NULL OR
                                 p_embargo_details IS NOT NULL) THEN
                p_message_name := 'IGS_RE_CANT_SPECIFY_EMBARGO';
                IF p_legacy <> 'Y' THEN
                      RETURN FALSE;
                ELSE
                      FND_MESSAGE.SET_NAME ('IGS',p_message_name);
                      FND_MSG_PUB.ADD;
                END IF;
        END IF;
        -- 1. Check that if the expiry date is set that the details are set.
        IF p_new_embargo_expiry_dt IS NOT NULL AND
                        p_embargo_details IS NULL THEN
                p_message_name := 'IGS_RE_CANT_ENTER_EMBARGO_DT';
                IF p_legacy <> 'Y' THEN
                      RETURN FALSE;
                ELSE
                      FND_MESSAGE.SET_NAME ('IGS',p_message_name);
                      FND_MSG_PUB.ADD;
                      RETURN FALSE;
                END IF;
        END IF;
        -- Check that the embargo expiry date is different to the old embargo date and
        -- not backdated
        IF p_legacy <> 'Y' THEN --for legacy this validation is not required
            IF NVL(p_old_embargo_expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                        NVL(p_new_embargo_expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
               (p_new_embargo_expiry_dt IS NOT NULL AND
                p_new_embargo_expiry_dt < TRUNC(SYSDATE)) THEN
                  p_message_name := 'IGS_RE_EMBARGO_DT_CANT_BACKDT';
                  RETURN FALSE;
            END IF;
        END IF;
        p_message_name := NULL;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_the_embrg;
  --
  -- Validate thesis deletion (logical deletion)
  FUNCTION RESP_VAL_THE_DEL(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_logical_delete_dt IN DATE ,
  p_thesis_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_the_del
        -- Description: Validate the IGS_RE_THESIS.logical_delete_dt, checking for
        -- * Cannot logically delete when status is SUBMITTED or EXAMINED
  DECLARE
        v_thesis_status         IGS_RE_THESIS_V.thesis_status%TYPE;
        v_ret_val               BOOLEAN := TRUE;
        CURSOR  c_thev IS
                SELECT  thesis_status
                FROM    IGS_RE_THESIS_V thev
                WHERE   person_id               = p_person_id AND
                        ca_sequence_number      = p_ca_sequence_number AND
                        sequence_number         = p_sequence_number;
  BEGIN
        p_message_name := NULL;
        IF p_logical_delete_dt IS NOT NULL THEN
                IF p_thesis_status IS NULL THEN
                        OPEN c_thev;
                        FETCH c_thev INTO v_thesis_status;
                        IF (c_thev%NOTFOUND) THEN
                                CLOSE c_thev;
                                RETURN TRUE;
                        END IF;
                        CLOSE c_thev;
                ELSE
                        v_thesis_status := p_thesis_status;
                END IF;
                IF v_thesis_status IN ( 'EXAMINED',
                                        'SUBMITTED') THEN
                        p_message_name := 'IGS_RE_CANT_DEL_THESIS_DETAIL';
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN v_ret_val;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_the_del;
  --
  -- To validate IGS_RE_THESIS library details
  FUNCTION RESP_VAL_THE_LBRY(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_library_catalogue_number IN VARCHAR2 ,
  p_library_lodgement_dt IN DATE ,
  p_thesis_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_the_lbry
        -- Description: Validate the IGS_RE_THESIS library details
        -- (library_catalogue_number, library_lodgement_dt), checking for :
        -- *That the details cannot be specified if the IGS_RE_THESIS status is not
        -- EXAMINED or SUBMITTED.
  DECLARE
        v_thesis_status         IGS_RE_THESIS_V.thesis_status%TYPE;
        v_ret_val               BOOLEAN := TRUE;
        CURSOR  c_thev IS
                SELECT  thesis_status
                FROM    IGS_RE_THESIS_V thev
                WHERE   person_id               = p_person_id AND
                        ca_sequence_number      = p_ca_sequence_number AND
                        sequence_number         = p_sequence_number;
  BEGIN
        p_message_name := NULL;
        IF p_library_catalogue_number IS NOT NULL OR
                        p_library_lodgement_dt IS NOT NULL THEN
                IF p_thesis_status IS NULL THEN
                        OPEN c_thev;
                        FETCH c_thev INTO v_thesis_status;
                        IF (c_thev%NOTFOUND) THEN
                                CLOSE c_thev;
                                RETURN TRUE;
                        END IF;
                        CLOSE c_thev;
                ELSE
                        v_thesis_status := p_thesis_status;
                END IF;
                IF v_thesis_status NOT IN (
                                        'EXAMINED',
                                        'SUBMITTED') THEN
                        p_message_name := 'IGS_RE_CANT_ENTER_LIBR_DETAIL';
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN v_ret_val;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_the_lbry;
  --
  -- To validate the IGS_RE_THESIS result code
  FUNCTION RESP_VAL_THE_THR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_thesis_status IN VARCHAR2 ,
  p_legacy IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*  Change History :
  Who             When            What
  (reverse chronological order - newest change first)

  Nishikant       15NOV2002       The function got modified to skip some validation in case
                                  It has been called from Legacy API. And if any error message then
                                  logs in the message stack and proceed further.
  */
  BEGIN -- resp_val_the_thr
        -- Validate IGS_RE_THESIS.thesis_result_cd, checking for :
        -- Closed result code
        -- Cannot be set against PENDING IGS_RE_THESIS status
        -- Cannot enter if outstanding submitted IGS_RE_THESIS examination
        -- Warn if result not the same as the last IGS_RE_THESIS examination
        -- Can only link to results which are flagged as 'final results'
  DECLARE
        cst_pending     CONSTANT        VARCHAR2(10) := 'PENDING';
        v_dummy                         VARCHAR2(1);
        v_thesis_status                 IGS_RE_THESIS_V.thesis_status%TYPE;
        v_closed_ind                    IGS_RE_THESIS_RESULT.closed_ind%TYPE;
        v_final_result_ind              IGS_LOOKUPS_VIEW.final_result_ind%TYPE;
        v_thesis_result_cd              IGS_RE_THESIS_EXAM.thesis_result_cd%TYPE;
        CURSOR  c_thev IS
                SELECT  thev.thesis_status
                FROM    IGS_RE_THESIS_V thev
                WHERE   thev.person_id          = p_person_id           AND
                        thev.ca_sequence_number = p_ca_sequence_number  AND
                        thev.sequence_number    = p_sequence_number;
        CURSOR  c_tex1 IS
                SELECT  'x'
                FROM    IGS_RE_THESIS_EXAM tex
                WHERE   tex.person_id           = p_person_id           AND
                        tex.ca_sequence_number  = p_ca_sequence_number  AND
                        tex.the_sequence_number = p_sequence_number     AND
                        tex.submission_dt       IS NOT NULL             AND
                        tex.thesis_result_cd    IS NULL;
   -- svenkata : Modified the WHERE clause of the query to match s_thesis_result_cd with the LOOKUP_CODE and not lookup_type .
   -- Bug # 2146848 .
        CURSOR  c_thr_sthr IS
                SELECT  thr.closed_ind,
                        sthr.final_result_ind
                FROM    IGS_RE_THESIS_RESULT thr,
                        IGS_LOOKUPS_VIEW sthr
                WHERE   thr.thesis_result_cd    = p_thesis_result_cd AND
                        sthr.LOOKUP_CODE = thr.s_thesis_result_cd
                        AND sthr.lookup_type = 'THESIS_RESULT';

        CURSOR  c_tex2 IS
                SELECT  tex.thesis_result_cd
                FROM    IGS_RE_THESIS_EXAM tex
                WHERE   tex.person_id           = p_person_id           AND
                        tex.ca_sequence_number  = p_ca_sequence_number  AND
                        tex.the_sequence_number = p_sequence_number     AND
                        tex.submission_dt       IS NOT NULL             AND
                        tex.thesis_result_cd    IS NOT NULL
                ORDER BY tex.submission_dt DESC;
  BEGIN
        p_message_name := NULL;
        IF p_thesis_result_cd IS NOT NULL THEN
                -- 1. Cannot be PENDING IGS_RE_THESIS status (selected from view).
                IF p_thesis_status IS NULL THEN
                        OPEN c_thev;
                        FETCH c_thev INTO v_thesis_status;
                        IF c_thev%NOTFOUND THEN
                                CLOSE c_thev;
                                --Invalid data ; will be picked up by calling routine
                                RETURN TRUE;
                        END IF;
                        CLOSE c_thev;
                ELSE
                         v_thesis_status := p_thesis_status;
                END IF;
                IF v_thesis_status = cst_pending THEN
                        p_message_name := 'IGS_RE_CHK_RES_NOT_YET_EXAMIN';
                        IF p_legacy = 'Y' THEN
                                FND_MESSAGE.SET_NAME('IGS',p_message_name);
                                FND_MSG_PUB.ADD;
                        END IF;
                        RETURN FALSE;
                END IF;
                --2. Cannot enter if outstanding (submitted) IGS_RE_THESIS examination.
             IF p_legacy <> 'Y' THEN --this validation is not required for legacy
                OPEN c_tex1;
                FETCH c_tex1 INTO v_dummy;
                IF c_tex1%FOUND THEN
                        CLOSE c_tex1;
                        p_message_name := 'IGS_RE_CHK_RES_OUTSTAND_EXAM';
                        RETURN FALSE;
                END IF;
                CLOSE c_tex1;
             END IF;
                -- 3. Check for closed code.
                OPEN c_thr_sthr;
                FETCH c_thr_sthr INTO   v_closed_ind,
                                        v_final_result_ind;
                IF c_thr_sthr%NOTFOUND THEN
                        CLOSE c_thr_sthr;
                        --Invalid data ; will be picked up by calling routine
                        RETURN TRUE;
                END IF;
                CLOSE c_thr_sthr;

                IF p_legacy <> 'Y' THEN
                        IF v_closed_ind = 'Y' THEN
                                p_message_name := 'IGS_RE_THESIS_RESUILT_CLOSED';
                                RETURN FALSE;
                        END IF;
                END IF;

                --4. Must be a final result
                IF v_final_result_ind = 'N' THEN
                        p_message_name := 'IGS_RE_CHK_RES_NOT_FINAL_RES';
                        IF p_legacy <> 'Y' THEN
                                RETURN FALSE;
                        ELSE
                                FND_MESSAGE.SET_NAME('IGS',p_message_name);
                                FND_MSG_PUB.ADD;
                                RETURN FALSE;
                        END IF;
                END IF;
                -- 5. Warn if result not the same as the latest examination record.
                IF p_legacy <> 'Y' THEN --this validation is not required for legacy
                        OPEN c_tex2;
                        FETCH c_tex2 INTO v_thesis_result_cd;
                        IF c_tex2%FOUND AND v_thesis_result_cd <> p_thesis_result_cd THEN
                                CLOSE c_tex2;
                                p_message_name := 'IGS_RE_FINAL_RESULT_MISMATCH';
                                RETURN TRUE;  --(Warning Only)
                        END IF;
                        CLOSE c_tex2;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF (c_thev%ISOPEN) THEN
                        CLOSE c_thev;
                END IF;
                IF (c_tex1%ISOPEN) THEN
                        CLOSE c_tex1;
                END IF;
                IF (c_thr_sthr%ISOPEN) THEN
                        CLOSE c_thr_sthr;
                END IF;
                IF (c_tex2%ISOPEN) THEN
                        CLOSE c_tex2;
                END IF;
                RAISE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_the_thr;
  --
  -- To validate the update of the IGS_RE_THESIS table.
  FUNCTION RESP_VAL_THE_UPD(
  p_logical_delete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_the_upd
        -- Validate for insert, update, delete of IGS_RE_THESIS, checking for :
        -- Cannot update if logical_delete_dt is set.
  DECLARE
  BEGIN
        IF p_logical_delete_dt IS NOT NULL THEN
                p_message_name := 'IGS_RE_CANT_UPD_THESIS';
                RETURN FALSE;
        END IF;
        p_message_name := NULL;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_the_upd;
  --
  -- To validate the IGS_RE_THESIS IGS_PE_TITLE
  FUNCTION RESP_VAL_THE_TTL(
  p_old_title IN VARCHAR2 ,
  p_new_title IN VARCHAR2 ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_the_ttl
        -- Validate for change of the IGS_RE_THESIS IGS_PE_TITLE, checking that it cannot be
        -- changed once a final result has been entered
  DECLARE
  BEGIN
        IF p_thesis_result_cd IS NOT NULL AND
                        (p_old_title IS NOT NULL AND
                        p_old_title <> NVL(p_new_title, 'NULL')) THEN
                p_message_name := 'IGS_RE_CANT_ALTER_THESIS_TITL';
                RETURN FALSE;
        END IF;
        p_message_name := NULL;
        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END resp_val_the_ttl;
  --
  -- To validate IGS_RE_THESIS finalised_title_indicator
  FUNCTION RESP_VAL_THE_FNL(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_final_title_ind IN VARCHAR2 ,
  p_thesis_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN -- resp_val_the_fnl
        -- Validate the IGS_RE_THESIS.final_title_ind, checking for :
        -- Cannot be unset once IGS_RE_THESIS is SUBMITTED or EXAMINED
  DECLARE
        cst_submitted   CONSTANT        varchar2(10) := 'SUBMITTED';
        cst_examined    CONSTANT        varchar2(10) := 'EXAMINED';
        v_thesis_status         IGS_RE_THESIS_V.thesis_status%TYPE;
        CURSOR  c_thev IS
                SELECT  thev.thesis_status
                FROM    IGS_RE_THESIS_V thev
                WHERE   thev.person_id          = p_person_id           AND
                        thev.ca_sequence_number = p_ca_sequence_number  AND
                        thev.sequence_number    = p_sequence_number;
  BEGIN
        p_message_name := NULL;
        IF p_final_title_ind = 'N' THEN
                IF p_thesis_status IS NULL THEN
                        OPEN c_thev;
                        FETCH c_thev INTO v_thesis_status;
                        IF c_thev%NOTFOUND THEN
                                CLOSE c_thev;
                                RETURN TRUE;
                        END IF;
                        CLOSE c_thev;
                ELSE
                        v_thesis_status := p_thesis_status;
                END IF;
                IF v_thesis_status IN (
                                cst_submitted,
                                cst_examined) THEN
                        p_message_name := 'IGS_RE_CANT_UNSET_FIN_TIT_IND';
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
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
  END resp_val_the_fnl;

FUNCTION get_candidacy_dtls (
           p_person_id IN NUMBER ,
           p_course_cd IN VARCHAR2 ,
           p_ca_sequence_number OUT NOCOPY NUMBER )
RETURN BOOLEAN IS
  /*
  ||  Created By : nbehera
  ||  Created On : 14-NOV-2002
  ||  Purpose : The function will check for a mapping ca_sequence_number in the table
  ||            igs_re_candidature_all for the corresponding person_id and course_cd combination
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

CURSOR c_ca_seq_number IS
SELECT sequence_number
FROM   igs_re_candidature_all
WHERE  sca_course_cd IS NOT NULL
AND    sca_course_cd = p_course_cd
AND    person_id = p_person_id;

BEGIN

OPEN c_ca_seq_number;
FETCH c_ca_seq_number INTO p_ca_sequence_number;

IF c_ca_seq_number%FOUND THEN
      CLOSE c_ca_seq_number;
      RETURN TRUE;
ELSE
      CLOSE c_ca_seq_number;
      RETURN FALSE;
END IF;
END get_candidacy_dtls ;

FUNCTION check_dup_thesis(
           p_person_id IN NUMBER ,
           p_title IN VARCHAR2 ,
           p_ca_sequence_number IN NUMBER )
RETURN BOOLEAN IS
  /*
  ||  Created By : nbehera
  ||  Created On : 14-NOV-2002
  ||  Purpose : The function checks if the Title of the thesis record already exists for
  ||            the given student.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
CURSOR c_title IS
SELECT title
FROM   igs_re_thesis_all the,
       igs_re_candidature re
WHERE  the.person_id = p_person_id
AND    the.title = p_title
AND    re.sequence_number = p_ca_sequence_number
AND    re.person_id = the.person_id;
l_title  igs_re_thesis_all.title%TYPE;

BEGIN
OPEN c_title;
FETCH c_title INTO l_title;

IF c_title%FOUND THEN
     CLOSE c_title;
     RETURN FALSE;
ELSE
     CLOSE c_title;
     RETURN TRUE;
END IF ;
END check_dup_thesis;

FUNCTION eval_min_sub_dt (
           p_expected_submission_date IN DATE,
           p_ca_sequence_number  IN NUMBER ,
           p_person_id IN NUMBER)
RETURN BOOLEAN IS
  /*
  ||  Created By : nbehera
  ||  Created On : 14-NOV-2002
  ||  Purpose : The function checks the value of the Expected Submission date of the Thesis details
  ||            against the value of Minimum submission date, as entered in the Candidacy Details Form.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

CURSOR c_min_subm_dt IS
SELECT min_submission_dt
FROM   igs_re_candidature
WHERE  sequence_number = p_ca_sequence_number
AND    person_id = p_person_id;
l_min_sub_date   igs_re_candidature.min_submission_dt%TYPE;

BEGIN

OPEN c_min_subm_dt;
FETCH c_min_subm_dt INTO l_min_sub_date;
CLOSE c_min_subm_dt;

--Expected submission date cannot be before the minimum submission date

IF p_expected_submission_date  < l_min_sub_date THEN
        RETURN FALSE;
ELSE
        RETURN TRUE;
END IF;
END eval_min_sub_dt;


END IGS_RE_VAL_THE;

/
