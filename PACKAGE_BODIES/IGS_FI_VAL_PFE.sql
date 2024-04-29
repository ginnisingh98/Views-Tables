--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_PFE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_PFE" AS
/* $Header: IGSFI37B.pls 115.7 2002/11/29 00:22:48 nsidana ship $ */
  --
  -- nalkumar       30-Nov-2001       Removed the function finp_val_pfe_status and finp_val_pfes_closed from this package.
  --		                      This is as per the SFCR015-HOLDS DLD. Bug:2126091
  --
  --msrinivi Bug 1956374 Removed finp_val_encmb_eff
  --bayadav         20-DEC-2001       Removed the function finp_val_sca_status from this package.
  --		                      This is as per the SFCR015-HOLDS DLD. Bug:2126091
  --
  -- Validate the IGS_PE_PERSON does not have an active encumbrance of this type.
  FUNCTION finp_val_prsn_encmb(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_fee_encumbrance_dt IN DATE ,
 p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- finp_val_prsn_encmb
  	-- Validates that IGS_PE_PERSON does not currently have an active IGS_PE_PERS_ENCUMB
  	-- record matching that which will be applied if the IGS_PE_PND_FEE_ENCUM
  	-- is authorised
  DECLARE
  	cst_academic			CONSTANT VARCHAR2(8) := 'ACADEMIC';
  	v_rec_found			BOOLEAN DEFAULT FALSE;
  	v_s_encmb_cat			IGS_FI_ENCMB_TYPE.s_encumbrance_cat%TYPE;
  	v_start_dt			IGS_PE_PERS_ENCUMB.start_dt%TYPE;
  	CURSOR c_encmb_type (
  			cp_encumbrance_type IGS_FI_ENCMB_TYPE.encumbrance_type%TYPE) IS
  		SELECT	et.s_encumbrance_cat
  		FROM	IGS_FI_ENCMB_TYPE		et
  		WHERE	et.encumbrance_type		= cp_encumbrance_type;
  	CURSOR c_prsn_encmb (
  			cp_person_id		IGS_PE_PERS_ENCUMB.person_id%TYPE,
  			cp_encumbrance_type	IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
  			cp_fee_encumbrance_dt	IGS_PE_PERS_ENCUMB.start_dt%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PE_PERS_ENCUMB	pe
  		WHERE	pe.person_id		=  cp_person_id AND
  			pe.encumbrance_type	=  cp_encumbrance_type AND
  			trunc(pe.start_dt) <=
  				trunc(cp_fee_encumbrance_dt) AND
  			(pe.expiry_dt IS NULL OR
  			 trunc(pe.expiry_dt) >
  			trunc(cp_fee_encumbrance_dt));
  	CURSOR c_prsn_encmb_1 (
  			cp_person_id		IGS_PE_PERS_ENCUMB.person_id%TYPE,
  			cp_encumbrance_type	IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
  			cp_start_dt		IGS_PE_PERS_ENCUMB.start_dt%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PE_PERS_ENCUMB	pe
  		WHERE	pe.person_id		= cp_person_id AND
  			pe.ENCUMBRANCE_TYPE	= cp_encumbrance_type AND
  			trunc(pe.start_dt)= trunc(cp_start_dt);
  BEGIN
  	p_message_name := null;
  	-- Check parameters
  	IF(p_person_id IS NULL OR
  			p_encumbrance_type IS NULL OR
  			p_fee_encumbrance_dt IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Evaluate the fee_encumbrance_dt.
  	-- If it is less then the current date, set it to the current date.
  	-- This is necessary as it is used as the start date value in the
  	-- IGS_PE_PERS_ENCUMB record and if less than the current date,
  	-- an error will result.
  	IF(p_fee_encumbrance_dt < sysdate) THEN
  		v_start_dt := SYSDATE;
  	ELSE
  		v_start_dt := p_fee_encumbrance_dt;
  	END IF;
  	-- Check the encumbrance category for the encumbrance type parameter
  	-- If it is of type 'ACADEMIC' then no further processing is required as
  	-- encumbrances which fall into this category are permitted to exist in
  	-- multiple open records but not with the same start date
  	OPEN	c_encmb_type(
  			p_encumbrance_type);
  	FETCH	c_encmb_type INTO v_s_encmb_cat;
  	IF(v_s_encmb_cat <> cst_academic) THEN
  		-- Check if an active encumbrance exists
  		FOR v_prsn_encmb_rec IN c_prsn_encmb(
  					p_person_id,
  					p_encumbrance_type,
  					v_start_dt) LOOP
  			v_rec_found := TRUE;
  		END LOOP;
  		IF(v_rec_found = TRUE) THEN
  			-- IGS_PE_PERSON has an encumbrance of the same type which is active
  			CLOSE c_encmb_type;
  			p_message_name:= 'IGS_FI_STUD_ACTIVE_ENRPRG';
  			RETURN FALSE;
  		ELSE
  			CLOSE c_encmb_type;
  			v_rec_found := FALSE;
  			-- Check that if created, the encumbrance will not cause a duplicate
  			-- record conflict by having the same start date as an existing record.
  			FOR v_prsn_encmb_rec IN c_prsn_encmb_1(
  						p_person_id,
  						p_encumbrance_type,
  						v_start_dt) LOOP
  				v_rec_found := TRUE;
  			END LOOP;
  			IF(v_rec_found = TRUE) THEN
  				p_message_name:= 'IGS_AD_NOTBE_NOTQUALIF_OFRMAD';
  				RETURN FALSE;
  			ELSE
  				RETURN TRUE;
  			END IF;
  		END IF;
  	ELSE
  		-- Having identified the encumbrance category as ?ACADEMIC? check that
  		-- if created it will not cause a duplicate record conflict by having the
  		-- same start date as an existing record.
  		FOR v_prsn_encmb_rec IN c_prsn_encmb_1(
  						p_person_id,
  						p_encumbrance_type,
  						v_start_dt) LOOP
  			v_rec_found := TRUE;
  		END LOOP;
  		IF(v_rec_found = TRUE) THEN
  			CLOSE c_encmb_type;
  			p_message_name:= 'IGS_AD_PREF_NOTALLOW_ADMAPL';
  			RETURN FALSE;
  		ELSE
  			CLOSE c_encmb_type;
  			RETURN TRUE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_prsn_encmb;

 -- Removed the function finp_val_sca_status  from this package
 -- as per the SFCR015-HOLDS DLD. Bug:2126091

END IGS_FI_VAL_PFE;

/
