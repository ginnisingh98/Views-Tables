--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PEN" AS
/* $Header: IGSEN54B.pls 115.6 2002/11/29 00:03:19 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
  --Bug 1956374  msrinivi Removed func genp_val_prsn_id 27 aug,2001
  --
  -- bug id : 1956374
  -- sjadhav,28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_et_closed
  --
  --
  -- Validate the person does not have an active enrolment.
  FUNCTION finp_val_encmb_eff(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_fee_encumbrance_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	--finp_val_encmb_eff
  	--Validate that the person does not currently have an active enrolment
  	--if the encumbrance to be applied has an encumbrance_effect which
  	--requires current enrolments to be discontinued before the encumbrance
  	--can be applied.
  DECLARE
  	v_message_name	VARCHAR2(30)  DEFAULT NULL;
  	v_return_type	VARCHAR2(1);
  	v_start_dt	DATE;
  	CURSOR c_etde IS
  		SELECT	etde.s_encmb_effect_type
  		FROM	IGS_FI_ENC_DFLT_EFT	etde
  		WHERE	encumbrance_type = p_encumbrance_type;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	--validate parameters
  	IF (p_person_id IS NULL	OR
  			p_encumbrance_type	IS NULL OR
  			p_fee_encumbrance_dt	IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	--The start date for encumbrances must not be prior to the current date
  	IF (p_fee_encumbrance_dt < SYSDATE) THEN
  		v_start_dt := SYSDATE;
  	ELSE
  		v_start_dt := p_fee_encumbrance_dt;
  	END IF;
  	--retrieve each encumbrance effect associated with the encumbrance type
  	FOR v_etde_rec IN c_etde LOOP
  		--Depending on the effect type, check for breached enrolment criteria
  		IF (v_etde_rec.s_encmb_effect_type = 'RVK_SRVC') THEN
  			IF (IGS_EN_VAL_PEE.enrp_val_pee_sca(
  						p_person_id,
  						p_message_name) = FALSE) THEN
  					v_message_name := 'IGS_FI_ENCUMB_NOTAPPLIED_RVK';
  					EXIT;
  			END IF;
  		END IF;
  		IF (v_etde_rec.s_encmb_effect_type IN('EXC_COURSE', 'SUS_COURSE')) THEN
  			IF (p_course_cd IS NOT NULL) THEN
  				IF IGS_EN_VAL_PCE.enrp_val_pce_crs(
  							p_person_id,
  							p_course_cd,
  							v_start_dt,
  							v_message_name,
  							v_return_type) = FALSE THEN
  					IF (v_return_type = 'E') THEN
  						v_message_name := 'IGS_FI_ENCUMB_NOTAPPLIED_EXC';
  						EXIT;
  					ELSE
  						v_message_name := null;
  					END IF;
  				ELSE
  					v_message_name := null;
  				END IF;
  			END IF;
  		END IF;
  	END LOOP;
  	IF (v_message_name is not null ) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_etde%ISOPEN) THEN
  			CLOSE c_etde;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEN.finp_val_encmb_eff');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;

  END finp_val_encmb_eff;
  --
  --
  -- Validate that person doesn't already have an open encumbrance.
  FUNCTION enrp_val_pen_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_psn_encmb_rec		IGS_PE_PERS_ENCUMB%ROWTYPE;
  	v_encmb_type_rec		IGS_FI_ENCMB_TYPE%ROWTYPE;
  	CURSOR c_psn_encmb_rec (
  		cp_person_id		IGS_PE_PERS_ENCUMB.person_id%TYPE,
  		cp_encumbrance_type	IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
  		cp_start_dt		IGS_PE_PERS_ENCUMB.start_dt%TYPE) IS
  		SELECT 	*
  		FROM	IGS_PE_PERS_ENCUMB
  		WHERE	person_id = cp_person_id 		AND
  			encumbrance_type = cp_encumbrance_type 	AND
  			start_dt <> cp_start_dt 		AND
  			expiry_dt IS NULL;
    	CURSOR c_encmb_type_rec (
    		cp_encumbrance_type	IGS_FI_ENCMB_TYPE.encumbrance_type%TYPE) IS
    		SELECT 	*
    		FROM	IGS_FI_ENCMB_TYPE
    		WHERE	encumbrance_type = cp_encumbrance_type 	AND
    			s_encumbrance_cat = 'ADMIN';
  BEGIN
  	-- This module checks if there are no other
  	-- 'open ended' IGS_PE_PERS_ENCUMB records for
  	-- the nominated encumbrance type.
  	p_message_name := null;
    	OPEN  c_encmb_type_rec(p_encumbrance_type);
    	FETCH c_encmb_type_rec INTO v_encmb_type_rec;
    	IF (c_encmb_type_rec%NOTFOUND) THEN
    		CLOSE c_encmb_type_rec;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_encmb_type_rec;
  	END IF;
  	OPEN  c_psn_encmb_rec(p_person_id,
  			      p_encumbrance_type,
  			      p_start_dt);
  	FETCH c_psn_encmb_rec INTO v_psn_encmb_rec;
  	IF (c_psn_encmb_rec%NOTFOUND) THEN
  		CLOSE c_psn_encmb_rec;
  	ELSE -- data is found
  		CLOSE c_psn_encmb_rec;
  		p_message_name := 'IGS_EN_ENCMBR_HAS_SPECIFIED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEN.enrp_val_pen_open');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;

  END;
  END enrp_val_pen_open;
  --
  -- Validate the application of an encumbrance type to a person.
  FUNCTION enrp_val_prsn_encmb(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_encmb_eff_rec_found 	BOOLEAN;
  	gv_count		NUMBER;
  	gv_level		NUMBER;
      gv_mess_num NUMBER;
  	gv_mess_name		VARCHAR2(30);
  	gv_rstr_at_ty		BOOLEAN;
  	gv_rstr_ge_cp		BOOLEAN;
  	gv_rstr_le_cp		BOOLEAN;
  	CURSOR	gc_encmb_eff (
  			cp_enc_type	IGS_FI_ENC_DFLT_EFT.encumbrance_type%TYPE)IS
  		SELECT	etde.s_encmb_effect_type,
  			seet.encumbrance_level
  		FROM	IGS_FI_ENC_DFLT_EFT etde,
--  			s_encmb_effect_type seet
			IGS_EN_ENCMB_EFCTTYP_V SEET
  		WHERE	etde.encumbrance_type = cp_enc_type AND
  			seet.s_encmb_effect_type = etde.s_encmb_effect_type
  		ORDER BY etde.s_encmb_effect_type ASC;
  BEGIN
  DECLARE
  	FUNCTION enrpl_val_rest_effects(
  		p_validation_level	VARCHAR2,
  		p_encmb_effect_type	IGS_FI_ENC_DFLT_EFT.s_encmb_effect_type%TYPE,
  		p_message_name		OUT NOCOPY varchar2)
  	RETURN BOOLEAN IS
  	BEGIN
  	DECLARE
  	BEGIN
  		-- set the default message number
  		-- to 0
  		p_message_name := null;
  		-- set encumbrance effect type flags
  		IF (p_encmb_effect_type = 'RSTR_AT_TY') THEN
  			gv_rstr_at_ty := TRUE;
  		END IF;
  		IF (p_encmb_effect_type = 'RSTR_GE_CP') THEN
  			gv_rstr_ge_cp := TRUE;
  		END IF;
  		IF (p_encmb_effect_type = 'RSTR_LE_CP') THEN
  			gv_rstr_le_cp := TRUE;
  		END IF;
  		-- validate that encumbrance effects are a
  		-- valid combination
  		-- RSTR_AT_TY not valid with RSTR_GE_CP or RSTR_LE_CP
  		-- RSTR_GE_CP not valid with RSTR_AT_TY or RSTR_LE_CP
  		-- RSTR_LE_CP not valid with RSTR_AT_TY or RSTR_GE_CP
  		IF ((gv_rstr_at_ty = TRUE AND (gv_rstr_ge_cp = TRUE   OR
  					     gv_rstr_le_cp = TRUE)) OR
  		   (gv_rstr_ge_cp = TRUE AND (gv_rstr_at_ty = TRUE   OR
  					     gv_rstr_le_cp = TRUE)) OR
  		   (gv_rstr_le_cp = TRUE AND (gv_rstr_at_ty = TRUE   OR
  					     gv_rstr_ge_cp = TRUE))) THEN
  			IF (p_validation_level = 'ENCUMBRANCE LEVEL') THEN
  				p_message_name := 'IGS_EN_ENCUMBTYPE_INV_COMBI';
  			ELSE
  				p_message_name := 'IGS_EN_ENCUMBTYPE_PRG_INVALID';
  			END IF;
  			RETURN FALSE;
  		END IF;
  		-- set the default return type
  		RETURN TRUE;
  	EXCEPTION
  		WHEN OTHERS THEN
		        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEN.enrpl_val_rest_effects');
			IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;

  	END;
  	END enrpl_val_rest_effects;
  BEGIN
  	-- This routine validates the combination of encumbrance
  	-- effect toyes appplied to a person.
  	-- The encumbrance type being applied must :
  	-- 1. have effect defined
  	-- 2. have effects at the same level
  	-- 3. have a valid combination of effects
  	-- 4. not have effects at a different level than
  	--    other effects defined for the person for the
  	--    effective period of time
  	-- 5. not have effects that are an invalid combination
  	--    with other effects defined for the person for the
  	--    effective period of time
  	-- set the default message number
  	p_message_name := null;
  	-- set that no encumbrance records have
  	-- yet been found
  	gv_encmb_eff_rec_found := FALSE;
  	-- initialise the count for encumbrance records
  	gv_count := 0;
  	-- retriveing the encumbrance effects for the goven
  	-- encumbrance type
  	FOR gv_encmb_eff_rec IN gc_encmb_eff(p_encumbrance_type) LOOP
  		-- set that a record was found
  		gv_encmb_eff_rec_found := TRUE;
  		-- counting the number of records found
  		gv_count := gv_count + 1;
  		-- validate that encumbrance effects are
  		-- the same level
  		IF (gv_count = 1) THEN
  			-- the first record selected
  			gv_level := gv_encmb_eff_rec.encumbrance_level;
  		ELSE
  			-- not at the first record
  			IF (gv_encmb_eff_rec.encumbrance_level <> gv_level) THEN
  				p_message_name := 'IGS_EN_ENCUMBTYPE_DIFF_LVLS';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-- validate that encumbrance effects are
  		-- a valid combination
  		IF (enrpl_val_rest_effects(
  				'ENCUMBRANCE LEVEL',
  				gv_encmb_eff_rec.s_encmb_effect_type,
  				gv_mess_name) = FALSE) THEN
  			p_message_name := gv_mess_name;
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	-- check if encumbrance record were found
  	-- (ie. whether encumbrance effects have been
  	-- defined for the encumbrance type)
  	IF (gv_encmb_eff_rec_found = FALSE) THEN
  		p_message_name := 'IGS_EN_ENCUMB_TYPE_NOTAPPLIED';
  		RETURN FALSE;
  	END IF;
  	-- set the default return type
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEN.enrp_val_prsn_encmb');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;

  END enrp_val_prsn_encmb;

END IGS_EN_VAL_PEN;

/
