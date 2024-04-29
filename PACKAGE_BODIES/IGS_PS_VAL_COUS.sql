--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_COUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_COUS" AS
/* $Header: IGSPS28B.pls 115.5 2002/11/29 03:00:29 nsidana ship $ */

  ----------------------------------------------------------------------------
  --  Change History :
  --  Who             When            What
  -- avenkatr     30-AUG-2001     Bug No 1956374. Removed procedure "crsp_val_iud_crv_dtl"
  -- avenkatr     30-AUG-2001     Bug No 1956374. Removed procedure "crsp_val_iud_uv_dtl"
  ----------------------------------------------------------------------------
  --
  -- Validate crs off IGS_PS_UNIT sets against IGS_PS_UNIT set IGS_PS_COURSE type restrictions
  FUNCTION crsp_val_cous_usctv(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_cous_usctv
  	-- This module validates the IGS_PS_OFR_UNIT_SET can only be linked
  	-- to IGS_PS_COURSE offerings which don't breach the IGS_EN_UNITSETPSTYPE
  	-- restrictions. That is, either no restrictions exist for the IGS_EN_UNIT_SET or
  	-- the IGS_PS_COURSE is of a type which is in the defined set.
  DECLARE
  	v_course_type		IGS_PS_VER.course_type%TYPE;
  	CURSOR c_crv IS
  		SELECT	crv.course_type
  		FROM	IGS_PS_VER	crv
  		WHERE	crv.course_cd		= p_course_cd AND
  			crv.version_number	= p_crv_version_number;
  	CURSOR c_usctv (
  		cp_course_type		IGS_PS_VER.course_type%TYPE) IS
  		SELECT	usctv.course_type
  		FROM	IGS_EN_UNIT_SET_COURSE_TYPE_V	usctv
  		WHERE	usctv.course_type	= cp_course_type AND
  			usctv.unit_set_cd	= p_unit_set_cd AND
  			usctv.version_number	= p_us_version_number;
  BEGIN
  	-- 1. Fetch the IGS_PS_COURSE type for the IGS_PS_OFR_UNIT_SET record
  	-- from its parent record
  	OPEN c_crv;
  	FETCH c_crv INTO v_course_type;
  	CLOSE c_crv;
  	-- 2. Check to see if IGS_PS_COURSE type is valid for the IGS_PS_UNIT set
  	OPEN c_usctv(
  		v_course_type);
  	FETCH c_usctv INTO v_course_type;
  	IF (c_usctv%FOUND) THEN
  		CLOSE c_usctv;
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_usctv;
  	p_message_name := 'IGS_PS_PRG_TYPE_INVALID';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_crv%ISOPEN) THEN
  			CLOSE c_crv;
  		END IF;
  		IF (c_usctv%ISOPEN) THEN
  			CLOSE c_usctv;
  		END IF;
 		App_Exception.Raise_Exception;
  END;
  END crsp_val_cous_usctv;
  --
  -- Validate crs off IGS_PS_UNIT set 'only as subordinate' indicator
  FUNCTION crsp_val_cous_subind(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_old_only_as_sub_ind IN VARCHAR2 DEFAULT 'N',
  p_new_only_as_sub_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_cous_subind
  	-- This module validates the only_as_sub_ind for a IGS_PS_OFR_UNIT_SET.
  	-- * It ensures that the indicator can not be changed from 'N' to 'Y' once
  	--   IGS_PS_OF_UNT_SET_RL records exist with the
  	--   IGS_PS_OFR_UNIT_SET as the superior.
  	-- * It ensures that the indicator can not be changed from 'N' to 'Y' once
  	--   IGS_PS_COO_AD_UNIT_S records exist for a IGS_PS_OF_OPT_AD_CAT for
  	--   a IGS_PS_OFR_OPT
  DECLARE
  	v_x	VARCHAR2(1);
  	CURSOR c_cousr IS
  		SELECT	'x'
  		FROM	IGS_PS_OF_UNT_SET_RL	cousr
  		WHERE	cousr.course_cd			= p_course_cd AND
  			cousr.crv_version_number	= p_crv_version_number AND
  			cousr.cal_type			= p_cal_type AND
  			cousr.sup_unit_set_cd		= p_unit_set_cd AND
  			cousr.sup_us_version_number	= p_us_version_number;
  	CURSOR c_cacus IS
  		SELECT	'x'
  		FROM	IGS_PS_COO_AD_UNIT_S		cacus
  		WHERE	cacus.course_cd			= p_course_cd AND
  			cacus.crv_version_number	= p_crv_version_number AND
  			cacus.cal_type			= p_cal_type AND
  			cacus.unit_set_cd		= p_unit_set_cd AND
  			cacus.us_version_number		= p_us_version_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_old_only_as_sub_ind = 'N' AND
  			p_new_only_as_sub_ind = 'Y' THEN
  		-- Validate against IGS_PS_OF_UNT_SET_RL
  		OPEN c_cousr;
  		FETCH c_cousr INTO v_x;
  		IF (c_cousr%FOUND) THEN
  			p_message_name := 'IGS_PS_SUBORD_INDICATOR_Y';
  			CLOSE c_cousr;
  			RETURN FALSE;
  		END IF;
  		CLOSE c_cousr;
  		-- Validate against IGS_PS_COO_AD_UNIT_S
  		OPEN c_cacus;
  		FETCH c_cacus INTO v_x;
  		IF (c_cacus%FOUND) THEN
  			CLOSE c_cacus;
  			p_message_name := 'IGS_PS_SUBORD_IND_NOTCHG_Y';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_cacus;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_cousr%ISOPEN) THEN
  			CLOSE c_cousr;
  		END IF;
  		IF (c_cacus%ISOPEN) THEN
  			CLOSE c_cacus;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  END crsp_val_cous_subind;
END IGS_PS_VAL_COus;

/
