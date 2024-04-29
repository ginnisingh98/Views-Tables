--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ASE" AS
/* $Header: IGSAD43B.pls 115.4 2002/11/28 21:32:45 nsidana ship $ */
  -- result_obtained_yr is not null then score and ass_type are not null.
  FUNCTION ADMP_VAL_ASE_SCOREAT(
  p_result_obtained_yr IN NUMBER ,
  p_score IN NUMBER ,
  p_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_ase_scoreat
  	-- Validate that if the IGS_AD_AUS_SEC_EDU.result_obtained_yr is
  	-- not null then the IGS_AD_AUS_SEC_EDU.score and
  	-- IGS_AD_AUS_SEC_EDU.aus_scndry_edu_ass_type are also not null.
  DECLARE
  BEGIN
  	p_message_name := Null;
  	IF p_result_obtained_yr IS NOT NULL THEN
  		IF p_score IS NULL OR
  			p_aus_scndry_edu_ass_type IS NULL THEN
  			p_message_name := 'IGS_AD_YEAR_ASSTYPE_SPECIFIED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ASE.admp_val_ase_scoreat');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ase_scoreat;
  --
  -- Validate state_cd = ass_type.state_cd or ass_type.state_cd is null
  FUNCTION ADMP_VAL_ASE_ATSTATE(
  p_state_cd IN VARCHAR2 ,
  p_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_ase_atstate
  	-- Validate that the IGS_AD_AUS_SEC_EDU.state_cd is the same as the
  	-- IGS_AD_AUSE_ED_AS_TY.state_cd or that the
  	-- IGS_AD_AUSE_ED_AS_TY.state_cd is null.
  DECLARE
  	v_state_cd		IGS_AD_AUS_SEC_EDU.state_cd%TYPE	DEFAULT NULL;
  	CURSOR c_aseat IS
  		SELECT	state_cd
  		FROM	IGS_AD_AUSE_ED_AS_TY
  		WHERE	aus_scndry_edu_ass_type = p_aus_scndry_edu_ass_type;
  BEGIN
  	p_message_name := Null;
  	IF p_aus_scndry_edu_ass_type IS NOT NULL THEN
  		OPEN c_aseat;
  		FETCH c_aseat INTO v_state_cd;
  		CLOSE c_aseat;
  		IF (v_state_cd <> p_state_cd) THEN
  			p_message_name := 'IGS_AD_SEC_ASSTYPE_STCD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ASE.admp_val_ase_atstate');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ase_atstate;
  --
  -- Validate that state_cd = IGS_AD_AUS_SEC_ED_SC .state_cd
  FUNCTION ADMP_VAL_ASE_SCSTATE(
  p_state_cd IN VARCHAR2 ,
  p_secondary_school_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_ase_scstate
  	-- Validate that the IGS_AD_AUS_SEC_EDU.state_cd is the same as the
  	-- IGS_AD_AUS_SEC_ED_SC.state_cd.
  DECLARE
  	v_state_cd	IGS_AD_AUS_SEC_EDU.state_cd%TYPE DEFAULT NULL;
  	CURSOR c_ases IS
  		SELECT	state_cd
  		FROM	IGS_AD_AUS_SEC_ED_SC
  		WHERE	secondary_school_cd = p_secondary_school_cd;
  BEGIN
  	p_message_name := Null;
  	IF p_secondary_school_cd IS NOT NULL THEN
  		OPEN c_ases;
  		FETCH c_ases INTO v_state_cd;
  		CLOSE c_ases;
  		IF (v_state_cd <> p_state_cd) THEN
  			p_message_name := 'IGS_AD_SEC_EDU_STCD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ASE.admp_val_ase_scstate');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ase_scstate;
  --
  -- Validate if IGS_AD_AUSE_ED_AS_TY is closed.
  FUNCTION ADMP_VAL_ASEATCLOSED(
  p_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_aseatclosed
  	-- Validate if IGS_AD_AUSE_ED_AS_TY.aus_scndry_edu_ass_type is closed.
  DECLARE
  	v_closed_ind	IGS_AD_AUSE_ED_AS_TY.closed_ind%TYPE	DEFAULT NULL;
  	CURSOR c_aseat IS
  		SELECT	closed_ind
  		FROM	IGS_AD_AUSE_ED_AS_TY
  		WHERE	aus_scndry_edu_ass_type = p_aus_scndry_edu_ass_type;
  BEGIN
  	p_message_name := Null;
  	IF p_aus_scndry_edu_ass_type IS NOT NULL THEN
  		OPEN c_aseat;
  		FETCH c_aseat INTO v_closed_ind;
  		CLOSE c_aseat;
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_ASSTYPE_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ASE.admp_val_aseatclosed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aseatclosed;

END IGS_AD_VAL_ASE;

/
