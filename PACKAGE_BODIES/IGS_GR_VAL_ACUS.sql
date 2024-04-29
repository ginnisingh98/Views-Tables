--------------------------------------------------------
--  DDL for Package Body IGS_GR_VAL_ACUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VAL_ACUS" AS
/* $Header: IGSGR03B.pls 115.4 2002/11/29 00:39:50 nsidana ship $ */
  --
  -- Validate if the award ceremony unit set group is closed
  FUNCTION grdp_val_acusg_close(
  p_grd_cal_type  IGS_GR_AWD_CRM_US_GP.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRM_US_GP.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CRM_US_GP.ceremony_number%TYPE ,
  p_award_course_cd  IGS_GR_AWD_CRM_US_GP.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CRM_US_GP.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CRM_US_GP.award_cd%TYPE ,
  p_us_group_number  IGS_GR_AWD_CRM_US_GP.us_group_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_acusg_close
  	-- Description: Validate if the award ceremony unit set group is closed
  DECLARE
  	v_acusg_rec		IGS_GR_AWD_CRM_US_GP.closed_ind%TYPE;
  	CURSOR	c_acusg IS
  		SELECT	acusg.closed_ind
  		FROM	IGS_GR_AWD_CRM_US_GP 	acusg
  		WHERE	acusg.grd_cal_type		= p_grd_cal_type and
  			acusg.grd_ci_sequence_number 	= p_grd_ci_sequence_number and
  			acusg.ceremony_number 		= p_ceremony_number and
  			acusg.award_course_cd 		= p_award_course_cd and
  			acusg.award_crs_version_number 	=p_award_crs_version_number and
  			acusg.award_cd			= p_award_cd and
  			acusg.us_group_number 		= p_us_group_number and
  			acusg.closed_ind 		='Y';
  BEGIN
  	p_message_name := NULL;
  	IF p_grd_cal_type IS NULL OR
    			p_grd_ci_sequence_number IS NULL OR
    			p_ceremony_number IS NULL OR
     			p_award_course_cd IS NULL OR
  	 		p_award_crs_version_number IS NULL OR
     			p_award_cd IS NULL OR
     			p_us_group_number iS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_acusg;
  	FETCH c_acusg INTO v_acusg_rec;
  	IF (c_acusg%FOUND) THEN
  		CLOSE c_acusg;
  		p_message_name := 'IGS_GR_AWD_CERM_GRP_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_acusg;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_acusg%ISOPEN) THEN
  			CLOSE c_acusg;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_acusg_close;
  --
  -- Validate the award ceremony unit set has related unit set attempts
  FUNCTION grdp_val_acus_susa(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_acus_susa
  	-- Description: Warn the user if no primary student_unit_set_attempt records
  	-- exist for the specified unit_set_cd and us_version_number.  WARNING ONLY
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_susa IS
  		SELECT	'X'
  		FROM	IGS_AS_SU_SETATMPT	susa
  		WHERE	susa.unit_set_cd		= p_unit_set_cd AND
  			susa.us_version_number		= p_us_version_number AND
  			susa.primary_set_ind		= 'Y';
  BEGIN
  	p_message_name := NULL;
  	IF p_unit_set_cd IS NULL OR
  			p_us_version_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_susa;
  	FETCH c_susa INTO v_dummy;
  	IF (c_susa%NOTFOUND) THEN
  		CLOSE c_susa;
  		p_message_name := 'IGS_GR_NO_STUD_UNIT_EXISTS';
  		RETURN TRUE;
  	END IF;
  	CLOSE c_susa;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_acus_susa;
  --
  -- Validate if the award ceremony is closed.
  FUNCTION grdp_val_awc_closed(
  p_grd_cal_type  IGS_GR_AWD_CEREMONY_ALL.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CEREMONY_ALL.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CEREMONY_ALL.ceremony_number%TYPE ,
  p_award_course_cd  IGS_GR_AWD_CEREMONY_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CEREMONY_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CEREMONY_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_awc_closed
  	-- Description: Validate if the award ceremony is closed
  DECLARE
  	v_awc_rec		IGS_GR_AWD_CEREMONY.closed_ind%TYPE;
  	CURSOR	c_awc IS
  		SELECT	'X'
  		FROM	IGS_GR_AWD_CEREMONY			awc
  		WHERE	awc.grd_cal_type		= p_grd_cal_type 	AND
  			awc.grd_ci_sequence_number 	= p_grd_ci_sequence_number AND
  			awc.ceremony_number 		= p_ceremony_number AND
  			NVL(awc.award_course_cd, 'NULL')= NVL(p_award_course_cd, 'NULL') AND
  			NVL(awc.award_crs_version_number, 0) =
  					NVL(p_award_crs_version_number, 0) AND
  			awc.award_cd			= p_award_cd AND
  			awc.closed_ind			= 'Y';
  BEGIN
  	p_message_name := NULL;
  	IF p_grd_cal_type IS NULL OR
     			p_grd_ci_sequence_number IS NULL OR
     			p_ceremony_number IS NULL OR
     			p_award_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_awc;
  	FETCH c_awc INTO v_awc_rec;
  	IF (c_awc%FOUND) THEN
  		CLOSE c_awc;
  		p_message_name := 'IGS_GR_AWD_CERM_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_awc;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_awc%ISOPEN) THEN
  			CLOSE c_awc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_awc_closed;
  --
  -- Validate the unit set has related course offering unit set records
  FUNCTION grdp_val_crv_us(
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_crv_us
  	-- Check if that the award_ceremony_unit_set.unit_set_cd and
  	--us_version_number is related to the award_ceremony.award_course_cd and
  	--award_crs_version_number.
  DECLARE
  	v_exists		VARCHAR2(1);
  	CURSOR c_us IS
  		SELECT	'x'
  		FROM	IGS_EN_UNIT_SET			us
  		WHERE	us.unit_set_cd		= p_unit_set_cd AND
  			us.version_number		= p_us_version_number AND
  			us.administrative_ind	= 'N';
  	CURSOR c_cous IS
  		SELECT	'x'
  		FROM	IGS_PS_OFR_UNIT_SET	cous
  		WHERE	cous.course_cd		= p_award_course_cd		AND
  			cous.crv_version_number	= p_award_crs_version_number	AND
  			cous.unit_set_cd	= p_unit_set_cd			AND
  			cous.us_version_number	= p_us_version_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters :
  	If p_award_course_cd IS NULL OR
  			p_award_crs_version_number	IS NULL OR
  			p_unit_set_cd			IS NULL OR
  			p_us_version_number		IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	--2. Check that the unit_set is not an adminidtraive unit set.
  	OPEN c_us;
  	FETCH c_us INTO v_exists;
  	IF c_us%NOTFOUND THEN
  		CLOSE c_us;
  		p_message_name := 'IGS_GR_ADM_UNIT_SET_NOT_ALLOW';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_us;
  	--3. Check that a course_offering_unit_set record exists for the supplied
  	--award_course_cd, award_crs_version_number, unit_set_cd and
  	--us_version_number.
  	OPEN c_cous;
  	FETCH c_cous INTO v_exists;
  	IF c_cous%NOTFOUND THEN
  		CLOSE c_cous;
  		p_message_name := 'IGS_GR_UNIT_SET_NOT_OFFERED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cous;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_us%ISOPEN THEN
  			CLOSE c_us;
  		END IF;
  		IF c_cous%ISOPEN THEN
  			CLOSE c_cous;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_crv_us;
END IGS_GR_VAL_ACUS;

/
