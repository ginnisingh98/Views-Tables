--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_POS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_POS" AS
/* $Header: IGSPS50B.pls 115.7 2003/02/26 05:50:34 sarakshi ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sarakshi    23-Feb-2003    Enh#2797116,modified cursor c_coo in the function crsp_val_pos_coo
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_am_closed"
  -- avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_att_closed"
  -- avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_crs_ci"
  --smaddali 21-oct-2001 modified crsp_val_pos_iu procedure for bug#1838421 .
  -- changed the select statement .it was selecting attendance_mode twice instead of  attendance_type ,
  -- so changed the second attendance_mode to attendance_type .Also changed the message name
  -- to IGS_PS_PAT_MANDATORY for the corresponding cursor code
  -------------------------------------------------------------------------------------------

  --
  -- Validate the admission category is not closed.
  FUNCTION crsp_val_ac_closed(
  p_admission_cat IN IGS_AD_CAT.admission_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_ac_closed
  	-- Validate if IGS_AD_CAT.IGS_AD_CAT is closed
  DECLARE
  	v_dummy			VARCHAR2(1);
  	CURSOR c_ac IS
  		SELECT 	'X'
  		FROM 	IGS_AD_CAT		ac
  		WHERE	ac.admission_cat	= p_admission_cat AND
  			ac.closed_ind		= 'Y';
  BEGIN
  	IF p_admission_cat IS NOT NULL THEN
  		OPEN c_ac;
  		FETCH c_ac INTO v_dummy;
  		IF (c_ac%FOUND) THEN
  			CLOSE c_ac;
  			p_message_name := 'IGS_AD_ADM_CATEGORY_CLOSED';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_ac;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_ac%ISOPEN) THEN
  			CLOSE c_ac;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POS.CRSP_VAL_AC_CLOSED');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_ac_closed;
  --

  -- Validate the calendar type is categorised admission and is not closed.
  FUNCTION crsp_val_pos_cat(
  p_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_pos_cat
  	-- Validate the IGS_CA_TYPE is not closed and the SI_CA_S_CA_CAT is set to ADMISSION.
  DECLARE
  	v_closed_ind		IGS_CA_TYPE.closed_ind%TYPE;
  	v_s_cal_cat		IGS_CA_TYPE.s_cal_cat%TYPE;
  	CURSOR	c_cat IS
  		SELECT closed_ind,
  			s_cal_cat
		FROM	IGS_CA_TYPE
  		WHERE	cal_type = p_cal_type;
  BEGIN
  	-- check parameters
  	IF p_cal_type IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- get the closed indicator and calender category for this cal type
  	OPEN c_cat;
  	FETCH c_cat INTO 	v_closed_ind,
  				v_s_cal_cat;
  	-- if no records found
  	IF (c_cat%NOTFOUND) THEN
  		CLOSE c_cat;
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cat;
  	--check if IGS_CA_TYPE is closed
  	IF v_closed_ind = 'Y' THEN
  		p_message_name := 'IGS_CA_CALTYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	--check if the IGS_CA_TYPE is of category 'ADMISSION'
  	IF v_s_cal_cat <> 'ADMISSION' THEN
  		p_message_name := 'IGS_PS_CALTYPE_ADMISSION_CAL';
  		RETURN FALSE;
  	END IF;
  	-- validated IGS_CA_TYPE is not closed and SI_CA_S_CA_CAT set to ADMISSION
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_cat%ISOPEN) THEN
  			CLOSE c_cat;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POS.CRSP_VAL_POS_CAT');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_pos_cat;
  --
  -- Warn if no IGS_PS_COURSE offering exists for the specified options.
  FUNCTION crsp_val_pos_coo(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_pos_coo
  	-- Warn the user if  location_cd, IGS_EN_ATD_MODE or IGS_EN_ATD_TYPE are set
  	-- that a IGS_PS_OFR_OPT record exists for the specified option.
  	-- Warning only.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_coo IS
  		SELECT 	'x'
  		FROM	IGS_PS_OFR_OPT
  		WHERE	course_cd		= p_course_cd AND
  				version_number		= p_version_number AND
  				cal_type 		= p_cal_type AND
  				(p_location_cd		IS NULL OR
  			 	location_cd		= p_location_cd) AND
  				(p_attendance_mode 	IS NULL OR
  			 	attendance_mode = p_attendance_mode) AND
  				(p_attendance_type 	IS NULL OR
  			 	attendance_type	= p_attendance_type) AND
                                delete_flag = 'N';
  BEGIN
  	-- check parameters
  	IF p_course_cd IS NULL OR
  			p_version_number IS NULL OR
  			p_cal_type IS NULL THEN
          	p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- Check for IGS_PS_OFR_OPT records for the IGS_PS_COURSE offering supplied
  	-- and for  IGS_EN_UNIT_SET versions with the uni_set_cd supplied which have a
  	--  IGS_EN_UNIT_SET_STAT.s_unit_set_status of ACTIVE:
  	OPEN c_coo;
  	FETCH c_coo INTO v_dummy;
  	IF (c_coo%NOTFOUND) THEN
  		-- no record found
  		CLOSE c_coo;
  		p_message_name := 'IGS_PS_POO_DOES_NOT_EXIST';
  		RETURN FALSE;
  	END IF;
  	-- record found
  	CLOSE c_coo;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_coo%ISOPEN) THEN
  			CLOSE c_coo;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POS.CRSP_VAL_POS_COO');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_pos_coo;
  --
  -- Warn if no IGS_PS_COURSE offering IGS_PS_UNIT set record exists.
  FUNCTION crsp_val_pos_cous(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_pos_cous
  	-- Warn the user if the IGS_EN_UNIT_SET is not linked to the IGS_PS_OFR.
  	-- Warning only.
  DECLARE
  	cst_active	CONSTANT	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE := 'ACTIVE';
  	v_dummy			VARCHAR(1);
  	CURSOR c_cous_us_uss IS
  		SELECT	'X'
  		FROM	IGS_PS_OFR_UNIT_SET	cous,
  			IGS_EN_UNIT_SET			us,
  			IGS_EN_UNIT_SET_STAT			uss
  		WHERE	cous.course_cd			= p_course_cd AND
  			cous.crv_version_number		= p_crv_version_number AND
  			cous.cal_type			= p_cal_type AND
  			cous.unit_set_cd		= p_unit_set_cd AND
  			cous.unit_set_cd		= us.unit_set_cd AND
  			cous.us_version_number		= us.version_number AND
  			us.unit_set_status			= uss.unit_set_status AND
  			uss.s_unit_set_status		= cst_active;
  BEGIN
  	IF p_course_cd IS NULL OR
  			p_crv_version_number IS NULL OR
  			p_cal_type IS NULL OR
  			p_unit_set_cd IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		OPEN c_cous_us_uss;
  		FETCH c_cous_us_uss INTO v_dummy;
  		IF (c_cous_us_uss%NOTFOUND) THEN
  			CLOSE c_cous_us_uss;
  			p_message_name := 'IGS_PS_UNITSET_NOT_LINK_PRG';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_cous_us_uss;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_cous_us_uss%ISOPEN) THEN
  			CLOSE c_cous_us_uss;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POS.CRSP_VAL_POS_COUS');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_pos_cous;
  --
  -- Validate pattern of study record is not ambiguous.
  FUNCTION crsp_val_pos_iu(
  p_course_cd IN IGS_PS_PAT_OF_STUDY.course_cd%TYPE ,
  p_version_number IN IGS_PS_PAT_OF_STUDY.version_number%TYPE ,
  p_cal_type IN IGS_PS_PAT_OF_STUDY.cal_type%TYPE ,
  p_sequence_number IN IGS_PS_PAT_OF_STUDY.sequence_number%TYPE ,
  p_location_cd IN IGS_PS_PAT_OF_STUDY.location_cd%TYPE ,
  p_attendance_mode IN IGS_PS_PAT_OF_STUDY.attendance_mode%TYPE ,
  p_attendance_type IN IGS_PS_PAT_OF_STUDY.attendance_type%TYPE ,
  p_unit_set_cd IN IGS_PS_PAT_OF_STUDY.unit_set_cd%TYPE ,
  p_admission_cal_type IN IGS_PS_PAT_OF_STUDY.admission_cal_type%TYPE ,
  p_admission_cat IN IGS_PS_PAT_OF_STUDY.admission_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_pos_iu
  	-- Validate IGS_PS_PAT_OF_STUDY records are unique for the IGS_PS_OFR
  	-- specified.  Once a IGS_AD_LOCATION code, attendance mode, attendance type,
  	-- IGS_PS_UNIT set code, admission calendar type or admission category is set
  	-- for one IGS_PS_PAT_OF_STUDY record for a IGS_PS_OFR it must be set
  	-- for all records.  This excludes the single default IGS_PS_PAT_OF_STUDY
  	-- record which is allowed to exist for each IGS_PS_OFR where IGS_AD_LOCATION
  	-- code, attendance mode, attendance type, IGS_PS_UNIT set code, admission calendar
  	-- type and admission category are all not set.
  DECLARE
  	v_dummy			VARCHAR2(255);
  	v_ret_false_flg		BOOLEAN;
  	v_location_cd		IGS_PS_PAT_OF_STUDY.location_cd%TYPE;
  	v_attendance_mode  	IGS_PS_PAT_OF_STUDY.attendance_mode%TYPE;
  	v_attendance_type		IGS_PS_PAT_OF_STUDY.attendance_type%TYPE;
  	v_unit_set_cd		IGS_PS_PAT_OF_STUDY.unit_set_cd%TYPE;
  	v_admission_cal_type	IGS_PS_PAT_OF_STUDY.admission_cal_type%TYPE;
  	v_admission_cat		IGS_PS_PAT_OF_STUDY.admission_cat%TYPE;
  	CURSOR c_pos IS
  		SELECT	'X'
  		FROM	IGS_PS_PAT_OF_STUDY	pos
  		WHERE	pos.course_cd		= p_course_cd AND
  			pos.version_number	= p_version_number AND
  			pos.cal_type		= p_cal_type AND
  			pos.sequence_number	<> p_sequence_number AND
  			pos.location_cd		IS NULL AND
  			pos.attendance_mode	IS NULL AND
  			pos.attendance_type	IS NULL AND
  			pos.unit_set_cd		IS NULL AND
  			pos.admission_cal_type	IS NULL AND
  			pos.admission_cat	IS NULL;

  	CURSOR c_pos2 IS
  		SELECT	'X'
  		FROM	IGS_PS_PAT_OF_STUDY	pos
  		WHERE	pos.course_cd		= p_course_cd AND
  			pos.version_number	= p_version_number AND
  			pos.cal_type            = p_cal_type AND
  			pos.sequence_number	<> p_sequence_number AND
  			((p_location_cd		IS NULL AND
  			pos.location_cd		IS NULL) OR
  			pos.location_cd		= p_location_cd) AND
  			((p_attendance_mode	IS NULL AND
  			pos.attendance_mode	IS NULL) OR
  			pos.attendance_mode	= p_attendance_mode) AND
  			((p_attendance_type	IS NULL AND
  			pos.attendance_type	IS NULL) OR
  			pos.attendance_type	= p_attendance_type) AND
  			((p_unit_set_cd		IS NULL AND
  			pos.unit_set_cd		IS NULL) OR
  			pos.unit_set_cd		= p_unit_set_cd) AND
  			((p_admission_cal_type	IS NULL AND
  			pos.admission_cal_type	IS NULL) OR
  			pos.admission_cal_type	= p_admission_cal_type) AND
  			((p_admission_cat	IS NULL AND
  			pos.admission_cat	IS NULL) OR
  			pos.admission_cat	= p_admission_cat);
  	--smaddali changed the select statement for bug#1838421 . it was selecting attendance_mode twice instead of
  	-- attendance_type , so changed the second attendance_mode to attendance_type
  	CURSOR c_pos3 IS
  		SELECT	pos.location_cd,
  			pos.attendance_mode,
  			pos.attendance_type,
  			pos.unit_set_cd,
  			pos.admission_cal_type,
  			pos.admission_cat
  		FROM	IGS_PS_PAT_OF_STUDY	pos
  		WHERE	pos.course_cd		= p_course_cd AND
  			pos.version_number	= p_version_number AND
  			pos.cal_type		= p_cal_type AND
  			pos.sequence_number	<> p_sequence_number AND
  			(pos.location_cd		IS NOT NULL OR
  			pos.attendance_mode	IS NOT NULL OR
  			pos.attendance_type	IS NOT NULL OR
  			pos.unit_set_cd		IS NOT NULL OR
  			pos.admission_cal_type	IS NOT NULL OR
  			pos.admission_cat		IS NOT NULL);
  BEGIN
  	-- 1. Check parameters
  	IF (p_course_cd IS NULL OR
  			p_version_number IS NULL OR
  			p_cal_type IS NULL OR
  			p_sequence_number IS NULL) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- 2. If all of the remaining parameters are null check that a
  	-- default (all null) record does not already exist
  	IF (p_location_cd IS NULL AND
  			p_attendance_mode IS NULL AND
  			p_attendance_type IS NULL AND
  			p_unit_set_cd IS NULL AND
  			p_admission_cal_type IS NULL AND
  			p_admission_cat IS NULL) THEN
  		OPEN c_pos;
  		FETCH c_pos INTO v_dummy;
  		IF (c_pos%FOUND) THEN
  			CLOSE c_pos;
  			p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_pos;
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- 3. Check that this record is not the same as an existing record
  	OPEN c_pos2;
  	FETCH c_pos2 INTO v_dummy;
  	IF (c_pos2%FOUND) THEN
  		CLOSE c_pos2;
  		p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_pos2;
  	-- 4. Check that if location_cd is set ,that other records have it set
  	--    (except the default all null record) or that if the location_cd
  	--    is not set that all other records do not have it set.
  	OPEN c_pos3;
  	v_ret_false_flg := FALSE;
  	LOOP
  		FETCH c_pos3 INTO	v_location_cd,
  				v_attendance_mode,
  				v_attendance_type,
  				v_unit_set_cd,
  				v_admission_cal_type,
  				v_admission_cat;
  		IF (c_pos3%NOTFOUND) THEN
  			CLOSE c_pos3;
  			EXIT;
  		END IF;
  		-- 4.1 Check IGS_AD_LOCATION code is set or unset for all pattern
  		-- of study records for this IGS_PS_COURSE offering.
  		--smaddali for bug#1838421 ,changed the message name from IGS_GE_RECORD_ALREADY_EXISTS
  	        --  to IGS_PS_PAT_MANDATORY in all the following IF cases
  		IF (p_location_cd IS NULL AND
  				v_location_cd IS NOT NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY';
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		IF (p_location_cd IS NOT NULL AND
  				v_location_cd IS NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY';
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		-- 4.2 Check attendance mode is set or unset for all pattern
  		-- of study records for this IGS_PS_COURSE offering.
  		IF (p_attendance_mode IS NULL AND
  				v_attendance_mode IS NOT NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY';
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		IF (p_attendance_mode IS NOT NULL AND
  				v_attendance_mode IS NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY';
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		-- 4.3 Check attendance type is set or unset for all pattern
  		-- of study records for this IGS_PS_COURSE offering.
  		IF (p_attendance_type IS NULL AND
  				v_attendance_type IS NOT NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY';
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		IF (p_attendance_type IS NOT NULL AND
  				v_attendance_type IS NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY' ;
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		-- 4.4 Check IGS_PS_UNIT set code is set or unset for all pattern
  		-- of study records for this IGS_PS_COURSE offering.
  		IF (p_unit_set_cd IS NULL AND
  				v_unit_set_cd IS NOT NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY';
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		IF (p_unit_set_cd IS NOT NULL AND
  				v_unit_set_cd IS NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY' ;
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		-- 4.5 Check admission calendar type is set or unset for all
  		-- pattern of study records for this IGS_PS_COURSE offering.
  		IF (p_admission_cal_type IS NULL AND
  				v_admission_cal_type IS NOT NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY' ;
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		IF (p_admission_cal_type IS NOT NULL AND
  				v_admission_cal_type IS NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY' ;
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		-- 4.6 Check admission category is set or unset for all
  		-- pattern of study records for this IGS_PS_COURSE offering.
  		IF (p_admission_cat IS NULL AND
  				v_admission_cat IS NOT NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY' ;
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  		IF (p_admission_cat IS NOT NULL AND
  				v_admission_cat IS NULL) THEN
  			p_message_name := 'IGS_PS_PAT_MANDATORY' ;
  			v_ret_false_flg := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF (v_ret_false_flg) THEN
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_pos%ISOPEN) THEN
  			CLOSE c_pos;
  		END IF;
  		IF (c_pos2%ISOPEN) THEN
  			CLOSE c_pos2;
  		END IF;
  		IF (c_pos3%ISOPEN) THEN
  			CLOSE c_pos3;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POS.CRSP_VAL_POS_IU');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_pos_iu;
  --
  -- Validate a least one version of the IGS_PS_UNIT set is active.
  FUNCTION crsp_val_us_active(
  p_unit_set_cd IN IGS_EN_UNIT_SET_ALL.unit_set_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_us_active
  	-- Validate the IGS_EN_UNIT_SET contains at least one version which is ACTIVE.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_us_uss IS
  		SELECT	'X'
  		FROM	IGS_EN_UNIT_SET us,
  			IGS_EN_UNIT_SET_STAT uss
  		WHERE	us.unit_set_cd 		= p_unit_set_cd AND
  			us.unit_set_status	= uss.unit_set_status AND
  			uss.s_unit_set_status 	= 'ACTIVE';
  BEGIN
  	-- Check parameters:
  	IF p_unit_set_cd IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- Check if the IGS_EN_UNIT_SET contains an active version:
  	OPEN c_us_uss;
  	FETCH c_us_uss INTO v_dummy;
  	--If no active record is found return error:
  	IF (c_us_uss%NOTFOUND) THEN
  		CLOSE c_us_uss;
  		p_message_name := 'IGS_PS_UNITSET_NO_ACTIVEVER';
  		RETURN FALSE;
  	END IF;
  	-- record is found
  	CLOSE c_us_uss;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_us_uss%ISOPEN) THEN
  			CLOSE c_us_uss;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POS.CRSP_VAL_US_ACTIVE');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_us_active;
END IGS_PS_VAL_POS;

/
