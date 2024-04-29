--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SPC" AS
/* $Header: IGSPR20B.pls 115.5 2002/11/29 02:48:59 nsidana ship $ */
   -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function prgp_val_crv_active removed

  -------------------------------------------------------------------------------------------
  --
  /* Bug 1956374
   Who msrinivi
   What duplicate removal Rremoved genp_prc_clear_rowid,genp_set_row_id
  */

  --

  -- Validate student progression course / outcome relationship

  FUNCTION prgp_val_spc_spo(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,


  p_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN IS

  	gv_other_detail		VARCHAR2(255);

  BEGIN	-- PRGP_VAL_SPC_SPO

  	-- Purpose: When creating a Student Progression Course record validate that

  	--	the record is related to a  student_progression_outcome with a

  	--	progression_outcome_type that relates to a s_encmb_effect_type

  	--	of EXC_COURSE or SUS_COURSE.

  DECLARE

  	v_exists	VARCHAR2(1);

  	CURSOR c_spo IS


  		SELECT	'x'

  		FROM	IGS_PR_STDNT_PR_OU	spo,

  			IGS_PR_OU_TYPE		pot,

  			IGS_FI_ENC_DFLT_EFT	etde

  		WHERE	spo.person_id			= p_person_id AND

  			spo.course_cd			= p_course_cd AND

  			spo.sequence_number		= p_sequence_number AND

  			spo.progression_outcome_type	= pot.progression_outcome_type AND

  			pot.encumbrance_type		= etde.encumbrance_type AND

  			etde.s_encmb_effect_type	IN ('EXC_COURSE','SUS_COURSE');

  BEGIN


  	-- Set the default message number

  	p_message_name  := null;

  	IF p_person_id IS NULL OR

  			p_course_cd IS NULL OR

  			p_sequence_number IS NULL THEN

  		RETURN TRUE;

  	END IF;

  	OPEN c_spo;

  	FETCH c_spo INTO v_exists;

  	IF c_spo%NOTFOUND THEN

  		CLOSE c_spo;

  		p_message_name  := 'IGS_PR_STPR_OUT_EXC_CR_SUS';


  		RETURN FALSE;

  	END IF;

  	CLOSE c_spo;

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

  		Fnd_message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;

  END; -- Function PRGP_VAL_SPC_SPO

  --

  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.


  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_spc_rowids(

  p_inserting IN BOOLEAN ,

  p_updating IN BOOLEAN ,

  p_deleting IN BOOLEAN ,

  p_message_name OUT NOCOPY VARCHAR2 )

  RETURN BOOLEAN IS

  	v_index			BINARY_INTEGER;

  BEGIN

  	-- Process saved rows.

  	FOR  v_index IN 1..gv_table_index - 1 LOOP


  		IF p_inserting OR p_deleting THEN

  			-- Update student progression outcome applied date

  			IGS_PR_GEN_004.IGS_PR_UPD_SPO_APLY_DT (

  					gt_rowid_table(v_index).person_id,

  					gt_rowid_table(v_index).course_cd,

  					gt_rowid_table(v_index).sequence_number);

  		END IF;

  	END LOOP;

  	RETURN TRUE;

  END prgp_prc_spc_rowids;

  --


  -- Routine to save key in a PL/SQL TABLE for the current commit.

  PROCEDURE prgp_set_spc_rowid(

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

  END prgp_set_spc_rowid;

END IGS_PR_VAL_SPC;

/
