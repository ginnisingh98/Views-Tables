--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_CRS_ADMPERD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_CRS_ADMPERD" AS
/* $Header: IGSAD51B.pls 115.4 2003/01/03 06:57:13 rghosh ship $ */
  -- Validate the admission application course version.
  FUNCTION admp_val_coo_crv(
    p_course_cd IN VARCHAR2 ,
    p_version_number IN NUMBER ,
    p_s_admission_process_type IN VARCHAR2 ,
    p_offer_ind IN VARCHAR2 DEFAULT 'N',
    p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN	-- admp_val_coo_crv
  	-- Validate the admission application course version.
  	-- Validations are -
  	-- * If the course version is nominated then the course status must be
  	-- Active,
  	--  however, if the course version is offered the course status must be Active
  	-- * For all admission process types, with the exception of Re-Admission,
  	--  the expiry date  of the course version must not be set.
  	-- * If the admission process type is Non-Award then the course version must be
  	--  a non-award course.
  	-- * If the admission process type is Transfer then the course version must not
  	--  be a generic course.
  DECLARE
  	CURSOR c_cvcsct (
  		cp_course_cd		IGS_PS_VER.course_cd%TYPE,
  		cp_version_number	IGS_PS_VER.version_number%TYPE) IS
  		SELECT	cs.s_course_status,
  			cv.expiry_dt,
  			cv.generic_course_ind,
  			ct.govt_course_type
  		FROM	IGS_PS_VER	cv,
  			IGS_PS_STAT	cs,
  			IGS_PS_TYPE	ct
  		WHERE	course_cd 	= cp_course_cd AND
  			version_number 	= cp_version_number AND
  			cv.course_status 	= cs.course_status AND
  			cv.course_type 	= ct.course_type;
  	v_cvcsct_rec		c_cvcsct%ROWTYPE;
  	cst_active		CONSTANT VARCHAR2(10) := 'ACTIVE';

  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Retrieve the course version data
  	OPEN c_cvcsct(
  		p_course_cd,
  		p_version_number);
  	FETCH c_cvcsct INTO v_cvcsct_rec;
  	IF c_cvcsct%NOTFOUND THEN
  		CLOSE c_cvcsct;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cvcsct;
  	-- Validate the course status
  	IF p_offer_ind = 'Y' THEN
  		IF v_cvcsct_rec.s_course_status <> cst_active THEN
			p_message_name := 'IGS_AD_OFFER_PRG_MUSTBEACTIVE';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF v_cvcsct_rec.s_course_status <> cst_active THEN
			p_message_name := 'IGS_AD_NOMINATED_PRG_ACTVPLAN';   --removed the planned status as per bug#2722785 --rghosh
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate the course version against the admission process type
  	IF p_s_admission_process_type <> 'RE-ADMIT' AND
  			v_cvcsct_rec.expiry_dt IS NOT NULL THEN
		p_message_name := 'IGS_AD_PRCTYPE_PRG_EXPDT_SET';
  		RETURN FALSE;
  	END IF;
  	IF p_s_admission_process_type = 'TRANSFER' AND
  			v_cvcsct_rec.generic_course_ind = 'Y' THEN
		p_message_name := 'IGS_AD_PRG_TRANSFERED_CANNOT';
  		RETURN FALSE;
  	END IF;
  	IF p_s_admission_process_type = 'NON-AWARD' AND
  			v_cvcsct_rec.govt_course_type <> 50 THEN
		p_message_name := 'IGS_AD_PRCTYPE_NONAWARD';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END admp_val_coo_crv;
  --
  -- Validate the course offering option against the admission cat.
  FUNCTION admp_val_coo_adm_cat(
    p_course_cd IN VARCHAR2 ,
    p_version_number IN NUMBER ,
    p_cal_type IN VARCHAR2 ,
    p_location_cd IN VARCHAR2 ,
    p_attendance_mode IN VARCHAR2 ,
    p_attendance_type IN VARCHAR2 ,
    p_admission_cat IN VARCHAR2 ,
    p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN	-- admp_val_coo_adm_cat
  	-- Validate that the course offering option of the admission application
  	-- against the admission category.
  DECLARE
  	CURSOR c_cooac IS
  		SELECT	location_cd,
  			attendance_mode,
  			attendance_type
  		FROM	IGS_PS_OF_OPT_AD_CAT
  		WHERE	course_cd 	= p_course_cd AND
  			version_number 	= p_version_number AND
  			cal_type 	= p_cal_type AND
  			admission_cat 	= p_admission_cat;
  	v_adm_cat_match		BOOLEAN DEFAULT FALSE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Course offering component of course offering option and admission
  	-- category must be set.
  	IF p_course_cd IS NULL OR
  			p_version_number IS NULL OR
  			p_cal_type IS NULL OR
  			p_admission_cat IS NULL THEN
		p_message_name := 'IGS_AD_DETERMINE_VALID_PRG';
  		RETURN FALSE;
  	END IF;
  	-- Validate the course offering option is mapped to the admission category
  	FOR v_cooac_rec IN c_cooac LOOP
  		-- Restrict the course offering option admission category records
  		-- to match on optional input parameters.
  		IF (p_location_cd IS NULL OR
  				v_cooac_rec.location_cd = p_location_cd) AND
  				(p_attendance_mode IS NULL OR
  				v_cooac_rec.attendance_mode = p_attendance_mode) AND
  				(p_attendance_type IS NULL OR
  				v_cooac_rec.attendance_type = p_attendance_type) THEN
  			-- There is an admission category match for the course offering option.
  			v_adm_cat_match := TRUE;
  		END IF;
  	END LOOP;
  	IF v_adm_cat_match THEN
  		RETURN TRUE;
  	END IF;
  	-- If this point is reached, there must have been no admission
  	-- category match for the course offering option.
	p_message_name := 'IGS_AD_PRGOFR_OPTION_NOTVALID';
  	RETURN FALSE;
  END;
  END admp_val_coo_adm_cat;
  --
  -- Validate course application to an admission period.
  FUNCTION admp_val_coo_admperd(
    p_adm_cal_type IN VARCHAR2 ,
    p_adm_ci_sequence_number IN NUMBER ,
    p_admission_cat IN VARCHAR2 ,
    p_s_admission_process_type IN VARCHAR2 ,
    p_course_cd IN VARCHAR2 ,
    p_version_number IN NUMBER ,
    p_acad_cal_type IN VARCHAR2 ,
    p_location_cd IN VARCHAR2 ,
    p_attendance_mode IN VARCHAR2 ,
    p_attendance_type IN VARCHAR2 ,
    p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN 	-- admp_val_coo_admperd
  	-- Validate that the course offering option is available for entry in
  	-- the admission period
  DECLARE
  	v_record_found		BOOLEAN DEFAULT FALSE;
  	CURSOR c_apcoo_adm (
  			cp_adm_cal_type			IGS_AD_PRD_PS_OF_OPT.adm_cal_type%TYPE,
  			cp_adm_ci_sequence_number
  							IGS_AD_PRD_PS_OF_OPT.adm_ci_sequence_number%TYPE,
  			cp_admission_cat			IGS_AD_PRD_PS_OF_OPT.admission_cat%TYPE,
  			cp_s_admission_process_type
  							IGS_AD_PRD_PS_OF_OPT.s_admission_process_type%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_AD_PRD_PS_OF_OPT apcoo
  		WHERE	apcoo.adm_cal_type		= cp_adm_cal_type AND
  			apcoo.adm_ci_sequence_number	= cp_adm_ci_sequence_number AND
  			apcoo.admission_cat		= cp_admission_cat AND
  			apcoo.s_admission_process_type	= cp_s_admission_process_type;
  	CURSOR c_adm_perd_course_off_opt (
  			cp_adm_cal_type			IGS_AD_PRD_PS_OF_OPT.adm_cal_type%TYPE,
  			cp_adm_ci_sequence_number
  							IGS_AD_PRD_PS_OF_OPT.adm_ci_sequence_number%TYPE,
  			cp_admission_cat			IGS_AD_PRD_PS_OF_OPT.admission_cat%TYPE,
  			cp_s_admission_process_type
  							IGS_AD_PRD_PS_OF_OPT.s_admission_process_type%TYPE,
  			cp_course_cd			IGS_PS_OFR_OPT.course_cd%TYPE,
  			cp_version_number		IGS_PS_OFR_OPT.version_number%TYPE,
  			cp_acad_cal_type		IGS_PS_OFR_OPT.cal_type%TYPE) IS
  		SELECT	apcoo.location_cd,
  			apcoo.attendance_mode,
  			apcoo.attendance_type
  		FROM	IGS_AD_PRD_PS_OF_OPT apcoo
  		WHERE	apcoo.adm_cal_type		= cp_adm_cal_type AND
  			apcoo.adm_ci_sequence_number	= cp_adm_ci_sequence_number AND
  			apcoo.admission_cat		= cp_admission_cat AND
  			apcoo.s_admission_process_type	= cp_s_admission_process_type AND
  			apcoo.course_cd			= cp_course_cd AND
  			apcoo.version_number		= cp_version_number AND
  			apcoo.acad_cal_type		= cp_acad_cal_type;
  BEGIN
  	p_message_name := null;
  	-- If there are no adm_perd_course_off_option for the admission period
  	-- then return TRUE
  	FOR v_apcoo_adm_rec IN c_apcoo_adm(
  					p_adm_cal_type,
  					p_adm_ci_sequence_number,
  					p_admission_cat,
  					p_s_admission_process_type) LOOP
  		v_record_found := TRUE;
  	END LOOP;
  	IF(v_record_found = FALSE) THEN
  		p_message_name := null;
  		RETURN TRUE;
  	ELSE
  		v_record_found := FALSE;
  	END IF;
  	-- Get course offering options for the admission period and course
  	FOR v_adm_perd_course_off_opt_rec IN c_adm_perd_course_off_opt(
  								p_adm_cal_type,
  								p_adm_ci_sequence_number,
  								p_admission_cat,
  								p_s_admission_process_type,
  								p_course_cd,
  								p_version_number,
  								p_acad_cal_type) LOOP
  		v_record_found := TRUE;
  		IF(v_adm_perd_course_off_opt_rec.location_cd IS NULL) THEN
  			IF(v_adm_perd_course_off_opt_rec.attendance_mode IS NULL) THEN
  				IF(v_adm_perd_course_off_opt_rec.attendance_type IS NULL OR
  						(v_adm_perd_course_off_opt_rec.attendance_type = p_attendance_type)) THEN
  					-- Valid match
  					RETURN TRUE;
  				END IF;
  			ELSE
  				IF(v_adm_perd_course_off_opt_rec.attendance_mode = p_attendance_mode AND
  						(v_adm_perd_course_off_opt_rec.attendance_type IS NULL OR
  						 v_adm_perd_course_off_opt_rec.attendance_type = p_attendance_type)) THEN
  					-- Valid match
  					RETURN TRUE;
  				END IF;
  			END IF;
  		ELSE
  			IF((v_adm_perd_course_off_opt_rec.location_cd = p_location_cd) AND
  					(v_adm_perd_course_off_opt_rec.attendance_mode IS NULL OR
  					 v_adm_perd_course_off_opt_rec.attendance_mode = p_attendance_mode) AND
  					(v_adm_perd_course_off_opt_rec.attendance_type IS NULL OR
  					 v_adm_perd_course_off_opt_rec.attendance_type = p_attendance_type)) THEN
  				-- Valid match
  				RETURN TRUE;
  			END IF;
  		END IF;
  	END LOOP;
  	IF(v_record_found = FALSE) THEN
  		-- This course must not be valid
		p_message_name := 'IGS_AD_PRGOFR_NO_ENTRY_POINT';
  		RETURN FALSE;
  	END IF;
  	-- No match
	p_message_name := 'IGS_AD_PRGOFR_NO_ENTRY_POINT';
  	RETURN FALSE;
  END;
  END admp_val_coo_admperd;
END IGS_AD_VAL_CRS_ADMPERD;

/
