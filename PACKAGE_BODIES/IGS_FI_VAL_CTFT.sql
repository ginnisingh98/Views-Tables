--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_CTFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_CTFT" AS
/* $Header: IGSFI16B.pls 115.5 2002/11/29 00:18:09 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  -------------------------------------------------------------------------------------------

  -- Ensure IGS_PS_COURSE group fee triggers can be created.
  FUNCTION finp_val_ctft_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_ctft_ins
  	-- Validate IGS_PS_TYPE_FEE_TRG.IGS_FI_FEE_TYPE.
  	-- If IGS_FI_FEE_TYPE.s_fee_trigger_cat <> 'COURSE'
  	--  then IGS_PS_COURSE type fee triggers cannot be defined.
  DECLARE
  	CURSOR c_ft(
  			cp_fee_type		IGS_FI_FEE_TYPE.fee_type	%TYPE) IS
  		SELECT	s_fee_trigger_cat
  		FROM	IGS_FI_FEE_TYPE
  		WHERE	fee_type = cp_fee_type;
  	v_ft_rec		c_ft%ROWTYPE;
  	cst_course		CONSTANT VARCHAR2(10) := 'COURSE';
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	-- Check parameters
  	IF p_fee_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the system fee trigger category of the IGS_FI_FEE_TYPE.
  	OPEN c_ft (p_fee_type);
  	FETCH c_ft INTO v_ft_rec;
  	IF c_ft%NOTFOUND THEN
  		CLOSE c_ft;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ft;
  	IF v_ft_rec.s_fee_trigger_cat <> cst_course THEN
  		p_message_name := 'IGS_FI_PRGTYPE_TRG_COURSE';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END finp_val_ctft_ins;
  --
  -- Ensure only one open IGS_PS_TYPE_FEE_TRG record exists..
  FUNCTION finp_val_ctft_open(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_course_type IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_ctft_open
  	-- validate that there no other 'open-ended' IGS_PS_GRP_FEE_TRG records for
  	-- the nominated IGS_PS_TYPE and the same parent IGS_FI_F_CAT_FEE_LBL
  DECLARE
  	CURSOR c_ctft IS
  		SELECT	ctft.course_type
  		FROM	IGS_PS_TYPE_FEE_TRG ctft
  		WHERE	ctft.fee_cat		= p_fee_cat AND
  			ctft.fee_cal_type 	= p_fee_cal_type AND
  			ctft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			ctft.fee_type		= p_fee_type AND
  			ctft.course_type	= p_course_type AND
  			ctft.create_dt		<> p_create_dt AND
  			ctft.logical_delete_dt IS NULL;
  	v_course_type	IGS_PS_TYPE_FEE_TRG.course_type%TYPE;
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	IF p_fee_cat IS NULL OR
  			p_fee_cal_type 		 IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_fee_type 		 IS NULL OR
  			p_course_type 		 IS NULL OR
  			p_create_dt 		 IS NULL 	THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_ctft;
  	FETCH c_ctft INTO v_course_type;
  	IF (c_ctft%FOUND) THEN
  		p_message_name := 'IGS_FI_PRGTYPE_FEETRG_OPEN';
  		CLOSE c_ctft;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ctft;
  	RETURN TRUE;
  END;
  END finp_val_ctft_open;


  --
END IGS_FI_VAL_CTFT;

/
