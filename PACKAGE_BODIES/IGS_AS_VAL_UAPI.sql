--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_UAPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_UAPI" AS
/* $Header: IGSAS36B.pls 115.5 2002/11/28 22:48:17 nsidana ship $ */
  -- Val IGS_PS_UNIT offering option restrictions match at pattern and item level.
  FUNCTION ASSP_VAL_UAPI_UOO(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_ass_id IN NUMBER ,
  p_uai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uapi_uoo
  	-- This module validate that the IGS_AS_ASSESSMNT_ITM being assigned to the
  	-- IGS_AS_UNT_PATRN_ITM is valid for the IGS_PS_UNIT offering options that the
  	-- IGS_AS_UNTAS_PATTERN applies too. That is, the IGS_AD_LOCATION, mode and
  	-- class must be identical.
  DECLARE
  	cst_null	CONSTANT	VARCHAR2(4) := 'NULL';
  	v_uap_location_cd		IGS_AS_UNTAS_PATTERN.location_cd%TYPE;
  	v_uap_unit_class		IGS_AS_UNTAS_PATTERN.unit_class%TYPE;
  	v_uap_unit_mode			IGS_AS_UNTAS_PATTERN.unit_mode%TYPE;
  	v_uai_location_cd		IGS_AS_UNITASS_ITEM.location_cd%TYPE;
  	v_uai_unit_class		IGS_AS_UNITASS_ITEM.unit_class%TYPE;
  	v_uai_unit_mode			IGS_AS_UNITASS_ITEM.unit_mode%TYPE;
  	CURSOR	c_uap IS
  		SELECT 	uap.location_cd,
  			uap.unit_class,
  		      uap.unit_mode
  		FROM	IGS_AS_UNTAS_PATTERN uap
  		WHERE	uap.ass_pattern_id = p_ass_pattern_id;
  	CURSOR	c_uai IS
  		SELECT 	uai.location_cd,
  			uai.unit_class,
  		      uai.unit_mode
  		FROM	IGS_AS_UNITASS_ITEM uai
  		WHERE	uai.unit_cd 		= p_unit_cd 		AND
  			uai.version_number 	= p_version_number 	AND
  			uai.cal_type 		= p_cal_type 		AND
  			uai.ci_sequence_number 	= p_ci_sequence_number 	AND
  			uai.ass_id 		= p_ass_id 		AND
  			uai.sequence_number 	= p_uai_sequence_number;
  BEGIN
  	OPEN c_uap;
  	FETCH c_uap INTO 	v_uap_location_cd,
  				v_uap_unit_class,
  				v_uap_unit_mode;
  	IF (c_uap%NOTFOUND) THEN
  		CLOSE c_uap;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_uap;
  	OPEN c_uai;
  	FETCH c_uai INTO 	v_uai_location_cd,
  				v_uai_unit_class,
  				v_uai_unit_mode;
  	IF (c_uai%NOTFOUND) THEN
  		CLOSE c_uai;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_uai;
  	IF (NVL(v_uai_location_cd, cst_null) <> NVL(v_uap_location_cd, cst_null)) OR
  			(NVL(v_uai_unit_class, cst_null) <> NVL(v_uap_unit_class, cst_null)) OR
   			(NVL(v_uai_unit_mode, cst_null) <> NVL(v_uap_unit_mode, cst_null)) THEN
  		p_message_name := 'IGS_AS_LOCCD_UNITCLASS_UNITMO';
  		RETURN FALSE;
  	END IF;
  	 p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_uai%ISOPEN) THEN
  			CLOSE c_uai;
  		END IF;
  		IF (c_uap%ISOPEN) THEN
  			CLOSE c_uap;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AS_VAL_UAPI.ASSP_VAL_UAPI_UOO');
         Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_uapi_uoo;
  --
  -- Validate the to apportionment percentage does not exceed 100 for uap.
  FUNCTION ASSP_VAL_UAPI_AP(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uapi_ap
  DECLARE
  	v_total_apportionment_percent	NUMBER;
  	CURSOR c_uapi IS
  	SELECT	NVL(SUM(uapi.apportionment_percentage), 0)
  	FROM	IGS_AS_UNT_PATRN_ITM uapi
  	WHERE	uapi.unit_cd		= p_unit_cd 		AND
  		uapi.version_number	= p_version_number	AND
  		uapi.cal_type		= p_cal_type		AND
  		uapi.ci_sequence_number	= p_ci_sequence_number	AND
  		uapi.ass_pattern_id	= p_ass_pattern_id;
  BEGIN
  	-- Set the default message number
  	 p_message_name := null;
  	-- Cursor handling
  	OPEN c_uapi;
  	FETCH c_uapi INTO v_total_apportionment_percent;
  	IF c_uapi %NOTFOUND THEN
  		CLOSE c_uapi;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_uapi;
  	IF v_total_apportionment_percent > 100.00 THEN
  		--p_message_name := 'IGS_GR_SPECIFY_PRXY_AWD_PERS';
  		p_message_name := 'IGS_AS_PERC_APPORTION_EX_100';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uapi %ISOPEN THEN
  			CLOSE c_uapi;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AS_VAL_UAPI.IGS_AS_VAL_UAPI');
         Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_uapi_ap;
END IGS_AS_VAL_UAPI;

/
