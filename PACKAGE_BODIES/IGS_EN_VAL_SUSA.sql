--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SUSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SUSA" AS
/* $Header: IGSEN69B.pls 120.3 2006/05/03 23:59:19 smaddali noship $ */

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed
  --                            Also the call to function igs_en_val_susa.genp_val_staff_prsn is
  --                            is replaced by igs_ad_val_acai.genp_val_staff_prsn
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_en_val_susa.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess.Also
  --                            Function genp_val_sdtt_sess Removed
  --msrinivi    27-Aug-2001     Function genp_val_prsn_id removed
  --prraj        15-Nov-2002    Added p_legacy parameter to functions enrp_val_susa_ins, enrp_val_susa_auth,
 --                             enrp_val_susa_cmplt, enrp_val_susa_sci_sd, enrp_val_susa_cousr, enrp_val_susa_parent,
 --                             enrp_val_susa_end_dt, enrp_val_susa_sci, enrp_val_susa_prmry as part of Legacy
 --                             build Bug# 2661533
  -------------------------------------------------------------------------------------------
  --
  -- Routine to process susa rowids in PL/SQL TABLE for current commit.
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

  --
  -- Validate the authorisation fields.
  FUNCTION enrp_val_susa_auth(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_end_dt IN IGS_AS_SU_SETATMPT.end_dt%TYPE ,
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS

  	v_message_name		 VARCHAR2(30);
  BEGIN	-- enrp_val_susa_auth
  	-- This module validates the authorisation fields associated with the
  	-- IGS_AS_SU_SETATMPT:
  	-- - If the authorised_person_id is set, then the authorised_on must also be

  	-- set and visa versa.
  	-- - authorised_person_id and authorised_on fields can only be set if the
  	-- end_dt is also set or the IGS_EN_UNIT_SET.authorisation_ind = 'Y'.
  	-- Validate that the person is a staff member.
  DECLARE
  	v_authorisation_rqrd_ind	IGS_EN_UNIT_SET.authorisation_rqrd_ind%TYPE;
  	CURSOR c_us IS
  		SELECT	us.authorisation_rqrd_ind
  		FROM	IGS_EN_UNIT_SET	us
  		WHERE	us.unit_set_cd		= p_unit_set_cd AND
  			us.version_number	= p_us_version_number;
  BEGIN
    p_message_name := NULL;

  	-- If the authorised_person_id is set, then the authorised_on must also be
  	-- set and visa versa.
  	IF (p_authorised_person_id IS NOT NULL AND
  			p_authorised_on IS NULL) THEN
  		p_message_name := 'IGS_EN_AUTHDT_MUSTBE_SET';

  		IF (p_legacy = 'Y') THEN
			-- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
		ELSE
			RETURN FALSE;
		END IF;

  	END IF;

  	IF (p_authorised_person_id IS NULL AND
  			p_authorised_on IS NOT NULL) THEN
  		p_message_name := 'IGS_EN_AUTHDT_NOTBE_AUTHPRSN';

        IF (p_legacy = 'Y') THEN
			-- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
		ELSE
			RETURN FALSE;
		END IF;

  	END IF;

  	-- authorised_person_id and authorised_on fields can only be set if the
  	-- end_dt is also set or the IGS_EN_UNIT_SET.authorisation_ind = 'Y'.
  	IF (p_authorised_person_id IS NOT NULL AND
  			p_end_dt IS NULL) THEN
  		OPEN c_us;
  		FETCH c_us INTO v_authorisation_rqrd_ind;
  		CLOSE c_us;
  		IF (v_authorisation_rqrd_ind = 'N') THEN
  			p_message_name := 'IGS_EN_AUTHDT_AUTHPRSN_SET';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                RETURN FALSE;
            END IF;

  		END IF;
  	END IF;

  	-- Validate that the authorising person is a staff member.
  	IF p_authorised_person_id IS NOT NULL THEN
  		IF igs_ad_val_acai.genp_val_staff_prsn(p_authorised_person_id,
  						v_message_name) = FALSE THEN
  			p_message_name := 'IGS_EN_AUTHORISED_PRSN_NOT';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                RETURN FALSE;
            END IF;

  		END IF;
  	END IF;

  	RETURN TRUE;

  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_auth');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_auth;


  --
  -- Validate the requirement complete fields for IGS_AS_SU_SETATMPT.
  FUNCTION enrp_val_susa_cmplt(
  p_rqrmnts_complete_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2,
  p_student_confirmed_ind IN VARCHAR2,
  p_message_name OUT NOCOPY  VARCHAR2,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_cmplt
  	-- This module validates the requirements complete fields
  	-- associated with the IGS_AS_SU_SETATMPT:
  	-- - If the rqrmnts_complete_ind is set, then the rqrmnts_complete_dt
  	-- must also be set and visa versa.
  	-- - rqrmnts_complete_dt and rqrmnts_complete_ind fields can only be

  	-- set if the student_confirmed_ind is also set.
  DECLARE
  BEGIN
    p_message_name := NULL;

  	-- If the rqrmnts_complete_ind is set, then the rqrmnts_complete_dt
  	-- must also be set and visa versa.
  	IF (p_rqrmnts_complete_ind = 'Y' AND
  			p_rqrmnts_complete_dt IS NULL) THEN
  		p_message_name := 'IGS_EN_COMPL_DT_SET_COMPL_IND';

        IF (p_legacy = 'Y') THEN
            -- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
        ELSE
            RETURN FALSE;
        END IF;

  	END IF;

  	IF (p_rqrmnts_complete_ind = 'N' AND
  			p_rqrmnts_complete_dt IS NOT NULL) THEN
  		p_message_name := 'IGS_EN_COMPLDT_NOTBE_SET_COMP';

        IF (p_legacy = 'Y') THEN
            -- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
        ELSE
            RETURN FALSE;
        END IF;

  	END IF;

  	-- rqrmnts_complete_dt and rqrmnts_complete_ind fields can only be
  	-- set if the student_confirmed_ind is also set.
  	IF (p_rqrmnts_complete_ind = 'Y' AND
  			p_student_confirmed_ind = 'N') THEN
  		p_message_name := 'IGS_EN_SU_SET_MUSTBE_CONFIRME';

        IF (p_legacy = 'Y') THEN
            -- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
        ELSE
            RETURN FALSE;
        END IF;

  	END IF;

  	RETURN TRUE;

  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_cmplt');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_cmplt;



 FUNCTION ENRP_VAL_SUSA_COUSR(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_message_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- enrp_val_susa_cousr
  	-- Validates that the IGS_EN_UNIT_SET being allocated to the IGS_AS_SU_SETATMPT
  	-- is:

  	-- * If the unit set is a subordinate within the IGS_PS_OF_UNT_SET_RL
  	--   table, then it must be specified as a child of one of the superior
  	--   units.
  	-- * If the unit set is being specified as a child of another
  	--   IGS_AS_SU_SETATMPT, then then parent unit set version must be
  	--   permitted within the course_off_unit_set_relationship entries
  DECLARE
  	v_ver_no		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_susa_us_version_no	IGS_AS_SU_SETATMPT.us_version_number%TYPE;
  	v_cal_type		IGS_EN_STDNT_PS_ATT.cal_type%TYPE;
  	v_only_as_sub_ind 	IGS_PS_OFR_UNIT_SET.only_as_sub_ind%TYPE;
  	v_check		VARCHAR2(1) := NULL;
  	-- Determine if the student's course offering and the course version
  	CURSOR c_sca IS
  		SELECT 	sca.version_number,
  			sca.cal_type
  		FROM	IGS_EN_STDNT_PS_ATT sca
  		WHERE	sca.person_id	= p_person_id AND
  			sca.course_cd	= p_course_cd;
  	CURSOR c_susa IS
  		SELECT 	susa.us_version_number
  		FROM	IGS_AS_SU_SETATMPT susa
  		WHERE	susa.person_id	    = p_person_id AND

  			susa.course_cd	    = p_course_cd AND
  			susa.unit_set_cd    = p_parent_unit_set_cd AND
  			susa.sequence_number = p_parent_sequence_number;
  	CURSOR c_cousr(
  			cp_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE,
  			cp_cal_type			IGS_EN_STDNT_PS_ATT.cal_type%TYPE,
  			cp_susa_us_version_number	IGS_AS_SU_SETATMPT.us_version_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_OF_UNT_SET_RL cousr
  		WHERE	cousr.course_cd 		= p_course_cd			AND
  			cousr.crv_version_number	= cp_version_number		AND
  			cousr.cal_type			= cp_cal_type			AND
  			cousr.sub_unit_set_cd		= p_unit_set_cd			AND
  			cousr.sub_us_version_number 	=p_us_version_number		AND
  			cousr.sup_unit_set_cd		= p_parent_unit_set_cd		AND
  			cousr.sup_us_version_number	= cp_susa_us_version_number;
  	CURSOR c_cousr2(
  			cp_us_version_number	IGS_EN_STDNT_PS_ATT.version_number%TYPE,
  			cp_cal_type		IGS_EN_STDNT_PS_ATT.cal_type%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_OF_UNT_SET_RL cousr
  		WHERE	cousr.course_cd			= p_course_cd 		AND
  			cousr.crv_version_number 		= cp_us_version_number 	AND

  			cousr.cal_type			= cp_cal_type 		AND
  			cousr.sub_unit_set_cd		= p_unit_set_cd 	AND
  			cousr.sub_us_version_number	= p_us_version_number;
  BEGIN
  	p_message_name := NULL;

  	OPEN c_sca;
  	FETCH c_sca INTO v_ver_no,
  			 v_cal_type;
  	IF (c_sca%NOTFOUND) THEN
  		CLOSE c_sca;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_sca;

  	-- Validate that if the unit set is being specified as a child of another unit
  	-- set, then the parent unit set version must be permitted within the
  	-- IGS_PS_OF_UNT_SET_RL entries
  	IF (p_parent_unit_set_cd IS NOT NULL OR
  			p_parent_sequence_number IS NOT NULL) THEN
  		OPEN c_susa;

  		FETCH c_susa INTO v_susa_us_version_no;
  		IF (c_susa%NOTFOUND) THEN
  			p_message_name := 'IGS_EN_UNIT_SET_NOT_PARENT_EX';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                CLOSE c_susa;
                RETURN FALSE;
            END IF;
  		END IF;
  		CLOSE c_susa;

  		OPEN c_cousr (
  				v_ver_no,
  				v_cal_type,
  				v_susa_us_version_no);
  		FETCH c_cousr INTO v_check;
  		IF (c_cousr%NOTFOUND) THEN
  			p_message_name := 'IGS_EN_UNIT_SET_RELATIONSHIP';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                CLOSE c_cousr;
                RETURN FALSE;
            END IF;
  		END IF;
  		CLOSE c_cousr;

  	ELSE
  		-- (p_parent_unit_set_cd IS NULL OR p_parent_sequence_number IS NULL)
  		-- Validate that if the IGS_EN_UNIT_SET is defined as a subordinate within
  		-- the IGS_PS_OF_UNT_SET_RL table, then the parent details must be

  		-- specified.
  		OPEN c_cousr2(
  				v_ver_no,
  				v_cal_type);
  		FETCH c_cousr2 INTO v_check;
  		IF (c_cousr2%NOTFOUND) THEN
  			CLOSE c_cousr2;
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			IF p_message_type = 'W' THEN
  				-- Return the warning message.
  				p_message_name := 'IGS_EN_UNITSET_HAVE_ONE_PAREN';

                IF (p_legacy = 'Y') THEN
                    -- Add excep to stack
                    FND_MESSAGE.Set_Name('IGS',p_message_name);
                    FND_MSG_PUB.Add;
                END IF;
  			ELSE
  				-- Return the error message.
  				p_message_name := 'IGS_EN_UNIT_SET_PARENT_UNITSE';

                IF (p_legacy = 'Y') THEN
                    -- Add excep to stack
                    FND_MESSAGE.Set_Name('IGS',p_message_name);
                    FND_MSG_PUB.Add;
                END IF;
  			END IF;
  			CLOSE c_cousr2;

  			RETURN FALSE;
  		END IF;
  		CLOSE c_cousr2;
  	END IF;
  	-- If processing successful then

  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sca%ISOPEN) THEN
  			CLOSE c_sca;
  		END IF;
  		IF (c_susa%ISOPEN) THEN
  			CLOSE c_susa;
  		END IF;
  		IF (c_cousr2%ISOPEN) THEN
  			CLOSE c_cousr2;
  		END IF;
  		IF (c_cousr%ISOPEN) THEN
  			CLOSE c_cousr;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_cousr');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_cousr;


  --
  -- Validate the student unit set attempt is able to be deleted.
  FUNCTION ENRP_VAL_SUSA_DEL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_end_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2,
  p_db_trg_call IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- enrp_val_susa_del
  	-- This module validates that the IGS_AS_SU_SETATMPT record being
  	-- deleted meets the following conditions:
  	-- - Cannot be deleted if the unit set has been completed.
  	-- - Cannot be deleted if the unit set has been ended.

  	-- - Cannot be deleted if it is the parent of another unit set.
  	-- - Cannot be deleted if it is part of the terms and conditions
  	--   of the admissions offer for the student.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_susa IS
  		SELECT	'X'
  		FROM	IGS_AS_SU_SETATMPT	susa
  		WHERE	susa.person_id			= p_person_id AND
  			susa.course_cd			= p_course_cd AND
  			susa.parent_unit_set_cd		= p_unit_set_cd AND
  			susa.parent_sequence_number	= p_sequence_number;
  	CURSOR c_acai_sca IS
  		SELECT	acai.unit_set_cd,
  			acai.us_version_number
  		FROM	IGS_AD_PS_APPL_INST	acai,
  			IGS_EN_STDNT_PS_ATT		sca
  		WHERE	sca.person_id			= p_person_id AND
  			sca.course_cd			= p_course_cd AND
  			acai.person_id			= sca.person_id AND
  			acai.admission_appl_number	= sca.adm_admission_appl_number AND
  			acai.nominated_course_cd	= sca.adm_nominated_course_cd AND
  			acai.sequence_number		= sca.adm_sequence_number;

  BEGIN
  	-- Cannot be deleted if the unit set has been completed.
  	IF (p_rqrmnts_complete_ind = 'Y') THEN
  		p_message_name := 'IGS_EN_NOTDEL_UNITSET_COMPL';
  		RETURN FALSE;
  	END IF;
  	-- Cannot be deleted if the unit set has been ended.
  	IF (p_end_dt IS NOT NULL) THEN
  		p_message_name := 'IGS_EN_NOTDEL_UNITSET_ENDED';
  		RETURN FALSE;
  	END IF;
  	-- Check if validation called from the database trigger. If yes, then
  	-- do not execute this query as will cause mutating trigger. The error
  	-- will be trapped by the RI constraints anyway.
  	IF p_db_trg_call = 'N' THEN
  		-- Cannot be deleted if it is the parent of another IGS_EN_UNIT_SET.
  		OPEN c_susa; -- Althogh handled by RI constraints, required for enrp_val_susa.
  		FETCH c_susa INTO v_dummy;
  		IF (c_susa%FOUND) THEN
  			CLOSE c_susa;
  			p_message_name := 'IGS_EN_NOTDEL_UNITSET_PARENT';
  			RETURN FALSE;
  		END IF;

  		CLOSE c_susa;
  	END IF;
  	-- Cannot be deleted if it is part of the terms and conditions
  	-- of the admissions offer for the student.
  	-- Determine if unit set is part of the admissions offer
  	IF igs_as_val_suaap.genp_val_sdtt_sess('ADMP_DEL_SCA_UNCONF') THEN
  		FOR v_acai_sca_rec IN c_acai_sca LOOP
  			IF (v_acai_sca_rec.unit_set_cd = p_unit_set_cd AND
  				v_acai_sca_rec.us_version_number = p_us_version_number) THEN
  				p_message_name := 'IGS_EN_NOTDEL_UNITSET_COND';
  				RETURN FALSE;
  			END IF;
  		END LOOP;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_del');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;


  END enrp_val_susa_del;
  --
  -- Validate the date fields associated with a student unit set attempt.
  FUNCTION ENRP_VAL_SUSA_DTS(
  p_selection_dt IN DATE ,
  p_end_dt IN DATE ,
  p_rqrmnts_complete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
 /* -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur     12-sep-03     Removed the validation of selection date being greater than
  --                               sysdate as perbug 3106879 to allow selection date to be future dated.
 -------------------------------------------------------------------------------------------*/

  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- enrp_val_susa_dts
  	-- This module validates the date fields associated with the
  	-- IGS_AS_SU_SETATMPT:
  	-- . If end_dt and selection_dt set, then end_dt >= selection_dt.
  	-- . end_dt and rqrmnts_complete_dt cannot both be set.
  	-- . Selection_dt, end_dt, rqrmnts_complete_dt cannot be future dated.
  	-- . If rqrmnts_complete_dt and selection_dt set,
  	--   then rqrmnts_complete_dt >= selection_dt.
  DECLARE
  	v_sysdate		DATE;
  BEGIN
  	-- If end_dt and selection_dt set, then end_dt >= selection_dt.

  	IF p_end_dt IS NOT NULL AND
  			p_selection_dt IS NOT NULL THEN
  		IF p_end_dt < p_selection_dt THEN
  			p_message_name := 'IGS_EN_ENDDT_NOTBE_EARLIER_DT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate that end_dt and rqrmnts_complete_dt cannot both be set.
  	IF p_end_dt IS NOT NULL AND
  			p_rqrmnts_complete_dt IS NOT NULL THEN
  		p_message_name := 'IGS_EN_ENDDT_COMPLDT_NOTSET';
  		RETURN FALSE;
  	END IF;
  	--  end_dt, rqrmnts_complete_dt cannot be future dated.
  	v_sysdate := TRUNC(SYSDATE);

  	IF p_end_dt IS NOT NULL THEN
  		IF TRUNC(p_end_dt) > v_sysdate THEN

  			p_message_name := 'IGS_EN_ENDDT_LE_CURR_DT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF p_rqrmnts_complete_dt IS NOT NULL THEN
  		IF TRUNC(p_rqrmnts_complete_dt) > v_sysdate THEN
  			p_message_name := 'IGS_EN_COMPLDT_LE_CURR_DT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- If rqrmnts_complete_dt and selection_dt set,
  	-- then rqrmnts_complete_dt >= selection_dt.
  	IF p_rqrmnts_complete_dt IS NOT NULL AND
  			p_selection_dt IS NOT NULL THEN
  		IF p_rqrmnts_complete_dt < p_selection_dt THEN
  			p_message_name := 'IGS_EN_COMPLDT_GE_CURR_DT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- If processing successful then
  	p_message_name := NULL;
  	RETURN TRUE;
  END;

  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_dts');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_dts;


  --
  -- Validate the student unit set attempt end date.
  FUNCTION ENRP_VAL_SUSA_END_DT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_end_dt IN DATE ,
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_message_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_end_dt
  	-- This module validates that the end date being altered for the
  	-- IGS_AS_SU_SETATMPT meets the following conditions:
  	-- . If the end date is being set and was specified as part of the students
  	--   offer (the admissions offer relating to the course attempt contains the
  	--   unit  set), then the authorise person and authorise on fields must be
  	--   set. (If fields already set, then return a warning message.)
  	-- . Only one record within the student course attempt unit set can have an
  	--   open end date.
  	-- . Cannot be unset if the parent record is ended.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	v_found		BOOLEAN;
  	CURSOR c_susa IS
  		SELECT	'x'
  		FROM	IGS_AS_SU_SETATMPT	susa
  		WHERE	susa.person_id			= p_person_id	 		AND
  			susa.course_cd			= p_course_cd 			AND
  			susa.unit_set_cd		= p_unit_set_cd 			AND
  			susa.end_dt			IS NULL				AND
  			susa.sequence_number		<> NVL(p_sequence_number, 0);

  	CURSOR c_susa_parent IS
  		SELECT	'x'
  		FROM	IGS_AS_SU_SETATMPT	susa
  		WHERE	susa.person_id		= p_person_id			AND
  			susa.course_cd		= p_course_cd			AND
  			susa.unit_set_cd	= p_parent_unit_set_cd		AND
  			susa.sequence_number	= p_parent_sequence_number	AND
  			susa.end_dt		IS NOT NULL;
  	CURSOR c_chk_us IS
  		SELECT	acai.unit_set_cd,
  			acai.us_version_number
  		FROM	IGS_AD_PS_APPL_INST	acai,
  			IGS_EN_STDNT_PS_ATT		sca
  		WHERE	sca.person_id			= p_person_id			AND
  			sca.course_cd			= p_course_cd			AND
  			sca.person_id			= acai.person_id		AND
  			sca.adm_admission_appl_number  = acai.admission_appl_number	AND
  			sca.adm_nominated_course_cd	= acai.nominated_course_cd	AND
  			sca.adm_sequence_number		= acai.sequence_number;
   BEGIN

    v_found := FALSE;

  	-- set default value
  	p_message_name := NULL;
  	IF p_end_dt IS NULL THEN

  		-- Only one record within the student course attempt unit set can have an
  		-- open end date irrespective of version number.
  		OPEN c_susa;
  		FETCH c_susa INTO v_dummy;
  		IF c_susa%FOUND THEN
  			p_message_name := 'IGS_EN_UNIT_SET_EXISTS';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                CLOSE c_susa;
                RETURN FALSE;
            END IF;
  		END IF;
  		CLOSE c_susa;

  		-- If end date cleared, validate parent is not ended.
  		IF p_parent_unit_set_cd IS NOT NULL AND
  				p_parent_sequence_number IS NOT NULL THEN
  			OPEN c_susa_parent;
  			FETCH c_susa_parent INTO v_dummy;
  			IF c_susa_parent%FOUND THEN
  				p_message_name := 'IGS_EN_UNIT_SET_NO_OPEN';

                IF (p_legacy = 'Y') THEN
                    -- Add excep to stack
                    FND_MESSAGE.Set_Name('IGS',p_message_name);
                    FND_MSG_PUB.Add;
                ELSE
                    CLOSE c_susa_parent;
                    RETURN FALSE;
                END IF;
  			END IF;
  			CLOSE c_susa_parent;

  		END IF;
  	ELSE	-- p_end_dt IS NOT NULL

  		-- Validate that if the end date is being set and was specified as part of
  		-- the students offer (the admissions offer relating to the course attempt
  		-- contains the unit  set), then the authorise person and authorise on fields
  		-- must be set. (If fields already set, then return a warning message.)
  		-- Determine if unit set is part of the admissions offer.
  		FOR v_chk_us_rec IN c_chk_us LOOP
  			IF v_chk_us_rec.unit_set_cd = p_unit_set_cd  AND
  					v_chk_us_rec.us_version_number = p_us_version_number THEN
  				v_found := TRUE;
  				EXIT;
  			END IF;
  		END LOOP;
  		IF v_found = TRUE THEN
  			-- If authorise details not set then return an error/warning.
  			-- otherwise if set, then return warning.
  			IF p_authorised_person_id IS NULL AND
  					p_authorised_on IS NULL THEN
  				IF p_message_type = 'W' THEN
  					-- Return warning.
  					p_message_name := 'IGS_EN_UNITSET_REQ_AUTHORISAT';
  					RETURN FALSE;
  				ELSE
  					p_message_name := 'IGS_EN_UNITSET_REQ_ENDED';

  					IF (p_legacy = 'Y') THEN
                        FND_MESSAGE.Set_Name('IGS',p_message_name);
                        FND_MSG_PUB.Add;
                    ELSE
                        RETURN FALSE;
                    END IF;
  				END IF;
  			ELSE
                -- Execute only in non-legacy mode
                IF (p_legacy <> 'Y') THEN
                    -- Return warning.
                    p_message_name := 'IGS_EN_UNITSET_REQ_AUTHORISAT';
                    RETURN FALSE;
                END IF;

  			END IF;
  		END IF;
  	END IF;	-- if p_end_dt is null
  	-- If processing successful then
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
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_end_dt');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_end_dt;


  --
  -- Validate student unit set atmpt voluntary end indicator and end date.
  FUNCTION ENRP_VAL_SUSA_END_VI(
  p_voluntary_end_ind IN VARCHAR2,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_end_vi
  	-- This module validates the voluntary_end_ind against the end_dt for a
  	-- IGS_AS_SU_SETATMPT record. The voluntary end indicator can only
  	-- be set if the end date is set, although it is not mandatory that it is set.
  DECLARE
  BEGIN
  	-- Validate the end date must be set if the voluntary end indicator is set
  	IF (p_voluntary_end_ind = 'Y' AND
  			p_end_dt IS NULL) THEN
  		p_message_name := 'IGS_EN_VOLUNTARY_END_INDICATO';
  		RETURN FALSE;
  	END IF;
  	-- If processing successful then

  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_end_vi');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_susa_end_vi;
  --
  -- Validate the student unit set attempt is able to be created.
  FUNCTION ENRP_VAL_SUSA_INS(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --stutta     06-Mar-2006    Split cursor c_susv to 3 cursors cur_susa, c_uso,c_usoo for
  --                          perf bug #3696127
  BEGIN	-- enrp_val_susa_ins
  	-- This module validates that the IGS_AS_SU_SETATMPT record being

  	-- created meets the following conditions:
  	-- . unit set version must be applicable to the course offering or the student
  	--   must have had it previously selected.
  	-- . Cannot be created against a unit set that has previously been completed
  	--   by the student (irrespective of version).
  DECLARE
  	v_dummy		VARCHAR2(1);
  	v_msg_num	 NUMBER(5);


	CURSOR c_uso IS
	SELECT 'X'
	FROM IGS_PS_OFR_UNIT_SET cous,
	     igs_en_unit_set_stat uss1,
	     IGS_EN_UNIT_SET_ALL US,
	     IGS_EN_STDNT_PS_ATT spa
	WHERE spa.person_id = p_person_id
	AND spa.course_cd = p_course_cd
	AND us.version_number = p_us_version_number
	AND us.unit_set_cd = p_unit_set_cd
	AND spa.course_cd = cous.course_cd
	AND spa.version_number = cous.crv_version_number
	AND spa.CAL_TYPE = cous.CAL_TYPE
	AND us.unit_set_cd = cous.unit_set_cd
	AND us.version_number = cous.us_version_number
	AND us.unit_set_status = uss1.unit_set_status
	AND uss1.s_unit_set_status ='ACTIVE'
	AND NOT EXISTS (SELECT   1
			FROM   IGS_PS_OF_OPT_UNT_ST coous
	WHERE  coous.coo_id= spa.coo_id
	     );


	CURSOR c_usoo IS
	SELECT 'X'
	FROM   IGS_PS_OF_OPT_UNT_ST coous,
	       IGS_EN_UNIT_SET_ALL US,
	       igs_en_unit_set_stat uss1,
	       IGS_EN_STDNT_PS_ATT spa
	WHERE spa.person_id = p_person_id
	AND   spa.course_cd = p_course_cd
	AND coous.coo_id  = spa.coo_id
	AND    us.version_number = p_us_version_number
	AND    us.unit_set_cd = p_unit_set_cd
	AND us.unit_set_cd = coous.unit_set_cd
	AND us.version_number = coous.us_version_number
	AND us.unit_set_status = uss1.unit_set_status
	AND uss1.s_unit_set_status = 'ACTIVE';

  	CURSOR c_susa IS
  		SELECT	'X'
  		FROM	IGS_AS_SU_SETATMPT	susa
  		WHERE	susa.person_id	= p_person_id	 	AND
  			susa.course_cd	= p_course_cd 		AND
  			susa.unit_set_cd = p_unit_set_cd 	AND
  			susa.sequence_number<> NVL(p_sequence_number, 0) AND
  			susa.rqrmnts_complete_ind	= 'Y';

  BEGIN
    p_message_name := NULL;

  	-- Validate that the unit set version must be applicable to the course
  	-- offering option
		v_dummy := NULL;
		OPEN c_usoo;
		FETCH c_usoo INTO v_dummy;
		CLOSE c_usoo;
		IF v_dummy IS NULL THEN -- c_usoo not found
		  --
		  v_dummy := NULL;
		  OPEN c_uso;
		  FETCH c_uso INTO v_dummy;
		  CLOSE c_uso;
		  IF v_dummy IS  NULL THEN -- c_uso is not found
			p_message_name := 'IGS_EN_UNIT_SETNOT_PERMITTED';
			IF (p_legacy = 'Y') THEN
		            -- Add excep to stack
		            FND_MESSAGE.Set_Name('IGS',p_message_name);
			    FND_MSG_PUB.Add;
			ELSE
				RETURN FALSE;
			END IF;
		  END IF;

		END IF;

             -- The student cannot create another attempt at a unit set if a record within
  	-- the student course attempt exists as completed.
        v_dummy := NULL;
  	OPEN c_susa;
  	FETCH c_susa INTO v_dummy;
  	IF c_susa%FOUND THEN
  		p_message_name := 'IGS_EN_STUD_COMPL_UNITSET';

  		IF (p_legacy = 'Y') THEN
			-- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
		ELSE
			CLOSE c_susa;
			RETURN FALSE;
		END IF;

  	END IF;
  	CLOSE c_susa;
  	-- If processing successful then

  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		IF c_uso%ISOPEN THEN
  			CLOSE c_uso;
  		END IF;
		IF c_usoo%ISOPEN THEN
  			CLOSE c_usoo;
  		END IF;
  		IF c_susa%ISOPEN THEN
  			CLOSE c_susa;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_ins');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_susa_ins;


  --
  -- Validate the linking of parent unit set to student unit set attempt .
  FUNCTION ENRP_VAL_SUSA_PARENT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_parent
  	-- This module validates the IGS_EN_UNIT_SET being allocated to the
  	-- IGS_AS_SU_SETATMPT as a parent:
  	-- - Cannot be a parent unit set attempt of itself.
  	-- - Can only be linked to a IGS_AS_SU_SETATMPT record for
  	--   the same person and course where the end date is null.
  	-- - Cannot be linked to itself via the parent student unit set
  	--   attempt relationship.
  	-- - Cannot be linked to a confirmed parent if the unit set is
  	--   unconfirmed.
  DECLARE
  	v_end_dt		IGS_AS_SU_SETATMPT.end_dt%TYPE;
  	v_student_confirmed_ind	IGS_AS_SU_SETATMPT.student_confirmed_ind%TYPE;
  	v_unit_set_cd		IGS_AS_SU_SETATMPT.unit_set_cd%TYPE;

  	CURSOR c_susa IS
  		SELECT	susa.end_dt,
  			susa.student_confirmed_ind
  		FROM	IGS_AS_SU_SETATMPT	susa
  		WHERE	susa.person_id		= p_person_id AND
  			susa.course_cd		= p_course_cd AND
  			susa.unit_set_cd	= p_parent_unit_set_cd AND
  			susa.sequence_number	= p_parent_sequence_number;
    	CURSOR c_susa_ancestor IS
    		SELECT	susa1.unit_set_cd
    		FROM	IGS_AS_SU_SETATMPT	susa1
    		START WITH	susa1.person_id		= p_person_id AND
    				susa1.course_cd		= p_course_cd AND
    				susa1.unit_set_cd		= p_parent_unit_set_cd AND
    				susa1.sequence_number	= p_parent_sequence_number
    		CONNECT BY	PRIOR susa1.person_id			= susa1.person_id AND
    				PRIOR susa1.course_cd			= susa1.course_cd AND
    				PRIOR susa1.parent_unit_set_cd		= susa1.unit_set_cd AND
    				PRIOR susa1.parent_sequence_number	= susa1.sequence_number;
    	CURSOR c_susa_descendant IS
    		SELECT	susa1.unit_set_cd
    		FROM	IGS_AS_SU_SETATMPT	susa1
    		START WITH	susa1.person_id		= p_person_id AND

    				susa1.course_cd		= p_course_cd AND
    				susa1.unit_set_cd	= p_unit_set_cd AND
    				susa1.sequence_number	= NVL(p_sequence_number, 0)
    		CONNECT BY	PRIOR susa1.person_id		= susa1.person_id AND
    				PRIOR susa1.course_cd		= susa1.course_cd AND
    				PRIOR susa1.unit_set_cd		= susa1.parent_unit_set_cd AND
    				PRIOR susa1.sequence_number	= susa1.parent_sequence_number;

  BEGIN
    p_message_name := NULL;

  	-- Check that a parent is being defined
  	IF (p_parent_unit_set_cd IS NULL OR
  			p_parent_sequence_number IS NULL) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;

  	-- Validate the unit set is not being specified as a
  	-- parent of itself irrespective of version.
  	IF (p_unit_set_cd = p_parent_unit_set_cd) THEN
  		p_message_name := 'IGS_EN_UNIT_SET_NOTBE_PARENT';

        IF (p_legacy = 'Y') THEN
            -- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
        ELSE
            RETURN FALSE;
        END IF;
  	END IF;

  	-- Validate can only be linked to a IGS_AS_SU_SETATMPT record for the
  	-- same person and course where the end date is null.
  	OPEN c_susa;
  	FETCH c_susa INTO	v_end_dt, v_student_confirmed_ind;
  	IF (c_susa%NOTFOUND) THEN
  		CLOSE c_susa;
  		p_message_name := 'IGS_EN_UNIT_SET_NOT_PARENT_EX';

        IF (p_legacy = 'Y') THEN
            -- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
        ELSE
            RETURN FALSE;
        END IF;
  	ELSE
  		CLOSE c_susa;
  		-- Check if the end date is set
  		IF (v_end_dt IS NOT NULL) THEN
  			p_message_name := 'IGS_EN_UNIT_SET_NOT_ENDDT';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                RETURN FALSE;
            END IF;
  		END IF;

  		-- Validate that if the unit set is confirmed,
  		-- then the parent must also be confirmed.
  		IF (v_student_confirmed_ind = 'N' AND			-- parent student confirmed ind
  				p_student_confirmed_ind = 'Y') THEN	-- child student confirmed ind
  			p_message_name := 'IGS_EN_UNIT_SET_PARENTSET_CON';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                RETURN FALSE;
            END IF;
  		END IF;
  	END IF;
    	-- Validate that the unit set cannot be linked to itself via the
    	-- parent relationship.

    	-- Check that the unit set does not already exist as an ancestor.
    	OPEN c_susa_ancestor;
    	FETCH c_susa_ancestor INTO v_unit_set_cd;
        LOOP
            IF (c_susa_ancestor%NOTFOUND) THEN
                EXIT;
            END IF;
            IF v_unit_set_cd = p_unit_set_cd THEN
                p_message_name := 'IGS_EN_INVALID_RELATIONSHIP';

                IF (p_legacy = 'Y') THEN
                    -- Add excep to stack
                    FND_MESSAGE.Set_Name('IGS',p_message_name);
                    FND_MSG_PUB.Add;
                    EXIT;
                ELSE
                    CLOSE c_susa_ancestor;
                    RETURN FALSE;
                END IF;
            END IF;
            FETCH c_susa_ancestor INTO v_unit_set_cd;
        END LOOP;
    	CLOSE c_susa_ancestor;

    	-- Check that the unit set does not already exist as a descendant
    	OPEN c_susa_descendant;
    	FETCH c_susa_descendant INTO v_unit_set_cd;
        LOOP
            IF (c_susa_descendant%NOTFOUND) THEN
                EXIT;
            END IF;
            IF v_unit_set_cd = p_parent_unit_set_cd THEN
                p_message_name := 'IGS_EN_INVALID_RELATIONSHIP';

                IF (p_legacy = 'Y') THEN
                    -- Add excep to stack
                    FND_MESSAGE.Set_Name('IGS',p_message_name);
                    FND_MSG_PUB.Add;
                    EXIT;
                ELSE
                    CLOSE c_susa_descendant;
                    RETURN FALSE;
                END IF;
            END IF;
            FETCH c_susa_descendant INTO v_unit_set_cd;
        END LOOP;
    	CLOSE c_susa_descendant;

  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_susa%ISOPEN) THEN
  			CLOSE c_susa;
  		END IF;
  		IF (c_susa_ancestor%ISOPEN) THEN
  			CLOSE c_susa_ancestor;
  		END IF;
  		IF (c_susa_descendant%ISOPEN) THEN
  			CLOSE c_susa_descendant;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_parent');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_parent;

  --
  -- Validate the IGS_AS_SU_SETATMPT.primary_set_ind field.
  FUNCTION ENRP_VAL_SUSA_PRMRY(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_primary_set_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_prmry
  	-- This module validates the IGS_AS_SU_SETATMPT.primary_set_ind cannot
  	-- be set if there exists a unit set of a higher rank within the students
  	-- unit set. Also, check that the primary indicator is only set for
  	-- non-administrative files.
  DECLARE

  	v_rank				IGS_EN_UNIT_SET_CAT.rank%TYPE;
  	v_administrative_ind		IGS_EN_UNIT_SET.administrative_ind%TYPE;
  	v_dummy				VARCHAR2(1);

  	CURSOR	c_us_usc IS
  		SELECT	us.administrative_ind,
  			usc.rank
  		FROM	IGS_EN_UNIT_SET	us,
  			IGS_EN_UNIT_SET_CAT	usc
  		WHERE	us.unit_set_cd		= p_unit_set_cd AND
  			us.version_number	= p_us_version_number AND
  			us.unit_set_cat		= usc.unit_set_cat;
  	CURSOR	c_susa_us_usc (
  		cp_rank		IGS_EN_UNIT_SET_CAT.rank%TYPE) IS
  		SELECT 	'x'
  		FROM	IGS_AS_SU_SETATMPT	susa,
  			IGS_EN_UNIT_SET			us,
  			IGS_EN_UNIT_SET_CAT			usc
  		WHERE	susa.person_id 		= p_person_id AND
  			susa.course_cd		= p_course_cd AND
  			susa.unit_set_cd	= us.unit_set_cd AND
  			susa.us_version_number	= us.version_number AND
  			us.administrative_ind	= 'N' AND
  			us.unit_set_cat		= usc.unit_set_cat AND
  			usc.rank		< cp_rank;
  BEGIN
    p_message_name := NULL;

  	-- If primary set indicator not set, return successful
  	-- as no validation required.
  	IF NVL(p_primary_set_ind, 'N') = 'N' THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;

  	-- Check if the unit set is administrative.
  	OPEN c_us_usc;
  	FETCH c_us_usc INTO	v_administrative_ind,
  				v_rank;
  	IF (c_us_usc%NOTFOUND) THEN
  		CLOSE c_us_usc;
  		RAISE NO_DATA_FOUND;
  	ELSE
  		IF (v_administrative_ind = 'Y') THEN
  			p_message_name := 'IGS_EN_PRIMARY_INDICATOR_NOT';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                CLOSE c_us_usc;
                RETURN FALSE;
            END IF;
  		END IF;
  	END IF;
  	CLOSE c_us_usc;

  	-- The below validation need not
    -- be checked when running in legacy mode
    IF (p_legacy <> 'Y') THEN
        -- Check if  there exists a non-administrative unit which has a higher rank.
        OPEN c_susa_us_usc(v_rank);
        FETCH c_susa_us_usc INTO v_dummy;
        IF (c_susa_us_usc%FOUND) THEN
            CLOSE c_susa_us_usc;
            p_message_name := 'IGS_EN_PRIMARY_IND_NOT_SET';
            RETURN FALSE;
        END IF;
        -- If processing successful then
        CLOSE c_susa_us_usc;
  	END IF;

  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_prmry');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_prmry;


  --
  -- Validate the student unit set attempt against for the stdnt crs atmpt.
  FUNCTION ENRP_VAL_SUSA_SCA(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_sca
  	-- This module validates the IGS_AS_SU_SETATMPT is created against
  	-- a valid IGS_EN_STDNT_PS_ATT status.
  DECLARE
  	cst_discontin	CONSTANT	VARCHAR2(10) := 'DISCONTIN';
  	cst_lapsed	CONSTANT	VARCHAR2(10) := 'LAPSED';
  	cst_deleted	CONSTANT	VARCHAR2(10) := 'DELETED';
  	v_dummy		VARCHAR2(1);
  	CURSOR c_sca IS
  		SELECT	'x'
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id			= p_person_id	 		AND
  			sca.course_cd			= p_course_cd 			AND
  			sca.course_attempt_status	IN (	cst_discontin,
  								cst_lapsed,
  								cst_deleted);
   BEGIN

  	-- set default value
  	p_message_name := NULL;
  	OPEN c_sca;
  	FETCH c_sca INTO v_dummy;
  	IF c_sca%FOUND THEN
  		CLOSE c_sca;
  		p_message_name := 'IGS_EN_SUA_NOT_CREATED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sca;
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
  				Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
				FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_sca');
				IGS_GE_MSG_STACK.ADD;

			App_Exception.Raise_Exception;
  END enrp_val_susa_sca;


  --
  -- Validate the student unit set attempt confirmation indicator.
  FUNCTION ENRP_VAL_SUSA_SCI(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2,
  p_selection_dt IN DATE ,
  p_end_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_sci
  	-- This module validates the confirmation of a IGS_EN_UNIT_SET for a
  	-- IGS_AS_SU_SETATMPT record. The validations are:
  	-- - The student confirmed indicator cannot be unset once the

  	--   end date has been set.
  	-- - The student confirmed indicator cannot be unset once the
  	--   requirements complete indicator has been set.
  	-- - The student confirmed indicator can only be set if the
  	--   student course attempt status is 'ENROLLED' or 'INACTIVE'.
  	-- - The student confirmed indicator cannot be set when a parent
  	--   unit set exists that is unconfirmed.
  	-- - The student confirmed indicator cannot be set if the student
  	--   is excluded from the unit set via encumbrances.
  DECLARE
  	cst_enrolled	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'ENROLLED';
  	cst_inactive	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INACTIVE';
  	v_dummy		VARCHAR2(1);
  	v_sca_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_message_name	 VARCHAR2(30);
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd AND
  			sca.course_attempt_status IN (

  						cst_enrolled,
  						cst_inactive);
  	CURSOR c_susa IS
  		SELECT	'X'
  		FROM	IGS_AS_SU_SETATMPT	susa
  		WHERE	susa.person_id			= p_person_id AND
  			susa.course_cd			= p_course_cd AND
  			susa.unit_set_cd		= p_parent_unit_set_cd AND
  			susa.sequence_number		= p_parent_sequence_number AND
  			susa.student_confirmed_ind	= 'N';


    CURSOR c_sca_legacy IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd AND
  			sca.course_attempt_status = 'UNCONFIRM';

  BEGIN
    p_message_name := NULL;

  	IF (p_student_confirmed_ind = 'Y') THEN
  		-- Validate the confirmed indicator can only be set when the
  		-- student course attempt is enrolled or inactive

        IF (p_legacy = 'Y') THEN
			OPEN c_sca_legacy;
  			FETCH c_sca_legacy INTO v_sca_version_number;
  			IF (c_sca_legacy%FOUND) THEN
  				p_message_name := 'IGS_EN_CANT_SET_CONF_IND';
  				FND_MESSAGE.Set_Name('IGS',p_message_name);
	            FND_MSG_PUB.Add;
			END IF;
			CLOSE c_sca_legacy;
		ELSE
            OPEN c_sca;
            FETCH c_sca INTO v_sca_version_number;
            IF (c_sca%NOTFOUND) THEN
                CLOSE c_sca;
                p_message_name := 'IGS_EN_UNIT_SET_SPA_ENR_INACT';
                RETURN FALSE;
            END IF;
            CLOSE c_sca;
        END IF;

  		-- Validate the confirmed indicator cannot be set when a parent

  		-- unit set exists that is unconfirmed.
  		IF (p_parent_unit_set_cd IS NOT NULL AND
  				p_parent_sequence_number IS NOT NULL) THEN
  			OPEN c_susa;
  			FETCH c_susa INTO v_dummy;
  			IF (c_susa%FOUND) THEN
  				p_message_name := 'IGS_EN_UNIT_SET_PARENTSET_CON';

                IF (p_legacy = 'Y') THEN
                    -- Add excep to stack
                    FND_MESSAGE.Set_Name('IGS',p_message_name);
                    FND_MSG_PUB.Add;
                ELSE
                    CLOSE c_susa;
                    RETURN FALSE;
                END IF;
  			END IF;
  			CLOSE c_susa;

  			-- Check that the relationship is still valid within the course offering
  			IF (Igs_En_Val_Susa.enrp_val_susa_cousr(
  							p_person_id,
  							p_course_cd,
  							p_unit_set_cd,
  							p_us_version_number,
  							p_parent_unit_set_cd,
  							p_parent_sequence_number,
  							'E',
  							v_message_name,
                            p_legacy) = FALSE) THEN
  				p_message_name := v_message_name;

                IF (p_legacy <> 'Y') THEN
                    RETURN FALSE;
                END IF;
  			END IF;
  		END IF;

        -- The below validations need not be
        -- done when operating in legacy mode
        IF (p_legacy <> 'Y') THEN

            -- Check that the unit set is still active
            IF (Igs_En_Val_Susa.enrp_val_susa_us_act(
                            p_person_id,
                            p_course_cd,
                            p_unit_set_cd,
                            p_sequence_number,
                            p_us_version_number,
                            v_message_name) = FALSE) THEN
                p_message_name := v_message_name;
                RETURN FALSE;
            END IF;
            -- Validate the confirmed indicator cannot be set if the student is
            -- excluded from the unit set via encumbrances
            IF (IGS_EN_VAL_ENCMB.enrp_val_excld_us(
                            p_person_id,
                            p_course_cd,
                            p_unit_set_cd,
                            p_us_version_number,
                            SYSDATE,
                            v_message_name) = FALSE) THEN
                p_message_name := v_message_name;

                RETURN FALSE;
            END IF;
        END IF;
  		-- unit set rules for enrolment are validated in separate module
  		-- (enrp_val_susa_sci_rl) because rules system contains savepoints and
  		-- rollbacks whick limit the routine from being called from database triggers.
  	ELSE
  		-- Validate the confirmed indicator being unset
  		-- Cannot be unset if the end date has been set
  		IF (p_end_dt IS NOT NULL) THEN
  			p_message_name := 'IGS_EN_UNIT_SET_UNCONF_ENDDT';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                RETURN FALSE;
            END IF;
  		END IF;

  		-- Cannot be unset if the requirements complete indicator has been set
  		IF (p_rqrmnts_complete_ind = 'Y') THEN
  			p_message_name := 'IGS_EN_UNIT_SET_UNCONF_REQ';

            IF (p_legacy = 'Y') THEN
                -- Add excep to stack
                FND_MESSAGE.Set_Name('IGS',p_message_name);
                FND_MSG_PUB.Add;
            ELSE
                RETURN FALSE;
            END IF;
  		END IF;
  	END IF;

  	RETURN TRUE;

  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sca%ISOPEN) THEN

  			CLOSE c_sca;
  		END IF;
  		IF (c_susa%ISOPEN) THEN
  			CLOSE c_susa;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_sci');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_sci;
  --
  -- Validate the student unit set attempt confirmation rules.
  FUNCTION ENRP_VAL_SUSA_SCI_RL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_new_student_confirmed_ind IN VARCHAR2,
  p_old_student_confirmed_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_message_text OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
   BEGIN	-- enrp_val_susa_sci_rl
  	-- - The student confirmed indicator cannot be set if
  	--  rules exist preventing this.
  DECLARE
  	cst_enrolled	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'ENROLLED';
  	cst_inactive	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INACTIVE';
  	v_sca_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_message_name	 VARCHAR2(30);
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd AND
  			sca.course_attempt_status IN (
  						cst_enrolled,
  						cst_inactive);
  BEGIN
  	p_message_text := NULL;

  	IF (p_new_student_confirmed_ind = 'Y') AND
  	    (NVL(p_old_student_confirmed_ind, 'N') = 'N') THEN
  		-- Validate the confirmed indicator can only be set when the
  		-- student course attempt is enrolled or inactive
  		OPEN c_sca;
  		FETCH c_sca INTO v_sca_version_number;
  		IF (c_sca%NOTFOUND) THEN
  			CLOSE c_sca;
  			p_message_name := 'IGS_EN_UNIT_SET_SPA_ENR_INACT';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_sca;
  		-- Validate unit set rules for enrolment
  		IF (IGS_RU_VAL_USET_RULE.rulp_val_enrol_uset(
  						p_person_id,
  						p_course_cd,
  						v_sca_version_number,
  						p_unit_set_cd,
  						p_us_version_number,
  						p_message_text) = FALSE) THEN
  			p_message_name := NULL;
  			RETURN FALSE;
  		END IF;

  	END IF;
  	p_message_name := NULL;
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
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_sci_rl');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_sci_rl;


  --
  -- Validate student unit set atmpt confirm indicator and selection date.
  FUNCTION ENRP_VAL_SUSA_SCI_SD(
  p_student_confirmed_ind IN VARCHAR2,
  p_selection_dt IN DATE,
  p_message_name OUT NOCOPY VARCHAR2,
  p_legacy IN VARCHAR2)
  RETURN BOOLEAN AS
   BEGIN	-- enrp_val_susa_sci_sd
  	-- This module validates the student_confirmed_ind against the selection_dt
  	-- for a IGS_AS_SU_SETATMPT record. The validations are:
  	-- - The selection date must be set if the confirmed indicator is set
  	--   (and visa versa).
  	-- - The selection date being unset, then the confirmed indicator must be
  	--   unset (and visa versa).
  DECLARE
  BEGIN
    p_message_name := NULL;

  	-- Validate the selection date must be set if the confirmed
  	-- indicator is set and visa versa.
  	IF (p_student_confirmed_ind = 'Y' AND
  			p_selection_dt IS NULL) THEN
  		p_message_name := 'IGS_EN_UNIT_SET_UNCONF_SETDT';

        IF (p_legacy = 'Y') THEN
            -- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
        ELSE
            RETURN FALSE;
        END IF;
  	END IF;

  	-- Validate the selection date must be unset if the
  	-- confirmed indicator is set and visa versa.
  	IF (p_student_confirmed_ind = 'N' AND
  			p_selection_dt IS NOT NULL) THEN
  		p_message_name := 'IGS_EN_UNIT_SET_UNCONF_NOTSET';

  		IF (p_legacy = 'Y') THEN
            -- Add excep to stack
            FND_MESSAGE.Set_Name('IGS',p_message_name);
            FND_MSG_PUB.Add;
        ELSE
            RETURN FALSE;
        END IF;
  	END IF;

  	RETURN TRUE;

  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_sci_sd');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa_sci_sd;


  --
  -- Validate the unit set is active for student unit set attempt.
  FUNCTION ENRP_VAL_SUSA_US_ACT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS


  BEGIN	-- enrp_val_susa_us_act
  	-- This module validates that the IGS_EN_UNIT_SET being allocated to the
  	-- IGS_AS_SU_SETATMPT is active with a null expiry date or active with
  	-- expiry date set and the student has previously selected in within the same
  	-- course attempt.
  DECLARE
  	cst_active	CONSTANT	VARCHAR2(6) := 'ACTIVE';
  	v_s_unit_set_status	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	v_expiry_dt		IGS_EN_UNIT_SET.expiry_dt%TYPE;
  	v_dummy			VARCHAR2(1);
  	CURSOR	c_us_uss IS
  		SELECT	uss.s_unit_set_status,
  			us.expiry_dt
  		FROM	IGS_EN_UNIT_SET us,
  			IGS_EN_UNIT_SET_STAT uss
  		WHERE	us.unit_set_status 	= uss.unit_set_status AND
  			us.unit_set_cd 		= p_unit_set_cd AND
  			us.version_number 	= p_version_number;
  	CURSOR	c_susa IS
  		SELECT	'x'
  		FROM	IGS_AS_SU_SETATMPT susa
  		WHERE	susa.person_id 		= p_person_id AND

  			susa.course_cd 		= p_course_cd AND
  			susa.unit_set_cd 	= p_unit_set_cd AND
  			susa.us_version_number 	= p_version_number AND
  			susa.sequence_number	<> NVL(p_sequence_number, 0);
  BEGIN
  	-- Validate that the unit set status is active and null expiry date.
  	OPEN c_us_uss;
  	FETCH 	c_us_uss	INTO 	v_s_unit_set_status,
  					v_expiry_dt;
  	IF v_s_unit_set_status <> cst_active THEN
  		CLOSE c_us_uss;
  		p_message_name := 'IGS_EN_UNIT_SETST_ACTIVE';
  		RETURN FALSE;
  	ELSE
  		IF v_expiry_dt IS NOT NULL THEN
  			-- Determine if the student has previously had the version selected
  			-- within the specified course
  			-- NOTE: sequence number comparison is used as this validation is called
  			-- from an after statement databae trigger in which case, want to ignore the
  			-- newly created record.
  			OPEN c_susa;
  			FETCH 	c_susa 	INTO 	v_dummy;
  			IF (c_susa%NOTFOUND) THEN

  				CLOSE c_susa;
  				p_message_name := 'IGS_EN_UNIT_SET_EXPDT_NOTSET';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_susa;
  		END IF;
  	END IF;
  	-- If processing successful then
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_us_act');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_susa_us_act;
  --
  -- Validate the student unit set attempt requires authorisation.
  FUNCTION ENRP_VAL_SUSA_US_ATH(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_us_ath
  	-- This module validates that the IGS_EN_UNIT_SET being allocated to the
  	-- IGS_AS_SU_SETATMPT requires authorisation.
  DECLARE
  	v_auth_rqrd_ind		IGS_EN_UNIT_SET.authorisation_rqrd_ind%TYPE;
  	CURSOR c_us IS
  		SELECT	us.authorisation_rqrd_ind
  		FROM	IGS_EN_UNIT_SET us
  		WHERE	unit_set_cd 	= p_unit_set_cd AND
  			version_number 	= p_version_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate that the is active and null expiry dt.
  	OPEN c_us;
  	FETCH c_us INTO	v_auth_rqrd_ind;
  	-- Validate that if the authorised indicator is set, then the
  	-- authorised_person_id and authorised_on fields must be set.

  	IF c_us%FOUND THEN
  		IF (v_auth_rqrd_ind = 'Y') AND
  				(p_authorised_person_id IS NULL OR
   				 p_authorised_on IS NULL) THEN
  			CLOSE c_us;
  			p_message_name := 'IGS_EN_UNIT_SET_REQ_AUTHORISA';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_us;
  	-- If processing successful then
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_us%NOTFOUND) THEN
  			CLOSE c_us;
  		END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_SUSA.enrp_val_susa_us_ath');
			IGS_GE_MSG_STACK.ADD;

			App_Exception.Raise_Exception;
  END enrp_val_susa_us_ath;
  --
  -- Validation routines for student unit set attempt.
  FUNCTION ENRP_VAL_SUSA(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_us_version_number IN NUMBER ,
  p_selection_dt IN DATE ,
  p_student_confirmed_ind IN VARCHAR2,
  p_end_dt IN DATE ,
  p_parent_unit_set_cd IN VARCHAR2 ,
  p_parent_sequence_number IN NUMBER ,
  p_primary_set_ind IN VARCHAR2,
  p_voluntary_end_ind IN VARCHAR2,
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_override_title IN VARCHAR2 ,
  p_rqrmnts_complete_ind IN VARCHAR2,
  p_rqrmnts_complete_dt IN DATE ,
  p_s_completed_source_type IN VARCHAR2 ,
  p_action IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_message_text OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa
  	-- This module validates
  DECLARE
  	v_message_name		VARCHAR2(30);
  	v_old_student_confirmed_ind
  				IGS_AS_SU_SETATMPT.student_confirmed_ind%TYPE;
  	CURSOR c_old_susa IS
  		SELECT	*
  		FROM	IGS_AS_SU_SETATMPT	susa
  		WHERE	susa.person_id		= p_person_id		AND
  			susa.course_cd		= p_course_cd		AND
  			susa.unit_set_cd		= p_unit_set_cd		AND
  			susa.sequence_number	= p_sequence_number;
  	v_old_susa_rec	c_old_susa%ROWTYPE;
  	cst_insert	CONSTANT VARCHAR2 (6) := 'INSERT';
  	cst_update	CONSTANT VARCHAR2 (6) := 'UPDATE';
  	cst_delete	CONSTANT VARCHAR2 (6) := 'DELETE';
  	cst_error		CONSTANT VARCHAR2(1) := 'E';

  	v_inserting	BOOLEAN := FALSE;
  	v_updating	BOOLEAN := FALSE;
  	v_deleting	BOOLEAN := FALSE;
  BEGIN
  	IF p_action = cst_insert THEN
  		v_inserting := TRUE;
  	ELSIF p_action = cst_update THEN
  		v_updating := TRUE;
  	ELSIF p_action = cst_delete THEN
  		v_deleting := TRUE;
  	ELSE
  		-- Invalid value for p_action.
  		p_message_name := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	END IF;
  	-- If updating, select the values of the record prior to update.
  	IF v_updating THEN
  		OPEN c_old_susa;
  		FETCH c_old_susa INTO v_old_susa_rec;
  		IF c_old_susa%NOTFOUND THEN
  			CLOSE c_old_susa;
 			Fnd_Message.Set_Name('IGS','IGS_EN_SU_SETATT_NOT_EXIST');
			IGS_GE_MSG_STACK.ADD;

			App_Exception.Raise_Exception;

  		END IF;
  		CLOSE c_old_susa;
  	END IF;
  	IF v_inserting THEN
  		-- Validate the the unit set is able to be created.
  		-- against the student course attempt.
  		IF Igs_En_Val_Susa.enrp_val_susa_sca(
  					p_person_id,
  					p_course_cd,
  					v_message_name) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate the the unit set is able to be created.
  		-- The student cannot have completed it previously,
  		-- no encumbrances must exist and it must be applicable
  		-- to the course offering.
  		IF Igs_En_Val_Susa.enrp_val_susa_ins(
  					p_person_id,
  					p_course_cd,
  					p_unit_set_cd,
  					p_sequence_number,
  					p_us_version_number,
  					v_message_name,
                    'N') = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate that the authorisation fields can only be set when end date is set
  	-- or the unit set cd requires authorisation (IGS_EN_UNIT_SET.authorisation_ind = 'Y')
  	IF v_inserting OR
  	  (v_updating AND
  	   ((NVL(p_authorised_person_id, 0) <>
  			NVL(v_old_susa_rec.authorised_person_id, 0)) OR
  	    (NVL(p_authorised_on,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		 <> NVL(v_old_susa_rec.authorised_on,
  				IGS_GE_DATE.IGSDATE('1900/01/01'))))) THEN
  		IF Igs_En_Val_Susa.enrp_val_susa_auth(
  				p_unit_set_cd,
  				p_us_version_number,
  				p_end_dt,
  				p_authorised_person_id,
  				p_authorised_on,
  				v_message_name,
                'N') = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF v_inserting OR
  	  (v_updating AND
  	   ((NVL(p_authorised_person_id, 0) <>
  			NVL(v_old_susa_rec.authorised_person_id, 0)) OR
  	    (p_student_confirmed_ind <> v_old_susa_rec.student_confirmed_ind) OR
  	    (NVL(p_authorised_on,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		 <> NVL(v_old_susa_rec.authorised_on,
  				IGS_GE_DATE.IGSDATE('1900/01/01'))))) THEN
  		-- Validate that the authorisation fields must be set when
  		-- the unit set cd requires authorisation (IGS_EN_UNIT_SET.authorisation_ind = 'Y')
  		-- Check required only when the unit set is confirmed.
  		IF (p_student_confirmed_ind = 'Y') THEN
  			IF Igs_En_Val_Susa.enrp_val_susa_us_ath(
  					p_unit_set_cd,
  					p_us_version_number,
  					p_authorised_person_id,

  					p_authorised_on,
  					v_message_name) = FALSE THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate that the completion fields can only be set when unit set is
  	-- confirmed
  	IF v_inserting OR
  	  (v_updating AND
  	   ((NVL(p_rqrmnts_complete_ind, 'x')
  		<> NVL(v_old_susa_rec.rqrmnts_complete_ind, 'x')) OR
  	    (NVL(p_rqrmnts_complete_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		 <> NVL(v_old_susa_rec.rqrmnts_complete_dt,
  			IGS_GE_DATE.IGSDATE('1900/01/01')))))THEN
  		IF Igs_En_Val_Susa.enrp_val_susa_cmplt(
  				p_rqrmnts_complete_dt,
  				p_rqrmnts_complete_ind,
  				p_student_confirmed_ind,
  				v_message_name,
                'N') = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;

  		END IF;
  	END IF;
  	-- Validate that the system competed source type field can only be
  	-- set when completion fields are set.
  	IF v_inserting OR
  	  (v_updating AND
  	   ((NVL(p_rqrmnts_complete_ind, 'x')
  		<> NVL(v_old_susa_rec.rqrmnts_complete_ind, 'x')) OR
  	    (NVL(p_s_completed_source_type, 'x')
  		<> NVL(v_old_susa_rec.s_completed_source_type, 'x')) OR
  	    (NVL(p_rqrmnts_complete_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		 <> NVL(v_old_susa_rec.rqrmnts_complete_dt,
  			IGS_GE_DATE.IGSDATE('1900/01/01')))))THEN
  		IF Igs_En_Val_Susa.enrp_val_susa_scst(
  				p_rqrmnts_complete_dt,
  				p_rqrmnts_complete_ind,
  				p_s_completed_source_type,
  				v_message_name) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate the date fields.

  	IF v_inserting OR
  	  (v_updating AND
  	    ((NVL(p_selection_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		 <> NVL(v_old_susa_rec.selection_dt,
  				IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
  	    (NVL(p_end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		 <> NVL(v_old_susa_rec.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
  	    (NVL(p_rqrmnts_complete_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		 <> NVL(v_old_susa_rec.rqrmnts_complete_dt,
  			IGS_GE_DATE.IGSDATE('1900/01/01'))))) THEN
  		IF Igs_En_Val_Susa.enrp_val_susa_dts(
  				p_selection_dt,
  				p_end_dt,
  				p_rqrmnts_complete_dt,
  				v_message_name) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate that the selection date can only be set/unset when unit set is
  	-- confirmed/unconfirmed
  	IF v_inserting OR
  	  (v_updating AND

  	   ((p_student_confirmed_ind <> v_old_susa_rec.student_confirmed_ind) OR
  	    (NVL(p_selection_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		 <> NVL(v_old_susa_rec.selection_dt,
  				IGS_GE_DATE.IGSDATE('1900/01/01'))))) THEN
  		IF Igs_En_Val_Susa.enrp_val_susa_sci_sd(
  				p_student_confirmed_ind,
  				p_selection_dt,
  				v_message_name,
                'N') = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate that the voluntary_end_ind can only be set when the end date is
  	-- set.
  	IF v_inserting OR
  	  (v_updating AND
  	   ((p_voluntary_end_ind <> v_old_susa_rec.voluntary_end_ind) OR
  	    (NVL(p_end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
  		 <> NVL(v_old_susa_rec.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))))) THEN
  		IF Igs_En_Val_Susa.enrp_val_susa_end_vi(
  				p_voluntary_end_ind,
  				p_end_dt,
  				v_message_name) = FALSE THEN

  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate that the unit set version number cannot be updated.
  	IF (v_updating AND
  	   (p_us_version_number <> v_old_susa_rec.us_version_number)) THEN
  		p_message_name := 'IGS_EN_UNIT_SET_VERNUM_NOTUPD';
  		RETURN FALSE;
  	END IF;
  	IF v_deleting THEN
  		-- Validate that the records can be deleted.
  		IF Igs_En_Val_Susa.enrp_val_susa_del(
  					p_person_id,
  					p_course_cd,
  					p_unit_set_cd,
  					p_sequence_number,
  					p_us_version_number,
  					p_end_dt,
  					p_rqrmnts_complete_ind,
  					'N', -- Indicating not called from trigger.
  					v_message_name) = FALSE THEN

  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
    	IF v_inserting THEN
  		-- Validate the the unit set is able to be created
  		-- with the unit set status being valid and the
  		-- expiry date not set. If set then person must have
  		-- previously selected it.
  		IF Igs_En_Val_Susa.enrp_val_susa_us_act(
  				p_person_id,
  				p_course_cd,
  				p_unit_set_cd,
  				p_sequence_number,
  				p_us_version_number,
  				v_message_name) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
    	END IF;
    	-- Validate the unit set parent relationship.
    	IF v_inserting OR

    	  (v_updating AND
    	   ((NVL(p_parent_unit_set_cd, 'NULL')
    		<> NVL(v_old_susa_rec.parent_unit_set_cd, 'NULL')) OR
    	   (NVL(p_parent_sequence_number, 0)
    		<> NVL(v_old_susa_rec.parent_sequence_number, 0)))) THEN
  		-- Validate if the unit set is to be defined as a subordinate or if
  		-- relationship specified, that it is valid within the course offering.
  		IF Igs_En_Val_Susa.enrp_val_susa_cousr(
  				p_person_id,
  				p_course_cd,
  				p_unit_set_cd,
  				p_us_version_number,
  				p_parent_unit_set_cd,
  				p_parent_sequence_number,
  				cst_error,
  				v_message_name,
                'N') = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate if the parent unit set has a null end date, unit set is
  		-- not being linked to itself (directly or indirectly). Cannot be
  		-- confirmed if parent is unconfirmed.

  		IF Igs_En_Val_Susa.enrp_val_susa_parent(
  				p_person_id,
  				p_course_cd,
  				p_unit_set_cd,
  				p_sequence_number,
  				p_parent_unit_set_cd,
  				p_parent_sequence_number,
  				p_student_confirmed_ind,
  				v_message_name,
                'N') = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
    	END IF;
    	IF v_inserting OR
    	    (NVL(p_end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
    		 <> NVL(v_old_susa_rec.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
  		-- Validate the end date, check if the authorisation details
  		-- need to be set or if more than one open end dated instance
  		-- of the unit set exists. Also cannot be cleared if parent ended.
  		-- If part of the admissions offer, authorisation required to end
  		-- the unit set.
  		IF Igs_En_Val_Susa.enrp_val_susa_end_dt(
  				p_person_id,
  				p_course_cd,
  				p_unit_set_cd,
  				p_sequence_number,
  				p_us_version_number,
  				p_end_dt,
  				p_authorised_person_id,
  				p_authorised_on,
  				p_parent_unit_set_cd,
  				p_parent_sequence_number,
  				cst_error,
  				v_message_name,
                'N') = FALSE THEN
  			-- Check if warning message returned.
  			IF v_message_name <> 'IGS_EN_UNITSET_REQ_AUTHORISAT' THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-- If updating and the end date has been set, validate that it is
  		-- possible to cascade the end date through to any descendant unit sets
  		-- (Inserted records cannot have children at that point).
  		IF v_updating AND

  		    p_end_dt IS NOT NULL THEN

  			IF Igs_En_Val_Susa.enrp_val_susa_ed_upd(
  					p_person_id,
  					p_course_cd,
  					p_unit_set_cd,
  					p_sequence_number,
  					p_end_dt,
  					p_voluntary_end_ind,
  					p_authorised_person_id,
  					p_authorised_on,
  					v_message_name) = FALSE THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
    	END IF;
    	IF (v_inserting AND p_student_confirmed_ind = 'Y') OR
    	  (v_updating AND
    	   (p_student_confirmed_ind  <> v_old_susa_rec.student_confirmed_ind)) THEN
  		-- Validate that the unit set is not confirmed when the student course
  		-- attempt is unconfirmed.
  		-- Also check that not unset one end date or complete date set. Cannot be

  		-- confirmed and linked to a parent that is unconfirmed. Cannot be
  		-- confirmed if encumbrances exist.
  		IF Igs_En_Val_Susa.enrp_val_susa_sci(
  				p_person_id,
  				p_course_cd,
  				p_unit_set_cd,
  				p_sequence_number,
  				p_us_version_number,
  				p_parent_unit_set_cd,
  				p_parent_sequence_number,
  				p_student_confirmed_ind,
  				p_selection_dt,
  				p_end_dt,
  				p_rqrmnts_complete_ind,
  				v_message_name,
                'N') = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate that if student confirmation indicator set, check if passes
  		-- any associated rules.
  		IF v_inserting THEN
  			v_old_student_confirmed_ind := NULL;

  		ELSE
  			v_old_student_confirmed_ind :=  v_old_susa_rec.student_confirmed_ind;
  		END IF;
  		IF Igs_En_Val_Susa.enrp_val_susa_sci_rl(
  				p_person_id,
  				p_course_cd,
  				p_unit_set_cd,
  				p_us_version_number,
  				p_student_confirmed_ind,
  				v_old_student_confirmed_ind,
  				v_message_name,
  				p_message_text) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- If updating and the student confirmed indicator is being unset,
  		-- then validate that able to  unset any descendant unit sets. (Only concerned
  		-- with update as unit set cannot have descendant at the point of
  		-- creation).
  		IF v_updating AND
  		    p_student_confirmed_ind = 'N' THEN

  			IF Igs_En_Val_Susa.enrp_val_susa_sci_up(
  					p_person_id,
  					p_course_cd,
  					p_unit_set_cd,
  					p_sequence_number,
  					p_student_confirmed_ind,
  					v_message_name) = FALSE THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
    	END IF;
    	-- Validate if the primary set indicator.
    	IF v_inserting OR
    	  (v_updating AND
    	   (p_primary_set_ind  <> v_old_susa_rec.primary_set_ind)) THEN
  		-- Validate the primary set indicator is only set for
  		-- non-administrative sets and that there does not already
  		-- exist a unit set that has a higher rank.
  		IF Igs_En_Val_Susa.enrp_val_susa_prmry(
  				p_person_id,
  				p_course_cd,

  				p_unit_set_cd,
  				p_us_version_number,
  				p_primary_set_ind,
  				v_message_name,
                'N') = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
    	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','Igs_En_Val_Susa.enrp_val_susa');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END enrp_val_susa;
  --
  -- Validate the cascading setting of the end date of an susa record.
  FUNCTION ENRP_VAL_SUSA_ED_UPD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_end_dt IN DATE ,
  p_voluntary_end_ind IN VARCHAR2,
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_ed_upd
  	-- This module is called when a IGS_AS_SU_SETATMPT is ended (end_dt set).
  	-- This module will check if the unit set has any child unit sets and
  	-- validate if able to set the end_dt and associated authorisation details
  	-- for all children
  DECLARE
  	v_unit_set_cd			IGS_AS_SU_SETATMPT.unit_set_cd%TYPE;
  	v_us_version_number		IGS_AS_SU_SETATMPT.us_version_number%TYPE;
  	v_sequence_number		IGS_AS_SU_SETATMPT.sequence_number%TYPE;
  	v_authorised_person_id		IGS_AS_SU_SETATMPT.authorised_person_id%TYPE;
  	v_authorised_on			IGS_AS_SU_SETATMPT.authorised_on%TYPE;
  	v_selection_dt			IGS_AS_SU_SETATMPT.selection_dt%TYPE;

  	v_end_dt				IGS_AS_SU_SETATMPT.end_dt%TYPE;
  	v_rqrmnts_complete_dt		IGS_AS_SU_SETATMPT.rqrmnts_complete_dt%TYPE;
  	v_parent_unit_set_cd		IGS_AS_SU_SETATMPT.parent_unit_set_cd%TYPE;
  	v_parent_sequence_number		IGS_AS_SU_SETATMPT.parent_sequence_number%TYPE;
  	v_student_confirmed_ind		IGS_AS_SU_SETATMPT.student_confirmed_ind%TYPE;
  	v_primary_set_ind			IGS_AS_SU_SETATMPT.primary_set_ind%TYPE;
  	v_voluntary_end_ind		IGS_AS_SU_SETATMPT.voluntary_end_ind%TYPE;
  	v_override_title			IGS_AS_SU_SETATMPT.override_title%TYPE;
  	v_rqrmnts_complete_ind		IGS_AS_SU_SETATMPT.rqrmnts_complete_ind%TYPE;
  	v_s_completed_source_type
  					IGS_AS_SU_SETATMPT.s_completed_source_type%TYPE;
  	v_message_name			 VARCHAR2(30);
  	v_message_text			VARCHAR2 (2000) := NULL;
  	CURSOR c_susa IS
  		SELECT	susa.unit_set_cd,
  			susa.us_version_number,
  			susa.sequence_number,
  			susa.authorised_person_id,
  			susa.authorised_on,
  			susa.selection_dt,
  			susa.end_dt,
  			susa.rqrmnts_complete_dt,
  			susa.parent_unit_set_cd,

  			susa.parent_sequence_number,
  			susa.student_confirmed_ind,
  			susa.primary_set_ind,
  			susa.voluntary_end_ind,
  			susa.override_title,
  			susa.rqrmnts_complete_ind,
  			susa.s_completed_source_type
  		FROM	IGS_AS_SU_SETATMPT susa
  			START WITH 	susa.person_id 			= p_person_id 	AND
  					susa.course_cd			= p_course_cd	AND
  					susa.parent_unit_set_cd 	= p_unit_set_cd AND
  					susa.parent_sequence_number 	= p_sequence_number
  			CONNECT BY
  				PRIOR	susa.person_id		= susa.person_id		AND
  				PRIOR	susa.course_cd		= susa.course_cd		AND
  				PRIOR	susa.unit_set_cd 	= susa.parent_unit_set_cd	AND
  				PRIOR	susa.sequence_number 	= susa.parent_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	OPEN c_susa;
  	FETCH c_susa INTO 	v_unit_set_cd,
  				v_us_version_number,

  				v_sequence_number,
  				v_authorised_person_id,
  				v_authorised_on,
  				v_selection_dt,
  				v_end_dt,
  				v_rqrmnts_complete_dt,
  				v_parent_unit_set_cd,
  				v_parent_sequence_number,
  				v_student_confirmed_ind,
  				v_primary_set_ind,
  				v_voluntary_end_ind,
  				v_override_title,
  				v_rqrmnts_complete_ind,
  				v_s_completed_source_type;
  	LOOP
  		EXIT WHEN (c_susa%NOTFOUND);
  		-- For each descendant record found, validate if able to then end the unit
  		-- set.
  		IF (v_end_dt IS NULL AND
      				v_rqrmnts_complete_dt IS NULL) THEN
  			-- Determine if authorised person id required to be updated (That is, if
  			-- authorise parameter fields null then do not alter fields.)
  			IF (p_authorised_person_id IS NOT NULL OR

      					p_authorised_on IS NOT NULL) THEN
  				v_authorised_person_id 	:= p_authorised_person_id;
  				v_authorised_on	 	:= p_authorised_on;
  			END IF;
  			-- Validate that able to update the record.
  			IF Igs_En_Val_Susa.enrp_val_susa(
  						p_person_id,
  						p_course_cd,
  						v_unit_set_cd,
  						v_sequence_number,
  						v_us_version_number,
  						v_selection_dt,
  						v_student_confirmed_ind,
  						p_end_dt,
  						v_parent_unit_set_cd,
  						v_parent_sequence_number,
  						v_primary_set_ind,
  						p_voluntary_end_ind,
  						v_authorised_person_id,
  						v_authorised_on,
  						v_override_title,
  						v_rqrmnts_complete_ind,
  						v_rqrmnts_complete_dt,

  						v_s_completed_source_type,
  						'UPDATE',
  						v_message_name,
  						v_message_text) = FALSE THEN
  				-- Ignore v_message_text as rules are not used here in any validation.
   				CLOSE c_susa;
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		FETCH c_susa INTO 	v_unit_set_cd,
  					v_us_version_number,
  					v_sequence_number,
  					v_authorised_person_id,
  					v_authorised_on,
  					v_selection_dt,
  					v_end_dt,
  					v_rqrmnts_complete_dt,
  					v_parent_unit_set_cd,
  					v_parent_sequence_number,
  					v_student_confirmed_ind,
  					v_primary_set_ind,
  					v_voluntary_end_ind,

  					v_override_title,
  					v_rqrmnts_complete_ind,
  					v_s_completed_source_type;
  	END LOOP;
  	CLOSE c_susa;
  	-- If processing successful then
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
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','Igs_En_Val_Susa.enrp_val_susa_ed_upd');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_susa_ed_upd;
  --
  -- Validate cascade unsetting of stdnt unit set atmpt confirmation ind.

  FUNCTION ENRP_VAL_SUSA_SCI_UP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_sci_up
  	-- This module is called when the student_confimed_ind is unset.
  	-- This module will check if the unit set has any child unit sets and
  	-- validate if able unset the the student_confirmed_ind for all children.
  DECLARE
  	v_enrp_val_susa_sci	BOOLEAN;
  	v_susa_rec_found	BOOLEAN;
  	v_message_name		 VARCHAR2(30);
  	v_message_text		VARCHAR2 (2000) := NULL;
  	CURSOR c_susa IS
  		SELECT	susa.unit_set_cd,
  			susa.us_version_number,
  			susa.sequence_number,
  			susa.authorised_person_id,

  			susa.authorised_on,
  			susa.selection_dt,
  			susa.end_dt,
  			susa.rqrmnts_complete_dt,
  			susa.parent_unit_set_cd,
  			susa.parent_sequence_number,
  			susa.student_confirmed_ind,
  			susa.primary_set_ind,
  			susa.voluntary_end_ind,
  			susa.override_title,
  			susa.rqrmnts_complete_ind,
  			susa.s_completed_source_type
  		FROM	IGS_AS_SU_SETATMPT susa
  			START WITH 	susa.person_id 			= p_person_id 	AND
  					susa.course_cd			= p_course_cd	AND
  					susa.parent_unit_set_cd 	= p_unit_set_cd AND
  					susa.parent_sequence_number 	= p_sequence_number
  			CONNECT BY
  				PRIOR	susa.person_id		= susa.person_id		AND
  				PRIOR	susa.course_cd		= susa.course_cd		AND
  				PRIOR	susa.unit_set_cd 	= susa.parent_unit_set_cd	AND
  				PRIOR	susa.sequence_number 	= susa.parent_sequence_number;
  BEGIN

    v_enrp_val_susa_sci := TRUE;
    v_susa_rec_found    := FALSE;

  	-- Set the default message number
  	p_message_name := NULL;
  	-- If student confirmed indicator is NULL or 'Y' then
  	-- not concerned with updating children
  	IF p_student_confirmed_ind = 'Y' OR
  			p_student_confirmed_ind IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- Process all descendants of the unit set and to validate if able
  	-- to unset the student confirmed indicator.
  	-- For each descendant record found, validate unsetting of the student
  	-- confirmed indicator.
  	FOR v_susa_rec IN c_susa LOOP
  		v_susa_rec_found := TRUE;
  		IF v_susa_rec.student_confirmed_ind = 'Y' THEN
  			-- Validate that able to update the record.
  			IF Igs_En_Val_Susa.enrp_val_susa(
  						p_person_id,
  						p_course_cd,
  						v_susa_rec.unit_set_cd,
  						v_susa_rec.sequence_number,
  						v_susa_rec.us_version_number,

  						NULL,	-- selection_dt
  						'N',	-- student_confirmed_ind
  						v_susa_rec.end_dt,
  						v_susa_rec.parent_unit_set_cd,
  						v_susa_rec.parent_sequence_number,
  						v_susa_rec.primary_set_ind,
  						v_susa_rec.voluntary_end_ind,
  						v_susa_rec.authorised_person_id,
  						v_susa_rec.authorised_on,
  						v_susa_rec.override_title,
  						v_susa_rec.rqrmnts_complete_ind,
  						v_susa_rec.rqrmnts_complete_dt,
  						v_susa_rec.s_completed_source_type,
  						'UPDATE',
  						v_message_name,
  						v_message_text) = FALSE THEN
  				-- Ignore v_message_text as rules are not used here in any validation.
  				p_message_name := v_message_name;
  				v_enrp_val_susa_sci := FALSE;
  				EXIT;
  			END IF;
  		END IF;
  	END LOOP;

  	IF (v_susa_rec_found = TRUE AND
  			v_enrp_val_susa_sci = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_susa%ISOPEN THEN
  			CLOSE c_susa;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
		WHEN NO_DATA_FOUND THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','Igs_En_Val_Susa.enrp_val_susa_sci_up');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_susa_sci_up;
  --
  -- Validate the requirement complete fields for IGS_AS_SU_SETATMPT.
  FUNCTION enrp_val_susa_scst(
  p_rqrmnts_complete_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2,
  p_s_completed_source_type IN VARCHAR2,
  p_message_name OUT NOCOPY  VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_scst
  	-- This module validates the system completed source type
  	-- field associated with the IGS_AS_SU_SETATMPT:
  	-- - s_completed_source_type can only be set if rqrmnts_complete_dt
  	--   and rqrmnts_complete_ind fields are set.
  DECLARE
  BEGIN
  	-- s_completed_source_type can only be set if rqrmnts_complete_dt and
  	-- rqrmnts_complete_ind fields are set.
  	IF (p_rqrmnts_complete_ind = 'N' AND
  			p_rqrmnts_complete_dt IS NULL AND
  			p_s_completed_source_type IS NOT NULL) THEN
  		p_message_name := 'IGS_EN_SYS_COMPL_SRCTYPE_SET';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;

  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','Igs_En_Val_Susa.enrp_val_susa_scst');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_susa_scst;
  --
  -- Validate a person id.
  --

END Igs_En_Val_Susa;

/
