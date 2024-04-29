--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_SCH" AS
/* $Header: IGSRE12B.pls 115.4 2002/11/29 03:29:30 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_strt_end_dt removed
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  -------------------------------------------------------------------------------------------

  -- To validate scholarship_type closed indicator
  FUNCTION RESP_VAL_SCHT_CLOSED(
  p_scholarship_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_scht_closed
  	-- Validate the IGS_RE_SCHOLARSHIP type closed indicator
  DECLARE
  	v_scht_found		VARCHAR2(1);
  	CURSOR	c_scht IS
  		SELECT	'x'
  		FROM	IGS_RE_SCHL_TYPE
  		WHERE	scholarship_type	= p_scholarship_type AND
  			closed_ind		= 'Y';
  BEGIN
  	-- initialse the message_nameber
  	p_message_name := NULL;
  	OPEN c_scht;
  	FETCH c_scht INTO v_scht_found;
  	IF (c_scht%FOUND) THEN
  		CLOSE c_scht;
  		p_message_name := 'IGS_RE_SCHOLAR_TYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_scht;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_scht%ISOPEN THEN
  			CLOSE c_scht;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_scht_closed;
  --
  -- To validate IGS_RE_SCHOLARSHIP date overlaps
  FUNCTION RESP_VAL_SCH_OVRLP(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_scholarship_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_sch_ovrlp
  	-- Validate that the scolarship record being created or updated
  	-- does not overlap with an existing scolarship record of the
  	-- same scolarship_type.
  DECLARE
  	v_end_dt	IGS_RE_SCHOLARSHIP.end_dt%TYPE;
  	v_high_dt	IGS_RE_SCHOLARSHIP.end_dt%TYPE;
  	v_exit_loop	BOOLEAN DEFAULT FALSE;
  	CURSOR	c_sch IS
  		SELECT	sch.start_dt,
  			sch.end_dt
  		FROM	IGS_RE_SCHOLARSHIP	sch
  		WHERE	sch.person_id		= p_person_id AND
  			sch.ca_sequence_number	= p_ca_sequence_number AND
  			sch.scholarship_type	= p_scholarship_type AND
  			sch.start_dt		<> p_start_dt;
  BEGIN
  	p_message_name := NULL;
  	-- set_v_high_dt
  	v_high_dt := IGS_GE_DATE.IGSDATE('9999/01/01');
  	-- set v_end_dt to v_high_dt when p_end_dt is null
  	v_end_dt := NVL(p_end_dt, v_high_dt);
  	FOR v_sch_rec IN c_sch LOOP
  		-- check that the current date is between an existing date range.
  		IF p_start_dt > v_sch_rec.start_dt AND
  				p_start_dt <= NVL(v_sch_rec.end_dt, v_high_dt) THEN
  			v_exit_loop := TRUE;
  			p_message_name := 'IGS_RE_ST_DT_BET_EXIST_DT_RNG';
  			EXIT;
  		END IF;
  		-- check that the current end date is between an existing date range.
  		IF v_end_dt >= v_sch_rec.start_dt AND
  				v_end_dt <= NVL(v_sch_rec.end_dt, v_high_dt) THEN
  			v_exit_loop := TRUE;
  			p_message_name := 'IGS_RE_EN_DT_BET_EXIST_DT_RNG';
  			EXIT;
  		END IF;
  		-- check whether the current dates overlap an entire existing date range.
  		IF p_start_dt < v_sch_rec.start_dt AND
  				v_end_dt >= NVL(v_sch_rec.end_dt, v_high_dt) THEN
  			v_exit_loop := TRUE;
  			p_message_name := 'IGS_RE_DT_OVERLAP_WITH_DT_RNG';
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_exit_loop THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sch%ISOPEN THEN
  			CLOSE c_sch;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_sch_ovrlp;

END IGS_RE_VAL_SCH;

/
