--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_SUAAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_SUAAP" AS
/* $Header: IGSAS31B.pls 120.0 2005/07/05 11:21:07 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .Modified function GENP_VAL_SDTT_SESS
  -------------------------------------------------------------------------------------------
  -- Val IGS_PS_UNIT assess pattern applies to stud IGS_PS_UNIT IGS_AD_LOCATION, class and mode.
  FUNCTION ASSP_VAL_UAP_LOC_UC(
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_uap_location_cd IN VARCHAR2 ,
  p_uap_unit_class IN VARCHAR2 ,
  p_uap_unit_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uap_loc_uc
  	-- This routine will validate that the IGS_AS_UNTAS_PATTERN's
  	-- IGS_AD_LOCATION, mode and class are applicable for the parameters passed in
  DECLARE
  	v_ret_val	BOOLEAN	DEFAULT TRUE;
  BEGIN
  	p_message_name := NULL;
  	IF p_location_cd <> NVL(p_uap_location_cd, p_location_cd) THEN
  			p_message_name := 'IGS_AS_UAP_LOC_NA_LOCATION';
  		RETURN FALSE;
  	ELSIF p_unit_class <> NVL(p_uap_unit_class, p_unit_class) THEN
  			p_message_name := 'IGS_AS_UAP_UNITCLASS_NA';
  		RETURN FALSE;
  	ELSIF p_unit_mode <> NVL(p_uap_unit_mode, p_unit_mode) THEN
  			p_message_name := 'IGS_AS_UAP_UNITMODE_NA';
  		RETURN FALSE;
  	ELSE
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	RETURN v_ret_val;
  END;

  END assp_val_uap_loc_uc;
  --
  -- Validate able to create stdnt_unit_atmp_ass_pattern.
  FUNCTION ASSP_VAL_SUAAP_INS(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_suaap_ins
  	-- Validate that the IGS_AS_SU_ATMPT_PAT can be created.
  	-- It must be valid for the students IGS_AD_LOCATION/class/mode and the status of
  	-- the student IGS_PS_UNIT attempt must be either UNCONFIRM/ENROLLED
  DECLARE
  	cst_enrolled		VARCHAR(8) := 'ENROLLED';
  	cst_unconfirmed		VARCHAR(9) := 'UNCONFIRM';
  	cst_completed		VARCHAR(9) := 'COMPLETED';
  	v_uooap_v_dummy		VARCHAR2(1) := NULL;
  	v_unit_attempt_status	IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
  	v_uoo_id		IGS_EN_SU_ATTEMPT.uoo_id%TYPE;
  	CURSOR c_sua IS
  		SELECT	sua.unit_attempt_status,
  			sua.uoo_id
  		FROM	IGS_EN_SU_ATTEMPT sua
  		WHERE	sua.person_id 		= p_person_id 	AND
  			sua.course_cd 		= p_course_cd 	AND
                -- anilk, 22-Apr-2003, Bug# 2829262
  			sua.uoo_id 	        = p_uoo_id;
  	CURSOR c_uooap_v(
  			cp_uoo_id	IGS_EN_SU_ATTEMPT.uoo_id%TYPE)IS
  		SELECT 	'x'
  		FROM	IGS_PS_UNIT_OFR_OPT_ASS_PAT_V uooap_v
  		WHERE	uooap_v.unit_cd 		= p_unit_cd AND
  			uooap_v.cal_type 		= p_cal_type AND
  			uooap_v.ci_sequence_number 	= p_ci_sequence_number AND
  			uooap_v.ass_pattern_id 		= p_ass_pattern_id AND
  			uooap_v.uoo_id			= cp_uoo_id AND
  			uooap_v.uap_logical_delete_dt IS NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate IGS_PS_UNIT version
  	OPEN c_sua;
  	FETCH c_sua INTO v_unit_attempt_status,
  			 v_uoo_id;
  	IF (c_sua%NOTFOUND) THEN
  		CLOSE c_sua;
  		RAISE NO_DATA_FOUND;
  	ELSE
  		CLOSE c_sua;
  		IF v_unit_attempt_status NOT IN (cst_unconfirmed, cst_enrolled) THEN
  			IF v_unit_attempt_status <> cst_completed THEN
  				-- Set message number to indicate incorrect student IGS_PS_UNIT status.
  				p_message_name := 'IGS_AS_SUA_STATUS_INVALID';
  				RETURN FALSE;
  			ELSE
  				-- Set message number to indicate incorrect student IGS_PS_UNIT status of
  				-- completed.
  				p_message_name := 'IGS_AS_CANNOT_ADD_ASSPATTERN';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	OPEN c_uooap_v (
  			v_uoo_id);
  	FETCH c_uooap_v INTO v_uooap_v_dummy;
  	IF (c_uooap_v%NOTFOUND) THEN
  		CLOSE c_uooap_v;
  		p_message_name := 'IGS_AS_SUA_ASSPAT_INVALID';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_uooap_v;
  	-- If processing reaches this point then return successfully.
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_uooap_v%ISOPEN) THEN
  			CLOSE c_uooap_v;
  		END IF;
  		IF (c_sua%ISOPEN) THEN
  			CLOSE c_sua;
  		END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_AS_VAL_SUAAP.ASSP_VAL_SUAAP_INS');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_suaap_ins;
  --
  -- Validate only one active instance of the assessment pattern for suaap.
  FUNCTION ASSP_VAL_SUAAP_ACTV(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_creation_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	--assp_val_suaap_actv
  DECLARE
  	v_suaap_count		VARCHAR2(1);
  	CURSOR c_suaap IS
  		SELECT	'x'
  		FROM	IGS_AS_SU_ATMPT_PAT	suaap
  		WHERE	suaap.person_id			= p_person_id AND
  			suaap.course_cd			= p_course_cd AND
                -- anilk, 22-Apr-2003, Bug# 2829262
		        suaap.uoo_id	                = p_uoo_id AND
  			suaap.ass_pattern_id		= p_ass_pattern_id AND
  			suaap.creation_dt		<> p_creation_dt AND
  			suaap.logical_delete_dt		IS NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	OPEN c_suaap ;
  	FETCH c_suaap INTO v_suaap_count;
  	IF c_suaap %FOUND THEN
  		CLOSE c_suaap;
  		p_message_name := 'IGS_AS_ASSPATTERN_EXISTS_STUD';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_suaap ;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_suaap %ISOPEN THEN
  			CLOSE c_suaap;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_AS_VAL_SUAAP.ASSP_VAL_SUAAP_ACTV');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_suaap_actv;
  --
  -- Validate that an entry exist in s_disable_table_trigger.
  FUNCTION GENP_VAL_SDTT_SESS(
  p_table_name IN VARCHAR2 )
  RETURN BOOLEAN IS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .Removed the exception Handler part
  -------------------------------------------------------------------------------------------
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_chk_for_tbl IS
  		SELECT	'x'
  		FROM	IGS_GE_S_DSB_TAB_TRG
  		WHERE	table_name = p_table_name AND
  			session_id = (
  				SELECT	userenv('SESSIONID')
  				FROM	dual );
  	v_return_result				CHAR;
  BEGIN
  	-- Validates that if a record exists in the s_disable_table_trigger
  	-- database table matching the table name and session id, then return
  	-- false indicating not to execute the table?s database triggers.
  	OPEN c_chk_for_tbl;
  	FETCH c_chk_for_tbl INTO v_return_result;
  	IF c_chk_for_tbl%FOUND THEN
  		CLOSE c_chk_for_tbl;
  		RETURN FALSE;
  	ELSE
  		CLOSE c_chk_for_tbl;
  		RETURN TRUE;
  	END IF;
  END;

  END GENP_VAL_SDTT_SESS;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

END IGS_AS_VAL_SUAAP;

/
