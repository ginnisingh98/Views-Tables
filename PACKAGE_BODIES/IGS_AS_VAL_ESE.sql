--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_ESE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_ESE" AS
/* $Header: IGSAS19B.pls 115.5 2002/11/28 22:44:11 nsidana ship $ */


  --
  -- To validate the uniqueness of the exam session number
  FUNCTION ASSP_VAL_ESE_NUM(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_ese_num
  	-- Validate the exam session number for an entire examination.
  	-- The number must be unique across the period
  DECLARE
  	v_check		CHAR;
  	v_ret_val	BOOLEAN DEFAULT TRUE;
  	CURSOR c_es IS
  		SELECT	dt_alias,
  			dai_sequence_number,
  			start_time,
  			end_time,
  			exam_session_number
  		FROM	IGS_AS_EXAM_SESSION es
  		WHERE	exam_cal_type 		= p_exam_cal_type AND
  			exam_ci_sequence_number = p_exam_ci_sequence_number;
  	CURSOR c_es1 (
  			cp_dt_alias		IGS_AS_EXAM_SESSION.dt_alias%TYPE,
  			cp_dai_sequence_number	IGS_AS_EXAM_SESSION.dai_sequence_number%TYPE,
  			cp_start_time		IGS_AS_EXAM_SESSION.start_time%TYPE,
  			cp_end_time		IGS_AS_EXAM_SESSION.end_time%TYPE,
  			cp_exam_session_number	IGS_AS_EXAM_SESSION.exam_session_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_AS_EXAM_SESSION es
  		WHERE	es.exam_cal_type 		= p_exam_cal_type 		AND
  			es.exam_ci_sequence_number 	= p_exam_ci_sequence_number 	AND
  			(dt_alias <> cp_dt_alias 			OR
  			 dai_sequence_number <> cp_dai_sequence_number	OR
  			 start_time <> cp_start_time			OR
  			 end_time <> cp_end_time) AND
  			exam_session_number = cp_exam_session_number;
  BEGIN
  	P_MESSAGE_NAME := NULL;
  	FOR v_es_rec IN c_es LOOP
  		OPEN c_es1 (
  				v_es_rec.dt_alias,
  				v_es_rec.dai_sequence_number,
  				v_es_rec.start_time,
  				v_es_rec.end_time,
  				v_es_rec.exam_session_number);
  		FETCH c_es1 INTO v_check;
  		IF (c_es1%FOUND) THEN
  			CLOSE c_es1;
  			P_MESSAGE_NAME := 'IGS_AS_MORE_THAN_ONE_SESSION';
  			v_ret_val := FALSE;
  			EXIT;
  		END IF;
  		CLOSE c_es1;
  	END LOOP;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	  	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
	  	FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ESE.assp_val_ese_num');
	  	IGS_GE_MSG_STACK.ADD;
  END assp_val_ese_num;
  --
  -- To validate for overlap in start/end times of exam sessions
  FUNCTION ASSP_VAL_ESE_OVRLP(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN 	-- assp_val_ese_ovrlp
  	-- Validate whether the examination session overlaps times with another session
  	-- within the same examination calendar.
  	-- This routine only returns warning, as it is seen as possible in unusual
  	-- situations
  DECLARE
  	v_alias_val	IGS_AS_EXAM_SESSION_V.alias_val%TYPE;
  	CURSOR	c_daiv(
  			cp_exam_cal_type 		IGS_CA_DA_INST_V.cal_type%TYPE,
  			cp_exam_ci_sequence_number 	IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
  			cp_dt_alias 			IGS_CA_DA_INST_V.dt_alias%TYPE,
  			cp_dai_sequence_number		IGS_CA_DA_INST_V.sequence_number%TYPE) IS
  		SELECT	daiv.alias_val
  		FROM	IGS_CA_DA_INST_V		daiv
  		WHERE	daiv.cal_type 			= cp_exam_cal_type AND
  			daiv.ci_sequence_number 	= cp_exam_ci_sequence_number AND
  		     	daiv.dt_alias 			= cp_dt_alias AND
  			daiv.sequence_number		= cp_dai_sequence_number;
  	CURSOR c_esv (
  			cp_exam_cal_type 		IGS_AS_EXAM_SESSION_V.exam_cal_type%TYPE,
  			cp_exam_ci_sequence_number 	IGS_AS_EXAM_SESSION_V.exam_ci_sequence_number%TYPE,
  			cp_alias_val			IGS_AS_EXAM_SESSION_V.alias_val%TYPE) IS
  		SELECT	*
  		FROM	IGS_AS_EXAM_SESSION_V			esv
  		WHERE	esv.exam_cal_type		= cp_exam_cal_type AND
  			esv.exam_ci_sequence_number	= cp_exam_ci_sequence_number AND
  			esv.alias_val			= cp_alias_val;
  BEGIN
  	P_MESSAGE_NAME := NULL;
  	-- Validate parameters
  	IF(p_exam_cal_type IS NULL OR
  			p_exam_ci_sequence_number IS NULL OR
  			p_dt_alias IS NULL OR
  			p_dai_sequence_number IS NULL OR
  			p_start_time IS NULL OR
  			p_end_time IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the session date of the parameter session by querying
  	-- the date alias instance view
  	OPEN	c_daiv(
  			p_exam_cal_type,
  			p_exam_ci_sequence_number,
  			p_dt_alias,
  			p_dai_sequence_number);
  	FETCH	c_daiv	INTO v_alias_val;
  	IF(c_daiv%NOTFOUND) THEN
  		CLOSE c_daiv;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_daiv;
  	-- Loop through IGS_AS_EXAM_SESSION_V records validating each record for
  	-- time overlaps
  	FOR v_esv_rec IN c_esv(
  				p_exam_cal_type,
  				p_exam_ci_sequence_number,
  				v_alias_val) LOOP
  		IF(v_esv_rec.dt_alias = p_dt_alias AND
  				v_esv_rec.dai_sequence_number = p_dai_sequence_number AND
  				v_esv_rec.start_time = p_start_time AND
  				v_esv_rec.end_time = p_end_time) THEN
  			-- Do not validate against the record passed in
  			NULL;
  		ELSE
  			IF(
  					(p_start_time >= v_esv_rec.start_time AND
  					 p_start_time <= v_esv_rec.end_time) OR
  					(p_end_time >= v_esv_rec.start_time AND
  					 p_end_time <= v_esv_rec.end_time) OR
  					(p_start_time <= v_esv_rec.start_time AND
  					 p_end_time >= v_esv_rec.end_time)) THEN
  				P_MESSAGE_NAME := 'IGS_AS_SESSION_TIMES_OVERLAP';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	  	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
	  	FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ESE.assp_val_ese_ovrlp');
	  	IGS_GE_MSG_STACK.ADD;
  END assp_val_ese_ovrlp;
  --
  -- Validate the IGS_AS_EXAM_SESSION calendar instance
  FUNCTION ASSP_VAL_ESE_CI(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_ese_ci
  	-- Validate the calendar instance being linked to an IGS_AS_EXAM_SESSION record.
  	-- Check for :
  	--  . Calendar type must have SI_CA_S_CA_CAT of 'EXAM'
  	--  . Calendar instance must have s_cal_status of 'ACTIVE'
  DECLARE
  	CURSOR c_cat IS
  		SELECT	s_cal_cat
  		FROM	IGS_CA_TYPE
  		WHERE	cal_type = p_cal_type;
  	v_cat_rec	c_cat%ROWTYPE;
  	CURSOR c_cs IS
  		SELECT	s_cal_status
  		FROM	IGS_CA_INST	ci,
  			IGS_CA_STAT	cs
  		WHERE	ci.cal_type		= p_cal_type	AND
  			ci.sequence_number	= p_sequence_number AND
  			cs.cal_status		= ci.cal_status;
  	v_cs_rec	c_cs%ROWTYPE;
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- 1. Check that calendar type is an examination calendar.
  	OPEN c_cat;
  	FETCH c_cat INTO v_cat_rec;
  	IF (c_cat%NOTFOUND) THEN
  		CLOSE c_cat;
  		-- Calendar type is not valid ; the routine is not applicable.
  		P_MESSAGE_NAME := NULL;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_cat;
  		IF (v_cat_rec.s_cal_cat <> 'EXAM') THEN
  			P_MESSAGE_NAME := 'IGS_AS_EXAMSESSIONS_LINKS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- 2. Check that calendar instance is active
  	OPEN c_cs;
  	FETCH c_cs INTO v_cs_rec;
  	IF (c_cs%NOTFOUND) THEN
  		CLOSE c_cs;
  		-- The calendar instance is not valid ; the routine is not applicable.
  		P_MESSAGE_NAME := NULL;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_cs;
  		IF (v_cs_rec.s_cal_status <> 'ACTIVE') THEN
  			P_MESSAGE_NAME := 'IGS_AS_EXAMCAL_NOT_ACTIVE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	  	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
	  	FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ESE.assp_val_ese_ci');
	  	IGS_GE_MSG_STACK.ADD;
  END assp_val_ese_ci;
  --
  -- Compare time component of two dates and start time is before end time.
  FUNCTION GENP_VAL_STRT_END_TM(
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	v_start_time		DATE;
  	v_end_time		DATE;
  BEGIN
  	--- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	--- Make sure the only comparing the time component and that the dates
  	--- are identical. (01/01/1900 is an arbitrary date)
  	v_start_time := IGS_GE_DATE.IGSDATE( '1900/01/01 ' || SUBSTR(IGS_GE_DATE.IGSCHARDT(p_start_time),12));
  	v_end_time := IGS_GE_DATE.IGSDATE( '1900/01/01 ' || SUBSTR(IGS_GE_DATE.IGSCHARDT(p_end_time),12));
  	IF v_end_time <= v_start_time THEN
  		P_MESSAGE_NAME := 'IGS_GE_ST_TIME_LT_END_TIME';
  		RETURN FALSE;
  	ELSE
  		RETURN TRUE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	  	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
	  	FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ESE.GENP_VAL_STRT_END_TM');
	  	IGS_GE_MSG_STACK.ADD;
  END GENP_VAL_STRT_END_TM;
END IGS_AS_VAL_ESE;

/
