--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PCE" AS
/* $Header: IGSEN50B.pls 115.5 2002/11/29 00:02:08 nsidana ship $ */
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- modified procedure ENRP_VAL_PEE_TABLE
  -- added code from IGSEN60B
  --
  -- Validate that IGS_PE_PERSON doesn't already have an open crs exclusion.
  FUNCTION enrp_val_pce_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_pce_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_val_pce_open
  	-- Validate that there are no other "open ended" pce records
  	-- for the nominated encumbrance effect type
  DECLARE
  	v_check		VARCHAR2(1);
  	v_ret_val	BOOLEAN DEFAULT TRUE;
  	CURSOR c_person_course_exclusion IS
  		SELECT 'x'
  		FROM	IGS_PE_COURSE_EXCL
  		WHERE
  			person_id		= p_person_id		AND
  			encumbrance_type	= p_encumbrance_type	AND
  			pen_start_dt		= p_pen_start_dt	AND
  			s_encmb_effect_type	= p_s_encmb_effect_type	AND
  			pee_start_dt		= p_pee_start_dt	AND
  			course_cd		= p_course_cd		AND
  			expiry_dt	IS NULL				AND
  			pce_start_dt		 <>  p_pce_start_dt;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_person_course_exclusion;
  	FETCH c_person_course_exclusion INTO v_check;
  	IF (c_person_course_exclusion%FOUND) THEN
  		-- open record already exists
  		IF (p_s_encmb_effect_type = 'EXC_COURSE') THEN
  			p_message_name := 'IGS_EN_PRSN_PRG_EXCLUSION';
  			v_ret_val := FALSE;
  		ELSE
  			p_message_name := 'IGS_EN_PRSN_PRG_SUSPENSION';
  			v_ret_val := FALSE;
  		END IF;
  	END IF;
  	CLOSE c_person_course_exclusion;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCE.enrp_val_pce_open');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END enrp_val_pce_open;
  --
  -- Routine to process pce rowids in PL/SQL TABLE for the current commit.
  FUNCTION enrp_prc_pce_rowids(
  p_inserting IN BOOLEAN ,
  p_updating IN BOOLEAN ,
  p_deleting IN BOOLEAN ,
  p_message_name IN OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
  	v_index		BINARY_INTEGER;
  	r_person_course_exclusion  IGS_PE_COURSE_EXCL%ROWTYPE;
  BEGIN
  	-- Process saved rows.
  	FOR  v_index IN 1..gv_table_index - 1
  	LOOP
  		BEGIN
  			SELECT	*
  			INTO	r_person_course_exclusion
  			FROM	IGS_PE_COURSE_EXCL
  			WHERE	ROWID = gt_rowid_table(v_index);
  			EXCEPTION
  				WHEN OTHERS THEN
				        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
					FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCE.enrp_prc_pce_rowids');
					IGS_GE_MSG_STACK.ADD;
	       	        		App_Exception.Raise_Exception;


  		END;
  		-- Validate for open ended person_crs_exclusion records.
  		IF r_person_course_exclusion.expiry_dt IS NULL THEN
  			IF IGS_EN_VAL_PCE.enrp_val_pce_open (
  					r_person_course_exclusion.person_id,
  					r_person_course_exclusion.encumbrance_type,
  					r_person_course_exclusion.pen_start_dt,
  					r_person_course_exclusion.s_encmb_effect_type,
  					r_person_course_exclusion.pee_start_dt,
  					r_person_course_exclusion.course_cd,
  					r_person_course_exclusion.pce_start_dt,
  					p_message_name) = FALSE THEN
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END enrp_prc_pce_rowids;
  --
  --
  -- To validate the nominated date is not less than current date..
  FUNCTION enrp_val_encmb_dt(
  p_date IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- Validate that encumbrance date (start or expiry)
  	-- is greater or equal to the current date
  DECLARE
  	BEGIN
  	p_message_name := NULL;
  	-- Validate input parameters
  	IF (p_date IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Validate that parameter date is not less than the current date
  	IF (TRUNC(p_date) < TRUNC(SYSDATE)) THEN
  		p_message_name := 'IGS_EN_DT_NOT_LT_CURR_DT';
  		RETURN FALSE;
  	ELSE
  		RETURN TRUE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCE.enrp_val_encmb_dt');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END enrp_val_encmb_dt;
  --
  -- To validate that expiry date is greater than or equal to start date.
  FUNCTION enrp_val_strt_exp_dt(
  p_start_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  	IF p_expiry_dt < p_start_dt THEN
  		p_message_name := 'IGS_EN_EXPDT_GE_STDT';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END enrp_val_strt_exp_dt;
  --
  -- Validate if a IGS_PS_COURSE must be discontinued before it can excluded.
  FUNCTION enrp_val_crs_exclsn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_exclusion_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
  	e_get_census_dt_alias_failed	EXCEPTION;
  BEGIN	-- enrp_val_crs_exlcsn
  	-- Validate if a IGS_PS_COURSE must be discontinued before
  	-- a IGS_PS_COURSE exclusion can be applied.  It is assumed that this
  	-- module only ever invoked with an enrolled IGS_PS_COURSE.
  DECLARE
  	cst_warn	CONSTANT VARCHAR2(1) := 'W';
  	cst_error	CONSTANT VARCHAR2(1) := 'E';
  	v_census_dt_alias	IGS_GE_S_GEN_CAL_CON.census_dt_alias%TYPE;
  	v_person_enrolled	BOOLEAN	DEFAULT FALSE;
  	v_validate_failed	BOOLEAN DEFAULT FALSE;
  	v_check		VARCHAR2(1);
  	CURSOR	c_get_census_dt_alias IS
  		SELECT	census_dt_alias
  		FROM	IGS_GE_S_GEN_CAL_CON
  		WHERE	s_control_num = 1;
  	CURSOR	c_student_unit_attempt IS
  		SELECT	cal_type,
  			ci_sequence_number
  		FROM	IGS_EN_SU_ATTEMPT
  		WHERE	person_id	= p_person_id	AND
  			course_cd	= p_course_cd	AND
  			unit_attempt_status = 'ENROLLED';
  	CURSOR	c_check_census_dt (
  			cp_cal_type		IGS_CA_DA_INST_V.cal_type%TYPE,
  			cp_ci_sequence_number	IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
  			cp_dt_alias		IGS_CA_DA_INST_V.dt_alias%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_CA_DA_INST_V
  		WHERE	cal_type		= cp_cal_type		AND
  			ci_sequence_number 	= cp_ci_sequence_number AND
  			dt_alias 		= cp_dt_alias		AND
  			NVL(alias_val,IGS_GE_DATE.IGSDATE('1900/01/01'))
  				 >= p_exclusion_start_dt;
  BEGIN
  	p_message_name := NULL;
  	-- Validate the input parameters
  	IF (p_person_id IS NULL 	OR
  			p_course_cd IS NULL OR
  			p_exclusion_start_dt IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_get_census_dt_alias;
  	FETCH c_get_census_dt_alias INTO v_census_dt_alias;
  	IF (c_get_census_dt_alias%NOTFOUND) THEN
  		CLOSE c_get_census_dt_alias;
  		RAISE e_get_census_dt_alias_failed;
  	END IF;
  	CLOSE c_get_census_dt_alias;
  	FOR v_sua_rec IN c_student_unit_attempt LOOP
  		v_person_enrolled := TRUE;
  		-- Check if the IGS_PE_PERSON is enrolled in units which have a census date after
  		-- the exclusion start date.
  		OPEN c_check_census_dt(v_sua_rec.cal_type,
  					v_sua_rec.ci_sequence_number,
  					v_census_dt_alias);
  		FETCH c_check_census_dt INTO v_check;
  		IF (c_check_census_dt%FOUND) THEN
  			CLOSE c_check_census_dt;
  			v_validate_failed := TRUE;
  			EXIT;
  		END IF;
  		CLOSE c_check_census_dt;
  	END LOOP;
  	IF (v_person_enrolled = FALSE) THEN
  		-- IGS_PE_PERSON is not enrolled in any units within the IGS_PS_COURSE
  		p_message_name := 'IGS_EN_CANT_APPLY_ENCUM_EFFEC';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	IF (v_validate_failed = TRUE) THEN
  		-- These units must be discontinued before the exclusion can be applied
  		p_message_name := 'IGS_EN_DISCON_STUD_ENRL';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- The IGS_PE_PERSON is not enrolled in any units within the IGS_PS_COURSE which have a
  	-- census date after the exclusion start date
  	-- Exclusion can be applied, but a warning will be displayed about the
  	-- enrolled IGS_PS_UNITs
  	p_message_name := 'IGS_EN_PERS_ENRL_EXCL_COURSE';
  	p_return_type := cst_warn;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN e_get_census_dt_alias_failed THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCE.enrp_val_crs_exclsn 1');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCE.enrp_val_crs_exclsn 2');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END enrp_val_crs_exclsn;
  --
  -- Validate the IGS_PS_COURSE code on the IGS_PE_PERSON IGS_PS_COURSE exclusion table.
  FUNCTION enrp_val_pce_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_exclusion_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_val_pce_crs
  	-- Validate whether or not a IGS_PE_PERSON is enrolled
  	-- in a specified IGS_PS_COURSE and whether or not the IGS_PS_COURSE must
  	-- be discontinue before a IGS_PS_COURSE exclusion can be applied
  DECLARE
  	v_check		VARCHAR2(1);
  	v_result	BOOLEAN;
  	CURSOR	c_person_exist IS
  		SELECT	'x'
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = p_person_id		AND
  			course_cd = p_course_cd		AND
  			course_attempt_status IN
  				('ENROLLED', 'INACTIVE', 'INTERMIT');
  BEGIN
  	p_message_name := NULL;
  	-- Validate input parameters
  	IF (p_person_id IS NULL OR
  			p_course_cd IS NULL OR
  			p_exclusion_start_dt IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Check if the IGS_PE_PERSON is enrolled in the specified IGS_PS_COURSE
  	OPEN c_person_exist;
  	FETCH c_person_exist INTO v_check;
  	IF (c_person_exist%FOUND) THEN
  		CLOSE c_person_exist;
  		-- validate if the IGS_PS_COURSE must be discontinued
  		v_result := IGS_EN_VAL_PCE.enrp_val_crs_exclsn(
  					p_person_id,
  					p_course_cd,
  					p_exclusion_start_dt,
  					p_message_name,
  					p_return_type);
  		RETURN v_result;
  	END IF;
  	CLOSE c_person_exist;
  	-- IGS_PE_PERSON is not enrolled in the specified IGS_PS_COURSE
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCE.enrp_val_pce_crs');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END enrp_val_pce_crs;
  --
  -- Validate the encumbrance effect table
  FUNCTION enrp_val_pee_table(
  p_effect_type IN VARCHAR2 ,
  p_table_name IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_val_pee_table
  	-- Validate if records can be created in the nominated exclusion/requirement
  	-- table for the nominated s_encmb_effect_type
  DECLARE
  BEGIN
        p_message_name := null;
        IF      (p_effect_type = 'EXC_CRS_GP' AND
                 p_table_name = 'IGS_PE_CRS_GRP_EXCL')  THEN
                RETURN TRUE;
        ELSIF   (p_effect_type IN('EXC_COURSE', 'SUS_COURSE') AND
                 p_table_name = 'IGS_PE_COURSE_EXCL')   THEN
                RETURN TRUE;
        ELSIF   (p_effect_type = 'EXC_CRS_U'    AND
                 p_table_name = 'IGS_PE_PERS_UNT_EXCL') THEN
                RETURN TRUE;
        ELSIF   (p_effect_type = 'RQRD_CRS_U'   AND
                 p_table_name = 'IGS_PE_UNT_REQUIRMNT') THEN
                RETURN TRUE;
        ELSIF   (p_effect_type = 'EXC_CRS_US'   AND
                 p_table_name = 'IGS_PE_UNT_SET_EXCL')  THEN
                RETURN TRUE;
        END IF;

  	-- Unable to create exclusion/requirement records for this
  	-- encumbrance effect type
  	p_message_name := 'IGS_EN_CANT_CREATE_REC_ENCUMB';
  	RETURN FALSE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCE.enrp_val_pee_table');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END enrp_val_pee_table;
  --
  -- To validate that child date is not less than parent start date.
  FUNCTION enrp_val_encmb_dts(
  p_parent_start_dt IN DATE ,
  p_child_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_val_encmb_dts
  	-- validate that a child encumbrace type record does not have
  	-- a start date less than of the parent record.
  DECLARE
  BEGIN
  	IF (p_child_start_dt < p_parent_start_dt) THEN
  		p_message_name := 'IGS_EN_CANT_SET_START_DATE';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PCE.enrp_val_encmb_dts');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END enrp_val_encmb_dts;
END IGS_EN_VAL_PCE;

/
