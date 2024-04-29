--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_POSU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_POSU" AS
/* $Header: IGSPS52B.pls 120.1 2005/11/16 02:13:04 appldev ship $ */
  --
  -- Validate pattern of study IGS_PS_UNIT record is unique.
  FUNCTION crsp_val_posu_iu(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_pos_sequence_number  IN NUMBER ,
  p_posp_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_location_cd  IN VARCHAR2,
  p_unit_class   IN VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_posu_iu
  	-- Validate IGS_PS_PAT_STUDY_UNT records.
  	-- Multiple records cannot exist with the same unit_cd for a parent
  	-- IGS_PS_PAT_OF_STUDY	record.
  -------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sarakshi    16-NOV-2005     Bug#4726345, shifted the uniuqeness validation before the MUS validation.
  -------------------------------------------------------------------
  DECLARE
  	v_posp_sequence_number 	NUMBER;
  	cst_error		VARCHAR2(1) := 'E';
  	cst_warning		VARCHAR2(1) := 'W';
        l_n_count               NUMBER;

	CURSOR cur_multiple_section IS
	SELECT 'X'
	FROM  igs_ps_pat_study_unt psu,
	      igs_ps_unit_ver_all a,
	      igs_ps_unit_stat  b
	WHERE
	psu.course_cd              = p_course_cd AND
	psu.version_number          = p_version_number AND
	psu.cal_type                = p_cal_type AND
	psu.pos_sequence_number    = p_pos_sequence_number AND
	psu.unit_cd = p_unit_cd  AND
	psu.unit_cd = a.unit_cd AND
	a.same_teaching_period = 'Y'  AND
	((a.expiry_dt IS NULL) OR (TRUNC(a.expiry_dt) >= TRUNC(SYSDATE))) AND
	a.unit_status = b.unit_status AND
	b.s_unit_status <> 'INACTIVE' AND
	(p_sequence_number IS NULL OR psu.sequence_number <> p_sequence_number);  --leave this record

	CURSOR cur_check_multi_section IS
	SELECT COUNT(*)
	FROM  igs_ps_pat_study_unt psu
	WHERE
	psu.course_cd              = p_course_cd AND
	psu.version_number          = p_version_number AND
	psu.cal_type                = p_cal_type AND
	psu.pos_sequence_number    = p_pos_sequence_number AND
	psu.unit_cd = p_unit_cd AND
	(p_sequence_number IS NULL OR psu.sequence_number <> p_sequence_number);  --leave this record


	CURSOR c_pfsu1 IS
	SELECT 'X'
	FROM   IGS_PS_PAT_STUDY_UNT
	WHERE
	course_cd               = p_course_cd AND
	version_number          = p_version_number AND
	cal_type                = p_cal_type AND
	pos_sequence_number     = p_pos_sequence_number AND
	posp_sequence_number    = p_posp_sequence_number  AND
	NVL(unit_cd,'NULL')           = NVL(p_unit_cd,'NULL')  AND
	NVL(unit_location_cd,'NULL')  = NVL(p_location_cd,'NULL') AND
	NVL(unit_class,'NULL')        = NVL(p_unit_class,'NULL') AND
	(p_sequence_number IS NULL OR
	sequence_number         <> p_sequence_number);
	l_c_var VARCHAR2(1);

	CURSOR c_pfsu IS
	SELECT posp_sequence_number
	FROM   IGS_PS_PAT_STUDY_UNT
	WHERE
	course_cd               = p_course_cd AND
	version_number          = p_version_number AND
	cal_type                = p_cal_type AND
	pos_sequence_number     = p_pos_sequence_number AND
	NVL(unit_cd,'NULL')           = NVL(p_unit_cd,'NULL')  AND
	NVL(unit_location_cd,'NULL')  = NVL(p_location_cd,'NULL') AND
	NVL(unit_class,'NULL')        = NVL(p_unit_class,'NULL') AND
	(p_sequence_number IS NULL OR
	sequence_number         <> p_sequence_number);

  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	p_return_type := '';
  	-- 1. Check parameters:
  	IF p_course_cd IS NULL OR
  			p_version_number IS NULL OR
  			p_cal_type IS NULL OR
  			p_pos_sequence_number IS NULL OR
  			p_posp_sequence_number IS NULL OR
  			p_unit_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;

---added by sarakshi added as aprt of bug#4069211--

	--Verify that the record is unique for a teaching calendar i.e. unit_cd,location_cd,unit_class
	--cannot be same for a teaching class, Null values also cannot be same
	OPEN c_pfsu1;
  	FETCH c_pfsu1 INTO l_c_var;
  	IF (c_pfsu1%FOUND) THEN
          CLOSE c_pfsu1;
    	  p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
	  p_return_type := cst_error;
  	  RETURN FALSE;
        END IF;
	CLOSE c_pfsu1;

        -- For a pattern of study period multiple patten of study unit can exists with same unit code if multiple unit section checkbx
	-- is checked at unit level.
	OPEN cur_multiple_section;
	FETCH cur_multiple_section INTO l_c_var;
	IF cur_multiple_section%NOTFOUND THEN
          CLOSE cur_multiple_section;
	  OPEN cur_check_multi_section;
	  FETCH cur_check_multi_section INTO l_n_count;
	  CLOSE cur_check_multi_section;
	  IF NVL(l_n_count,0) > 0 THEN
      	    p_message_name := 'IGS_PS_NOT_MULTIPLE_USEC';
	    p_return_type := cst_error;
  	    RETURN FALSE;
	  END IF;
        ELSE
          CLOSE cur_multiple_section;
	END IF;


---added by sarakshi --

  	-- 2. Check for records with the same unit_cd for
  	--    the parent IGS_PS_PAT_OF_STUDY record:

	--Verify that if the record(unit code, location code and unit class) exists for some other teaching calendar for the academic period , then warn the user.
  	OPEN c_pfsu;
  	FETCH c_pfsu INTO v_posp_sequence_number;
  	IF (c_pfsu%FOUND) THEN
 	  CLOSE c_pfsu;
  	  p_message_name := 'IGS_PS_RECORD_ALREADY_EXISTS';
  	  p_return_type := cst_warning;
  	  RETURN FALSE;
  	END IF;
  	CLOSE c_pfsu;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pfsu%ISOPEN THEN
  			CLOSE c_pfsu;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POSu.crsp_val_posu_iu');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_posu_iu;
  --
  -- Validate the pattern of study IGS_PS_UNIT record has the required fields.
  FUNCTION crsp_val_posu_rqrd(
  p_unit_cd IN VARCHAR2 ,
  p_unit_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_description IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_posu_rqrd
  	-- Validate IGS_PS_PAT_STUDY_UNT records, either unit_cd or
  	-- description must be specified. The unit_location_cd and
  	-- IGS_AS_UNIT_CLASS can only be specified if the unit_cd is set.
  DECLARE
  BEGIN
  	-- 1. Check that one of either unit_cd or description is specified
  	IF (p_unit_cd IS NULL AND
  	    p_description IS NULL) OR
  	    (p_unit_cd IS NOT NULL AND
  	    p_description IS NOT NULL)THEN
  		p_message_name := 'IGS_PS_UNITCD_OR_DESC_SPECIFY';
  		RETURN FALSE;
  	END IF;
  	-- 2. Check that if the unit_cd is not set that the unit_location_cd
  	-- and IGS_AS_UNIT_CLASS are not specified
  	IF (p_unit_cd IS NULL AND
  			(p_unit_location_cd IS NOT NULL OR
  			p_unit_class IS NOT NULL)) THEN
  		p_message_name := 'IGS_PS_UNITLOCCD_UNTCLASS_SPC';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POSu.crsp_val_posu_rqrd');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_posu_rqrd;
  --
  -- Warn if no IGS_PS_UNIT offering option exists for the specified options.
  FUNCTION crsp_val_posu_uoo(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_pos_sequence_number IN NUMBER ,
  p_posp_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_unit_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_posp_uoo_ci IS
  		SELECT	'X'
  		FROM	IGS_PS_PAT_STUDY_PRD	posp,
  			IGS_PS_UNIT_OFR_OPT	uoo,
  			IGS_CA_INST		ci
  		WHERE	posp.course_cd			= p_course_cd AND
  			posp.version_number 		= p_version_number AND
  			posp.cal_type			= p_cal_type AND
  			posp.pos_sequence_number	= p_pos_sequence_number AND
  			posp.sequence_number		= p_posp_sequence_number AND
  			uoo.unit_cd			= p_unit_cd AND
  			uoo.cal_type			= posp.teach_cal_type AND
  			(p_unit_location_cd  IS NULL OR
  			uoo.location_cd			= p_unit_location_cd) AND
  			(p_unit_class  IS NULL OR
  			uoo.unit_class			= p_unit_class) AND
  			uoo.cal_type			= ci.cal_type AND
  			uoo.ci_sequence_number		= ci.sequence_number AND
  			ci.end_dt			> SYSDATE;
  BEGIN
  	-- 1. Check parameters
  	IF (p_course_cd IS NULL OR
  			p_version_number IS NULL OR
  			p_cal_type IS NULL OR
  			p_pos_sequence_number IS NULL OR
  			p_posp_sequence_number IS NULL OR
  			p_unit_cd IS NULL) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- 2. Check for future IGS_PS_UNIT_OFR_OPT records for the IGS_PS_COURSE offering
  	-- supplied for the IGS_PS_PAT_STUDY_UNT.unit_cd, location_cd, IGS_AS_UNIT_CLASS
  	-- and IGS_PS_PAT_STUDY_PRD.teach_cal_type
  	OPEN c_posp_uoo_ci;
  	FETCH c_posp_uoo_ci INTO v_dummy;
  	IF (c_posp_uoo_ci%NOTFOUND) THEN
  		CLOSE c_posp_uoo_ci;
  		p_message_name := 'IGS_PS_FUTURE_UOO_NOT_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_posp_uoo_ci;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_posp_uoo_ci%ISOPEN) THEN
  			CLOSE c_posp_uoo_ci;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POSu.crsp_val_posu_uoo');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_posu_uoo;
  --
  -- Validate a least one version of the IGS_PS_UNIT is active.
  FUNCTION crsp_val_uv_active(
  p_unit_cd IN IGS_PS_UNIT_VER_ALL.unit_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
-- who      when          What
--sarakshi  23-dec-2002   Bug#2689625,removed the exception section
  BEGIN	-- crsp_val_uv_active
  	-- Validate the IGS_PS_UNIT has at least one ACTIVE IGS_PS_UNIT_VER.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_chk_uv IS
  		SELECT	'X'
  		FROM	IGS_PS_UNIT_VER	uv,
  			IGS_PS_UNIT_STAT	ust
  		WHERE	uv.unit_cd 		= p_unit_cd		AND
  			uv.unit_status	= ust.unit_status AND
  			ust.s_unit_status 	= 'ACTIVE';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- 1. Check parameters:
  	IF p_unit_cd IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- 2. Check if the unit_cd has an active IGS_PS_UNIT_VER:
  	OPEN c_chk_uv;
  	FETCH c_chk_uv INTO v_dummy;
  	-- 3. IF no active record is found return error:
  	IF (c_chk_uv%NOTFOUND) THEN
  		CLOSE c_chk_uv;
  		p_message_name := 'IGS_PS_UNITCD_NO_ACTIVE_UNITV';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_chk_uv;
  	RETURN TRUE;
  END;

  END crsp_val_uv_active;

  --
END IGS_PS_VAL_POSu;

/
