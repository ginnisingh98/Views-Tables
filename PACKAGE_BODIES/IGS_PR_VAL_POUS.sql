--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_POUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_POUS" AS
/* $Header: IGSPR18B.pls 120.0 2005/07/05 11:39:41 appldev noship $ */

   /* Bug 1956374
    Who msrinivi
    What duplicate removal Rremoved genp_prc_clear_rowid
   */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_US_ACTIVE) - from the spec and body. -- kdande
*/
  --

  -- Validate that a prg_outcome_unit_set record can be created

  FUNCTION prgp_val_pous_pro(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_sequence_number IN NUMBER ,


  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN IS

  	gv_other_detail                 VARCHAR2(255);

  BEGIN	-- prgp_val_pous_pro

  	-- When creating a Progression Outcome Unit Set record validate that the
  	-- record


  	-- is related to a  progression_rule_outcome with a progression_outcome_type


  	-- that relates to a s_encmb_effect_type of EXC_CRS_US

  DECLARE

  	cst_exc_crs_us	CONSTANT	VARCHAR(10) := 'EXC_CRS_US';

  	v_dummy                         VARCHAR2(1);

  	CURSOR c_pro_pot_etde IS

  		SELECT 	'X'


  		FROM		IGS_PR_RU_OU       	pro,

  				IGS_PR_OU_TYPE      	pot,

  				IGS_FI_ENC_DFLT_EFT     		etde

  		WHERE		pro.progression_rule_cat	= p_progression_rule_cat AND

  				pro.pra_sequence_number		= p_pra_sequence_number AND

  				pro.sequence_number		= p_sequence_number AND

  				pro.progression_outcome_type 	= pot.progression_outcome_type AND


  				pot. encumbrance_type		= etde.encumbrance_type  AND

  				etde.s_encmb_effect_type	= cst_exc_crs_us;

  BEGIN

  	-- Set the default message number

  	p_message_name := null;

  	IF p_progression_rule_cat IS NULL OR


  			p_pra_sequence_number IS NULL OR

  				p_sequence_number IS NULL THEN

  		RETURN TRUE;

  	END IF;

  	OPEN c_pro_pot_etde;

  	FETCH c_pro_pot_etde INTO v_dummy;

  	IF c_pro_pot_etde%NOTFOUND THEN


  		CLOSE c_pro_pot_etde;

  		p_message_name := 'IGS_PR_OUT_ENCTY_EXC_CRS_US';

  		RETURN FALSE;

  	END IF;

  	CLOSE c_pro_pot_etde;

  	RETURN TRUE;


  EXCEPTION

  	WHEN OTHERS THEN

  		IF c_pro_pot_etde%ISOPEN THEN

  			CLOSE c_pro_pot_etde;

  		END IF;

  		RAISE;

  END;


  EXCEPTION

  	WHEN OTHERS THEN


  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;

  END prgp_val_pous_pro;


  --

  -- Validate progression rule outcome automatically apply indicator

  FUNCTION prgp_val_pous_auto(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_pro_sequence_number IN NUMBER ,


  p_unit_set_cd IN VARCHAR2 ,

  p_us_version_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN IS

  	gv_other_detail                 VARCHAR2(255);

  BEGIN	-- prgp_val_pous_auto

  	-- When deleting a Progression Outcome Unit Set record validate if the record




  	-- is related to a  IGS_PR_RU_OU        with a progression_outcome_type

  	-- that relates to a s_encmb_effect_type of EXC_CRS_US and the

  	-- apply_automatically_ind is set to 'Y' that at least one

  	-- prg_outcome_unit_set record exists.

  DECLARE


  	cst_exc_crs_us	CONSTANT	VARCHAR(10) := 'EXC_CRS_US';

  	v_dummy                         VARCHAR2(1);

  	CURSOR c_pro_pous_pot_etde IS
	 SELECT 'X'
	  FROM igs_pr_ru_ou pro
	  WHERE pro.progression_rule_cat = p_progression_rule_cat
	    AND pro.pra_sequence_number = p_pra_sequence_number
	    AND pro.sequence_number = p_pro_sequence_number
	    AND pro.apply_automatically_ind = 'N'
	 UNION ALL
	  SELECT 'X'
	  FROM igs_pr_ru_ou pro,
		igs_pr_ou_unit_set pous,
		igs_pr_ou_type_all pot,
		igs_fi_enc_dflt_eft etde
	  WHERE pro.progression_rule_cat = p_progression_rule_cat
	    AND pro.pra_sequence_number = p_pra_sequence_number
	    AND pro.sequence_number = p_pro_sequence_number
	    AND pro.apply_automatically_ind = 'Y'
	    AND pro.progression_rule_cat = pous.progression_rule_cat
	    AND pro.pra_sequence_number = pous.pra_sequence_number
	    AND pro.sequence_number = pous.pro_sequence_number
	    AND (  pous.unit_set_cd <> p_unit_set_cd
		OR pous.us_version_number <> p_us_version_number
		)
	    AND pro.progression_outcome_type = pot.progression_outcome_type
	    AND pot.encumbrance_type = etde.encumbrance_type
	    AND etde.s_encmb_effect_type = cst_exc_crs_us ;

  BEGIN

  	-- Set the default message number

  	p_message_name := null;

  	IF p_progression_rule_cat IS NULL OR

  			p_pra_sequence_number IS NULL OR


  			p_pro_sequence_number IS NULL OR

  			p_unit_set_cd IS NULL OR

  			p_us_version_number IS NULL THEN

  		RETURN TRUE;

  	END IF;

  	OPEN c_pro_pous_pot_etde;

  	FETCH c_pro_pous_pot_etde INTO v_dummy;


  	IF c_pro_pous_pot_etde%NOTFOUND THEN

  		CLOSE c_pro_pous_pot_etde;

  		p_message_name := 'IGS_PR_APAUO_SOTY_ENEF_USE_LEX';

  		RETURN FALSE;

  	END IF;

  	CLOSE c_pro_pous_pot_etde;


  	RETURN TRUE;

  EXCEPTION

  	WHEN OTHERS THEN

  		IF c_pro_pous_pot_etde%ISOPEN THEN

  			CLOSE c_pro_pous_pot_etde;

  		END IF;

  		RAISE;


  END;

  EXCEPTION

  	WHEN OTHERS THEN


  			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		        IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;

  		RAISE;

  END prgp_val_pous_auto;

  --


  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_pous_rowids(

  p_inserting IN BOOLEAN ,

  p_updating IN BOOLEAN ,

  p_deleting IN BOOLEAN ,

  p_message_name OUT NOCOPY VARCHAR2 )


  RETURN BOOLEAN IS

  	v_index			BINARY_INTEGER;

  	v_message_name		VARCHAR2(30);

  BEGIN

  	-- Process saved rows.

  	FOR  v_index IN 1..gv_table_index - 1 LOOP

  		-- Validate delete


  		IF p_deleting THEN

  			IF IGS_PR_val_pous.prgp_val_pous_auto (

  					gt_rowid_table(v_index).progression_rule_cat,

  					gt_rowid_table(v_index).pra_sequence_number,

  					gt_rowid_table(v_index).pro_sequence_number,

  					gt_rowid_table(v_index).unit_set_cd,


  					gt_rowid_table(v_index).us_version_number,

  					v_message_name) = FALSE THEN

  				p_message_name := v_message_name;

  				RETURN FALSE;

  			END IF;

  		END IF;

  	END LOOP;


  	RETURN TRUE;

  END prgp_prc_pous_rowids;

  --

  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_pous_rowid(

  p_progression_rule_cat IN VARCHAR2 ,


  p_pra_sequence_number IN NUMBER ,

  p_pro_sequence_number IN NUMBER ,

  p_unit_set_cd IN VARCHAR2 ,

  p_us_version_number IN NUMBER )

  IS

  	v_index				BINARY_INTEGER;

  	v_pous_found			BOOLEAN DEFAULT FALSE;


  BEGIN

  	-- Check if record already exists in gt_rowid_table

  	FOR v_index IN 1..gv_table_index - 1 LOOP

  		IF gt_rowid_table(v_index).progression_rule_cat = p_progression_rule_cat AND



  		   gt_rowid_table(v_index).pra_sequence_number = p_pra_sequence_number AND


  		   gt_rowid_table(v_index).pro_sequence_number = p_pro_sequence_number AND

  		   gt_rowid_table(v_index).unit_set_cd = p_unit_set_cd AND

  		   gt_rowid_table(v_index).us_version_number = p_us_version_number THEN

  			v_pous_found := TRUE;

  			EXIT;

  		END IF;

  	END LOOP;


  	-- Save student progression outcome key details

  	IF NOT v_pous_found THEN

  		gt_rowid_table(gv_table_index).progression_rule_cat :=
  		p_progression_rule_cat;


  		gt_rowid_table(gv_table_index).pra_sequence_number := p_pra_sequence_number;




  		gt_rowid_table(gv_table_index).pro_sequence_number := p_pro_sequence_number;



  		gt_rowid_table(gv_table_index).unit_set_cd := p_unit_set_cd;

  		gt_rowid_table(gv_table_index).us_version_number := p_us_version_number;

  		gv_table_index := gv_table_index +1;

  	END IF;

  END prgp_set_pous_rowid;

END IGS_PR_VAL_POUS;

/
