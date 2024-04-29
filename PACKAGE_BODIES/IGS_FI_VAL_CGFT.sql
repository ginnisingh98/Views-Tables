--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_CGFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_CGFT" AS
/* $Header: IGSFI14B.pls 115.4 2002/11/29 00:17:50 nsidana ship $ */

-- bug id : 1956374
-- sjadhav , 28-aug-2001
-- remove  FUNCTION enrp_val_crs_gp_clsd

  -- Ensure IGS_PS_COURSE group fee triggers can be created.
  FUNCTION finp_val_cgft_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_cgft_ins
  	-- Validate IGS_PS_GRP_FEE_TRG.IGS_FI_FEE_TYPE.
  	-- If IGS_FI_FEE_TYPE.s_fee_trigger_cat <> IGS_PS_COURSE
  	-- then IGS_PS_COURSE group fee triggers cannot be defined.
  DECLARE
  	CURSOR c_ft(
  			cp_fee_type		IGS_FI_FEE_TYPE.fee_type%TYPE) IS
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
  		p_message_name := 'IGS_FI_PRGGRP_TRG_COURSE';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END finp_val_cgft_ins;
 --
  -- Ensure only one open IGS_PS_GRP_FEE_TRG record exists..
  FUNCTION finp_val_cgft_open(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_course_group_cd IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_cgft_open
  	-- validate that there no other 'open-ended' IGS_PS_GRP_FEE_TRG records for
  	-- the nominated course_group_cd and the same parent IGS_FI_F_CAT_FEE_LBL
  DECLARE
  	CURSOR c_cgft IS
  		SELECT	cgft.course_group_cd
  		FROM	IGS_PS_GRP_FEE_TRG cgft
  		WHERE	cgft.fee_cat		= p_fee_cat AND
  			cgft.fee_cal_type 	= p_fee_cal_type AND
  			cgft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			cgft.fee_type 		= p_fee_type AND
  			cgft.course_group_cd	= p_course_group_cd AND
  			cgft.create_dt		<> p_create_dt AND
  			cgft.logical_delete_dt IS NULL;
  	v_course_type	IGS_PS_TYPE_FEE_TRG.course_type%TYPE;
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	IF p_fee_cat IS NULL OR
  			p_fee_cal_type 		 IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_fee_type 		 IS NULL OR
  			p_course_group_cd 	 IS NULL OR
  			p_create_dt 		 IS NULL 	THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_cgft;
  	FETCH c_cgft INTO v_course_type;
  	IF (c_cgft%FOUND) THEN
  		p_message_name := 'IGS_FI_PRGGRP_FEETRG_OPEN';
  		CLOSE c_cgft;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cgft;
  	RETURN TRUE;
  END;
  END finp_val_cgft_open;

END IGS_FI_VAL_CGFT;

/
