--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PEE" AS
/* $Header: IGSEN53B.pls 115.7 2002/11/29 00:03:03 nsidana ship $ */
  --
  -- Validate the cp restriction on the PERSON exclusion effect table.
  FUNCTION enrp_val_pee_crs_cp(
  p_person_id IN NUMBER ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	v_person_id	IGS_PE_PERSENC_EFFCT.person_id%TYPE;
  	CURSOR c_pee IS
  		SELECT	pee.person_id
  		FROM	IGS_PE_PERSENC_EFFCT	pee
  		WHERE	pee.person_id = p_person_id AND
  			pee.s_encmb_effect_type = p_s_encmb_effect_type AND
  			pee.sequence_number <> p_sequence_number AND
  			(	pee.expiry_dt IS NULL OR
  				pee.expiry_dt > SYSDATE)	AND
  			pee.course_cd = p_course_cd;
  BEGIN
  	--  Validate that there is not an existing RSTR_LE_CP  or
  	--RSTR_GE_CP encumbrance effect for the nominated course code, when
  	--attempting to apply credit point restriction effect.  Required to
  	--prevent the situation of having a full-time and part-time
  	--restriction applied to the same course.
  	--  Note:course_cd is not part of the primary key of IGS_PE_PERSENC_EFFCT
  	--It is included in the selection criteria as it is possible for course_based
  	--IGS_PE_PERSENC_EFFCT records to exist for more than one records.
  	--(ie the primary key will match. - uniqueness is enforced by a sequence
  	-- number.
  	--1.	Validate the input parameters.
  	IF (p_person_id IS NULL OR
  			p_course_cd IS NULL OR
  			(p_s_encmb_effect_type NOT IN ('RSTR_LE_CP', 'RSTR_GE_CP'))) THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	--2.	Select all IGS_PE_PERSENC_EFFCT's-
  	OPEN c_pee;
  	FETCH c_pee INTO v_person_id;
  	IF (c_pee%NOTFOUND) THEN
  		CLOSE c_pee;
  		p_message_name := null;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_pee;
  		p_message_name := 'IGS_GE_DUPLICATE_VALUE';
  		RETURN FALSE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_crs_cp');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END enrp_val_pee_crs_cp;
  --
  -- Validate the att type on the person exclusion effect table.
  FUNCTION enrp_val_pee_crs_att(
  p_person_id IN NUMBER ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	v_person_id	IGS_PE_PERSENC_EFFCT.person_id%TYPE;
  	CURSOR c_pee IS
  		SELECT	pee.person_id
  		FROM	IGS_PE_PERSENC_EFFCT	pee
  		WHERE	pee.person_id = p_person_id AND
  			pee.s_encmb_effect_type = p_s_encmb_effect_type AND
  			pee.sequence_number <> p_sequence_number AND
  			(	pee.expiry_dt IS NULL OR
  				pee.expiry_dt > SYSDATE)	AND
  			pee.course_cd = p_course_cd;
  BEGIN
  	--  Validate that here is not an existing RSTR_AT_TY encumbrance
  	--effect for the nominated course code.  Required to prevent the
  	--situation of having a full-time and part-time restriction applied
  	--to the same course.
  	--  Note:course_cd is not part of the primary key of IGS_PE_PERSENC_EFFCT
  	--  It is included in the selection criteria as it is possible for course_based
  	-- IGS_PE_PERSENC_EFFCT records to exist for more than one records.
  	-- (ie the primary key will match. - uniqueness is enforced by a sequence
  	-- number.
  	--1.	Validate the input parameters.
  	IF (p_person_id IS NULL OR
  			p_s_encmb_effect_type IS NULL OR
  			p_course_cd IS NULL) THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	--2.	Select all IGS_PE_PERSENC_EFFCT's-
  	OPEN c_pee;
  	FETCH c_pee INTO v_person_id;
  	IF (c_pee%NOTFOUND) THEN
  		CLOSE c_pee;
  		p_message_name := null;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_pee;
  		p_message_name := 'IGS_EN_ACTIVE_RSTR_AL_IY_EXIS';
  		RETURN FALSE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_crs_att');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END enrp_val_pee_crs_att;
  --
  -- bug id : 1956374
  -- sjadhav , 28 -aug -2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_encmb_dts
  --
  -- Validate that person doesn't already have a matching encumb effect.
  FUNCTION enrp_val_pee_chk(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_rec_found		BOOLEAN;
  	CURSOR c_pee_no_course IS
  		SELECT	person_id
  		FROM	IGS_PE_PERSENC_EFFCT pee
  		WHERE	pee.person_id		 = p_person_id		 AND
  			pee.encumbrance_type	 = p_encumbrance_type	 AND
  			pee.pen_start_dt	 = p_pen_start_dt	 AND
  			pee.s_encmb_effect_type	 = p_s_encmb_effect_type AND
  			pee.pee_start_dt	= p_pee_start_dt;
  	CURSOR c_pee_course IS
  		SELECT	person_id
  		FROM	IGS_PE_PERSENC_EFFCT pee
  		WHERE	pee.person_id		 = p_person_id		 AND
  			pee.encumbrance_type	 = p_encumbrance_type	 AND
  			pee.pen_start_dt	 = p_pen_start_dt	 AND
  			pee.s_encmb_effect_type	 = p_s_encmb_effect_type AND
  			pee.pee_start_dt	= p_pee_start_dt AND
  			pee.course_cd		 = p_course_cd;
  BEGIN
  	-- This module validates that there are no matching
  	-- IGS_PE_PERSENC_EFFCT records for the nominated encumbrance
  	-- effect type.
  	-- validate the input parameters
  	IF (p_person_id IS NULL OR
  	    p_encumbrance_type IS NULL OR
  	    p_pen_start_dt IS NULL OR
  	    p_s_encmb_effect_type IS NULL OR
  	    p_pee_start_dt IS NULL) THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	-- check if a IGS_PE_PERSENC_EFFCT record
  	-- exists when the course_cd is not specified
  	IF (p_course_cd IS NULL) THEN
  		-- set that no records have yet been found
  		v_rec_found := FALSE;
  		FOR v_pee_no_course IN c_pee_no_course LOOP
  			v_rec_found := TRUE;
  		END LOOP;
  		-- when no records are found
  		IF (v_rec_found = FALSE) THEN
  			p_message_name := null;
  			RETURN TRUE;
  		ELSE
  			-- records were found
  			p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- check if a IGS_PE_PERSENC_EFFCT record
  	-- exists when the course_cd is specified
  	IF (p_course_cd IS NOT NULL) THEN
  		-- set that no records have yet been found
  		v_rec_found := FALSE;
  		FOR v_pee_course IN c_pee_course LOOP
  			v_rec_found := TRUE;
  		END LOOP;
  		-- when no records are found
  		IF (v_rec_found = FALSE) THEN
  			p_message_name := null;
  			RETURN TRUE;
  		ELSE
  			-- records were found
  			p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- set the default return message number and type
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_chk');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_pee_chk;
  --
  -- Validate that person doesn't already have an open encumbrance effect.
  FUNCTION enrp_val_pee_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_rec_found		BOOLEAN;
  	CURSOR c_pee_no_course IS
  		SELECT	person_id
  		FROM	IGS_PE_PERSENC_EFFCT pee
  		WHERE	pee.person_id		 = p_person_id		 AND
  			pee.encumbrance_type	 = p_encumbrance_type	 AND
  			pee.pen_start_dt	 = p_pen_start_dt	 AND
  			pee.s_encmb_effect_type	 = p_s_encmb_effect_type AND
  			pee.sequence_number	 <>  p_sequence_number	 AND
  			pee.expiry_dt 		IS NULL;
  	CURSOR c_pee_course IS
  		SELECT	person_id
  		FROM	IGS_PE_PERSENC_EFFCT pee
  		WHERE	pee.person_id		 = p_person_id		 AND
  			pee.encumbrance_type	 = p_encumbrance_type	 AND
  			pee.pen_start_dt	 = p_pen_start_dt	 AND
  			pee.s_encmb_effect_type	 = p_s_encmb_effect_type AND
  			pee.sequence_number	 <>  p_sequence_number	 AND
  			pee.expiry_dt 		 IS NULL		 AND
  			pee.course_cd		 = p_course_cd;
  BEGIN
  	-- This module validates that there are no other 'open ended'
  	-- IGS_PE_PERSENC_EFFCT records for the nominated encumbrance
  	-- effect type.
  	-- validate the input parameters
  	IF (p_person_id IS NULL OR
  	    p_encumbrance_type IS NULL OR
  	    p_pen_start_dt IS NULL OR
  	    p_s_encmb_effect_type IS NULL OR
  	    p_sequence_number IS NULL) THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	-- check if a IGS_PE_PERSENC_EFFCT record
  	-- exists when the course_cd is not specified
  	IF (p_course_cd IS NULL) THEN
  		-- set that no records have yet been found
  		v_rec_found := FALSE;
  		FOR v_pee_no_course IN c_pee_no_course LOOP
  			v_rec_found := TRUE;
  		END LOOP;
  		-- when no records are found
  		IF (v_rec_found = FALSE) THEN
  			p_message_name := null;
  			RETURN TRUE;
  		ELSE
  			-- records were found
  			p_message_name := 'IGS_EN_PERS_ENCUMB_ALREADY_SP';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- check if a IGS_PE_PERSENC_EFFCT record
  	-- exists when the course_cd is specified
  	IF (p_course_cd IS NOT NULL) THEN
  		-- set that no records have yet been found
  		v_rec_found := FALSE;
  		FOR v_pee_course IN c_pee_course LOOP
  			v_rec_found := TRUE;
  		END LOOP;
  		-- when no records are found
  		IF (v_rec_found = FALSE) THEN
  			p_message_name := null;
  			RETURN TRUE;
  		ELSE
  			-- records were found
  			p_message_name := 'IGS_EN_PRSN_ENCUMB_EFFECT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- set the default return message number and type
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_open');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_pee_open;
  --
  -- Validate the course code on the person exclusion effect table.
  FUNCTION enrp_val_pee_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_pee_crs
  	-- for a IGS_PE_PERSENC_EFFCT if the course_cd is set ensure
  	-- that the person is enrolled in a course
  DECLARE
  	v_check		VARCHAR2(1);
  	CURSOR	c_person_exist IS
  		SELECT	'x'
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = p_person_id	AND
  			course_cd = p_course_cd	AND
  			course_attempt_status IN
  				('ENROLLED', 'INACTIVE', 'INTERMIT');
  BEGIN
  	p_message_name := null;
  	-- validate input parameter
  	IF (p_person_id IS NULL OR
  			p_course_cd IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- check if the person is enrolled in the specified course
  	OPEN c_person_exist;
  	FETCH c_person_exist INTO v_check;
  	IF (c_person_exist%NOTFOUND) THEN
  		-- person is not enrolled in the specified course
  		CLOSE c_person_exist;
  		p_message_name := 'IGS_EN_PERSON_NOT_ENROLLED';
  		RETURN FALSE;
  	END IF;
  	-- person is enrolled in the specified course
  	CLOSE c_person_exist;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_crs');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END enrp_val_pee_crs;
  --
  -- Validate whether or not a person is enrolled in any course.
  FUNCTION enrp_val_pee_sca(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_pee_sca
  	-- validate whether or not a person is enrolled in any course
  DECLARE
  	v_check		VARCHAR2(1);
  	CURSOR	c_person_exist IS
  		SELECT	'x'
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = p_person_id	AND
  			course_attempt_status IN
  			('ENROLLED', 'INACTIVE', 'INTERMIT');
  BEGIN
  	p_message_name := null;
  	-- validate input parameters
  	IF (p_person_id IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_person_exist;
  	FETCH c_person_exist INTO v_check;
  	IF (c_person_exist%FOUND) THEN
  		CLOSE c_person_exist;
  		p_message_name := 'IGS_EN_PERS_ENRL_COURSE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_person_exist;
  	-- person is not enrolled in a course
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_sca');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END enrp_val_pee_sca;
  --
  -- Validate person is enrolled for encumbrance purposes
  FUNCTION enrp_val_pee_enrol(
  p_person_id IN NUMBER ,
  p_effect_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_pee_enrol
  	-- For a IGS_PE_PERSENC_EFFCT based on a s_encmb_effect_type which has
  	-- the to_course_ind set, ensure that the person is enrolled in a course.
  	-- If not, this type of effect cannot be created.
  DECLARE
  	v_check		VARCHAR2(1);
  	CURSOR	c_seet_exist IS
  		SELECT	'x'
  		FROM	IGS_EN_ENCMB_EFCTTYP_V
  		WHERE	S_ENCMB_EFFECT_TYPE = p_effect_type	AND
  			apply_to_course_ind = 'Y';
  	CURSOR	c_sca_exist IS
  		SELECT	'x'
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id	AND
  			sca.course_attempt_status IN ('ENROLLED', 'INACTIVE', 'INTERMIT');
  BEGIN
  	p_message_name := null;
  	-- validate the input parameters
  	IF (p_person_id IS NULL OR p_effect_type IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Check if the apply_to_course_ind is set for the effect_type
  	OPEN c_seet_exist;
  	FETCH c_seet_exist INTO v_check;
  	IF (c_seet_exist%NOTFOUND) THEN
  		CLOSE c_seet_exist;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_seet_exist;
  	-- Check if the person is enrolled in a course
  	OPEN c_sca_exist;
  	FETCH c_sca_exist INTO v_check;
  	IF (c_sca_exist%FOUND) THEN
  		CLOSE c_sca_exist;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_sca_exist;
  		p_message_name := 'IGS_EN_EFFECT_TYPE_NOT_CREATE';
  		RETURN FALSE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_enrol');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END enrp_val_pee_enrol;
  --
  -- Validate the encumbrance effect course code
  FUNCTION enrp_val_pee_crs_cd(
  p_effect_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_pee_crs_cd
  	-- Validate if the course_cd can be set for the nominated s_encmb_effect_type
  DECLARE
  	v_check		VARCHAR2(1);
  	CURSOR c_seet IS
  		SELECT 'x'
  		FROM 	IGS_EN_ENCMB_EFCTTYP_V
  		WHERE	s_encmb_effect_type = p_effect_type	AND
  			apply_to_course_ind = 'Y';
  BEGIN
  	-- course code is only specified and must be for encumbrance effect types
  	-- which have the apply_to_course_ind set
  	p_message_name := null;
  	OPEN c_seet;
  	FETCH c_seet INTO v_check;
  	IF (c_seet%NOTFOUND) THEN
  		CLOSE c_seet;
  		IF (p_course_cd IS NULL) THEN
  			-- course not set which is correct
  			RETURN TRUE;
  		ELSE
  			-- course cannot be set
  			p_message_name := 'IGS_EN_CANT_SPEC_COURS_CD';
  			RETURN FALSE;
  		END IF;
  	ELSE -- effect has the course ind set
  		CLOSE c_seet;
  		IF (p_course_cd IS NULL) THEN
  			-- course must be set
  			p_message_name := 'IGS_EN_MUST_SPEC_COURS_CD';
  			RETURN FALSE;
  		ELSE
  			RETURN TRUE;
  		END IF;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_crs_cd');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END enrp_val_pee_crs_cd;
  --
  -- Validate the encumbrance effect restricted credit points
  FUNCTION enrp_val_pee_rstr_cp(
  p_effect_type IN VARCHAR2 ,
  p_restricted_enrolment_cp IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  BEGIN
  	-- This module validates if the restricted enrolment credit points
  	-- can be set for the nominated s_encmb_effect_type.
  	-- validate that enrolment credit points are only specified (and must be)
  	-- for the 'Restricted Credit Point' effects 'RSTR_LE_CP' and
  	-- 'RSTR_GE_CP'.
  	p_message_name := null;
  	IF (p_effect_type IN ('RSTR_GE_CP', 'RSTR_LE_CP')) THEN
  		IF (p_restricted_enrolment_cp IS NULL) THEN
  			-- credit points must be set
  			p_message_name := 'IGS_EN_SPEC_RESR_ENR_POINTS';
  			RETURN FALSE;
  		END IF;
  	ELSE -- no credit point is set at all (i.e can only be
  	     -- set if the s_encmb_effect_type is set)
  		IF (p_restricted_enrolment_cp IS NOT NULL) THEN
  			-- credit points cannot be set
  			p_message_name := 'IGS_EN_CANT_SPEC_ENRL_CRDT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_rstr_cp');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_pee_rstr_cp;
  --
  -- Validate the encumbrance effect attendance type
  FUNCTION enrp_val_pee_rstr_at(
  p_effect_type IN VARCHAR2 ,
  p_restricted_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN -- enrp_val_pee_rstr_at
  DECLARE
  BEGIN
  	p_message_name := null;
  	-- attendance type is only specified (and must be) for the
  	-- Restricted Attendance Type' effect ('RSTR_AT_TY')
  	IF (p_effect_type = 'RSTR_AT_TY') THEN
  		IF (p_restricted_attendance_type IS NULL) THEN
  			p_message_name := 'IGS_EN_REST_ATTN_NOT_NULL';
  			RETURN FALSE;
  		ELSE
  			RETURN TRUE;
  		END IF;
  	END IF;
  	IF (p_restricted_attendance_type IS NOT NULL) THEN
  		p_message_name := 'IGS_EN_CAN_SPEC_RESTR_ATT';
  		RETURN FALSE;
  	ELSE
  		RETURN TRUE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_pee_rstr_at');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END enrp_val_pee_rstr_at;
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dts
  --
  -- Validate the attendance type closed indicator.
  FUNCTION enrp_val_att_closed(
  p_attend_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_closed_ind		VARCHAR2(1);
  	CURSOR c_attend_type IS
  		SELECT	closed_ind
  		FROM	IGS_EN_ATD_TYPE
  		WHERE	attendance_type = p_attend_type;
  BEGIN
  	-- Check if the IGS_EN_ATD_TYPE is closed
  	p_message_name := null;
  	OPEN c_attend_type;
  	FETCH c_attend_type INTO v_closed_ind;
  	IF (c_attend_type%NOTFOUND) THEN
  		CLOSE c_attend_type;
  		RETURN TRUE;
  	END IF;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_PS_ATTEND_TYPE_CLOSED';
  		CLOSE c_attend_type;
  		RETURN FALSE;
  	END IF;
  	-- record is not closed
  	CLOSE c_attend_type;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PEE.enrp_val_att_closed');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_att_closed;
  --
END IGS_EN_VAL_PEE;

/
