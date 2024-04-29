--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_DIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_DIT" AS
/* $Header: IGSEN31B.pls 115.4 2002/11/28 23:56:46 nsidana ship $ */
  --
  /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid,genp_set_row_id
  */
  -- Routine to process dit rowids in a PL/SQL TABLE for the current commit
  FUNCTION enrp_prc_dit_rowids(
  p_inserting IN BOOLEAN ,
  p_updating IN BOOLEAN ,
  p_deleting IN BOOLEAN ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	v_index			BINARY_INTEGER;
  	v_other_detail		VARCHAR(255);
  	r_disability_type 		IGS_AD_DISBL_TYPE%ROWTYPE;
  BEGIN
  	-- Process saved rows.
  	FOR  v_index IN 1..gv_table_index - 1
  	LOOP
  		BEGIN
  			SELECT	*
  			INTO	r_disability_type
  			FROM	IGS_AD_DISBL_TYPE
  			WHERE	rowid = gt_rowid_table(v_index);
  			EXCEPTION
  				WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_DIT.enrp_prc_dit_rowids');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  		END;
  		-- Validate for open IGS_AD_DISBL_TYPE records.
  		IF r_disability_type.closed_ind = 'N' THEN
  			IF IGS_EN_VAL_DIT.enrp_val_dit_open (
  					r_disability_type.disability_type,
  					r_disability_type.govt_disability_type,
  					p_message_name) = FALSE THEN
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END enrp_prc_dit_rowids;
  --
  -- Validate the disability type.
  FUNCTION enrp_val_dit_open(
  p_disability_type IN VARCHAR2 ,
  p_govt_disability_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	gv_other_detail	 VARCHAR(255);
  	CURSOR	gc_dit(
  			cp_disability_type IGS_AD_DISBL_TYPE.disability_type%TYPE,
  			cp_govt_disability_type IGS_AD_DISBL_TYPE.govt_disability_type%TYPE)
  	IS
  		SELECT	IGS_AD_DISBL_TYPE.closed_ind
  		FROM	IGS_AD_DISBL_TYPE
  		WHERE	IGS_AD_DISBL_TYPE.disability_type <> cp_disability_type AND
  			IGS_AD_DISBL_TYPE.govt_disability_type = cp_govt_disability_type AND
  			IGS_AD_DISBL_TYPE.closed_ind = 'N';
  BEGIN
  	-- this module validates that there are no other "open" IGS_AD_DISBL_TYPE
  	-- records for the nominated government disability_type (IGS_AD_DISBL_TYPE)
  	p_message_name := null;
  	FOR gc_dit_rec IN gc_dit(
  				p_disability_type,
  				p_govt_disability_type) LOOP
  		IF gc_dit_rec.closed_ind = 'N' THEN
  			p_message_name := 'IGS_EN_ONE_DISABILIT_TYP_EXIS';
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  	EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_DIT.enrp_val_dit_open');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_dit_open;
END IGS_EN_VAL_DIT;

/
