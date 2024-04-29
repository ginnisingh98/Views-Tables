--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SCI" AS
/* $Header: IGSEN64B.pls 120.0 2005/06/01 17:58:08 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_strt_end_dt removed
  -- smaddali  20-sep-04     EN306- intermission updates build, bug#3889089
  -------------------------------------------------------------------------------------------
  -- To validate that SCI is possible with students UA's
  FUNCTION ENRP_VAL_SCI_UA(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
  	NO_RECORDS_FOUND	EXCEPTION;
   BEGIN
  DECLARE
  	v_census_date		IGS_GE_S_GEN_CAL_CON.census_dt_alias%TYPE;
      	CURSOR	c_census_dt IS
  		SELECT	census_dt_alias
  		FROM	IGS_GE_S_GEN_CAL_CON
  		WHERE	s_control_num = 1;
  	CURSOR  c_sua_details(
  		cp_person_id	IGS_EN_STDNT_PS_INTM.person_id%TYPE,
  		cp_course_cd	IGS_EN_STDNT_PS_INTM.course_cd%TYPE) IS
  		SELECT	cal_type,
  			ci_sequence_number
  		FROM	IGS_EN_SU_ATTEMPT
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd AND
  			unit_attempt_status NOT IN ('UNCONFIRM',
  						    'INVALID',
  						    'DISCONTIN');
  	CURSOR  c_daiv_details(
  		cp_cal_type	IGS_CA_DA_INST_V.cal_type%TYPE,
  		cp_ci_seq_num	IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
  		cp_dt_alias	IGS_CA_DA_INST_V.dt_alias%TYPE) IS
  		SELECT	alias_val
  		FROM	IGS_CA_DA_INST_V
  		WHERE	cal_type 	   = cp_cal_type   AND
  			ci_sequence_number = cp_ci_seq_num AND
  			dt_alias	   = cp_dt_alias
  		ORDER BY alias_val;
  BEGIN
  	-- This module validates that the intermission is
  	-- in line with the student's unit attempts.
  	-- The rules are that the intermission can't
  	-- pre-date the censusdate of the student's last
  	-- enrolled unit attempts teaching period (ie.
  	-- where the current date is > the same census
  	-- date).  This check excludes unit attempts of
  	-- status 'UNCONFIRM', 'INVALID', 'DISCONTIN'.
  	p_message_name := null;
  	OPEN  c_census_dt;
  	FETCH c_census_dt INTO v_census_date;
  	IF (c_census_dt%NOTFOUND) THEN
  		CLOSE c_census_dt;
  		RAISE NO_RECORDS_FOUND;
  	END IF;
  	CLOSE c_census_dt;
  	-- selecting IGS_CA_TYPE and ci_sequence_number details
  	FOR v_sua_rec IN c_sua_details(p_person_id,
  				       p_course_cd) LOOP
  		-- looping backwards through the
  		-- student's unit attempt records
  		FOR v_daiv_rec IN c_daiv_details(v_sua_rec.cal_type,
  					         v_sua_rec.ci_sequence_number,
  				       	         v_census_date) LOOP
  			-- set the message number if the census
  			-- date is after the current date and the
  			-- intermssion start date is on or before
  			-- it, as intermission is not permitted
  			IF (SYSDATE > v_daiv_rec.alias_val AND
  			    p_start_dt <= v_daiv_rec.alias_val) THEN
  				p_message_name := 'IGS_EN_INTER_NOTBACK_DATED';
  				RETURN FALSE;
  			END IF;
  		END LOOP;
  	END LOOP;
  	RETURN TRUE;
  EXCEPTION
  	WHEN NO_RECORDS_FOUND THEN
			Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCI.enrp_val_sci_ua');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_sci_ua;
  --
  -- Validate that intermission is allowed for the student COURSE attempt
  FUNCTION ENRP_VAL_SCI_ALWD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
  BEGIN
  DECLARE
   	v_course_attempt_status   IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	CURSOR	c_sca IS
  		SELECT 	course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = p_person_id AND
  			course_cd = p_course_cd;
  BEGIN
  	-- This module validates that intermission is allowed
  	-- for the student's COURSE attempt, subject to :
  	--	# the COURSE status of the student's IGS_PS_COURSE
  	--	  attempt can't be 'UNCONFIRM', 'DISCONTIN',
  	--	 'LAPSED', 'DELETED' 'COMPLETED'
  	p_message_name := null;
  	OPEN  c_sca;
  	FETCH c_sca INTO v_course_attempt_status;
  	-- check if a record has been found
  	IF (c_sca%NOTFOUND) THEN
  		CLOSE c_sca;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sca;
  	IF (v_course_attempt_status = 'DISCONTIN') THEN
  		p_message_name := 'IGS_EN_INTRM_NA_FOR_DICONT';
  		RETURN FALSE;
  	ELSIF (v_course_attempt_status = 'LAPSED') THEN
  		p_message_name := 'IGS_EN_INTRM_NA_FOR_LAPSED';
  		RETURN FALSE;
  	ELSIF (v_course_attempt_status = 'DELETED') THEN
  		p_message_name := 'IGS_EN_INTRM_NA_FOR_DELETED';
  		RETURN FALSE;
  	ELSIF (v_course_attempt_status = 'COMPLETED') THEN
  		p_message_name := 'IGS_EN_INTER_NOTALLOW_COMPLET';
  		RETURN FALSE;
  	ELSIF (v_course_attempt_status = 'UNCONFIRM') THEN
  		p_message_name := 'IGS_EN_CHG_OPT_NOTALLOW_UNCON';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCI.enrp_val_sci_alwd');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_sci_alwd;
  --
  -- Validate COURSE version of student COURSE intermission.
  FUNCTION ENRP_VAL_SCI_CV_ALWD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
  BEGIN
  DECLARE
   	v_version_number  	IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_int_allowed_ind	IGS_PS_VER.intrmsn_allowed_ind%TYPE;
  	v_num_units_bf_int	IGS_PS_VER.num_of_units_before_intrmsn%TYPE;
  	v_count			NUMBER;
  	CURSOR	c_sca_details
  		(cp_person_id	IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  		 cp_course_cd	IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  		SELECT 	version_number
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd;
  	CURSOR	c_cv_details
  		(cp_course_cd	IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
  		 cp_version_num	IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
  		SELECT 	intrmsn_allowed_ind,
  			num_of_units_before_intrmsn
  		FROM	IGS_PS_VER
  		WHERE	course_cd = cp_course_cd AND
  			version_number = cp_version_num;
  	CURSOR	c_sca_count
  		(cp_person_id	IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  		 cp_course_cd	IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  		SELECT 	count(*)
  		FROM	IGS_EN_SU_ATTEMPT
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd AND
  			unit_attempt_status = 'COMPLETED';
  BEGIN
  	-- This module validates that intermission is allowed
  	-- for the student's COURSE version, subject to :
  	--	# the IGS_PS_VER.intrmsn_allowed_ind
  	--	  being set (this is only a warning)
  	--	# the number of complete unit attempt must
  	--	  exceed the IGS_PS_VER.num_of_units_
  	--	  before_intrmsn
  	p_message_name := null;
  	OPEN  c_sca_details(p_person_id,
  		   	    p_course_cd);
  	FETCH c_sca_details INTO v_version_number;
  	-- check if a record has been found
  	IF (c_sca_details%NOTFOUND) THEN
  		CLOSE c_sca_details;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sca_details;
  	OPEN c_cv_details(p_course_cd,
  			  v_version_number);
  	FETCH c_cv_details INTO v_int_allowed_ind,
  				v_num_units_bf_int;
  	-- check if the IGS_PS_VER intermission
  	-- allowed indicator
  	IF (v_int_allowed_ind = 'N') THEN
  		p_message_name := 'IGS_EN_INTERMISSION_NOTPERM';
  		RETURN FALSE;
  	END IF;
  	-- check that the student has completed
  	-- enough unit attempts
  	IF (v_num_units_bf_int IS NOT NULL OR
  	    v_num_units_bf_int <> 0) THEN
  		OPEN  c_sca_count(p_person_id,
  				  p_course_cd);
  		FETCH c_sca_count INTO v_count;
  		CLOSE c_sca_count;
  		IF (v_count < v_num_units_bf_int) THEN
  			p_message_name := 'IGS_EN_INCOMPL_STUD_UNITS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCI.enrp_val_sci_cv_alwd');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_sci_cv_alwd;
  --
  -- Validate whether student COURSE intermission deletion is allowed
  FUNCTION ENRP_VAL_SCI_DEL(
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
   BEGIN
  DECLARE
  BEGIN
  	--- Set default message number
  	p_message_name := null;
  	IF p_start_dt <= SYSDATE THEN
  		p_message_name := 'IGS_EN_NOTDEL_ITMDET_SET_ENDT';
  		Return FALSE;
  	END IF;
  	--- Return default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCI.enrp_val_sci_del');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_sci_del;
  --
  -- Validate student COURSE intermission duration
  FUNCTION ENRP_VAL_SCI_DRTN(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
   BEGIN
  DECLARE
  	CURSOR	c_get_mid IS
  		SELECT	max_intrmsn_duration
  		FROM	IGS_PS_VER
  		WHERE	course_cd = p_course_cd AND
  			version_number = p_version_number;
  	v_mid					IGS_PS_VER.max_intrmsn_duration%TYPE;
  BEGIN
  	--- Set default message number
  	p_message_name := null;
  	--- Select the maximum intermission from the students COURSE version
  	OPEN c_get_mid;
  	FETCH c_get_mid INTO v_mid;
  	IF c_get_mid%NOTFOUND OR
  	v_mid IS NULL OR
  	v_mid = 0 THEN
  		CLOSE c_get_mid;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_mid;
  	IF MONTHS_BETWEEN( p_end_dt, p_start_dt) > v_mid THEN
  		p_message_name := 'IGS_EN_INTR_PER_EXCEEDS_MAX';
  		RETURN FALSE;
  	END IF;
  	--- Return default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCI.enrp_val_sci_drtn');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_sci_drtn;
  --
  -- Validate for overlap of student COURSE intermission records.
  FUNCTION ENRP_VAL_SCI_OVRLP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
  BEGIN
  DECLARE
   	v_sci_rec	 	IGS_EN_STDNT_PS_INTM%ROWTYPE;
        -- smaddali added the logical detele date check for EN306 - intermission updates build, bug#3889089 ,
        -- check for other active records overlapping with the current record.
  	CURSOR	c_sci(
  		cp_person_id IGS_EN_STDNT_PS_INTM.person_id%TYPE,
  		cp_course_cd IGS_EN_STDNT_PS_INTM.course_cd%TYPE,
  		cp_start_dt  IGS_EN_STDNT_PS_INTM.start_dt%TYPE) IS
  		SELECT	start_dt,
  			end_dt
  		FROM	IGS_EN_STDNT_PS_INTM
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd AND
  			start_dt <> cp_start_dt AND
                        TRUNC(logical_delete_date) = to_date('31-12-4712','DD-MM-YYYY');
  BEGIN
  	-- This module validates that the student_course_intermssion
  	-- record being created or updated does not overlap with an
  	-- existing intermission record for the nominated
  	-- IGS_EN_STDNT_PS_ATT
  	p_message_name := null;
  	FOR c_sci_rec IN c_sci(p_person_id,
  			    p_course_cd,
  			    p_start_dt) LOOP
  		-- Validate the start date is not between an existing date range
  		IF (p_start_dt >= c_sci_rec.start_dt) AND
  		     p_start_dt <= c_sci_rec.end_dt THEN
  			p_message_name := 'IGS_EN_IDO_STDT_BTWN_DTRNG';
  			RETURN FALSE;
  		END IF;
  		-- Validate the end date is not between an existing date range
  		IF (p_end_dt >= c_sci_rec.start_dt AND
      	                     p_end_dt <= c_sci_rec.end_dt) THEN
  			p_message_name := 'IGS_EN_IDO_ENDDT_BTWN_DTRNG';
  			RETURN FALSE;
  		END IF;
  		-- Validate the current dates do not overlap and entire exisitng date range
  		IF (p_start_dt <= c_sci_rec.start_dt AND
       	                     p_end_dt >= c_sci_rec.end_dt) THEN
  			p_message_name := 'IGS_EN_IDO_DT_OVERLAP_DTRNG';
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCI.enrp_val_sci_ovrlp');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_sci_ovrlp;
  --

END IGS_EN_VAL_SCI;

/
