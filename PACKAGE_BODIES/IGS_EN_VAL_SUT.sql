--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SUT" AS
/* $Header: IGSEN70B.pls 120.0 2005/06/01 14:43:00 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  --amuthu      14-JUL-2004     Allowing the drop of duplicate unit attempt as
  --                            part of IGS.M bug 3765628/ IGS.L.#R bug 3703889
  --                            Modified the logic in enrp_val_sut_delete to correctly
  --                            check if unit has been transfered to another program
  --                            before deleting it.
  --ckasu       06-Dec-2004     modified enrp_val_sut_insert procedure as a part of bug#4048248
  --                            inorder to transfer discontinue unit attempt with result other
  --                            than fail from source prgm to dest prgm.
  -- smaddali   16-dec-04       Modified enrp_val_sut_insert for bug#4063726.
  -------------------------------------------------------------------------------------------
  -- To validate for student unit transfer on delete.
 FUNCTION enrp_val_sut_delete(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER)
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      New parameter p_uoo_id is added to the function and modified c_sua
  --                            cursor where clause w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
  BEGIN	-- enrp_val_sut_delete
  	-- This module validates the delete of IGS_PS_STDNT_UNT_TRN details.
  DECLARE
  	CURSOR c_sua IS
                SELECT  'X'
                FROM    IGS_PS_STDNT_UNT_TRN sut, igs_en_su_attempt sua
                WHERE   sut.person_id           = p_person_id AND
                        sut.transfer_course_cd  = p_course_cd AND
                        sut.uoo_id              = p_uoo_id AND
                        sua.person_id = sut.person_id AND
                        sua.course_cd = sut.transfer_course_cd AND
                        sua.uoo_id = sut.uoo_id;
  	v_dummy		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Validate that related DUPLICATE student unit attempt
  	-- does not exist.
  	OPEN c_sua;
  	FETCH c_sua INTO v_dummy;
  	IF c_sua%FOUND THEN
  		-- Prevent deletion of transfer link
  		CLOSE c_sua;
  		p_message_name := 'IGS_EN_STUDUNIT_TRNS_NOTDEL';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sua;
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
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUT.enrp_val_sut_delete');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_sut_delete;
  --
  -- To validate for student unit transfer on insert.
  FUNCTION enrp_val_sut_insert(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_transfer_course_cd          IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN NUMBER)
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  -- enrp_val_sut_insert
  -- This module validates the insert of IGS_PS_STDNT_UNT_TRN details
  -- * Transferred 'from' IGS_PS_UNIT must have unit_attempt_status 'COMPLETED',
  --   'DUPLICATE', ('DISCONTIN' and IGS_EN_SU_ATTEMPT has a result of
  --   'FAIL').
  -- * Cannot insert if transferred ?to? IGS_PS_UNIT maps to IGS_EN_STDNT_PS_ATT
  --   with course_attempt_status 'UNCONFIRM', 'DISCONTIN', 'LAPSED',
  --   'COMPLETED'.
  -- IGS_GE_NOTE: all statuses with the exception of unconfirmed are handled in
  -- ENRP_VAL_SCT_TO validation.
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      New parameter p_uoo_id is added to the function and modified c_sua
  --                            cursor where clause w.r.t. bug number 2829262
  --ckasu       06-Dec-2004     removed ELSIF condition as aprt of bug#4048248 inorder to transfer
  --                            discontinue unit attempt with result other than fail from source prgm
  --                            to dest prgm.
  -- smaddali  16-dec-04        Modified the validation to allow creation of transfer records for
  --                            ENROLLED and INVALID unit attempts. bug#4063726
  -------------------------------------------------------------------------------------------

  BEGIN
  DECLARE
  	cst_dropped 		CONSTANT	VARCHAR2(10) := 'DROPPED';
  	cst_unconfirm		CONSTANT	VARCHAR2(10) := 'UNCONFIRM';
  	CURSOR c_sua_from IS
  		SELECT  sua.unit_attempt_status
  		FROM	IGS_EN_SU_ATTEMPT 	sua
  		WHERE	sua.person_id		= p_person_id AND
  			sua.course_cd		= p_transfer_course_cd AND
  			sua.uoo_id   	   	= p_uoo_id ;
  	CURSOR c_sca IS
  		SELECT	sca.course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id		= p_person_id AND
  			sca.course_cd		= p_course_cd;
  	v_from_unit_attempt_status		IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
  	v_s_result_type				IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  	v_outcome_dt				IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
  	v_grading_schema_cd			IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  	v_gs_version_number			IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  	v_grade					IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  	v_mark					IGS_AS_SU_STMPTOUT.mark%TYPE;
  	v_origin_course_cd			IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  	v_course_attempt_status			IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  BEGIN
  	p_message_name := null;
  	-- Get student unit attempt of transfer 'from' IGS_PS_UNIT
  	OPEN c_sua_from;
  	FETCH c_sua_from INTO v_from_unit_attempt_status;
  	IF (c_sua_from%NOTFOUND) THEN
  		-- This is a foreign key constraint and will be handled elsewhere
  		CLOSE c_sua_from;
  		p_message_name := null;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_sua_from;
  		-- Can only transfer duplicate, completed and discontinued units
        -- smaddali modified this validation to enable transfer of enrolled and invalid unit attempts also. bug#4063726
  		IF v_from_unit_attempt_status IN (
  						cst_unconfirm,
  						cst_dropped ) THEN
  			p_message_name := 'IGS_EN_TRNS_FROMUNIT_NOTCONFI';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	OPEN c_sca;
  	FETCH c_sca INTO v_course_attempt_status;
  	IF (c_sca%NOTFOUND) THEN
  		-- This could not happen without above student unit attempt select failing
  		CLOSE c_sca;
  		p_message_name := null;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_sca;
  		IF v_course_attempt_status = cst_unconfirm THEN
  			p_message_name := 'IGS_EN_NOTTRNS_UA_UNCONFIRM';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sua_from%ISOPEN) THEN
  			CLOSE c_sua_from;
  		END IF;
  		IF (c_sca%ISOPEN) THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUT.enrp_val_sut_insert');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_sut_insert;
END IGS_EN_VAL_SUT;

/
