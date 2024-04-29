--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SCSR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SCSR" AS
/* $Header: IGSEN65B.pls 115.5 2002/11/29 00:06:52 nsidana ship $ */
  --
  -- Validate the student course special requirement dates.
  FUNCTION enrp_val_scsr_dates(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_special_requirement_cd IN VARCHAR2 ,
  p_completed_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN	-- enrp_val_scsr_dates
  	-- * Validate that if the expiry_dt of the current record is NULL that another
  	--   IGS_PS_STDNT_SPL_REQ record does not does not exist for the same
  	--   IGS_EN_STDNT_PS_ATT with the same special_requirement_cd with a NULL
  	--   expiry_dt.
  	-- * Validate that the current record's completed_dt and expiry_dt do not
  	--    overlap with another IGS_PS_STDNT_SPL_REQ record for the same
  	--    IGS_EN_STDNT_PS_ATT with the same special_requirement_cd.
  	-- * Validation will fail if any of the following are true -
  	-- (a)   The current completed date is between an existing date range.
  	-- (b)  The current expiry date is between an existing date range.
  	-- (c)  The current dates overlap an entire existing date range.
  	-- (d)  The current dates overlap an existing completed date.
  	-- (e) The current open date range is before an existing completed
  	-- or expiry date.
  DECLARE
  	v_dummy 	VARCHAR2(1);
  	v_ret_val	BOOLEAN := TRUE;
  	CURSOR c_scsr1 IS
  		SELECT	'X'
  		FROM	IGS_PS_STDNT_SPL_REQ scsr1
  		WHERE	scsr1.person_id 		= p_person_id AND
  			scsr1.course_cd 		= p_course_cd AND
  			scsr1.special_requirement_cd 	= p_special_requirement_cd AND
  			scsr1.completed_dt 		<> p_completed_dt AND
  			scsr1.expiry_dt IS NULL;
  	CURSOR c_scsr2 IS
  		SELECT	scsr2.completed_dt,
  			scsr2.expiry_dt
  		FROM	IGS_PS_STDNT_SPL_REQ scsr2
  		WHERE	scsr2.person_id 		= p_person_id AND
  			scsr2.course_cd 		= p_course_cd AND
  			scsr2.special_requirement_cd 	= p_special_requirement_cd AND
  			scsr2.completed_dt 		<> p_completed_dt;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- 1.	Check the passed parameters.
  	IF p_person_id IS NULL OR
     			p_course_cd IS NULL OR
     			p_special_requirement_cd IS NULL OR
     			p_completed_dt IS NULL THEN
  		p_message_name := null;
  		RETURN v_ret_val;
  	END IF;
  	-- 2.	Check if p_expiry_dt is NULL and that no other matching records exist
  	--      with a NULL expiry_dt.
	-- New message created for bug#2283458
  	OPEN c_scsr1;
  	FETCH c_scsr1 INTO v_dummy;
  	IF p_expiry_dt IS NULL THEN
  		IF (c_scsr1%FOUND) THEN
  			CLOSE c_scsr1;
  			p_message_name := 'IGS_EN_COMPLDT_OVERLAPS';
  			v_ret_val := FALSE;
  			RETURN v_ret_val;
  		END IF;
  	END IF;
  	CLOSE c_scsr1;
  	-- 3.	Find all of the matching records accept for the record passed in.
  	-- 4.	Loop through the matching records checking for records with
  	--      overlapping dates.
  	FOR v_scsr2_rec IN c_scsr2 LOOP
  		IF v_scsr2_rec.expiry_dt IS NOT NULL THEN
  			-- Validate (a),(b),(c),(e)
  			IF p_completed_dt >= v_scsr2_rec.completed_dt AND
  					p_completed_dt <= v_scsr2_rec.expiry_dt THEN
  				p_message_name := 'IGS_EN_COMPLDT_BTWN_STDT_COMD';
  				v_ret_val := FALSE;
  			END IF;
  			IF p_expiry_dt IS NOT NULL THEN
  				-- Validate (b),(c)
  				IF p_expiry_dt >= v_scsr2_rec.completed_dt AND
  						p_expiry_dt <= v_scsr2_rec.expiry_dt THEN
  					p_message_name := 'IGS_EN_EXPDT_BTWN_EXPDT_COMPL';
  					v_ret_val := FALSE;
  				END IF;
  				IF p_completed_dt <= v_scsr2_rec.completed_dt AND
  						p_expiry_dt >= v_scsr2_rec.expiry_dt THEN
  					p_message_name := 'IGS_EN_COMPLDT_EXPDT_ENCOMPAS';
  					v_ret_val := FALSE;
  				END IF;
  			ELSE
  				-- p_expiry_dt IS NULL and Validate (e)
  				IF p_completed_dt <= v_scsr2_rec.completed_dt OR
  						p_completed_dt <= v_scsr2_rec.expiry_dt THEN
  					p_message_name := 'IGS_EN_UNEXP_RECORD_OVERLAPS';
  					v_ret_val := FALSE;
  				END IF;
  			END IF;
  		ELSE
  			-- expiry_dt IS NULL and Validate (d)
  			IF p_completed_dt >= v_scsr2_rec.completed_dt OR
  					p_expiry_dt  >= v_scsr2_rec.completed_dt THEN
  				p_message_name := 'IGS_EN_DT_OVERLAP_UNEXPIRED';
  				v_ret_val := FALSE;
  			END IF;
  		END IF;
  	END LOOP; -- c_scsr2
  	RETURN v_ret_val;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_scsr1%ISOPEN) THEN
  			CLOSE c_scsr1;
  		END IF;
  		IF (c_scsr2%ISOPEN) THEN
  			CLOSE c_scsr2;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCSR.enrp_val_scsr_dates');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_scsr_dates;
  --
  -- Validate the student course special requirement completed date.
  FUNCTION enrp_val_scsr_cmp_dt(
  p_completed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN	-- enrp_val_scsr_cmp_dt
  	-- Validate thata IGS_PS_STDNT_SPL_REQ.completed_dt is less
  	-- than or equal to today's date/
  DECLARE
  	CURSOR	c_scsr IS
  		SELECT	'x'
  		FROM	dual
  		WHERE	SYSDATE < p_completed_dt;
  	v_c_scsr_found		VARCHAR2(1) DEFAULT NULL;
  BEGIN
  	-- initialise p_message_name
  	p_message_name := null;
  	-- Check p_completed_dt
  	IF p_completed_dt IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Check if the sysdate is less than or equal to p_completed_dt
  	OPEN c_scsr;
  	FETCH c_scsr INTO v_c_scsr_found;
  	IF (c_scsr%FOUND) THEN
  		CLOSE c_scsr;
  		p_message_name := 'IGS_EN_COMPLT_LE_TODAY_DATE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_scsr;
   	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_scsr%ISOPEN) THEN
  			CLOSE c_scsr;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCSR.enrp_val_scsr_cmp_dt');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_scsr_cmp_dt;
  --
  -- Validate the student course special requirement expiry date.
  FUNCTION enrp_val_scsr_exp_dt(
  p_completed_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_val_scsr_exp_dt
  	-- Validate that IGS_PS_STDNT_SPL_REQ.expiry_dt
  	-- if it is not NULL, it must be greater than or equal to the completed_dt
  DECLARE
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_completed_dt IS NULL OR
  			p_expiry_dt IS NULL THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	-- 2.	Check that the p_expiry_dt is not less than the p_completed_dt.
  	IF p_expiry_dt < p_completed_dt THEN
  		p_message_name := 'IGS_EN_EXPDT_GE_COMPLDT';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCSR.enrp_val_scsr_exp_dt');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_scsr_exp_dt;
  --
  -- Validate the student course special requirement SCA status.
  FUNCTION enrp_val_scsr_scas(
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_val_scsr_scas
  	-- Validate the IGS_EN_STDNT_PS_ATT.course_attempt_status is
  	-- ENROLLED, COMPLETED, INACTIVE or INTERMIT (not DISCONTIN,
  	-- DELETED, LAPSED or UNCONFIRM) before inserting, updating
  	-- or deleting IGS_PS_STDNT_SPL_REQ records.
  DECLARE
  	CURSOR	c_sca IS
  		SELECT	course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id	= p_person_id AND
  			course_cd	= p_course_cd;
  	v_course_attempt_status		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  BEGIN
  	p_message_name := null;
  	-- Check parameters
  	IF p_person_id IS NULL OR p_course_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the course_attempt_status for the specified
  	-- IGS_EN_STDNT_PS_ATT.
  	OPEN c_sca;
  	FETCH c_sca INTO v_course_attempt_status;
  	IF (c_sca%FOUND) THEN
  		IF v_course_attempt_status IN (
  						'DISCONTIN',
  						'DELETED',
  						'LAPSED',
  						'UNCONFIRM') THEN
  			CLOSE c_sca;
  			p_message_name := 'IGS_EN_STUDPRG_SPLREQ_NOTIUD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_sca;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sca%ISOPEN) THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCSR.enrp_val_scsr_scas');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_scsr_scas;
  --
  -- Validate the special requirement closed indicator.
  FUNCTION enrp_val_srq_closed(
  p_special_requirement_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN	-- enrp_val_srq_closed
  	-- Validate that the IGS_GE_SPL_REQ is not closed
  DECLARE
  	CURSOR	c_srq IS
  		SELECT	'x'
  		FROM	IGS_GE_SPL_REQ	srq
  		WHERE	srq.special_requirement_cd	= p_special_requirement_cd AND
  			srq.closed_ind			= 'Y';
  	v_closed_ind		VARCHAR2(1) DEFAULT NULL;
  BEGIN
  	p_message_name := null;
  	-- Check p_special_requirement_cd
  	IF p_special_requirement_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Check that the closed_ind <> 'Y'
  	OPEN c_srq;
  	FETCH c_srq INTO v_closed_ind;
  	IF (c_srq%FOUND) THEN
  		CLOSE c_srq;
  		p_message_name := 'IGS_EN_SPLREQ_CLOSED';
  		RETURN  FALSE;
  	END IF;
  	CLOSE c_srq;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_srq%ISOPEN) THEN
  			CLOSE c_srq;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCSR.enrp_val_srq_closed');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_srq_closed;
  --
END IGS_EN_VAL_SCSR;

/
