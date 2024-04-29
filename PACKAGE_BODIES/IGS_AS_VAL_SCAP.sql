--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_SCAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_SCAP" AS
/* $Header: IGSAS28B.pls 115.8 2003/05/27 18:45:13 anilk ship $ */

  --
  -- Validate special consideration category closed indicator.
  FUNCTION assp_val_spcc_closed(
  p_spcl_consideration_cat  IGS_AS_SPCL_CONS_CAT.spcl_consideration_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- assp_val_spcc_closed
  	-- Validate the special consideration category closed indicator.
  DECLARE
  	v_closed_ind	IGS_AS_SPCL_CONS_CAT.closed_ind%TYPE;
  	CURSOR c_spcc IS
  		SELECT 	closed_ind
  		FROM	IGS_AS_SPCL_CONS_CAT
  		WHERE	spcl_consideration_cat = p_spcl_consideration_cat;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_spcc;
  	FETCH c_spcc INTO v_closed_ind;
  	IF (c_spcc%NOTFOUND) THEN
  		CLOSE c_spcc;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'Y') THEN
  		CLOSE c_spcc;
  		p_message_name := 'IGS_AS_SPLCONS_CAT_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_spcc;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_SCAP.assp_val_spcc_closed');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  END assp_val_spcc_closed;
  --
  -- Validate special consideration outcome closed indicator.
  FUNCTION assp_val_spco_closed(
  p_spcl_consideration_outcome  IGS_AS_SPCL_CONS_OUT.spcl_consideration_outcome%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- assp_val_spco_closed
  	-- Validate the special conderation outcome closed indicator
  	-- also caters for the sought outcome closed indicator as sought outcomes
  	-- exist in
  	-- the same table as special consideration outcomes (ie; the actual outcome of
  	-- an application) and are simply a subset of the special consideration
  	-- outcomes.
  DECLARE
  	v_closed_ind	IGS_AS_SPCL_CONS_OUT.closed_ind%TYPE;
  	CURSOR c_spco IS
  		SELECT 	closed_ind
  		FROM	IGS_AS_SPCL_CONS_OUT
  		WHERE	spcl_consideration_outcome = p_spcl_consideration_outcome;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_spco;
  	FETCH c_spco INTO v_closed_ind;
  	IF (c_spco%NOTFOUND) THEN
  		CLOSE c_spco;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'Y') THEN
  		CLOSE c_spco;
  		p_message_name := 'IGS_AS_SPLCONS_OUTCOME_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_spco;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_SCAP.assp_val_spco_closed');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  END assp_val_spco_closed;
  --
  -- Validate SUAAI or SCAP can be created
  FUNCTION assp_val_suaai_ins(
  p_person_id  IGS_AS_SU_ATMPT_ITM.person_id%TYPE ,
  p_course_cd  IGS_AS_SU_ATMPT_ITM.course_cd%TYPE ,
  p_unit_cd  IGS_AS_SU_ATMPT_ITM.unit_cd%TYPE ,
  p_cal_type  IGS_AS_SU_ATMPT_ITM.cal_type%TYPE ,
  p_ci_sequence_number  IGS_AS_SU_ATMPT_ITM.ci_sequence_number%TYPE ,
  p_ass_id  IGS_AS_SU_ATMPT_ITM.ass_id%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_attempt_status	IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
  	l_uoo_id                igs_en_su_attempt.uoo_id%TYPE;
  	v_person_id		IGS_AS_UAI_SUA_V.person_id%TYPE;
  	cst_unconfirm		CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE :=
  					'UNCONFIRM';
  	cst_enrolled		CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE :=
  					'ENROLLED';
        l_dummy                 VARCHAR2(1);
  	CURSOR c_sua IS
  		SELECT 	sua.unit_attempt_status,
  		        sua.uoo_id
  		FROM	IGS_EN_SU_ATTEMPT sua
  		WHERE	sua.person_id		= p_person_id	AND
  			sua.course_cd		= p_course_cd	AND
                -- anilk, 22-Apr-2003, Bug# 2829262
  			sua.uoo_id	        = p_uoo_id;
  	CURSOR c_suv IS
  		SELECT	suv.person_id
  		FROM	IGS_AS_UAI_SUA_V suv
  		WHERE	suv.person_id			= p_person_id 		AND
  			suv.course_cd			= p_course_cd 		AND
                -- anilk, 22-Apr-2003, Bug# 2829262
  			suv.uoo_id      		= p_uoo_id      	AND
  			suv.ass_id			= p_ass_id		AND
  			suv.uai_logical_delete_dt	IS NULL;
  -- The Following cursor is added by Nishikant -15JAN2002- Enh Bug#2162831
  -- to check whether the assessment item is available at unitsection level or not
  -- Changed as required by the JOB.Maintain the student attempt Items and the
  -- form IGSAS016
        CURSOR c_usv(l_usv_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
                SELECT  'X'
                FROM    igs_ps_unitass_item_v usv
                WHERE   usv.ass_id = p_ass_id AND
                        usv.uoo_id = l_usv_uoo_id AND
                        usv.logical_delete_dt IS NULL;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	OPEN c_sua;
  	FETCH c_sua INTO v_attempt_status,l_uoo_id;
  	IF (c_sua%NOTFOUND) THEN
  		CLOSE c_sua;
  		RAISE NO_DATA_FOUND;
  	ELSE
  		IF (v_attempt_status NOT IN(cst_unconfirm, cst_enrolled)) THEN
  			IF (v_attempt_status <> 'COMPLETED') THEN
  				p_message_name := 'IGS_AS_SUA_STATUS_INVALID';
  				CLOSE c_sua;
  				RETURN FALSE;
  			ELSE
  				p_message_name := 'IGS_AS_SUA_STATUS_INVALID_COM';
  				CLOSE c_sua;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	CLOSE c_sua;

  	OPEN c_usv(l_uoo_id);
  	FETCH c_usv INTO l_dummy;
  	IF c_usv%FOUND THEN
  	    CLOSE c_usv;
  	    RETURN TRUE;
  	ELSE
  	    OPEN c_suv;
  	    FETCH c_suv INTO v_person_id;
  	    IF (c_suv%NOTFOUND) THEN
  		p_message_name := 'IGS_AS_SUA_ASSITEM_INVALID';
  		CLOSE c_suv;
  		RETURN FALSE;
  	    END IF;
  	    CLOSE c_suv;
  	    RETURN TRUE;
        END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_SCAP.assp_val_suaai_ins');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  END assp_val_suaai_ins;
  --
  -- Retrofitted
  FUNCTION assp_val_suaai_delet(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_id  IGS_AS_SU_ATMPT_ITM.ass_id%TYPE ,
  p_creation_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_suaai_delet
  	-- This module validates the deletion date a suaai record
  DECLARE
  	CURSOR c_suaai IS
  	SELECT	suaai.logical_delete_dt
  	FROM	IGS_AS_SU_ATMPT_ITM	suaai
  	WHERE	suaai.person_id		= p_person_id AND
  		suaai.course_cd		= p_course_cd AND
        -- anilk, 22-Apr-2003, Bug# 2829262
  		suaai.uoo_id            = p_uoo_id AND
  		suaai.ass_id		= p_ass_id AND
  		suaai.creation_dt	= p_creation_dt AND
  		suaai.logical_delete_dt IS NOT NULL;
  	v_suaai_logical_delete_dt	DATE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_suaai;
  	FETCH c_suaai INTO v_suaai_logical_delete_dt;
  	IF c_suaai%FOUND THEN
  	CLOSE c_suaai;
  		p_message_name := 'IGS_FI_ELERNG_RATE_FEEASS_RAT';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	CLOSE c_suaai;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_SCAP.assp_val_suaai_delet');
	       IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END assp_val_suaai_delet;
END IGS_AS_VAL_SCAP;

/
