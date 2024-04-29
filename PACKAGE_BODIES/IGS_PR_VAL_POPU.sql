--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_POPU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_POPU" AS
/* $Header: IGSPR17B.pls 120.0 2005/07/05 12:49:08 appldev noship $ */
/* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid,genp_set_row_id
*/

  --

  -- Validate that a IGS_PR_OU_UNIT record can be created

  FUNCTION prgp_val_popu_pro(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_sequence_number IN NUMBER ,


  p_s_unit_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN IS

  	gv_other_detail                 VARCHAR2(255);

  BEGIN	-- prgp_val_popu_pro

  	-- When creating a Progression Outcome Unit record validate that the record

  	-- is related to a  progression_rule_outcome with a progression_outcome_type


  	-- that relates to a s_encmb_effect_type of EXC_CRS_U when s_unit_type

  	-- = EXCLUDE or a s_encmb_effect_type of RQRD_CRS_U when s_unit_type

  	-- = REQUIRED

  DECLARE

  	cst_exc_crs_u	CONSTANT	VARCHAR(10) := 'EXC_CRS_U';

  	cst_rqrd_crs_u	CONSTANT	VARCHAR(10) := 'RQRD_CRS_U';


  	v_dummy                         VARCHAR2(1);

  	CURSOR c1_pro_pot_etde IS

  		SELECT 	'X'

  		FROM		IGS_PR_RU_OU                  	pro,

  				IGS_PR_OU_TYPE 	pot,

  				IGS_FI_ENC_DFLT_EFT		etde

  		WHERE		pro.progression_rule_cat	= p_progression_rule_cat AND


  				pro.pra_sequence_number		= p_pra_sequence_number AND

  				pro.sequence_number		= p_sequence_number AND

  				pro.progression_outcome_type 	= pot.progression_outcome_type AND

  				pot. encumbrance_type		= etde.encumbrance_type  AND

  				etde.s_encmb_effect_type	= cst_exc_crs_u;

  	CURSOR c2_pro_pot_etde IS


  		SELECT 	'X'

  		FROM		IGS_PR_RU_OU                  	pro,

  				IGS_PR_OU_TYPE 	pot,

  				IGS_FI_ENC_DFLT_EFT		etde

  		WHERE		pro.progression_rule_cat	= p_progression_rule_cat AND

  				pro.pra_sequence_number		= p_pra_sequence_number AND

  				pro.sequence_number		= p_sequence_number AND


  				pro.progression_outcome_type 	= pot.progression_outcome_type AND

  				pot. encumbrance_type		= etde.encumbrance_type  AND

  				etde.s_encmb_effect_type	= cst_rqrd_crs_u;

  BEGIN

  	-- Set the default message number

  	p_message_name := null;


  	IF p_progression_rule_cat IS NULL OR

  			p_pra_sequence_number IS NULL OR

  				p_sequence_number IS NULL OR

  					p_s_unit_type IS NULL THEN

  		RETURN TRUE;

  	END IF;

  	IF p_s_unit_type = 'EXCLUDED' THEN


  		OPEN c1_pro_pot_etde;

  		FETCH c1_pro_pot_etde INTO v_dummy;

  		IF c1_pro_pot_etde%NOTFOUND THEN

  			CLOSE c1_pro_pot_etde;

  			p_message_name := 'IGS_PR_OUT_ENCTY_EXC_CRS_U';

  			RETURN FALSE;


  		END IF;

  		CLOSE c1_pro_pot_etde;

  	END IF;

  	IF p_s_unit_type = 'REQUIRED' THEN

  		OPEN c2_pro_pot_etde;

  		FETCH c2_pro_pot_etde INTO v_dummy;

  		IF c2_pro_pot_etde%NOTFOUND THEN


  			CLOSE c2_pro_pot_etde;

  			p_message_name := 'IGS_PR_OUT_ENCTY_RQRD_CRS_U';

  			RETURN FALSE;

  		END IF;

  		CLOSE c2_pro_pot_etde;

  	END IF;


  	RETURN TRUE;

  EXCEPTION

  	WHEN OTHERS THEN

  		IF c1_pro_pot_etde%ISOPEN THEN

  			CLOSE c1_pro_pot_etde;

  		END IF;

  		IF c2_pro_pot_etde%ISOPEN THEN


  			CLOSE c2_pro_pot_etde;

  		END IF;

  		RAISE;

  END;

  EXCEPTION

  	WHEN OTHERS THEN



  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;

  END prgp_val_popu_pro;

  --


  -- Validate progression rule outcome automatically apply indicator

  FUNCTION prgp_val_popu_auto(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_pro_sequence_number IN NUMBER ,

  p_unit_cd IN VARCHAR2 ,

  p_old_s_unit_type IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN IS

  	gv_other_detail                 VARCHAR2(255);

  BEGIN	-- prgp_val_popu_auto

  	-- When updating or deleting a Progression Outcome Unit record validate that

  	-- the record is related to a  IGS_PR_RU_OU                   with the


  	-- apply_automatically_ind set to 'Y' and a progression_outcome_type

  	-- that relates to:

  	-- a s_encmb_effect_type of EXC_CRS_U when s_unit_type = EXCLUDE or

  	-- a s_encmb_effect_type of RQRD_CRS_U when s_unit_type = REQUIRED

  DECLARE

  	cst_exc_crs_u	CONSTANT	VARCHAR(10) := 'EXC_CRS_U';

  	cst_rqrd_crs_u	CONSTANT	VARCHAR(10) := 'RQRD_CRS_U';


  	cst_excluded	CONSTANT	VARCHAR(10) := 'EXCLUDED';

  	cst_required	CONSTANT	VARCHAR(10) := 'REQUIRED';

  	v_dummy                         VARCHAR2(1);

  	CURSOR c_pro_popu_pot_etde_1 IS
		SELECT 'X'
		  FROM igs_pr_ru_ou pro
		 WHERE pro.progression_rule_cat = p_progression_rule_cat
		   AND pro.pra_sequence_number = p_pra_sequence_number
		   AND pro.sequence_number = p_pro_sequence_number
		   AND pro.apply_automatically_ind = 'N'
		UNION ALL
		SELECT 'X'
		  FROM igs_pr_ru_ou pro,
		       igs_pr_ou_unit popu,
		       igs_pr_ou_type pot,
		       igs_fi_enc_dflt_eft etde
		 WHERE pro.progression_rule_cat = p_progression_rule_cat
		   AND pro.pra_sequence_number = p_pra_sequence_number
		   AND pro.sequence_number = p_pro_sequence_number
		   AND pro.apply_automatically_ind = 'Y'
		   AND pro.progression_rule_cat = popu.progression_rule_cat
		   AND pro.pra_sequence_number = popu.pra_sequence_number
		   AND pro.sequence_number = popu.pro_sequence_number
		   AND popu.unit_cd <> p_unit_cd
		   AND popu.s_unit_type = cst_excluded
		   AND pro.progression_outcome_type = pot.progression_outcome_type
		   AND pot.encumbrance_type = etde.encumbrance_type
		   AND etde.s_encmb_effect_type = cst_exc_crs_u;

  	CURSOR c_pro_popu_pot_etde_2 IS

  		SELECT 		'X'

  		FROM		IGS_PR_RU_OU                  	pro,

  				IGS_PR_OU_UNIT           		popu,


  				IGS_PR_OU_TYPE           	pot,

  				IGS_FI_ENC_DFLT_EFT        		etde

  		WHERE		pro.progression_rule_cat	= p_progression_rule_cat AND

  				pro.pra_sequence_number		= p_pra_sequence_number AND

  				pro.sequence_number		= p_pro_sequence_number AND

  				(pro.apply_automatically_ind		= 'N' OR


  				(pro.apply_automatically_ind		= 'Y' AND

  				pro.progression_rule_cat	= popu.progression_rule_cat AND

  				pro.pra_sequence_number		= popu.pra_sequence_number AND

  				pro.sequence_number		= popu.pro_sequence_number AND

  				popu.unit_cd			<> p_unit_cd  AND

  				popu.s_unit_type			= cst_required AND

  				pro.progression_outcome_type 	= pot.progression_outcome_type AND


  				pot. encumbrance_type		= etde.encumbrance_type  AND

  				etde.s_encmb_effect_type	= cst_rqrd_crs_u));

  BEGIN

  	-- Set the default message number

  	p_message_name := null;

  	IF p_progression_rule_cat IS NULL OR


  			p_pra_sequence_number IS NULL OR

  			p_pro_sequence_number IS NULL OR

  			p_unit_cd IS NULL OR

  			p_old_s_unit_type IS NULL THEN

  		RETURN TRUE;

  	END IF;

  	IF p_old_s_unit_type = cst_excluded THEN


  		OPEN c_pro_popu_pot_etde_1;

  		FETCH c_pro_popu_pot_etde_1 INTO v_dummy;

  		IF c_pro_popu_pot_etde_1%NOTFOUND THEN

  			CLOSE c_pro_popu_pot_etde_1;

  			p_message_name := 'IGS_PR_APAUO_OTY_ENEF_UEX_EXRT';

  			RETURN FALSE;


  		ELSE

  			CLOSE c_pro_popu_pot_etde_1;

  		END IF;

  	END IF;

  	IF p_old_s_unit_type = cst_required THEN

  		OPEN c_pro_popu_pot_etde_2;

  		FETCH c_pro_popu_pot_etde_2 INTO v_dummy;


  		IF c_pro_popu_pot_etde_2%NOTFOUND THEN

  			CLOSE c_pro_popu_pot_etde_2;

  			p_message_name := 'IGS_PR_APAUO_OTY_ENEF_UR_MET';

  			RETURN FALSE;

  		ELSE

  			CLOSE c_pro_popu_pot_etde_2;


  		END IF;

  	END IF;

  	RETURN TRUE;

  EXCEPTION

  	WHEN OTHERS THEN

  		IF c_pro_popu_pot_etde_1%ISOPEN THEN

  			CLOSE c_pro_popu_pot_etde_1;


  		END IF;

  		IF c_pro_popu_pot_etde_2%ISOPEN THEN

  			CLOSE c_pro_popu_pot_etde_2;

  		END IF;

  		RAISE;

  END;


  EXCEPTION

  	WHEN OTHERS THEN


  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;

  END prgp_val_popu_auto;

  --

  -- Routine to process rowids in a PL/SQL TABLE for the current commit.


  FUNCTION prgp_prc_popu_rowids(

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


  			IF IGS_PR_val_popu.prgp_val_popu_auto (

  					gt_rowid_table(v_index).progression_rule_cat,

  					gt_rowid_table(v_index).pra_sequence_number,

  					gt_rowid_table(v_index).pro_sequence_number,

  					gt_rowid_table(v_index).unit_cd,

  					gt_rowid_table(v_index).old_s_unit_type,

  					v_message_name) = FALSE THEN


  				p_message_name := v_message_name;

  				RETURN FALSE;

  			END IF;

  		END IF;

  		-- Check the decision status can be changed

  		IF p_updating THEN


  			IF IGS_PR_val_popu.prgp_val_popu_auto (

  						gt_rowid_table(v_index).progression_rule_cat,

  						gt_rowid_table(v_index).pra_sequence_number,

  						gt_rowid_table(v_index).pro_sequence_number,

  						gt_rowid_table(v_index).unit_cd,

  						gt_rowid_table(v_index).old_s_unit_type,

  						v_message_name) = FALSE THEN


  				p_message_name := v_message_name;

  				RETURN FALSE;

  			END IF;

  		END IF;

  	END LOOP;

  	RETURN TRUE;


  END prgp_prc_popu_rowids;

  --

  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_popu_rowid(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_pro_sequence_number IN NUMBER ,


  p_unit_cd IN VARCHAR2 ,

  p_old_s_unit_type IN VARCHAR2 )

  IS

  	v_index				BINARY_INTEGER;

  	v_popu_found			BOOLEAN DEFAULT FALSE;

  BEGIN


  	-- Check if record already exists in gt_rowid_table

  	FOR v_index IN 1..gv_table_index - 1 LOOP

  		IF gt_rowid_table(v_index).progression_rule_cat = p_progression_rule_cat AND



  		   gt_rowid_table(v_index).pra_sequence_number = p_pra_sequence_number AND

  		   gt_rowid_table(v_index).pro_sequence_number = p_pro_sequence_number AND

  		   gt_rowid_table(v_index).unit_cd = p_unit_cd AND


  		   gt_rowid_table(v_index).old_s_unit_type = p_old_s_unit_type THEN

  			v_popu_found := TRUE;

  			EXIT;

  		END IF;

  	END LOOP;

  	-- Save student progression outcome key details


  	IF NOT v_popu_found THEN

  		gt_rowid_table(gv_table_index).progression_rule_cat :=
  		p_progression_rule_cat;

  		gt_rowid_table(gv_table_index).pra_sequence_number := p_pra_sequence_number;



  		gt_rowid_table(gv_table_index).pro_sequence_number := p_pro_sequence_number;




  		gt_rowid_table(gv_table_index).unit_cd := p_unit_cd;

  		gt_rowid_table(gv_table_index).old_s_unit_type := p_old_s_unit_type;

  		gv_table_index := gv_table_index +1;

  	END IF;

  END prgp_set_popu_rowid;

  --


  -- Warn if the unit does not have an active unit version

  FUNCTION prgp_val_uv_active(

  p_unit_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN IS

  	gv_other_detail		VARCHAR2(255);

  BEGIN	-- PRGP_VAL_UV_ACTIVE


  	-- Purpose: Warn the user if the supplied unit_cd has no

  	--	ACTIVE unit_version records.

  DECLARE

  	v_exists	VARCHAR2(1);

  	CURSOR c_uv_ust IS

  		SELECT	'x'


  		FROM	IGS_PS_UNIT_VER              	uv,

  			IGS_PS_UNIT_STAT            	ust

  		WHERE	uv.unit_cd		= p_unit_cd AND

  			uv.unit_status		= ust.unit_status AND

  			ust.s_unit_status	= 'ACTIVE';

  BEGIN

  	-- Set the default message number


  	p_message_name := null;

  	IF p_unit_cd IS NULL THEN

  		RETURN TRUE;

  	END IF;

  	OPEN c_uv_ust;

  	FETCH c_uv_ust INTO v_exists;


  	IF c_uv_ust%NOTFOUND THEN

  		CLOSE c_uv_ust;

  		p_message_name := 'IGS_PR_UNT_CNT_NOACT_VER';

  		RETURN TRUE;

  	END IF;

  	CLOSE c_uv_ust;

  	-- Return the default value


  	RETURN TRUE;

  EXCEPTION

  	WHEN OTHERS THEN

  		IF c_uv_ust%ISOPEN THEN

  			CLOSE c_uv_ust;

  		END IF;


  		RAISE;

  END;

  EXCEPTION

  	WHEN OTHERS THEN


  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;

  END; -- Function PRGP_VAL_UV_ACTIVE


END IGS_PR_VAL_POPU;

/
