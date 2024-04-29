--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SPU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SPU" AS
/* $Header: IGSPR22B.pls 115.7 2002/11/29 02:49:37 nsidana ship $ */

  /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid
  */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_UV_ACTIVE) - from the spec and body. -- kdande
*/
  --

  -- Validate student progression unit / outcome relationship

  FUNCTION prgp_val_spu_spo(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_s_unit_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN IS

  	gv_other_detail		VARCHAR2(255);

  BEGIN	-- PRGP_VAL_SPU_SPO


  	-- Purpose: When creating a Student Progression Unit record validate that the

  	--	record is related to a IGS_PR_STDNT_PR_OU with a

  	--	progression_outcome_type that relates to:

  	--		a s_encmb_effect_type of EXC_CRS_U when s_unit_type = EXCLUDED or

  	--		a s_encmb_effect_type of RQRD_CRS_U when s_unit_type = REQUIRED.

  DECLARE

  	v_exists	VARCHAR2(1);

  	CURSOR c_spo(

  		cp_see_type	IGS_FI_ENC_DFLT_EFT.s_encmb_effect_type%TYPE) IS

  		SELECT	'x'

  		FROM	IGS_PR_STDNT_PR_OU	spo,

  			IGS_PR_OU_TYPE	pot,


  			IGS_FI_ENC_DFLT_EFT		etde

  		WHERE	spo.person_id	= p_person_id AND

  			spo.course_cd	= p_course_cd AND

  			spo.sequence_number	= p_sequence_number AND

  			spo.progression_outcome_type	= pot.progression_outcome_type AND

  			pot.encumbrance_type	= etde.encumbrance_type AND

  			etde.s_encmb_effect_type	= cp_see_type;

  BEGIN

  	-- Set the default message number

  	p_message_name := null;

  	IF p_person_id IS NULL OR


  			p_course_cd IS NULL OR

  			p_sequence_number IS NULL OR

  			p_s_unit_type IS NULL THEN

  		RETURN TRUE;

  	END IF;

  	IF p_s_unit_type = 'EXCLUDED' THEN

  		OPEN c_spo('EXC_CRS_U');

  		FETCH c_spo INTO v_exists;

  		IF c_spo%NOTFOUND THEN

  			CLOSE c_spo;

  			p_message_name := 'IGS_PR_STPR_OUT_EXC_CRS_U';

  			RETURN FALSE;


  		END IF;

  		CLOSE c_spo;

  	END IF;

  	IF p_s_unit_type = 'REQUIRED' THEN

  		OPEN c_spo('RQRD_CRS_U');

  		FETCH c_spo INTO v_exists;

  		IF c_spo%NOTFOUND THEN

  			CLOSE c_spo;

  			p_message_name := 'IGS_PR_STPR_OUT_RQRD_CRS_U';

  			RETURN FALSE;

  		END IF;


  		CLOSE c_spo;

  	END IF;

  	-- Return the default value

  	RETURN TRUE;

  EXCEPTION

  	WHEN OTHERS THEN

  		IF c_spo%ISOPEN THEN

  			CLOSE c_spo;

  		END IF;

  		RAISE;

  END;

  EXCEPTION


  	WHEN OTHERS THEN


  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                 IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END; -- Function PRGP_VAL_SPU_SPO

  --


  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_spu_rowids(

  p_inserting IN BOOLEAN ,

  p_updating IN BOOLEAN ,


  p_deleting IN BOOLEAN ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN IS

  	v_index			BINARY_INTEGER;

  BEGIN

  	-- Process saved rows.

  	FOR  v_index IN 1..gv_table_index - 1 LOOP

  		IF p_inserting OR p_updating OR p_deleting THEN

  			-- Update student progression outcome applied date

  			IGS_PR_GEN_004.IGS_PR_UPD_SPO_APLY_DT (

  					gt_rowid_table(v_index).person_id,

  					gt_rowid_table(v_index).course_cd,


  					gt_rowid_table(v_index).sequence_number);

  		END IF;

  	END LOOP;

  	RETURN TRUE;

  END prgp_prc_spu_rowids;

  --

  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_spu_rowid(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER )


  IS

  	v_index				BINARY_INTEGER;

  	v_spo_found			BOOLEAN DEFAULT FALSE;

  BEGIN

  	-- Check if record already exists in gt_rowid_table

  	FOR v_index IN 1..gv_table_index - 1 LOOP

  		IF gt_rowid_table(v_index).person_id = p_person_id AND

  		   gt_rowid_table(v_index).course_cd = p_course_cd AND

  		   gt_rowid_table(v_index).sequence_number = p_sequence_number THEN

  			v_spo_found := TRUE;

  			EXIT;

  		END IF;


  	END LOOP;

  	-- Save student progression outcome key details

  	IF NOT v_spo_found THEN

  		gt_rowid_table(gv_table_index).person_id := p_person_id;

  		gt_rowid_table(gv_table_index).course_cd := p_course_cd;

  		gt_rowid_table(gv_table_index).sequence_number := p_sequence_number;

  		gv_table_index := gv_table_index +1;

  	END IF;

  END prgp_set_spu_rowid;

END IGS_PR_VAL_SPU;

/
