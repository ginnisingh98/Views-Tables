--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_UAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_UAI" AS
/* $Header: IGSAS34B.pls 120.0 2005/07/05 11:41:37 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- DDEY       02-Jan-2001    Bug # 2162831 . FUNCTION assp_val_unit_sec_uniqref is added.
  --smadathi    24-AUG-2001     Bug No. 1956374 .Removed references to duplicate
  --                            function GENP_VAL_SDTT_SESS
  -------------------------------------------------------------------------------------------
  -- Validate assessment item exists
  FUNCTION assp_val_ai_exists(
  p_ass_id IN IGS_AS_ASSESSMNT_ITM_ALL.ass_id%TYPE ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail			VARCHAR2(255);
  BEGIN	-- assp_val_ai_exists
  	--Validate that the assessment item exists.
  DECLARE
  	CURSOR c_ai (
  			cp_ass_id		IGS_AS_ASSESSMNT_ITM.ass_id%TYPE) IS
  		SELECT	COUNT(*)
  		FROM	IGS_AS_ASSESSMNT_ITM
  		WHERE	ass_id = cp_ass_id;
  	v_ai_count				NUMBER;
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	-- Cursor handling
  	OPEN c_ai(
  			p_ass_id);
  	FETCH c_ai INTO v_ai_count;
  	CLOSE c_ai;
  	IF (v_ai_count = 0) THEN
  		P_MESSAGE_NAME := 'IGS_GE_VAL_DOES_NOT_XS';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		NULL; --FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                --APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_ai_exists;
  --

  -- Validate IGS_PS_UNIT mode closed indicator.
  FUNCTION crsp_val_um_closed(
  p_unit_mode IN IGS_AS_UNIT_MODE.unit_mode%TYPE ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- crsp_val_um_closed
  	-- Validate the IGS_AS_UNIT_MODE closed indicator
  DECLARE
  	CURSOR c_um(
  			cp_unit_mode	IGS_AS_UNIT_MODE.unit_mode%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AS_UNIT_MODE
  		WHERE	unit_mode = cp_unit_mode;
  	v_um_rec			c_um%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	-- Cursor handling
  	OPEN c_um(
  			p_unit_mode);
  	FETCH c_um INTO v_um_rec;
  	IF c_um%NOTFOUND THEN
  		CLOSE c_um;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_um;
  	IF (v_um_rec.closed_ind = cst_yes) THEN
  		P_MESSAGE_NAME := 'IGS_PS_UNITMODE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;

  END crsp_val_um_closed;
  --
  -- Validate IGS_PS_UNIT class closed indicator.
  FUNCTION crsp_val_ucl_closed(
  p_unit_class IN IGS_AS_UNIT_CLASS_ALL.unit_class%TYPE ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- crsp_val_ucl_closed
  	-- Validate the IGS_PS_UNIT class closed indicator
  DECLARE
  	CURSOR c_ucl(
  			cp_unit_class	IGS_AS_UNIT_CLASS.unit_class%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AS_UNIT_CLASS
  		WHERE	unit_class = cp_unit_class;
  	v_ucl_rec		c_ucl%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	-- Cursor handling
  	OPEN c_ucl(
  			p_unit_class);
  	FETCH c_ucl INTO v_ucl_rec;
  	IF c_ucl%NOTFOUND THEN
  		CLOSE c_ucl;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ucl;
  	IF (v_ucl_rec.closed_ind = cst_yes) THEN
  		P_MESSAGE_NAME := 'IGS_PS_UNITCLASS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END crsp_val_ucl_closed;
  --
  -- Validate IGS_PS_UNIT assessment item links for invalid combinations.
  FUNCTION assp_val_uai_links(
  p_unit_cd IN IGS_AS_UNITASS_ITEM_ALL.unit_cd%TYPE ,
  p_version_number IN IGS_AS_UNITASS_ITEM_ALL.version_number%TYPE ,
  p_cal_type IN IGS_AS_UNITASS_ITEM_ALL.cal_type%TYPE ,
  p_ci_sequence_number IN IGS_AS_UNITASS_ITEM_ALL.ci_sequence_number%TYPE ,
  p_ass_id IN IGS_AS_UNITASS_ITEM_ALL.ass_id%TYPE ,
  p_sequence_number IN IGS_AS_UNITASS_ITEM_ALL.sequence_number%TYPE ,
  p_location_cd IN VARCHAR2,
  p_unit_mode IN IGS_AS_UNIT_MODE.unit_mode%TYPE,
  p_unit_class IN  IGS_AS_UNIT_CLASS_ALL.unit_class%TYPE,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- assp_val_uai_links
--ijeddy, Bug 3201661, Grade Book. Obsoleted
        RETURN TRUE;
  END assp_val_uai_links;
  --
  -- Generic links validation routine.
  -- Validate that date is not after the assessment variation cutoff date.
  FUNCTION ASSP_VAL_CUTOFF_DT(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_cutoff_dt
  	-- Validate that it is possible to alter assessment items for a teaching period
  	-- provided the efffective date is before the cutoff date.
  DECLARE
  	cst_one				CONSTANT  NUMBER := 1;
  	v_ass_item_cutoff_dt_alias		IGS_AS_CAL_CONF.ass_item_cutoff_dt_alias%TYPE;
  	v_alias_val				IGS_CA_DA_INST_V.alias_val%TYPE;
  	CURSOR c_sacc IS
  		SELECT	ass_item_cutoff_dt_alias
  		FROM	IGS_AS_CAL_CONF
  		WHERE	s_control_num 	= cst_one;
  	CURSOR c_daiv(
  			cp_cal_type		IGS_EN_SU_ATTEMPT.cal_type%TYPE,
  			cp_ci_sequence_number	IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
  			cp_dt_alias			IGS_AS_CAL_CONF.ass_item_cutoff_dt_alias%TYPE) IS
  		SELECT	alias_val
  		FROM	IGS_CA_DA_INST_V
  		WHERE	cal_type 		= cp_cal_type AND
  			ci_sequence_number 	= cp_ci_sequence_number AND
  			dt_alias 		= cp_dt_alias
  		ORDER BY alias_val DESC;
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	-- Determine the date alias for the assessment item variation cutoff date.
  	OPEN c_sacc;
  	FETCH c_sacc INTO v_ass_item_cutoff_dt_alias;
  	IF c_sacc%NOTFOUND THEN
  		CLOSE c_sacc;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sacc;
  	IF (v_ass_item_cutoff_dt_alias IS NULL) THEN
  		P_MESSAGE_NAME := null;
  		RETURN TRUE;
  	END IF;
  	-- Determine the latest date alias instance within the teaching period and
  	-- verify that the effective date is less than the date alias instance value.
  	OPEN c_daiv(
  			p_cal_type,
  			p_ci_sequence_number,
  			v_ass_item_cutoff_dt_alias);
  	FETCH c_daiv INTO v_alias_val;
  	IF c_daiv%NOTFOUND THEN
  		CLOSE c_daiv;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_daiv;
  	IF (p_effective_dt > v_alias_val) THEN
  		P_MESSAGE_NAME := 'IGS_AS_NOTALTER_ASSITEM_DET';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		NULL; --FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                --APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_cutoff_dt;
  --
  -- Validate Calendar Instance for IGS_PS_COURSE Information.
  FUNCTION CRSP_VAL_CRS_CI(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	cst_active	CONSTANT VARCHAR2(8) := 'ACTIVE';
  	v_s_cal_status	IGS_CA_STAT.s_cal_status%TYPE;
  	CURSOR 	c_cal_status(
  			cp_cal_type IGS_CA_INST.cal_type%TYPE,
  			cp_ci_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
  		SELECT 	IGS_CA_STAT.s_cal_status
  		FROM	IGS_CA_INST, IGS_CA_STAT
  		WHERE	IGS_CA_INST.cal_type = cp_cal_type AND
  			IGS_CA_INST.sequence_number = cp_ci_sequence_number AND
  			IGS_CA_INST.cal_status = IGS_CA_STAT.cal_status;
  	v_other_detail	VARCHAR2(255);
  BEGIN
  	P_MESSAGE_NAME := null;
  	OPEN c_cal_status(
  			p_cal_type,
  			p_ci_sequence_number);
  	FETCH c_cal_status INTO v_s_cal_status;
  	CLOSE c_cal_status;
  	IF (v_s_cal_status = cst_active) THEN
  		RETURN TRUE;
  	ELSE
  		P_MESSAGE_NAME := 'IGS_PS_CAL_MUSTBE_ACTIVE';
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
  		NULL; --FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                --APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crs_ci;
  --
  -- Validate IGS_PS_UNIT Offering Calendar Type.
  FUNCTION crsp_val_uo_cal_type(
  p_cal_type IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	v_other_detail		VARCHAR2(255);
  	v_cal_type_rec		IGS_CA_TYPE%ROWTYPE;
  	CURSOR c_cal_type IS
  		SELECT *
  		FROM IGS_CA_TYPE
  		WHERE cal_type	= p_cal_type;
  BEGIN
  	P_MESSAGE_NAME := null;
  	OPEN c_cal_type;
  	FETCH c_cal_type INTO v_cal_type_rec;
  	IF (c_cal_type%NOTFOUND) THEN
  		CLOSE c_cal_type;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cal_type;
  	-- Test cal_cat.closed_ind
  	IF (v_cal_type_rec.closed_ind <> 'N') THEN
  		P_MESSAGE_NAME := 'IGS_CA_CALTYPE_CLOSED';
  		RETURN FALSE;
  	-- Test cal_cat.SI_CA_S_CA_CAT

  	ELSIF (v_cal_type_rec.s_cal_cat <> 'TEACHING') THEN
  		P_MESSAGE_NAME := 'IGS_PS_CAL_CATEGORY_TEACHING';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;

  END crsp_val_uo_cal_type;
  --
  -- Retrofitted
  FUNCTION assp_val_uai_uniqref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uai_uniqref
  	-- Validate reference number is unique within a IGS_PS_UNIT offering pattern for
  	-- examinable items
  DECLARE
  	CURSOR c_uai IS
  		SELECT	'x'
  		FROM	IGS_AS_ASSESSMNT_TYP		atyp,
  			IGS_AS_ASSESSMNT_ITM		ai,
  			IGS_AS_UNITASS_ITEM	uai
  		WHERE	atyp.examinable_ind 	= 'Y' AND
  			ai.assessment_type 	= atyp.assessment_type AND
  			uai.ass_id 		= ai.ass_id AND
  			uai.unit_cd 		= p_unit_cd AND
  			uai.version_number 	= p_version_number AND
  			uai.cal_type 		= p_cal_type AND
  			uai.ci_sequence_number 	= p_ci_sequence_number AND
  			uai.ass_id 		<> p_ass_id AND
  			uai.sequence_number 	<> p_sequence_number AND
  			NVL(uai.reference, 'NULL') = NVL(p_reference, 'NULL');
  	v_uai_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	-- Check for the existence of a record
  	OPEN c_uai;
  	FETCH c_uai INTO v_uai_exists;
  	IF c_uai%NOTFOUND THEN
  		CLOSE c_uai;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_uai;
  	-- Records have been found
  	P_MESSAGE_NAME := 'IGS_AS_REFCD_UAI_UNIQUE';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uai%ISOPEN THEN
  			CLOSE c_uai;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  			NULL; --FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                         --APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_uai_uniqref;

-- Added by DDEY as part of bug # 2162831 .
-- This function validate if the reference number is unique
-- within the Unit Section.

-- There are 2 cases for checking the Reference Number
-- Case 1: For examinable items Reference must be unique for each item .
-- Case 2: For non-examinable items of assessment type ASSIGNMENT, reference must be unique
-- for a particular assessment type associated with a unit offering pattern.

FUNCTION assp_val_unit_sec_uniqref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_unit_sec_uniqref
  	-- Validate reference number is unique within a IGS_PS_UNIT offering pattern for
  	-- examinable items
  DECLARE
  	CURSOR c_uai IS
           SELECT	'x'
  		FROM	IGS_AS_ASSESSMNT_TYP		atyp,
  			IGS_AS_ASSESSMNT_ITM		ai,
  			IGS_PS_UNITASS_ITEM	uai,
			IGS_PS_UNIT_OFR_OPT   uoo
  		WHERE	atyp.examinable_ind 	= 'Y' AND
			ai.assessment_type 	= atyp.assessment_type AND
  			uai.ass_id 		= ai.ass_id AND
                      	uoo.unit_cd 		= p_unit_cd AND
  			uoo.version_number 	= p_version_number AND
  			uoo.cal_type 		= p_cal_type AND
  			uoo.ci_sequence_number 	= p_ci_sequence_number AND
                      	uoo.uoo_id              = uai.uoo_id AND
			uai.ass_id 		<> p_ass_id AND
  			uai.sequence_number 	<> p_sequence_number AND
  			NVL(uai.reference, 'NULL') = NVL(p_reference, 'NULL');

  	v_uai_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	-- Check for the existence of a record
  	OPEN c_uai;
  	FETCH c_uai INTO v_uai_exists;
  	IF c_uai%NOTFOUND THEN
  		CLOSE c_uai;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_uai;
  	-- Records have been found
  	P_MESSAGE_NAME := 'IGS_PS_REFCD_UAI_UNIQUE';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uai%ISOPEN THEN
  			CLOSE c_uai;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  			NULL; --FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                         --APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_unit_sec_uniqref;


  --
  -- Retrofitted
  FUNCTION assp_val_uai_opt_ref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_assessment_type IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uai_opt_ref
  	-- Validate that the reference number (when it has been set)
  	-- is unique within an assessment type within a IGS_PS_UNIT offering
  	-- pattern for non-examinable items which have not been deleted.
  	-- This is similar to ASSP_VAL_UAI_UNIQREF except that:
  	-- * The routine validates non-examinable items as opposed
  	--   to examinable items
  	-- * Reference is optional
  	-- * Reference when set is unique within an assessment type and
  	--   only for items that have not been deleted
  DECLARE
  	CURSOR c_uai IS
  		SELECT	'x'
  		FROM	IGS_AS_UNITASS_ITEM	uai,
  			IGS_AS_ASSESSMNT_ITM		ai,
  			IGS_AS_ASSESSMNT_TYP		atyp
  		WHERE	atyp.examinable_ind 	= 'N' AND
  			atyp.ASSESSMENT_TYPE 	= p_assessment_type AND
  			atyp.ASSESSMENT_TYPE 	= ai.ASSESSMENT_TYPE AND
  			uai.ass_id 		= ai.ass_id AND
  			uai.unit_cd 		= p_unit_cd AND
  			uai.version_number 	= p_version_number AND
  			uai.cal_type 		= p_cal_type AND
  			uai.ci_sequence_number 	= p_ci_sequence_number AND
  			uai.ass_id		<> p_ass_id AND
  			uai.sequence_number 	<> p_sequence_number AND
  			uai.reference 		= p_reference AND
  			uai.logical_delete_dt 	IS NULL;
  	v_uai_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	IF p_reference IS NOT NULL THEN
  		-- Select from the table taking care not to select
  		-- record passed in.
  		OPEN c_uai;
  		FETCH c_uai INTO v_uai_exists;
  		IF c_uai%FOUND THEN
  			CLOSE c_uai;
  			P_MESSAGE_NAME := 'IGS_AS_REF_UAI_UNIQUE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_uai;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uai%ISOPEN THEN
  			CLOSE c_uai;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  			NULL; --FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                         --APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_uai_opt_ref;
  --
  -- Retrofitted

  --
  -- To validate the examination calendar type/sequence number of the uai
  FUNCTION ASSP_VAL_UAI_CAL(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_sequence_number IN NUMBER ,
  p_teach_cal_type IN VARCHAR2 ,
  p_teach_sequence_number IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN boolean IS
  BEGIN
  	Return TRUE;
  END;
  --
  -- Retrofitted
  FUNCTION assp_val_uai_sameref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uai_sameref
  	-- Validate reference number is the same for all items,
  	-- with the same assessment id, within a IGS_PS_UNIT offering pattern
  	-- for examinable items.
  DECLARE
  	CURSOR c_uai IS
  		SELECT	'x'
  		FROM	IGS_AS_ASSESSMNT_TYP		atyp,
  			IGS_AS_ASSESSMNT_ITM		ai,
  			IGS_AS_UNITASS_ITEM	uai
  		WHERE	atyp.examinable_ind 	= 'Y' AND
  			ai.assessment_type 	= atyp.assessment_type AND
  			uai.ass_id 		= ai.ass_id AND
  			uai.unit_cd 		= p_unit_cd AND
  			uai.version_number 	= p_version_number AND
  			uai.cal_type 		= p_cal_type AND
  			uai.ci_sequence_number 	= p_ci_sequence_number AND
  			uai.ass_id 		= p_ass_id AND
  			uai.sequence_number 	<> p_sequence_number AND
  			NVL(uai.reference, 'NULL') <> NVL(p_reference, 'NULL');
  	v_uai_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	-- Check for the existence of a record
  	OPEN c_uai;
  	FETCH c_uai INTO v_uai_exists;
  	IF c_uai%NOTFOUND THEN
  		CLOSE c_uai;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_uai;
  	-- Records have been found
  	P_MESSAGE_NAME := 'IGS_AS_REF_UAI_SAME';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uai%ISOPEN THEN
  			CLOSE c_uai;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  			NULL; --FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                         --APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_uai_sameref;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  -- Val IGS_PS_UNIT assess item applies to stud IGS_PS_UNIT IGS_AD_LOCATION, class and mode.
  FUNCTION ASSP_VAL_SUA_UAI(
  p_student_location_cd IN VARCHAR2 ,
  p_student_unit_class IN VARCHAR2 ,
  p_student_unit_mode IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 )
  RETURN CHAR IS
  	v_message_name 		VARCHAR2(30);
  BEGIN	-- assp_val_sua_uai
  	-- Validate that the IGS_AS_UNITASS_ITEM's IGS_AD_LOCATION, mode and class
  	-- are applicable for the student
--ijeddy, Bug 3201661, Grade Book.Obsoleted
  		RETURN 'TRUE';
  END assp_val_sua_uai;
  --
  -- Validate the IGS_PS_COURSE type for an assessment item against student IGS_PS_COURSE
  FUNCTION ASSP_VAL_SUA_AI_ACOT(
  p_ass_id IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
  RETURN VARCHAR2 IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_sua_ai_acot
  	-- Validate that if the assessment item is of an examinable type,
  	-- then validate if there exists IGS_AS_COURSE_TYPE records that restrict
  	-- the assessment item to particular IGS_PS_COURSE type for the student's IGS_PS_COURSE.
  DECLARE
  	cst_no			CONSTANT CHAR := 'N';
  	v_course_type		IGS_PS_VER.course_type%TYPE;
  	V_MESSAGE_NAME		VARCHAR2(30) := NULL;
  	CURSOR c_sua(	cp_person_id		IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  			cp_course_cd		IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  		SELECT	crv.course_type
  		FROM	IGS_EN_STDNT_PS_ATT sca,
  			IGS_PS_VER crv
  		WHERE	sca.person_id = cp_person_id AND
  			sca.course_cd = cp_course_cd AND
  			sca.course_cd = crv.course_cd AND
  			sca.version_number = crv.version_number;
  BEGIN
  	-- Cursor handling
  	OPEN c_sua(	p_person_id,
  			p_course_cd);
  	FETCH c_sua INTO v_course_type;
  	IF c_sua%NOTFOUND THEN
  		CLOSE c_sua;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_sua;
  	IF IGS_AS_VAL_SUAAI.assp_val_ai_acot(p_ass_id,
  					v_course_type,
  					V_MESSAGE_NAME) = TRUE THEN
  		RETURN 'TRUE';
  	ELSE
  		RETURN 'FALSE';
  	END IF;
  END;
  END assp_val_sua_ai_acot;
  --
  --
  -- Validate modification of IGS_PS_UNIT ass item does not conflict with uapi.
  FUNCTION ASSP_VAL_UAI_UAPI(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_id IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_old_location_cd IN VARCHAR2 ,
  p_old_unit_class IN VARCHAR2 ,
  p_old_unit_mode IN VARCHAR2 ,
  p_old_logical_delete_dt IN DATE ,
  p_new_location_cd IN VARCHAR2 ,
  p_new_unit_class IN VARCHAR2 ,
  p_new_unit_mode IN VARCHAR2 ,
  p_new_logical_delete_dt IN DATE ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uai_uapi
  	-- Validate that can update the IGS_AS_UNITASS_ITEM.
  	-- Modification is not allowed if :
  	-- logically deleting and the item belongs to a pattern. It must be removed
  	-- from the pattern first.
  	-- Updating IGS_AD_LOCATION, IGS_PS_UNIT mode or IGS_PS_UNIT class and the item belongs to a
  	-- pattern. The pattern IGS_AD_LOCATION, IGS_PS_UNIT mode or IGS_PS_UNIT class must be update
  	-- first or the item removed from the pattern(s).
        --stubbed by ijeddy for bug 3881046 on 22 Sept, 2004.
  	RETURN TRUE;
  END assp_val_uai_uapi;
END IGS_AS_VAL_UAI;

/
