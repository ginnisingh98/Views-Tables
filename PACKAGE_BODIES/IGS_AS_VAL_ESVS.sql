--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_ESVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_ESVS" AS
/* $Header: IGSAS21B.pls 115.5 2002/11/28 22:44:40 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn
  --                            removed
  -------------------------------------------------------------------------------------------
  -- Validate if a IGS_PE_PERSON is an active student.

  --
  -- Validate exam instance exists for the session and IGS_GR_VENUE.
  FUNCTION ASSP_VAL_EI_VENUE(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_venue_cd IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- assp_val_ei_venue
  	-- Validate there exists at least one exam instance
  	-- at a IGS_GR_VENUE for which the supervisor is being allocated.
  DECLARE
  	v_start_time	DATE;
	v_flag VARCHAR2(1) ;
  	v_end_time	DATE;
  	v_system_date	DATE;
	CURSOR c_ei IS
  		SELECT	'1',ei.start_time,ei.end_time
  		FROM	IGS_AS_EXAM_INSTANCE ei
  		WHERE	ei.exam_cal_type 		= p_exam_cal_type AND
  			ei.exam_ci_sequence_number 	= p_exam_ci_sequence_number AND
  			ei.dt_alias			= p_dt_alias AND
  			ei.dai_sequence_number		= p_dai_sequence_number	AND
  			ei.venue_cd 		  	= p_venue_cd;
     v_x	c_ei%ROWTYPE;
  BEGIN
  	P_MESSAGE_NAME := NULL;
  	v_system_date := SYSDATE;
    v_flag := 'F' ;
  	v_start_time := Igs_Ge_Gen_003.GENP_SET_TIME(p_start_time);
  	v_end_time := Igs_Ge_Gen_003.GENP_SET_TIME(p_end_time);
  	OPEN c_ei;
	LOOP
  	FETCH c_ei INTO v_x;
	EXIT WHEN c_ei%NOTFOUND ;
    IF	Igs_Ge_Gen_003.GENP_SET_TIME(v_x.start_time) 	=  v_start_time	AND
		Igs_Ge_Gen_003.GENP_SET_TIME(v_x.end_time)   	=  v_end_time	THEN
        v_flag := 'T' ;
		EXIT;
	END IF;
	END LOOP;
  	CLOSE c_ei;
	IF v_flag = 'F' THEN
  		P_MESSAGE_NAME := 'IGS_AS_NOEXAM_INSTANCE_EXIST';
  		RETURN FALSE;
	ELSE
    	P_MESSAGE_NAME := NULL;
    	RETURN TRUE;
	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
           	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
 		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ESVS.assp_val_ei_venue');
 		IGS_GE_MSG_STACK.ADD;
  END assp_val_ei_venue;
  --
  -- Validate IGS_GR_VENUE is within the supervisor's exam IGS_AD_LOCATIONs
  FUNCTION ASSP_VAL_ELS_VENUE(
  p_person_id IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--assp_val_els_venue
  	--Validate if the IGS_PE_PERSON is being allocated to supervise an exam
  	-- instance/IGS_GR_VENUE, then check that the IGS_GR_VENUE is within one of the IGS_PE_PERSONs
  	-- exam_location_supvsr records
  DECLARE
  	v_els_exists	VARCHAR2(1);
  	CURSOR c_els IS
  		SELECT 	'X'
  		FROM 	IGS_AS_EXM_LOC_SPVSR	els,
  			IGS_GR_VENUE			ve
  		WHERE 	els.person_id		= p_person_id		AND
  			els.exam_location_cd	= ve.exam_location_cd	AND
  			ve.venue_cd		= p_venue_cd;
  BEGIN
  	--Set the default message number
  	P_MESSAGE_NAME := NULL;
  	--Determine if the IGS_GR_VENUE is within a persons supervisory IGS_AD_LOCATIONs
  	OPEN c_els;
  	FETCH c_els INTO v_els_exists;
  	IF (c_els%NOTFOUND) THEN
  		--Return a warning message indicating that the exam IGS_GR_VENUE is not within
  		--a IGS_AD_LOCATION that the IGS_PE_PERSON supervises.
  		CLOSE c_els;
  		P_MESSAGE_NAME := 'IGS_AS_VENUE_NOTWITHIN_SUPVEX';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_els;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	 	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
 		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ESVS.assp_val_els_venue');
 		IGS_GE_MSG_STACK.ADD;
  END assp_val_els_venue;
  --
   -- Validate if the exam supervisor type is not closed.

  --
  --
  -- Validate if supervisor allocated different exam IGS_AD_LOCATION for same day.
  FUNCTION ASSP_VAL_ESU_ESE_EL(
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
  BEGIN	-- assp_val_esu_ese_el
  	-- Validate the IGS_PE_PERSON is not being allocated to sessions at two different exam
  	-- locations on the same day
  DECLARE
  	v_dt_alias_val		DATE;
  	v_exam_location_cd	IGS_GR_VENUE.exam_location_cd%TYPE;
  	v_check			CHAR;
  	CURSOR c_venue IS
  		SELECT 	exam_location_cd
  		FROM	IGS_GR_VENUE
  		WHERE	venue_cd = p_venue_cd;
  	CURSOR	c_eis_ve (
  			cp_dt_alias_val		DATE,
  			cp_exam_location_cd	IGS_GR_VENUE.exam_location_cd%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_AS_EXM_INS_SPVSR 	eis,
  			IGS_GR_VENUE 			ve
  		WHERE	eis.person_id 	= p_person_id		AND
  			IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  					eis.dt_alias,
  					eis.dai_sequence_number,
  					eis.exam_cal_type,
  					eis.exam_ci_sequence_number) = cp_dt_alias_val AND
  			eis.venue_cd 	= ve.venue_cd 				AND
  			ve.exam_location_cd <> cp_exam_location_cd;
  	CURSOR	c_esvs_ve (
  			cp_dt_alias_val		DATE,
  			cp_exam_location_cd	IGS_GR_VENUE.exam_location_cd%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_AS_EXM_SES_VN_SP 	esvs,
  			IGS_GR_VENUE 				ve
  		WHERE	esvs.person_id 	= p_person_id			AND
  			IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  					esvs.dt_alias,
  					esvs.dai_sequence_number,
  					esvs.exam_cal_type,
  					esvs.exam_ci_sequence_number) = cp_dt_alias_val AND
  			esvs.venue_cd 	= ve.venue_cd			AND
  			ve.exam_location_cd <> cp_exam_location_cd;
  BEGIN
  	P_MESSAGE_NAME := NULL;
  	-- Get the date for the date alias instance value.
  	v_dt_alias_val := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  					p_dt_alias,
  					p_dai_sequence_number,
  					p_exam_cal_type,
  					p_exam_ci_sequence_number);
  	-- Get the exam IGS_AD_LOCATION for the IGS_GR_VENUE.
  	OPEN c_venue;
  	FETCH c_venue INTO v_exam_location_cd;
  	CLOSE c_venue;
  	-- Determine if the IGS_PE_PERSON has been allocated to supervise an exam instance for
  	-- the same day at a different exam locations.
  	OPEN c_eis_ve (
  			v_dt_alias_val,
  			v_exam_location_cd);
  	FETCH c_eis_ve INTO v_check;
  	IF (c_eis_ve%FOUND) THEN
  		-- Return an warning message indicating that the IGS_PE_PERSON has been allocated
  		-- to different exam locations on the same day.
  		CLOSE c_eis_ve;
  		P_MESSAGE_NAME := 'IGS_AS_PRSN_ALLOC_DIFF_EXAM';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_eis_ve;
  	-- Determine if the IGS_PE_PERSON has already been allocated to supervise at a IGS_GR_VENUE
  	-- for the same day at a different exam IGS_AD_LOCATION.
  	OPEN c_esvs_ve(
  			v_dt_alias_val,
  			v_exam_location_cd);
  	FETCH c_esvs_ve INTO v_check;
  	IF (c_esvs_ve%FOUND) THEN
  		-- Return an warning message indicating that the IGS_PE_PERSON has been allocated
  		-- to different exam locations on the same day.
  		CLOSE c_esvs_ve;
  		P_MESSAGE_NAME := 'IGS_AS_PRSN_ALLOC_DIFF_EXAM';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_esvs_ve;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	 	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
 		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ESVS.assp_val_esu_ese_el');
 		IGS_GE_MSG_STACK.ADD;
  END assp_val_esu_ese_el;
  --
  -- Validate if the supervisor limit exceeded for the session and IGS_GR_VENUE.
   -- Supervisor cannot be allocated concurrent sessions at different IGS_GR_VENUEs
  FUNCTION ASSP_VAL_ESU_ESE_VE(
  p_person_id IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_override_start_time IN DATE ,
  p_override_end_time IN DATE ,
  p_venue_cd IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail_1	VARCHAR2(255);
  	gv_other_detail_2	VARCHAR2(255);
  BEGIN	--assp_val_esu_ese_ve
  	--Validate the IGS_PE_PERSON cannot be allocated to supervise
  	--concurrent exam sessions at different IGS_GR_VENUEs
  DECLARE
  	v_eis_exists	VARCHAR2(1);
  	v_esvs_exists	VARCHAR2(1);
  	v_dt_alias_val	DATE;
  	v_start_time	DATE;
  	v_end_time	DATE;
  	CURSOR c_eis IS
  		SELECT	'X'
  		FROM	IGS_AS_EXM_INS_SPVSR	eis
  		WHERE	person_id			= p_person_id		AND
  			IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  				dt_alias,
  				dai_sequence_number,
  				exam_cal_type,
  				exam_ci_sequence_number) = v_dt_alias_val	AND
   				((Igs_Ge_Gen_003.GENP_SET_TIME(NVL(override_start_time, start_time))
  					BETWEEN v_start_time AND v_end_time OR
  				(Igs_Ge_Gen_003.GENP_SET_TIME( NVL(override_end_time, end_time))
  					BETWEEN  v_start_time AND v_end_time)) OR
  				(Igs_Ge_Gen_003.GENP_SET_TIME( NVL(override_start_time, start_time)) 	<= v_start_time AND
  				Igs_Ge_Gen_003.GENP_SET_TIME( NVL(override_end_time, end_time)) 	>= v_end_time)) AND
  				venue_cd 						<> p_venue_cd;
  	CURSOR c_esvs IS
  		SELECT	'X'
  		FROM	IGS_AS_EXM_SES_VN_SP	esvs
  		WHERE	person_id			= p_person_id		AND
  			IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  				dt_alias,
  				dai_sequence_number,
  				exam_cal_type,
  				exam_ci_sequence_number) = v_dt_alias_val	AND
   				((Igs_Ge_Gen_003.GENP_SET_TIME(NVL(override_start_time, start_time))
  					BETWEEN v_start_time AND v_end_time OR
  				(Igs_Ge_Gen_003.GENP_SET_TIME( NVL(override_end_time, end_time))
  					BETWEEN  v_start_time AND v_end_time)) OR
  				(Igs_Ge_Gen_003.GENP_SET_TIME( NVL(override_start_time, start_time)) 	<= v_start_time AND
  				Igs_Ge_Gen_003.GENP_SET_TIME( NVL(override_end_time, end_time)) 	>= v_end_time)) AND
  				venue_cd 						<> p_venue_cd;
  BEGIN
  	--Set the default message number
  	P_MESSAGE_NAME := NULL;
  	--Get the date for the date alias instance value
  	v_dt_alias_val := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  					p_dt_alias,
  					p_dai_sequence_number,
  					p_exam_cal_type,
  					p_exam_ci_sequence_number);
  	--Calculate which time parameter to use and set the date component
  	--to be consistent when comparing times.
  	--This is due to the date component varying when entering
  	--a time format within a form
  	v_start_time	:= Igs_Ge_Gen_003.GENP_SET_TIME(NVL(p_override_start_time, p_start_time));
  	v_end_time	:= Igs_Ge_Gen_003.GENP_SET_TIME( NVL(p_override_end_time, p_end_time));
  	OPEN c_eis;
  	FETCH c_eis INTO v_eis_exists;
  	IF (c_eis%FOUND) THEN
  		P_MESSAGE_NAME := 'IGS_AS_PRSN_ALLOC_DIFF_VENUE';
  		CLOSE c_eis;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_eis;
  	--Determine if the IGS_PE_PERSON has been allocated to supervise
  	--at a different IGS_GR_VENUE for the same session.
  	OPEN c_esvs;
  	FETCH c_esvs INTO v_esvs_exists;
  	IF (c_esvs%FOUND) THEN
  		--Return an error message indicating that the IGS_PE_PERSON has been
  		--allocated to concurrent sessions at different venues.
  		P_MESSAGE_NAME := 'IGS_AS_PRSN_ALLOC_DIFF_VENUE';
  		CLOSE c_esvs;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_esvs;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	 	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
 		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ESVS.assp_val_esu_ese_ve');
 		IGS_GE_MSG_STACK.ADD;
  END assp_val_esu_ese_ve;
  --

END Igs_As_Val_Esvs;

/
