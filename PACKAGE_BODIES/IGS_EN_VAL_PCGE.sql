--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PCGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PCGE" AS
/* $Header: IGSEN51B.pls 115.6 2003/05/21 10:10:50 ptandon ship $ */
  --
  -- Validate that IGS_PE_PERSON doesn't already have an open crs grp exclusion.
  /*---------------------------------------------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When          What
  --ptandon    21-MAY-2003    Replaced usage of Message IGS_EN_COURSE_GRP_CLOSED with IGS_PS_PRGGRP_CODE_CLOSED. Bug#2755657
  -----------------------------------------------------------------------------------------------------------------------------------------*/

  FUNCTION enrp_val_pcge_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_course_group_cd IN VARCHAR2 ,
  p_pcge_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_pcge_open
  	-- Validate that there are no other "open ended" pcge records
  	-- for the nominated encumbrance effect type
  DECLARE
  	v_check		VARCHAR2(1);
  	v_ret_val	BOOLEAN DEFAULT TRUE;
  	CURSOR c_person_crs_grp_exclusion IS
  		SELECT 'x'
  		FROM	IGS_PE_CRS_GRP_EXCL
  		WHERE
  			person_id		= p_person_id		AND
  			encumbrance_type	= p_encumbrance_type	AND
  			pen_start_dt		= p_pen_start_dt	AND
  			s_encmb_effect_type	= p_s_encmb_effect_type	AND
  			pee_start_dt		= p_pee_start_dt	AND
  			course_group_cd		= p_course_group_cd	AND
  			pcge_start_dt		 <>  p_pcge_start_dt;
  BEGIN
  	p_message_name := null;
  	OPEN c_person_crs_grp_exclusion;
  	FETCH c_person_crs_grp_exclusion INTO v_check;
  	IF (c_person_crs_grp_exclusion%FOUND) THEN
  		-- open record already exists
  		p_message_name := 'IGS_EN_PRSN_PRGGRP_EXCLUSION';
  		v_ret_val := FALSE;
  	END IF;
  	CLOSE c_person_crs_grp_exclusion;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCGE.enrp_val_pcge_open');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END enrp_val_pcge_open;

  -- bug id : 1956374
  --  sjadhav,28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_encmb_dts
  -- removed enrp_val_crs_exclsn
  --
  --
  -- Validate the IGS_PS_COURSE group closed indicator.
  FUNCTION enrp_val_crs_gp_clsd(
  p_course_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_closed_ind		VARCHAR2(1);
  	CURSOR c_course_group_cd IS
  		SELECT	closed_ind
  		FROM	IGS_PS_GRP
  		WHERE	course_group_cd = p_course_group_cd;
  BEGIN
  	-- Check if the IGS_PS_COURSE group code is closed
  	p_message_name := null;
  	OPEN c_course_group_cd;
  	FETCH c_course_group_cd INTO v_closed_ind;
  	IF (c_course_group_cd%NOTFOUND) THEN
  		CLOSE c_course_group_cd;
  		RETURN TRUE;
  	END IF;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_PS_PRGGRP_CODE_CLOSED';
  		CLOSE c_course_group_cd;
  		RETURN FALSE;
  	END IF;
  	-- record is not closed
  	CLOSE c_course_group_cd;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCGE.enrp_val_crs_gp_clsd');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_crs_gp_clsd;
  --
  -- Validate the IGS_PS_COURSE group on the IGS_PE_PERSON IGS_PS_COURSE group exclusion table.
  FUNCTION enrp_val_pcge_crs_gp(
  p_person_id IN NUMBER ,
  p_course_group_cd IN VARCHAR2 ,
  p_exclusion_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_pcge_crs_gp
  	-- Validate whether or not a IGS_PE_PERSON is enrolled in a IGS_PS_COURSE within the
  	-- specified IGS_PS_COURSE group and whether or not the IGS_PS_COURSE must be
  	-- discontinued before a IGS_PS_COURSE exclusion can be applied.
  DECLARE
  	v_person_enrolled	BOOLEAN	DEFAULT	FALSE;
  	v_validate_failed	BOOLEAN DEFAULT	FALSE;
  	CURSOR	c_get_course_cd IS
  		SELECT	sca.course_cd
  		FROM	IGS_EN_STDNT_PS_ATT	sca,
  			IGS_PS_GRP_MBR	cgm
  		WHERE	sca.person_id		= p_person_id	AND
  			sca.course_attempt_status IN
  				('ENROLLED', 'INACTIVE', 'INTERMIT')	AND
  			sca.course_cd		= cgm.course_cd		AND
  			cgm.course_group_cd	= p_course_group_cd;
  BEGIN
  	p_message_name := null;
  	-- Validate input parameters
  	IF (p_person_id IS NULL OR
  			p_course_group_cd IS NULL OR
  			p_exclusion_start_dt IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Check if the IGS_PE_PERSON is enrolled in a IGS_PS_COURSE within the
  	-- specified IGS_PS_COURSE group
  	FOR v_rec IN c_get_course_cd LOOP
  		v_person_enrolled := TRUE;
  		-- Validate if the IGS_PS_COURSE must be discontinued before a IGS_PS_COURSE
  		-- group exclusion can be applied
  		IF (IGS_EN_VAL_PCE.enrp_val_crs_exclsn(
  					p_person_id,
  					v_rec.course_cd,
  					p_exclusion_start_dt,
  					p_message_name,
  					p_return_type) = FALSE) THEN
  			v_validate_failed := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF (v_person_enrolled = FALSE) THEN
  		RETURN TRUE;
  	END IF;
  	IF (v_validate_failed = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCGE.enrp_val_pcge_crs_gp');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END enrp_val_pcge_crs_gp;
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed enrp_val_crs_exclsn
  --
  --
  -- bug id : 1956374
  -- removed FUNCTION enrp_val_encmb_dts
  --
END IGS_EN_VAL_PCGE;

/
