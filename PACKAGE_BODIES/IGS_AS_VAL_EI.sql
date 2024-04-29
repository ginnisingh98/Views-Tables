--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_EI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_EI" AS
/* $Header: IGSAS16B.pls 115.4 2002/11/28 22:43:29 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "assp_val_ve_closed"
  -------------------------------------------------------------------------------------------
  --
  -- Validate insert of IGS_AS_EXAM_INSTANCE record
  FUNCTION ASSP_VAL_EI_INS(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_ass_id IN NUMBER ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS


  BEGIN -- assp_val_ei_ins
        -- This module validates the insert of an IGS_AS_EXAM_INSTANCE record
  DECLARE

        v_active_unit           BOOLEAN;
        v_ust_exist             BOOLEAN;

        v_atyp_exam_ind         IGS_AS_ASSESSMNT_TYP.examinable_ind%TYPE;
        v_ai_sched_ind          IGS_AS_ASSESSMNT_ITM.exam_scheduled_ind%TYPE;


        CURSOR c_atyp IS
                SELECT  atyp.examinable_ind,
                        ai.exam_scheduled_ind
                FROM    IGS_AS_ASSESSMNT_TYP         atyp,
                        IGS_AS_ASSESSMNT_ITM         ai
                WHERE   ai.ass_id               = p_ass_id      AND
                        atyp.assessment_type    = ai.assessment_type;

        CURSOR c_ust IS
                SELECT  ust.s_unit_status
                FROM    IGS_PS_UNIT_STAT             ust,
                        IGS_AS_UNITASS_ITEM    uai,
                        IGS_PS_UNIT_VER            uv
                WHERE   uai.ass_id                              = p_ass_id              AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                        p_exam_cal_type,
                                        p_exam_ci_sequence_number,
                                        uai.cal_type,
                                        uai.ci_sequence_number,
                                        'N')                    = 'Y'                   AND
                        uv.unit_cd                              = uai.unit_cd           AND
                        uv.version_number                       = uai.version_number    AND
                        ust.unit_status                         = uv.unit_status;

  BEGIN
        -- Set the default message number
        P_MESSAGE_NAME := NULL;

        --initialise variables
        v_active_unit   := FALSE;
        v_ust_exist     := FALSE;

        -- Check that assessment item is examinable and scheduled
        OPEN c_atyp ;
        FETCH c_atyp INTO       v_atyp_exam_ind,
                                v_ai_sched_ind;
        IF (c_atyp%NOTFOUND) THEN
                --Routine is not applicable
                CLOSE c_atyp;
                RETURN TRUE;
        END IF;
        CLOSE c_atyp;


        IF (v_atyp_exam_ind = 'N') THEN
                --Assessment item is not examinable so return
                P_MESSAGE_NAME := 'IGS_AS_ASSITEM_EXAM_SCHEDULES';
                RETURN FALSE;
        END IF;


        IF (v_ai_sched_ind = 'N') THEN
                --Assessment item is not scheduled so return
                P_MESSAGE_NAME := 'IGS_AS_ASSITEM_MARKED_SCHEDUL';
                RETURN FALSE;
        END IF;

        RETURN TRUE;
  END;
  EXCEPTION
        WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_EI.assp_val_ei_ins');
		IGS_GE_MSG_STACK.ADD;
  END assp_val_ei_ins;
END IGS_AS_VAL_EI;

/
