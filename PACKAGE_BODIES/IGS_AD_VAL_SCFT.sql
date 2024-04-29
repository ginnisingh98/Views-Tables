--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_SCFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_SCFT" AS
/* $Header: IGSAD69B.pls 115.4 2002/11/28 21:39:32 nsidana ship $ */

-----------------------------------------------------------------------
--  Change History :
--  Who             When            What
-- avenkatR     30-AUG-2001     Remove procedure "crsp_Val_fs_closed"
-- avenkatr     30-AUG-2001     Remove procedure "crsp_Val_iud_crv_dtl"
-----------------------------------------------------------------------
  --
  -- Validate SCFT optional values unique across records
  FUNCTION admp_val_scft_uniq(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_scft_uniq
  	-- This module checks the combination of optional components of
  	-- IGS_AD_SBM_PS_FNTRGT is unique within submission, course and funding source.
  DECLARE
  	v_scft_count			NUMBER;
  	CURSOR	c_scft IS
  		SELECT	count(*)
  		FROM	IGS_AD_SBM_PS_FNTRGT
  		WHERE	submission_yr			= p_submission_yr AND
  			submission_number		= p_submission_number AND
  			course_cd 			= p_course_cd AND
  			crv_version_number 		= p_crv_version_number AND
  			funding_source 			= p_funding_source AND
  			NVL(location_cd, 'NULL') 	= NVL(p_location_cd, 'NULL') AND
  			NVL(attendance_mode, 'NULL')	= NVL(p_attendance_mode, 'NULL') AND
  			NVL(attendance_type, 'NULL')	= NVL(p_attendance_type, 'NULL') AND
  			NVL(unit_set_cd, 'NULL')	= NVL(p_unit_set_cd, 'NULL') AND
  			NVL(us_version_number, 0)	= NVL(p_us_version_number, 0);
  BEGIN
  	p_message_name := null;
  	OPEN c_scft;
  	FETCH c_scft INTO v_scft_count;
  	IF (c_scft%FOUND) AND
  	    v_scft_count > 1 THEN
  		CLOSE c_scft;
		p_message_name := 'IGS_AD_COMBINATION_UNIQUE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_scft;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_scft%ISOPEN THEN
  			CLOSE c_scft;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SCFT.admp_val_scft_uniq');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_scft_uniq;


  -- Validate crs fund target course version in a valid course off pattern
  FUNCTION admp_val_scft_cop(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_scft_cop
  	-- This module validates the IGS_PS_VER component of IGS_AD_SBM_PS_FNTRGT
  	-- exists and is offered within a IGS_PS_OFR_PAT that is in the
  	-- academic period of the submission period.
  DECLARE
  	v_cop		VARCHAR2(1);
  	CURSOR	c_cop IS
  		SELECT	'x'
  		FROM 	IGS_PS_OFR_PAT cop,
    			IGS_ST_GVTSEMLOAD_CA gslc,
     			IGS_CA_INST_REL cir
  		WHERE  	gslc.submission_yr	= p_submission_yr AND
     			gslc.submission_number	= p_submission_number AND
     			cop.course_cd 		= p_course_cd AND
     			cop.version_number	= p_crv_version_number AND
     			(cop.offered_ind 	= 'Y'  OR
     			cop.enrollable_ind 	= 'Y') AND
     			cop.cal_type 		= cir.sup_cal_type AND
     			cop.ci_sequence_number	= cir.sup_ci_sequence_number AND
     			gslc.cal_type		= cir.sub_cal_type AND
     			gslc.ci_sequence_number	= cir.sub_ci_sequence_number;
  BEGIN
  	p_message_name := null;
  	OPEN c_cop;
  	FETCH c_cop INTO v_cop;
  	IF (c_cop%NOTFOUND) THEN
  		CLOSE c_cop;
		p_message_name := 'IGS_AD_PRG_VERSION_DETAILS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cop;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_cop%ISOPEN THEN
  			CLOSE c_cop;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SCFT.admp_val_scft_cop');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_scft_cop;

  --
  -- Validate crs fund target funding source is within restriction
  FUNCTION admp_val_scft_fs(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_scft_fs
  	-- This module validates that the funding_source for the IGS_AD_SBM_PS_FNTRGT
  	-- complies with any IGS_FI_FND_SRC_RSTN.
  DECLARE
  	v_fsr			VARCHAR2(1);
  	CURSOR	c_fsr (
  		cp_funding_source	IGS_AD_SBM_PS_FNTRGT.funding_source%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_FI_FND_SRC_RSTN
  		WHERE	course_cd		= p_course_cd AND
  			version_number		= p_crv_version_number AND
  			restricted_ind		= 'Y' AND
  			(cp_funding_source 	IS NULL OR
  			funding_source		= cp_funding_source);
  BEGIN
  	p_message_name := null;
  	OPEN c_fsr(
  		NULL);
  	FETCH c_fsr INTO v_fsr;
  	IF (c_fsr%FOUND) THEN
  		CLOSE c_fsr;
  		OPEN c_fsr(
  			p_funding_source);
  		FETCH c_fsr INTO v_fsr;
  		IF (c_fsr%NOTFOUND) THEN
  			CLOSE c_fsr;
			p_message_name := 'IGS_AD_FUNDING_SRC_RESTRICTIO';
  			RETURN FALSE;
  		ELSE
  			CLOSE c_fsr;
  		END IF;
  	ELSE
  		CLOSE c_fsr;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_fsr%ISOPEN THEN
  			CLOSE c_fsr;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	   Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SCFT.admp_val_scft_fs');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_scft_fs;

  --
  -- Validate crs fund target IGS_PS_UNIT set in a valid course offering IGS_PS_UNIT set
  FUNCTION admp_val_scft_cous(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_scft_cous
  	-- This module validates the IGS_EN_UNIT_SET component of IGS_AD_SBM_PS_FNTRGT
  	-- does not have a system status of 'INACTIVE' and maps to at least one
  	-- course_offering_unot_set or IGS_PS_OF_OPT_UNT_ST.
  DECLARE
  	v_coousv		VARCHAR2(1);
  	cst_inactive		CONSTANT IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE := 'INACTIVE';
  	CURSOR	c_coousv IS
  		SELECT 	'x'
  		FROM	IGS_PS_OFR_OPT_UNIT_SET_V coousv,
  			IGS_EN_UNIT_SET us,
  			IGS_EN_UNIT_SET_STAT uss
  		WHERE  	coousv.unit_set_cd 		= p_unit_set_cd AND
     			coousv.us_version_number	= p_us_version_number AND
     			coousv.course_cd 		= p_course_cd AND
     			coousv.crv_version_number 	= p_crv_version_number AND
     			coousv.location_cd 		LIKE NVL(p_location_cd, '%') AND
     			coousv.attendance_mode 		LIKE NVL(p_attendance_mode, '%') AND
     			coousv.attendance_type 		LIKE NVL(p_attendance_type, '%') AND
  			us.unit_set_cd 			= coousv.unit_set_cd AND
  			us.version_number 		= coousv.us_version_number AND
  			uss.unit_set_status 		= us.unit_set_status AND
  			uss.s_unit_set_status 		<> cst_inactive;
  BEGIN
  	p_message_name := null;
  	IF p_unit_set_cd IS NULL AND
  	    p_us_version_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_coousv;
  	FETCH c_coousv INTO v_coousv;
  	IF (c_coousv%NOTFOUND) THEN
  		CLOSE c_coousv;
		p_message_name := 'IGS_AD_UNIT_SET_DOESNOT_EXIST';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_coousv;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_coousv%ISOPEN THEN
  			CLOSE c_coousv;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SCFT.admp_val_scft_cous');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_scft_cous;

  --
  -- Validate crs fund target detail in a valid course offering pattern
  FUNCTION admp_val_scft_dtl(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_scft_dtl
  	-- This module validates the location_cd/attendance_mode/attendance_type are in
  	-- at least one enrollable or offered IGS_PS_OFR_PAT for the academic
  	-- period of the submission period.
  DECLARE
  	v_cop			VARCHAR2(1);
  	CURSOR	c_cop IS
  		SELECT 	'x'
  		FROM 	IGS_PS_OFR_PAT cop,
  			IGS_ST_GVTSEMLOAD_CA gslc,
  			IGS_CA_INST_REL cir
  		WHERE  	gslc.submission_yr 	= p_submission_yr AND
     			gslc.submission_number	= p_submission_number AND
     			cop.course_cd 		= p_course_cd AND
     			cop.version_number 	= p_crv_version_number AND
  			(cop.offered_ind 	= 'Y'  OR
     			cop.enrollable_ind 	= 'Y') AND
     			cop.cal_type 		= cir.sup_cal_type AND
     			cop.ci_sequence_number 	= cir.sup_ci_sequence_number AND
     			gslc.cal_type 		= cir.sub_cal_type AND
     			gslc.ci_sequence_number = cir.sub_ci_sequence_number AND
  			cop.location_cd 	LIKE NVL(p_location_cd, '%') AND
    			cop.attendance_mode 	LIKE NVL(p_attendance_mode, '%') AND
     			cop.attendance_type 	LIKE NVL(p_attendance_type, '%');
  BEGIN
  	p_message_name := null;
  	OPEN c_cop;
  	FETCH c_cop INTO v_cop;
  	IF (c_cop%NOTFOUND) THEN
  		CLOSE c_cop;
		p_message_name := 'IGS_AD_COMBINATION_DOESNOT_EX';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cop;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_cop%ISOPEN THEN
  			CLOSE c_cop;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SCFT.admp_val_scft_dtl');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_scft_dtl;
END IGS_AD_VAL_SCFT;

/
