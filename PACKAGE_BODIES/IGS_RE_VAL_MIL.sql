--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_MIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_MIL" AS
/* $Header: IGSRE09B.pls 120.0 2005/06/01 16:27:42 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  --vkarthik    23-Apr-2004     Removed validations that checks for the milestone due date to be greater than sysdate
  --                            in RESP_VAL_MIL_DUE
  -------------------------------------------------------------------------------------------
  -- To validate the logical uniqueness of IGS_PR_MILESTONEs
  FUNCTION RESP_VAL_MIL_UNIQ(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_mil_uniq
  	-- Validate that there are no ?logically? duplicate IGS_PR_MILESTONE records
  	-- for a candidate, where the IGS_PR_MILESTONE type and due date are the same.
  DECLARE
  	v_return_false	BOOLEAN;
  	CURSOR c_mil IS
  	SELECT	count('x') duplicate_cnt
  	FROM	IGS_PR_MILESTONE	mil
  	WHERE	mil.person_id		= p_person_id and
  		mil.ca_sequence_number	= p_ca_sequence_number
  	GROUP BY
  		mil.milestone_type,
  		mil.due_dt;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- To quit out NOCOPY of the for loop
  	v_return_false := FALSE;
  	FOR v_mil_rec IN c_mil LOOP
  		IF v_mil_rec.duplicate_cnt > 1 THEN
  			p_message_name := 'IGS_RE_2_MILSTON_HAV_SAMEDUE';
  			v_return_false := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_return_false THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_mil%ISOPEN THEN
  			CLOSE c_mil;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_mil_uniq;
  --
  -- To validate the delete of IGS_PR_MILESTONE details
  FUNCTION RESP_VAL_MIL_DEL(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_milestone_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- resp_val_mil_del
  	-- Validate deletion of IGS_PR_MILESTONE record, checking for:
  	-- * Cannot delete IGS_PR_MILESTONE if status <> 'PLANNED'
  	-- * Cannot delete IGS_PR_MILESTONE which has had a status other than planned
  DECLARE
  	cst_planned	CONSTANT	IGS_PR_MILESTONE.milestone_status%TYPE := 'PLANNED';
  	cst_replanned	CONSTANT	IGS_PR_MILESTONE.milestone_status%TYPE := 'RE-PLANNED';
  	cst_achieved	CONSTANT	IGS_PR_MILESTONE.milestone_status%TYPE := 'ACHIEVED';
  	v_s_milestone_status		IGS_PR_MS_STAT.s_milestone_status%TYPE;
  	v_milh_mst_exists		VARCHAR2(1);
  	CURSOR c_mst IS
  		SELECT	mst.s_milestone_status
  		FROM	IGS_PR_MS_STAT	mst
  		WHERE	mst.milestone_status	= p_milestone_status;
  	CURSOR c_milh_mst IS
  		SELECT	'x'
  		FROM	IGS_PR_MILESTONE_HST	milh,
  			IGS_PR_MS_STAT	mst
  		WHERE	milh.person_id		= p_person_id AND
  			milh.ca_sequence_number	= p_ca_sequence_number AND
  			milh.sequence_number	= p_sequence_number AND
  			milh.milestone_status	IS NOT NULL AND
  			mst.milestone_status	= milh.milestone_status AND
  			mst.s_milestone_status	IN (
  						cst_planned,
  						cst_replanned,
  						cst_achieved);
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Select detail from IGS_PR_MILESTONE status
  	OPEN c_mst;
  	FETCH c_mst INTO v_s_milestone_status;
  	IF c_mst%FOUND THEN
  		CLOSE c_mst;
  		-- If not planned then reject
  		IF v_s_milestone_status <> cst_planned THEN
  			p_message_name := 'IGS_RE_PLAN_MILESTON_CAN_DEL';
  			RETURN FALSE;
  		END IF;
  		-- if ever been other than planned then reject
  		OPEN c_milh_mst;
  		FETCH c_milh_mst INTO v_milh_mst_exists;
  		IF c_milh_mst%FOUND THEN
  			CLOSE c_milh_mst;
  			p_message_name := 'IGS_RE_CANT_DEL_MILESTONE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_milh_mst;
  	ELSE
  		CLOSE c_mst;
  	END IF;
  	RETURN TRUE ;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_mst%ISOPEN THEN
  			CLOSE c_mst;
  		END IF;
  		IF c_milh_mst%ISOPEN THEN
  			CLOSE c_milh_mst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_mil_del;
  --
  -- To  validate IGS_PR_MILESTONE actual date reached
  FUNCTION RESP_VAL_MIL_ACTUAL(
  p_milestone_status IN VARCHAR2 ,
  p_actual_reached_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_mil_actual
  	-- Purpose: Briefly explain the functionality of the function
  	-- Validate the IGS_PR_MILESTONE.actual_dt_reached, checking for:
  	--	- Cannot be a future date
  	--	- Can only be set when IGS_PR_MILESTONE status is ACHIEVED or FAILED
  	--	- Must be set when IGS_PR_MILESTONE status is ACHIEVED or FAILED
  DECLARE
  	CURSOR c_mst IS
  		SELECT	mst.s_milestone_status
  		FROM	IGS_PR_MS_STAT	mst
  		WHERE	mst.milestone_status	= p_milestone_status;
  	v_mst_status	IGS_PR_MS_STAT.s_milestone_status%TYPE;
  	cst_achieved	CONSTANT IGS_PR_MS_STAT.s_milestone_status%TYPE := 'ACHIEVED';
  	cst_failed	CONSTANT IGS_PR_MS_STAT.s_milestone_status%TYPE := 'FAILED';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_mst;
  	FETCH c_mst INTO v_mst_status;
  	IF c_mst%NOTFOUND THEN
  		CLOSE c_mst;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_mst;
  	IF p_actual_reached_dt IS NOT NULL THEN
  		IF v_mst_status NOT IN (
  					cst_achieved,
  					cst_failed) THEN
  			p_message_name := 'IGS_RE_CANT_SET_MILESTONE';
  			RETURN FALSE;
  		END IF;
  		IF p_actual_reached_dt > TRUNC(SYSDATE) THEN
  			p_message_name := 'IGS_RE_ACTUAL_DT_CANT_FUT_DT';
  			RETURN FALSE;
  		END IF;
  	ELSE -- p_actual_reached_dt IS NULL
  		IF v_mst_status IN (
  				cst_achieved,
  				cst_failed) THEN
  			p_message_name := 'IGS_RE_SET_ACTUAL_DATE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_mst%ISOPEN THEN
  			CLOSE c_mst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_mil_actual;
  --
  -- To validate IGS_PR_MILESTONE notification days
  FUNCTION RESP_VAL_MIL_DAYS(
  p_milestone_type IN VARCHAR2 ,
  p_milestone_status IN VARCHAR2 ,
  p_due_dt IN DATE ,
  p_old_imminent_days IN NUMBER ,
  p_new_imminent_days IN NUMBER ,
  p_old_reminder_days IN NUMBER ,
  p_new_reminder_days IN NUMBER ,
  p_old_re_reminder_days IN NUMBER ,
  p_new_re_reminder_days IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_mil_days
  	-- Validate the IGS_PR_MILESTONE.{ovrd_ntfctn_imminent_days,
  	--	ovrd_ntfctn_reminder_days, ovrd_ntfctn_re_reminder_days}
  	--	fields, checking,
  	-- Can only be changed if s_milestone_status is ?PLANNED? or ?RE-PLANNED?.
  	-- The imminent_days cannot be changed to bring the notification days
  	--	prior to the current date.
  	-- The re_reminder_days can only be set if the reminder_days are set.
  DECLARE
  	cst_planned	CONSTANT	IGS_PR_MS_STAT.s_milestone_status%TYPE := 'PLANNED';
  	cst_replanned	CONSTANT
  					IGS_PR_MS_STAT.s_milestone_status%TYPE := 'RE-PLANNED';
  	v_mst_status	IGS_PR_MS_STAT.s_milestone_status%TYPE;
  	CURSOR c_mst IS
  		SELECT	mst.s_milestone_status
  		FROM	IGS_PR_MS_STAT	mst
  		WHERE	mst.milestone_status	= p_milestone_status;
  	v_mty_nrd	IGS_PR_MILESTONE.ovrd_ntfctn_reminder_days%TYPE;
  	v_mty_nrrd	IGS_PR_MILESTONE.ovrd_ntfctn_re_reminder_days%TYPE;
  	CURSOR c_mty IS
  		SELECT	mty.ntfctn_re_reminder_days,
  			mty.ntfctn_reminder_days
  		FROM	IGS_PR_MILESTONE_TYP		mty
  		WHERE	mty.milestone_type	= p_milestone_type;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_mst ;
  	FETCH c_mst INTO v_mst_status;
  	IF c_mst%NOTFOUND THEN
  		CLOSE c_mst;
  		-- invalid data
  		RETURN TRUE;
  	END IF;
  	CLOSE c_mst;
  	IF v_mst_status NOT IN (cst_planned,
  				cst_replanned) AND
  			(NVL(p_old_imminent_days,0) <> NVL(p_new_imminent_days,0) OR
  			NVL(p_old_reminder_days,0) <> NVL(p_new_reminder_days,0) OR
  			NVL(p_old_re_reminder_days,0) <> NVL(p_new_re_reminder_days,0)) THEN
  		p_message_name := 'IGS_RE_CANT_CHANGE_NOTIF_DAYS';
  		RETURN FALSE;
  	END IF;
  	IF NVL(p_old_imminent_days,0) <> NVL(p_new_imminent_days,0) THEN
  		IF (p_due_dt - p_new_imminent_days) < TRUNC(SYSDATE) THEN
  			p_message_name := 'IGS_RE_CANT_CHANG_IMMINENT_DY';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF NVL(p_old_reminder_days,0) <> NVL(p_new_reminder_days,0) OR
  			NVL(p_old_re_reminder_days,0) <> NVL(p_new_re_reminder_days,0) THEN
  		OPEN c_mty;
  		FETCH c_mty INTO v_mty_nrrd, v_mty_nrd;
  		IF c_mty%NOTFOUND THEN
  			CLOSE c_mty;
  			-- invalid parameters
  			RETURN TRUE;
  		END IF;
  		CLOSE c_mty;
  		IF NVL(p_new_re_reminder_days,v_mty_nrrd) IS NOT NULL AND
  				NVL(p_new_reminder_days,v_mty_nrd) IS NULL THEN
  			p_message_name := 'IGS_RE_CANT_ENTER_REMINDER_DY';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_mst %ISOPEN THEN
  			CLOSE c_mst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_mil_days;
  --
  -- To validate IGS_PR_MILESTONE due date
  FUNCTION RESP_VAL_MIL_DUE(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_old_milestone_status IN VARCHAR2 ,
  p_new_milestone_status IN VARCHAR2 ,
  p_old_due_dt IN DATE ,
  p_new_due_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_mil_due
  	-- Validate IGS_PR_MILESTONE.due_dt checking for,
  	--	If the IGS_PR_MILESTONE status has been changed to RE-PLANNED then
  	--		the due_dt must have been changed.
  DECLARE
  	cst_planned	CONSTANT	IGS_PR_MS_STAT.s_milestone_status%TYPE := 'PLANNED';
  	cst_replanned	CONSTANT	IGS_PR_MS_STAT.s_milestone_status%TYPE := 'RE-PLANNED';
  	CURSOR c_mil IS
  		SELECT	mil.due_dt
  		FROM	IGS_PR_MILESTONE mil
  		WHERE	mil.person_id	= p_person_id	AND
  			mil.ca_sequence_number	= p_ca_sequence_number	AND
  			NVL(mil.preced_sequence_number,0)	= p_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF NVL(p_old_due_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
  					p_new_due_dt THEN
  		FOR v_mil_rec IN c_mil
  		LOOP
  			IF p_new_due_dt > v_mil_rec.due_dt THEN
  				p_message_name := 'IGS_RE_DUE_DT_GT_ANOT_MILSTON';
  				RETURN TRUE;
  			END IF;
  		END LOOP;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_mil_due;
  --
  -- To validate IGS_PR_MILESTONE status
  FUNCTION RESP_VAL_MIL_MST(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_preced_sequence_number IN NUMBER ,
  p_old_milestone_status IN VARCHAR2 ,
  p_new_milestone_status IN VARCHAR2 ,
  p_old_due_dt IN DATE ,
  p_new_due_dt IN DATE ,
  p_validation_level IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_mil_mst
  	-- Validate IGS_PR_MILESTONE.IGS_PR_MS_STAT, checking for :
  	--	Closed IGS_PR_MILESTONE status.
  DECLARE
  	cst_planned		CONSTANT	VARCHAR2(10) := 'PLANNED';
  	cst_replanned	CONSTANT	VARCHAR2(10) := 'RE-PLANNED';
  	cst_failed		CONSTANT	VARCHAR2(10) := 'FAILED';
  	cst_achieved	CONSTANT	VARCHAR2(10) := 'ACHIEVED';
  	CURSOR c_mst (
  		cp_milestone_status		IGS_PR_MILESTONE.milestone_status%TYPE) IS
  		SELECT	s_milestone_status,
  			closed_ind
  		FROM	IGS_PR_MS_STAT	mst
  		WHERE	mst.milestone_status	= cp_milestone_status;
  	CURSOR	c_mil IS
  		SELECT	mst.s_milestone_status
  		FROM	IGS_PR_MILESTONE mil,
  			IGS_PR_MS_STAT mst
  		WHERE	mil.person_id	= p_person_id	AND
  			mil.ca_sequence_number	= p_ca_sequence_number	AND
  			mil.sequence_number	= p_preced_sequence_number AND
  			mst.milestone_status	= mil.milestone_status;
  	v_old_mst_rec	c_mst%ROWTYPE;
  	v_new_mst_rec	c_mst%ROWTYPE;
  	v_s_milestone_status	IGS_PR_MS_STAT.s_milestone_status%TYPE;
  BEGIN
    	-- Set the default message number
    	p_message_name := null;
    	OPEN c_mst (p_new_milestone_status);
    	FETCH c_mst INTO v_new_mst_rec;
  	IF c_mst%NOTFOUND THEN
  		CLOSE c_mst;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_mst;
  	IF p_validation_level in ('ITEM','TRIGGER') THEN
  		-- 2. Check for close IGS_PR_MILESTONE status
    		IF v_new_mst_rec.closed_ind = 'Y' THEN
  	  		CLOSE c_mst;
    			p_message_name := 'IGS_RE_MILSTN_STAT_CLOSED';
    			RETURN FALSE;
  		END IF;
    	END IF;
  	IF p_old_milestone_status IS NOT NULL THEN
  		OPEN c_mst (p_old_milestone_status);
  		FETCH c_mst INTO v_old_mst_rec;
  		IF c_mst%NOTFOUND THEN
  			CLOSE c_mst;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_mst;
  	END IF;
  	IF p_validation_level in ('RECORD','TRIGGER') THEN
  		-- 3. Check whether being re-planned and date has changed.
  		If v_new_mst_rec.s_milestone_status = cst_replanned AND
  			v_old_mst_rec.s_milestone_status <> cst_replanned AND
  			NVL(p_old_due_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) = p_new_due_dt THEN
  				p_message_name := 'IGS_RE_DUE_DT_MUST_BE_CHANGED';
  				RETURN FALSE;
  		END IF;
  	END IF;
  	IF p_validation_level in ('ITEM','TRIGGER') THEN
  		-- 4. Check status of preceding IGS_PR_MILESTONE.
  		If NVL(p_old_milestone_status, ' ') <> p_new_milestone_status AND
  			p_preced_sequence_number IS NOT NULL AND
  			v_new_mst_rec.s_milestone_status IN (cst_achieved,cst_failed) THEN
  				OPEN	c_mil;
  				FETCH	c_mil INTO v_s_milestone_status;
  				IF c_mil%FOUND THEN
  					CLOSE c_mil;
  					IF v_s_milestone_status IN (cst_planned,cst_replanned) THEN
  						p_message_name := 'IGS_RE_CUR_MILST_SET_ACH/FAIL';
  						RETURN TRUE;			-- Warning Only
  					END IF;
  				ELSE
  					CLOSE c_mil;
  				END IF;
  		END IF;
  	END IF;
    	RETURN TRUE;
    EXCEPTION
    	WHEN OTHERS THEN
    		IF c_mst%ISOPEN THEN
    			CLOSE c_mst;
    		END IF;
    		IF c_mil%ISOPEN THEN
    			CLOSE c_mil;
    		END IF;
    		RAISE;
   END;
   EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
   END resp_val_mil_mst;
  --
  -- To validate IGS_PR_MILESTONE type
  FUNCTION RESP_VAL_MIL_MTY(
  p_milestone_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_mil_mty
  	-- Validate the IGS_PR_MILESTONE type, checking for :
  	-- 	That the IGS_PR_MILESTONE type is not closed.
  DECLARE
  	CURSOR c_mty IS
  		SELECT 'x'
  		FROM	IGS_PR_MILESTONE_TYP	mty
  		WHERE	mty.milestone_type	= p_milestone_type AND
  			mty.closed_ind		= 'Y';
  	v_mty_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- check for closed IGS_PR_MILESTONE type
  	OPEN c_mty;
  	FETCH c_mty INTO v_mty_exists;
  	IF c_mty%FOUND THEN
  		CLOSE c_mty;
  		p_message_name := 'IGS_RE_MILSTN_TYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_mty;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_mty%ISOPEN THEN
  			CLOSE c_mty;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_mil_mty;
  --
  -- To validate IGS_PR_MILESTONE preceding sequence number
  FUNCTION RESP_VAL_MIL_PRCD(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_due_dt IN DATE ,
  p_preced_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_mil_prcd
  	-- Validate the preceeding IGS_PR_MILESTONE details, checking for:
  	--	Cannot link a IGS_PR_MILESTONE to itself.
  	--	Cannot link a IGS_PR_MILESTONE to a IGS_PR_MILESTONE with due_dt
  	--		less than the current record.
  DECLARE
  	v_mil_due_dt	IGS_PR_MILESTONE.due_dt%TYPE;
  	CURSOR c_mil IS
  		SELECT	mil.due_dt
  		FROM	IGS_PR_MILESTONE	mil
  		WHERE	mil.person_id		= p_person_id AND
  			mil.ca_sequence_number	= p_ca_sequence_number AND
  			mil.sequence_number	= p_preced_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_sequence_number = p_preced_sequence_number THEN
  		p_message_name := 'IGS_RE_MILSTN_CANT_PRECED';
  		RETURN FALSE;
  	END IF;
  	-- check that not linked to another IGS_PR_MILESTONE of a lesser date
  	OPEN c_mil;
  	FETCH c_mil INTO v_mil_due_dt;
  	IF c_mil%NOTFOUND THEN
  		CLOSE c_mil;
  		-- invalid parameters
  		RETURN TRUE;
  	ELSE
  		CLOSE c_mil;
  		IF v_mil_due_dt > p_due_dt THEN
  			p_message_name :='IGS_RE_CANT_PRECED_LATER_DATE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_mil %ISOPEN THEN
  			CLOSE c_mil;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_mil_prcd;
END IGS_RE_VAL_MIL;

/
