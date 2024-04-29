--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_FSR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_FSR" AS
 /* $Header: IGSPS43B.pls 115.3 2002/11/29 03:04:00 nsidana ship $ */

  --
  -- Validate the funding source restriction restricted indicator.
  FUNCTION CRSP_VAL_FSR_RSTRCT(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	CURSOR c_count_all_fs IS
  		SELECT	COUNT(*)
  		FROM	IGS_FI_FND_SRC_RSTN
  		WHERE	course_cd = p_course_cd AND
  			version_number = p_version_number;
  	CURSOR c_count_restrct_fs IS
  		SELECT	COUNT(*)
  		FROM	IGS_FI_FND_SRC_RSTN
  		WHERE	course_cd = p_course_cd AND
  			version_number = p_version_number AND
  			restricted_ind = 'Y';
  BEGIN
  	--- Set default message number
  	p_message_name := NULL;
  	--- Get count for total and restricted funding source records
  	DECLARE
  		v_total_fs_count	NUMBER;
  		v_rstrct_fs_count	NUMBER;
  	BEGIN
  		OPEN c_count_all_fs;
  		FETCH c_count_all_fs INTO v_total_fs_count;
  		CLOSE c_count_all_fs;
  		OPEN c_count_restrct_fs;
  		FETCH c_count_restrct_fs INTO v_rstrct_fs_count;
  		CLOSE c_count_restrct_fs;
  		IF v_total_fs_count > 1 THEN
  			IF v_total_fs_count = v_rstrct_fs_count THEN
  				RETURN TRUE;
  			ELSE
  				p_message_name := 'IGS_PS_RESTIND_SET_FUNDSRC';
  				RETURN FALSE;
  			END IF;
  		ELSE
  			RETURN TRUE;
  		END IF;
  	END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_FSr.crsp_val_fsr_rstrct');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_fsr_rstrct;
  --
  -- Validate the funding source restriction indicators.
  FUNCTION crsp_val_fsr_inds(
  p_dflt_ind IN VARCHAR2 DEFAULT 'N',
  p_restricted_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  BEGIN
  	-- when both the default indicator and the
  	-- restricted indicator are set to 'N'
  	IF (p_dflt_ind = 'N' AND p_restricted_ind = 'N') THEN
  		--CLOSE c_fsr_indicators;
  		p_message_name := 'IGS_PS_FUNDSRC_REST_INDSET';
  		RETURN FALSE;
  	ELSE
  	-- when the default indicator and the
  	-- restricted indocator are both set to
  	-- something other than 'N'
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_FSr.crsp_val_fsr_inds');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END;
  END crsp_val_fsr_inds;
  --
  -- Validate the funding source restriction funding source.
  FUNCTION crsp_val_fsr_fnd_src(
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_FI_FUND_SRC.closed_ind%TYPE;
  	CURSOR	c_funding_source IS
  		SELECT closed_ind
  		FROM   IGS_FI_FUND_SRC
  		WHERE  funding_source = p_funding_source;
  BEGIN
  	OPEN c_funding_source;
  	FETCH c_funding_source INTO v_closed_ind;
  	IF c_funding_source%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_funding_source;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_funding_source;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_FUND_SOURCE_CLOSED';
  		CLOSE c_funding_source;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_FSr.crsp_val_fsr_fnd_src');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_fsr_fnd_src;
  --
  -- Validate the funding source restriction default indicator.
  FUNCTION crsp_val_fsr_default(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_funding_source_rest_rec	IGS_FI_FND_SRC_RSTN%ROWTYPE;
  	CURSOR	c_funding_source_rest IS
  		SELECT	*
  		FROM	IGS_FI_FND_SRC_RSTN
  		WHERE	course_cd 	= p_course_cd 		AND
  			version_number 	= p_version_number 	AND
  			dflt_ind 		= 'Y';
  BEGIN
  	OPEN c_funding_source_rest;
  	LOOP
  		FETCH c_funding_source_rest INTO v_funding_source_rest_rec;
  		EXIT WHEN c_funding_source_rest%NOTFOUND;
  	END LOOP;
  	IF (c_funding_source_rest%ROWCOUNT <= 1) THEN
  		-- none or one record is selected
  		CLOSE c_funding_source_rest;
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		-- more than one record is selected
  		CLOSE c_funding_source_rest;
  		p_message_name := 'IGS_PS_ONE_FUNDSRC_RESCT_MARK';
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_FSr.crsp_val_fsr_default');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_fsr_default;
END IGS_PS_VAL_FSr;

/
