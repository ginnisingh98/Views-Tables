--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_EIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_EIS" AS
/* $Header: IGSAS17B.pls 115.5 2002/11/28 22:43:44 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed
  -------------------------------------------------------------------------------------------
  --
   -- Validate if a person is an active student.
  FUNCTION ASSP_VAL_ACTV_STDNT(
  p_person_id IN NUMBER ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN 	-- assp_val_actv_stdnt
  	-- Validates if the person is an active student
  DECLARE
  	cst_lapsed 			CONSTANT VARCHAR2(6) := 'LAPSED';
  	cst_enrolled			CONSTANT VARCHAR2(8) := 'ENROLLED';
  	cst_intermit 			CONSTANT VARCHAR2(8) := 'INTERMIT';
  	cst_inactive 			CONSTANT VARCHAR2(8) := 'INACTIVE';
  	v_rec_found			BOOLEAN DEFAULT FALSE;
  	CURSOR c_sca (
  			cp_person_id	IGS_EN_STDNT_PS_ATT.person_id%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_EN_STDNT_PS_ATT 		sca
  		WHERE	sca.person_id			= cp_person_id AND
  			sca.course_attempt_status	IN (cst_enrolled, cst_intermit,
  								cst_lapsed, cst_inactive);
  BEGIN
  	P_MESSAGE_NAME := NULL;
  	FOR v_sca_rec IN c_sca(
  				p_person_id) LOOP
  		v_rec_found := TRUE;
  	END LOOP;
  	IF(v_rec_found = TRUE) THEN
  		P_MESSAGE_NAME := 'IGS_AS_PRSN_AN_ACTIVE_STUD';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_EIS.ASSP_VAL_ACTV_STDNT');
	IGS_GE_MSG_STACK.ADD;
  END assp_val_actv_stdnt;
  -- Validate if a person is an active student.

  --
  -- Validate venue is within the supervisor's exam exam locations

  -- Validate if more than one person incharge at a session and venue.
  FUNCTION ASSP_VAL_ESE_INCHRG(
  p_person_id IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_venue_cd IN VARCHAR2 ,
  p_exam_supervisor_type IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_ese_inchrg
  	-- Validate that not more than one person has been allocated to be in-charge
  	-- for a particular session at a venue.
  DECLARE
  	v_start_time		DATE;
  	v_end_time		DATE;
  	v_exam_inst_count	NUMBER(5);
  	v_venue_count		NUMBER(5);
  	CURSOR c_check_not_charge IS
  		SELECT	'x'
  		FROM	IGS_AS_EXM_SPRVSRTYP
  		WHERE	exam_supervisor_type	= p_exam_supervisor_type AND
  			in_charge_ind		= 'N';
  	v_not_charge_exist	VARCHAR2(1);
  	CURSOR c_exam_inst_count IS
  		SELECT	count(distinct eis.person_id)
  		FROM	IGS_AS_EXM_INS_SPVSR	eis,
  			IGS_AS_EXM_SUPRVISOR		esu,
  			IGS_AS_EXM_SPRVSRTYP	est
  		WHERE	eis.person_id			<> p_person_id			AND
  			eis.exam_cal_type		= p_exam_cal_type		AND
  			eis.exam_ci_sequence_number	= p_exam_ci_sequence_number	AND
  			eis.dt_alias			= p_dt_alias			AND
  			eis.dai_sequence_number		= p_dai_sequence_number		AND
  			IGS_GE_GEN_003.GENP_SET_TIME(eis.start_time)	= v_start_time			AND
  			IGS_GE_GEN_003.GENP_SET_TIME(eis.end_time)	= v_end_time			AND
  			eis.venue_cd			= p_venue_cd			AND
  			eis.person_id			= esu.person_id			AND
  			esu.exam_supervisor_type	= est.exam_supervisor_type	AND
  			est.in_charge_ind		= 'Y';
  	CURSOR c_venue_count IS
  		SELECT	count(esvs.person_id)
  		FROM	IGS_AS_EXM_SES_VN_SP	esvs,
  			IGS_AS_EXM_SUPRVISOR			esu,
  			IGS_AS_EXM_SPRVSRTYP		est
  		WHERE	esvs.person_id			<> p_person_id			AND
  			esvs.exam_cal_type		= p_exam_cal_type		AND
  			esvs.exam_ci_sequence_number	= p_exam_ci_sequence_number 	AND
  			esvs.dt_alias			= p_dt_alias			AND
  			esvs.dai_sequence_number	= p_dai_sequence_number 	AND
  			IGS_GE_GEN_003.GENP_SET_TIME(esvs.start_time)	= v_start_time			AND
  			IGS_GE_GEN_003.GENP_SET_TIME(esvs.end_time)	= v_end_time			AND
  			esvs.venue_cd			= p_venue_cd			AND
  			esvs.person_id			= esu.person_id			AND
  			esu.exam_supervisor_type	= est.exam_supervisor_type 	AND
  			est.in_charge_ind	= 'Y';
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- Check if the person being allocated to the session/venue is to be
  	-- in-charge. If person not being allocated as in-charge, then no need
  	-- to validate further, then return successfully.
  	OPEN c_check_not_charge;
  	FETCH c_check_not_charge INTO v_not_charge_exist;
  	IF c_check_not_charge%FOUND THEN
  		CLOSE c_check_not_charge;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_check_not_charge;
  	-- Check if more than one supervisor to a session and venue has been allocated
  	-- as being 'in-charge'.
  	v_start_time := IGS_GE_GEN_003.GENP_SET_TIME(p_start_time);
  	v_end_time := IGS_GE_GEN_003.GENP_SET_TIME(p_end_time);
  	-- Determine the distinct number of supervisors already allocated to the
  	-- session/venu within the exam instance that are 'in-charge'
  	OPEN c_exam_inst_count;
  	FETCH c_exam_inst_count INTO v_exam_inst_count;
  	CLOSE c_exam_inst_count;
  	-- Check if person already allocated as being incharge.
  	IF NVL(v_exam_inst_count, 0) > 0 THEN
  		P_MESSAGE_NAME := 'IGS_AS_SUPV_EXISTS_NOMINATED';
  		RETURN FALSE;
  	END IF;
  	-- Determine the number of supervisors already allocated to the venue for the
  	-- session that are 'in-charge'.
  	OPEN c_venue_count;
  	FETCH c_venue_count INTO v_venue_count;
  	CLOSE c_venue_count;
  	IF NVL(v_venue_count, 0) > 0 THEN
  		P_MESSAGE_NAME := 'IGS_AS_SUPV_EXISTS_NOMINATED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_EIS.ASSP_VAL_ESE_INCHRG');
        IGS_GE_MSG_STACK.ADD;

  END assp_val_ese_inchrg;
  --
  -- Validate if the exam supervisor type is not closed.

  --
  -- Validate if person allocated as incharge when not normally incharge.
  FUNCTION ASSP_VAL_EST_INCHRG(
  p_person_id IN NUMBER ,
  p_exam_supervisor_type IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	--assp_val_est_inchrg
  	--Validate the Exam Supervisor Type in-charge indicator. This routine will be
  	-- called when overiding the exam supervisor type for an
  	-- IGS_AS_EXM_INS_SPVSR or IGS_AS_EXM_SES_VN_SP. If the person is being
  	-- made an in-charge supervisor when they are normally are not in-charge,
  	-- then return a warning message.
  DECLARE
  	v_est_in_charge_ind	IGS_AS_EXM_SPRVSRTYP.in_charge_ind%TYPE;
  	v_in_charge_ind		IGS_AS_EXM_SPRVSRTYP.in_charge_ind%TYPE;
  	CURSOR c_est IS
  		SELECT 	est.in_charge_ind
  		FROM 	IGS_AS_EXM_SUPRVISOR		esu,
  			IGS_AS_EXM_SPRVSRTYP	est
  		WHERE 	esu.person_id			= p_person_id	AND
  			esu.exam_supervisor_type	= est.exam_supervisor_type;
  	CURSOR c_est2 IS
  		SELECT	est.in_charge_ind
  		FROM	IGS_AS_EXM_SPRVSRTYP	est
  		WHERE	exam_supervisor_type	= p_exam_supervisor_type;
  BEGIN
  	--Set the default message number
  	P_MESSAGE_NAME := NULL;
  	--Select the persons current type and in_charge indicator
  	OPEN c_est;
  	FETCH c_est INTO v_est_in_charge_ind;
  	CLOSE c_est;
  	--Select the in-charge indicator of the exam_supervisor_type that will be
  	-- used to overide the persons current type
  	OPEN c_est2;
  	FETCH c_est2 INTO v_in_charge_ind;
  	--This situation should never happen it is really validating RI constraints.
  	--As it is only a warning, return successfully.
  	IF (c_est2%NOTFOUND) THEN
  		CLOSE c_est2;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_est2;
  	--If the person normally isnt in_charge and is being given a supervisory
  	--position as in-charge, then return a warning message.
  	IF (v_in_charge_ind = 'Y'	AND
  			v_est_in_charge_ind = 'N') THEN
  		P_MESSAGE_NAME := 'IGS_AS_PRSN_NOTHAVE_SUPVTYPE';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_EIS.assp_val_est_inchrg');
        	IGS_GE_MSG_STACK.ADD;
  END assp_val_est_inchrg;
  --
  --
  -- Validate if the supervisor limit exceeded for the session and venue.
  FUNCTION ASSP_VAL_ESU_ESE_LMT(
  p_person_id IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_venue_cd IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_esu_ese_lmt
  	-- Validate that adding the person to a session at a venue will cause
  	-- the venue.supervisor_lit to be exceeded.
  DECLARE
  	v_start_time			IGS_AS_EXAM_SESSION.start_time%TYPE;
  	v_end_time			IGS_AS_EXAM_SESSION.end_time%TYPE;
  	v_supervisor_count		NUMBER(5);
  	v_venue_count			NUMBER(5);
  	v_supervisor_limit		IGS_GR_VENUE.supervisor_limit%TYPE;
  	CURSOR	c_sprvsr_cnt (
  			cp_start_time		IGS_AS_EXAM_SESSION.start_time%TYPE,
  			cp_end_time		IGS_AS_EXAM_SESSION.end_time%TYPE) IS
  		SELECT	COUNT(DISTINCT person_id)
  		FROM	IGS_AS_EXM_INS_SPVSR
  		WHERE	exam_cal_type 		= p_exam_cal_type	AND
  			exam_ci_sequence_number	= p_exam_ci_sequence_number 	AND
  			dt_alias		= p_dt_alias		AND
  			dai_sequence_number	= p_dai_sequence_number	AND
  			IGS_GE_GEN_003.GENP_SET_TIME(start_time) = cp_start_time	AND
  			IGS_GE_GEN_003.GENP_SET_TIME(end_time) = cp_end_time		AND
  			venue_cd 		= p_venue_cd;
  	CURSOR	c_venue_cnt (
  			cp_start_time		IGS_AS_EXAM_SESSION.start_time%TYPE,
  			cp_end_time		IGS_AS_EXAM_SESSION.end_time%TYPE) IS
  		SELECT	COUNT(person_id) -- v_venue_count
  		FROM	IGS_AS_EXM_SES_VN_SP
  		WHERE	exam_cal_type 		= p_exam_cal_type	AND
  			exam_ci_sequence_number	= p_exam_ci_sequence_number 	AND
  			dt_alias		= p_dt_alias		AND
  			dai_sequence_number	= p_dai_sequence_number	AND
  			IGS_GE_GEN_003.GENP_SET_TIME(start_time) = cp_start_time	AND
  			IGS_GE_GEN_003.GENP_SET_TIME(end_time) = cp_end_time		AND
  			venue_cd		= p_venue_cd;
  	CURSOR c_venue IS
  		SELECT	supervisor_limit
  		FROM	IGS_GR_VENUE
  		WHERE	venue_cd = p_venue_cd;
  BEGIN
  	P_MESSAGE_NAME := NULL;
  	-- Check if the allocation of a supervisor to a session and venue will cause
  	-- the venue.supervisor_limit to be exceeded.
  	v_start_time := IGS_GE_GEN_003.GENP_SET_TIME(
  				p_start_time);
  	v_end_time := IGS_GE_GEN_003.GENP_SET_TIME(
  				p_end_time);
  	-- Determine the distinct number of supervisors already allocated to the
  	-- session/venu within the exam instance
  	OPEN c_sprvsr_cnt(
  			v_start_time,
  			v_end_time);
  	FETCH c_sprvsr_cnt INTO v_supervisor_count;
  	CLOSE c_sprvsr_cnt;
  	-- Determine the number of supervisors already allocated to the venue for the
  	-- session.
  	OPEN c_venue_cnt(
  			v_start_time,
  			v_end_time);
  	FETCH c_venue_cnt INTO v_venue_count;
  	CLOSE c_venue_cnt;
  	-- Add the count to the total and increment by 1 to include the person about to
  	-- be added.
  	v_supervisor_count := v_supervisor_count + v_venue_count + 1;
  	-- Determine the supervisor limit for the venue.
  	OPEN c_venue;
  	FETCH c_venue INTO v_supervisor_limit;
  	CLOSE c_venue;
  	-- Check if the limit has been exceeded.
  	-- Note: If the selected limit is NULL then no limit exists.
  	IF v_supervisor_count > NVL(v_supervisor_limit, v_supervisor_count) THEN
  		P_MESSAGE_NAME := 'IGS_AS_SUPV_LIMIT_EXCEEDS';
  		RETURN FALSE;
  	END IF;
  	Return TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_EIS.assp_val_esu_ese_lmt');
        	IGS_GE_MSG_STACK.ADD;
  END assp_val_esu_ese_lmt;
  --
  -- Supervisor cannot be allocated concurrent sessions at different venues
   --

END IGS_AS_VAL_EIS;

/
