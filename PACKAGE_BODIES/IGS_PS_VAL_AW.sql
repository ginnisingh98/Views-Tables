--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_AW" AS
/* $Header: IGSPS12B.pls 115.5 2003/06/09 04:41:10 smvk ship $ */

  -- Validate update to IGS_PS_AWD type.
  FUNCTION crsp_val_aw_upd(
  p_award_cd  IGS_PS_AWD.award_cd%TYPE ,
  p_new_award_type  IGS_PS_AWD.s_award_type%TYPE ,
  p_old_award_type  IGS_PS_AWD.s_award_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_aw_upd
  	-- This routine validates changes to IGS_PS_AWD records. It checks;
  	-- change of system IGS_PS_AWD type does not invalidate IGS_GR_GRADUAND,
  	-- IGS_PS_COURSE IGS_PS_AWD or special IGS_PS_AWD details
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              :
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smvk     03-Jun-2003   Bug # 2858436. Modified the cursor c_caw to select open program awards only.
   ***************************************************************/

  DECLARE
  	CURSOR c_caw IS
  		SELECT 	'x'
  		FROM	IGS_PS_AWARD	caw
  		WHERE	caw.award_cd	= p_award_cd
                AND     caw.closed_ind  = 'N';
  	CURSOR c_gr IS
  		SELECT	'x'
  		FROM	IGS_GR_GRADUAND	gr
  		WHERE	gr.award_cd	= p_award_cd;
  	CURSOR c_spa IS
  		SELECT	'x'
  		FROM	IGS_GR_SPECIAL_AWARD	spa
  		WHERE	spa.award_cd	= p_award_cd;
  	v_c_exists	VARCHAR2(1);
  	cst_course	CONSTANT VARCHAR2(10) := 'COURSE';
  	cst_honorary	CONSTANT VARCHAR2(10) := 'HONORARY';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Check Parameters.
  	IF p_award_cd IS NULL OR
  			p_new_award_type IS NULL OR
  			p_old_award_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_new_award_type = p_old_award_type THEN
  		RETURN TRUE;
  	END IF;
  	IF p_old_award_type = cst_course THEN
  		OPEN c_caw;
  		FETCH c_caw INTO v_c_exists;
  		IF c_caw%FOUND THEN
  			CLOSE c_caw;
  			p_message_name := 'IGS_GR_COUR_REC_IN_USE_UPD_NA';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_caw;
  	ELSIF p_old_award_type = cst_honorary THEN
  		OPEN c_gr;
  		FETCH c_gr INTO v_c_exists;
  		IF c_gr%FOUND THEN
  			CLOSE c_gr;
  			p_message_name := 'IGS_GR_GRAD_REC_IN_USE_UPD_NA';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_gr;
  	ELSE --special IGS_PS_AWDs
  		OPEN c_spa;
  		FETCH c_spa INTO v_c_exists;
  		IF c_spa%FOUND THEN
  			CLOSE c_spa;
  			p_message_name := 'IGS_GR_SPEC_REC_IN_USE_UPD_NA';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_spa;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_caw %ISOPEN THEN
  			CLOSE c_caw;
  		END IF;
  		IF c_gr %ISOPEN THEN
  			CLOSE c_gr;
  		END IF;
  		IF c_spa %ISOPEN THEN
  			CLOSE c_spa;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
  		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_AW.crsp_val_aw_upd');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_aw_upd;

  -- Validate a testamur type is not closed.
  FUNCTION crsp_val_tt_closed(
  p_testamur_type  IGS_GR_TESTAMUR_TYPE.testamur_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_tt_closed
  	-- Validate if the testamur type is closed.
  DECLARE
  	CURSOR c_tt IS
  		SELECT	'x'
  		FROM	IGS_GR_TESTAMUR_TYPE	tt
  		WHERE	testamur_type	= p_testamur_type AND
  			closed_ind 	= 'Y';
  	v_tt_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	OPEN c_tt;
  	FETCH c_tt INTO v_tt_exists;
  	IF c_tt%FOUND THEN
  		CLOSE c_tt;
  		p_message_name := 'IGS_PS_TESTAMUR_TYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_tt;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_tt%ISOPEN THEN
  			CLOSE c_tt;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
  		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_AW.crsp_val_tt_closed');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_tt_closed;

END IGS_PS_VAL_AW;

/
