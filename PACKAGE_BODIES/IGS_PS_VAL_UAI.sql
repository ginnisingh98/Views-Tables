--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_UAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_UAI" AS
/* $Header: IGSPS76B.pls 115.11 2002/12/26 07:34:30 sarakshi ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- ddey      09-JAN-2001     The function assp_val_uai_links is removed.
  --  The function was called from the library IGSPS092.pld and was called from the TBH
  --  IGSPI0KB.pls of the . This TBH is used for the form IGSPS092. All the calls for
  --  this functions are removed form the library and the TBH. Apart form this, the function
  --  assp_val_uai_links is not called from any other place .
  --  As per the requirement mentioned in the DLD Calcualtion of results Part 1 (Bug # 2162831)
  --  this  function is no more required. Hence it is removed.
  --smadathi    29-AUG-2001      The function genp_val_sdtt_sess removed .
  -----------------------------------------------------------------------------------


  --
  --
  -- Validate Calendar Instance for IGS_PS_COURSE Information.
  FUNCTION CRSP_VAL_CRS_CI(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sarakshi  23-dec-2002   Bug#2689625,removed the exception  part
  (reverse chronological order - newest change first)
  ***************************************************************/

  	cst_active	CONSTANT VARCHAR2(8) := 'ACTIVE';
  	v_s_cal_status	IGS_CA_STAT.s_cal_status%TYPE;
  	CURSOR 	c_cal_status(
  			cp_cal_type IGS_CA_INST_ALL.cal_type%TYPE,
  			cp_ci_sequence_number IGS_CA_INST_ALL.sequence_number%TYPE) IS
  		SELECT 	IGS_CA_STAT.s_cal_status
  		FROM	IGS_CA_INST, IGS_CA_STAT
  		WHERE	IGS_CA_INST.cal_type = cp_cal_type AND
  			IGS_CA_INST.sequence_number = cp_ci_sequence_number AND
  			IGS_CA_INST.cal_status = IGS_CA_STAT.cal_status;
  	v_other_detail	VARCHAR2(255);
  BEGIN
  	P_MESSAGE_NAME := null;
  	OPEN c_cal_status(
  			p_cal_type,
  			p_ci_sequence_number);
  	FETCH c_cal_status INTO v_s_cal_status;
  	CLOSE c_cal_status;
  	IF (v_s_cal_status = cst_active) THEN
  		RETURN TRUE;
  	ELSE
  		P_MESSAGE_NAME := 'IGS_PS_CAL_MUSTBE_ACTIVE';
  		RETURN FALSE;
  	END IF;
  END crsp_val_crs_ci;

  -- Retrofitted
   -- Retrofitted
  FUNCTION assp_val_uai_opt_ref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_assessment_type IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sarakshi  23-dec-2002   Bug#2689625,removed the outer exception

  (reverse chronological order - newest change first)
  ***************************************************************/
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uai_opt_ref
  	-- Validate that the reference number (when it has been set)
  	-- is unique within an assessment type within a IGS_PS_UNIT offering
  	-- pattern for non-examinable items which have not been deleted.
  	-- This is similar to ASSP_VAL_UAI_UNIQREF except that:
  	-- * The routine validates non-examinable items as opposed
  	--   to examinable items
  	-- * Reference is optional
  	-- * Reference when set is unique within an assessment type and
  	--   only for items that have not been deleted
  DECLARE
  	CURSOR c_uai IS
  		SELECT	'x'
  		FROM	igs_ps_unitass_item	uai,
  			IGS_AS_ASSESSMNT_ITM		ai,
  			IGS_AS_ASSESSMNT_TYP		atyp,
                  igs_ps_unit_ofr_opt uoo
  		WHERE	atyp.examinable_ind 	= 'N' AND
  			atyp.ASSESSMENT_TYPE 	= p_assessment_type AND
  			atyp.ASSESSMENT_TYPE 	= ai.ASSESSMENT_TYPE AND
  			uai.ass_id 		= ai.ass_id AND
  			uoo.unit_cd 		= p_unit_cd AND
  			uoo.version_number 	= p_version_number AND
  			uoo.cal_type 		= p_cal_type AND
  			uoo.ci_sequence_number 	= p_ci_sequence_number AND
  			uai.ass_id		<> p_ass_id AND
  			uai.sequence_number 	<> p_sequence_number AND
  			uai.reference 		= p_reference AND
  			uai.logical_delete_dt 	IS NULL and uai.uoo_id=uoo.uoo_id;
  	v_uai_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	IF p_reference IS NOT NULL THEN
  		-- Select from the table taking care not to select
  		-- record passed in.
  		OPEN c_uai;
  		FETCH c_uai INTO v_uai_exists;
  		IF c_uai%FOUND THEN
  			CLOSE c_uai;
  			P_MESSAGE_NAME := 'IGS_PS_REF_UAI_UNIQUE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_uai;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uai%ISOPEN THEN
  			CLOSE c_uai;
  		END IF;
  		RAISE;
  END;
  END assp_val_uai_opt_ref;
  --
  -- Retrofitted
   --


  -- Retrofitted
  FUNCTION assp_val_uai_sameref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sarakshi  23-dec-2002   Bug#2689625,removed the outer exception

  (reverse chronological order - newest change first)
  ***************************************************************/

  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uai_sameref
  	-- Validate reference number is the same for all items,
  	-- with the same assessment id, within a IGS_PS_UNIT offering pattern
  	-- for examinable items.
  DECLARE
  	CURSOR c_uai IS
  		SELECT	'x'
  		FROM	IGS_AS_ASSESSMNT_TYP		atyp,
  			IGS_AS_ASSESSMNT_ITM		ai,
  			igs_ps_unitass_item	uai,
                  igs_ps_unit_ofr_opt uoo
  		WHERE	atyp.examinable_ind 	= 'Y' AND
  			ai.assessment_type 	= atyp.assessment_type AND
  			uai.ass_id 		= ai.ass_id AND
  			uoo.unit_cd 		= p_unit_cd AND
  			uoo.version_number 	= p_version_number AND
  			uoo.cal_type 		= p_cal_type AND
  			uoo.ci_sequence_number 	= p_ci_sequence_number AND
  			uai.ass_id 		= p_ass_id AND
  			uai.sequence_number 	<> p_sequence_number AND
  			NVL(uai.reference, 'NULL') <> NVL(p_reference, 'NULL') and uai.uoo_id=uoo.uoo_id;
  	v_uai_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := null;
  	-- Check for the existence of a record
  	OPEN c_uai;
  	FETCH c_uai INTO v_uai_exists;
  	IF c_uai%NOTFOUND THEN
  		CLOSE c_uai;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_uai;
  	-- Records have been found
  	P_MESSAGE_NAME := 'IGS_AS_REF_UAI_SAME';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uai%ISOPEN THEN
  			CLOSE c_uai;
  		END IF;
  		RAISE;
  END;
  END assp_val_uai_sameref;
  --

    --
 END IGS_PS_VAL_UAI;

/
