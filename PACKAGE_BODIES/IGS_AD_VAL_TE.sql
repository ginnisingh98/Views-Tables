--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_TE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_TE" AS
/* $Header: IGSAD72B.pls 115.3 2002/11/28 21:40:17 nsidana ship $ */

  --
  -- Validate tertiary education IGS_OR_INSTITUTION details.
  FUNCTION admp_val_te_inst(
  p_institution_cd IN VARCHAR2 ,
  p_institution_name IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_te_inst
  	-- Validate IGS_AD_TER_EDU IGS_OR_INSTITUTION details
  DECLARE
  	v_local_inst_ind	IGS_OR_INSTITUTION.local_institution_ind%TYPE;
  	CURSOR c_institution IS
  		SELECT	local_institution_ind
  		FROM	IGS_OR_INSTITUTION
  		WHERE	institution_cd = p_institution_cd;
  BEGIN
  	p_message_name := null;
  	IF 	p_institution_cd IS NULL AND
  		p_institution_name IS NULL THEN
		p_message_name := 'IGS_AD_INSCD_INSNAME_SPECIFY';
  		RETURN FALSE;
  	END IF;
  	IF 	p_institution_cd IS NOT NULL AND
  		p_institution_name IS NOT NULL THEN
		p_message_name := 'IGS_AD_INSCD_OR_INSNAME_REQ';
  		RETURN FALSE;
  	END IF;
  	IF p_institution_cd IS NOT NULL THEN
  		OPEN c_institution;
  		FETCH c_institution INTO v_local_inst_ind;
  		IF (c_institution%FOUND) THEN
  			IF v_local_inst_ind = 'Y' THEN
  				CLOSE c_institution;
				p_message_name := 'IGS_AD_LOCALINS_INFO_TRTYEDU';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE c_institution;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_TE.admp_val_te_inst');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_te_inst;
  --
  -- Validate tertiary education enrolment years.
  FUNCTION admp_val_te_enr_yr(
  p_enrolment_first_yr IN NUMBER ,
  p_enrolment_latest_yr IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_te_enr_yr
  	-- Validate the IGS_AD_TER_EDU enrolment first and latest years.
  DECLARE
  BEGIN
  	p_message_name := null;
  	IF 	p_enrolment_first_yr IS NOT NULL	AND
  		p_enrolment_latest_yr IS NOT NULL	AND
  		p_enrolment_latest_yr < p_enrolment_first_yr THEN
		p_message_name := 'IGS_AD_ENR_LY_LE_ENR_FY';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_TE.admp_val_te_enr_yr');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_te_enr_yr;
  --
  -- Validate if IGS_AD_TER_ED_LV_COM.tertiary_edu_lvl_comp is closed.
  FUNCTION admp_val_telocclosed(
  p_tertiary_edu_lvl_comp IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--admp_val_telocclosed
  	--This module validates if IGS_AD_TER_ED_LV_COM.tertiary_edu_lvl_comp
  	--  is closed
  DECLARE
  	v_teloc_exists	VARCHAR2(1);
  	CURSOR c_teloc IS
  		SELECT 	'X'
  		FROM	IGS_AD_TER_ED_LV_COM teloc
  		WHERE	teloc.tertiary_edu_lvl_comp	= p_tertiary_edu_lvl_comp AND
  			teloc.closed_ind = 'Y';
  BEGIN
  	--Set the default message number
  	p_message_name := null;
  	--If the closed indicator is 'Y' then set p_message_name
  	OPEN c_teloc;
  	FETCH c_teloc INTO v_teloc_exists;
  	IF (c_teloc%FOUND) THEN
		p_message_name := 'IGS_AD_TRTYEDU_LOC_CLOSED';
  		CLOSE c_teloc;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_teloc;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_TE.admp_val_telocclosed');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_telocclosed;
  --
  -- Validate if IGS_AD_TER_ED_LVL_QF.tertiary_edu_lvl_qual is closed.
  FUNCTION admp_val_teloqclosed(
  p_tertiary_edu_lvl_qual IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--admp_val_teloqclosed
  	--This module validates if IGS_AD_TER_ED_LVL_QF.IGS_AD_TER_ED_LVL_QF
  	--  is closed
  DECLARE
  	v_teloq_exists	VARCHAR2(1);
  	CURSOR c_teloq IS
  		SELECT 	'X'
  		FROM	IGS_AD_TER_ED_LVL_QF teloq
  		WHERE	teloq.tertiary_edu_lvl_qual = p_tertiary_edu_lvl_qual AND
  			teloq.closed_ind = 'Y';
  BEGIN
  	--Set the default message number
  	p_message_name := null;
  	--If the closed indicator is 'Y' then set p_message_name
  	OPEN c_teloq;
  	FETCH c_teloq INTO v_teloq_exists;
  	IF (c_teloq%FOUND) THEN
		p_message_name := 'IGS_AD_TRTYEDU_LOQ_CLOSED';
  		CLOSE c_teloq;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_teloq;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_TE.admp_val_teloqclosed');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_teloqclosed;
END IGS_AD_VAL_TE;

/
