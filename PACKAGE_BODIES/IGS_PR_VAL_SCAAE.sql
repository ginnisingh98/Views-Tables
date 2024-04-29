--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SCAAE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SCAAE" AS
/* $Header: IGSPR09B.pls 115.5 2002/11/29 02:45:53 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed.
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_exists"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_active"
  -------------------------------------------------------------------------------------------
  -- Validate the Student IGS_PS_COURSE Attempt Status for completion purposes.
  FUNCTION prgp_val_sca_cmplt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_sca_cmplt
  	-- Validate IGS_EN_STDNT_PS_ATT.course_attempt_status when setting the
  	--student_course_attepmt.course_rqrmnt_complete_ind or the
  	--IGS_PS_STDNT_APV_ALT.rqrmnts_complete_ind.
  	-- Cannot be set if course_attempt_status is 'DISCONTIN', 'INTERMIT' or
  	-- 'UNCONFIRM'.
  DECLARE
  	cst_discontinued		CONSTANT
  						IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'DISCONTIN';
  	cst_intermit		CONSTANT
  						IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INTERMIT';
  	cst_lapsed		CONSTANT
  						IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'LAPSED';
  	v_sca_course_attempt_status
  						IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	CURSOR c_sca IS
  		SELECT	sca.course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id And
  			sca.course_cd	= p_course_cd And
  			sca.course_attempt_status IN (
  						cst_discontinued,
  						cst_intermit,
  						cst_lapsed);
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	--1. Check parameters :
  	IF p_person_id IS NULL OR
  				p_course_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	--2. Get the IGS_PS_COURSE attempt status.
  	OPEN c_sca;
  	FETCH c_sca INTO v_sca_course_attempt_status;
  	IF c_sca%FOUND THEN
  		CLOSE c_sca;
  		IF  v_sca_course_attempt_status = cst_discontinued THEN
  			p_message_name := 'IGS_PR_DISCON_DT_BE_LIFTED';
  		ELSIF v_sca_course_attempt_status = cst_intermit THEN
  			p_message_name := 'IGS_PR_INTERMISSION_BE_LIFTED';
  		ELSE
  			p_message_name := 'IGS_PR_LAPSED_DT_BE_LIFTED';
  		END IF;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sca;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  END prgp_val_sca_cmplt;
  --
  -- Validate the Student Crs Attempt Approved Alt Exit complete indicator.
  FUNCTION prgp_val_scaae_cmplt(
  p_rqrmnts_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_rqrmnts_complete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_scaae_cmplt
  	-- Validate IGS_PS_STDNT_APV_ALT.rqrmnts_complete_dt
  	--	* Cannot be set if IGS_PS_STDNT_APV_ALT.rqrmnts_complete_ind
  	--	  is not also set.
  	--	* Must be set if IGS_PS_STDNT_APV_ALT.rqrmnts_complete_ind is set.
  	--	* If required, IGS_PS_STDNT_APV_ALT.rqrmnts_complete_dt cannot
  	--	  be futre dated.
  BEGIN
  	p_message_name := Null;
  	-- Check parameters.
  	IF p_rqrmnts_complete_ind IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_rqrmnts_complete_ind = 'Y' AND
  			p_rqrmnts_complete_dt IS NULL THEN
  		p_message_name := 'IGS_PR_SPECIFY_REQR_COMPL_DT';
  		RETURN FALSE;
  	END IF;
  	IF p_rqrmnts_complete_ind = 'N' AND
  			p_rqrmnts_complete_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_CANT_SPECIFY_REQR_COMP';
  		RETURN FALSE;
  	END IF;
  	-- rqrmnts_complete_dt cannot be future dated;
  	IF p_rqrmnts_complete_dt IS NOT NULL AND
  			p_rqrmnts_complete_dt > TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_REQR_DT_LE_CURR_DT';
  		RETURN FALSE;
  	END IF;
  	-- No error.
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCAAE.PRGP_VAL_SCAAE_CMPLT');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_scaae_cmplt;
END IGS_PR_VAL_SCAAE;

/
