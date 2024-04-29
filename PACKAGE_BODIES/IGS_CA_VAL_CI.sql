--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_CI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_CI" AS
/* $Header: IGSCA05B.pls 115.7 2002/11/28 22:57:15 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --npalanis   12-NOV-2002      Bug No. 2563531 .The alternate code is made required for
  --                            LOAD calendar instances.
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function genp_val_strt_end_dt removed
  -------------------------------------------------------------------------------------------
  -- Validate if calendar status is closed.
  FUNCTION calp_val_cs_closed(
  p_cal_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail	VARCHAR2(255);
  BEGIN	--calp_val_cs_closed
  	--This module Validates if IGS_CA_STAT.cal_status is closed
  DECLARE
  	v_cs_exists	VARCHAR2(1);
  	CURSOR c_cs IS
  		SELECT 	'X'
  		FROM	IGS_CA_STAT	cs
  		WHERE	cs.cal_status	= p_cal_status AND
  			cs.closed_ind	= 'Y';
  BEGIN
  	--Set the default message number
  	p_message_name :=NULL;
  	--If record exists then closed_ind = 'Y' therefore set p_message_name
  	OPEN c_cs;
  	FETCH c_cs INTO v_cs_exists;
  	IF (c_cs%FOUND) THEN
  		p_message_name := 'IGS_CA_CAL_STATUS_CLOSED';
  		CLOSE c_cs;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cs;
  	RETURN TRUE;
  END;

  END calp_val_cs_closed;
  --
  -- To validate calendar instance alternate code
  FUNCTION calp_val_ci_alt_cd(
  p_cal_type IN VARCHAR2 ,
  p_alternate_code IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN
  DECLARE
  	cst_academic 			CONSTANT VARCHAR2(10) := 'ACADEMIC';
  	cst_teaching 			CONSTANT VARCHAR2(10) := 'TEACHING';
  	cst_admission 			CONSTANT VARCHAR2(10) := 'ADMISSION';
  	cst_progress			CONSTANT VARCHAR2(10) := 'PROGRESS';
        cst_award                       CONSTANT VARCHAR2(10) := 'AWARD';
        cst_load                        CONSTANT VARCHAR2(10) := 'LOAD';
  	v_s_cal_cat			IGS_CA_TYPE.s_cal_cat%TYPE;
  	CURSOR c_cal_type (
  			cp_cal_type	IGS_CA_TYPE.cal_type%TYPE) IS
  		SELECT	CAT.s_cal_cat
  		FROM	IGS_CA_TYPE CAT
  		WHERE	CAT.cal_type = cp_cal_type;
  BEGIN
  	-- Module to validate that alternate code is given for calendar instances whose
  	-- calendar type  has system calendar categories 'ACADEMIC', 'TEACHING',
  	-- 'ADMISSION','AWARD' and 'PROGRESS'.
  	p_message_name := NULL;
  	OPEN	c_cal_type(
  			p_cal_type);
  	FETCH	c_cal_type INTO v_s_cal_cat;
  	IF(c_cal_type%FOUND) THEN
  		IF(p_alternate_code IS NULL) THEN
  			IF(v_s_cal_cat = cst_academic) THEN
  				CLOSE c_cal_type;
  				p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  				RETURN FALSE;
  			END IF;
  			IF(v_s_cal_cat = cst_teaching) THEN
  				CLOSE c_cal_type;
  				p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  				RETURN FALSE;
  			END IF;
  			IF(v_s_cal_cat = cst_admission) THEN
  				CLOSE c_cal_type;
  				p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  				RETURN FALSE;
  			END IF;
-- added for bug 1620686
                        IF(v_s_cal_cat = cst_award) THEN
                                CLOSE c_cal_type;
                                p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                                RETURN FALSE;
                        END IF;
-- added for bug 1620686
  			IF(v_s_cal_cat = cst_progress) THEN
  				CLOSE c_cal_type;
  				p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  				RETURN FALSE;
  			END IF;
-- added for bug 2563531 ( to check that the load caledar is required)
  			IF(v_s_cal_cat = cst_load) THEN
  				CLOSE c_cal_type;
  				p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	CLOSE c_cal_type;
  	RETURN TRUE;
  END;
  END calp_val_ci_alt_cd;
  --
  --
  -- To validate a change of calendar instance
  FUNCTION calp_val_ci_status(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_old_cal_status IN VARCHAR2 ,
  p_new_cal_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	cst_planned		CONSTANT VARCHAR2(8) := 'PLANNED';
  	cst_active		CONSTANT VARCHAR2(8) := 'ACTIVE';
  	cst_inactive 		CONSTANT VARCHAR2(8) := 'INACTIVE';
  	v_other_detail		VARCHAR2(255);
  	v_cal_instance_rec	IGS_CA_INST%ROWTYPE;
  	v_cal_instance_rltshp_rec	IGS_CA_INST_REL%ROWTYPE;
  	v_dt_alias_instance_rec	IGS_CA_DA_INST_V%ROWTYPE;
  	v_new_s_cal_status	IGS_CA_STAT.s_cal_status%TYPE;
  	v_old_s_cal_status		IGS_CA_STAT.s_cal_status%TYPE;
  	v_s_cal_status		IGS_CA_STAT.s_cal_status%TYPE;
  	-- define cursors
  	CURSOR	c_cal_status(cp_cal_status IGS_CA_STAT.cal_status%TYPE)
  	IS
  	SELECT 	*
  	FROM	IGS_CA_STAT
  	WHERE	cal_status = cp_cal_status;
  	CURSOR	c_cir_subord_calendars
  	IS
  	SELECT 	*
  	FROM	IGS_CA_INST_REL
  	WHERE	sup_cal_type = p_cal_type AND
  		sup_ci_sequence_number = p_sequence_number;
  	CURSOR	c_cir_superior_calendars
  	IS
  	SELECT 	*
  	FROM	IGS_CA_INST_REL
  	WHERE	sub_cal_type = p_cal_type AND
  		sub_ci_sequence_number = p_sequence_number;
  	CURSOR	c_dt_alias_instance
  	IS
  	SELECT 	*
  	FROM	IGS_CA_DA_INST_V
  	WHERE	cal_type = p_cal_type AND
  		ci_sequence_number = p_sequence_number;
  	CURSOR	c_cal_instance(cp_cal_type IGS_CA_INST.cal_type%TYPE,
  		cp_sequence_number IGS_CA_INST.sequence_number%TYPE)
  	IS
  	SELECT 	*
  	FROM	IGS_CA_INST
  	WHERE	cal_type = cp_cal_type AND
  		sequence_number = cp_sequence_number;
  	-- define sub-routines
  	FUNCTION check_status_change
  	RETURN boolean AS
  	BEGIN
  		FOR	v_cal_status_rec IN c_cal_status(p_old_cal_status) LOOP
  			v_old_s_cal_status := v_cal_status_rec.s_cal_status;
  		END LOOP;
  		IF (v_new_s_cal_status = cst_inactive)
  		THEN
  			-- check calendar status is not being changed from PLANNED to INACTIVE
  			IF (v_old_s_cal_status = cst_planned)
  			THEN
  				p_message_name := 'IGS_CA_CALST_NOTCHG_PLAN_ACT';
  				RETURN FALSE;
  			END IF;
  		ELSIF (v_new_s_cal_status = cst_planned)
  		THEN
  			-- Check status is not being changed from INACTIVE to PLANNED
  			IF (v_old_s_cal_status = cst_inactive) THEN
  				p_message_name := 'IGS_CA_INACTIVE_NOTCHG_PLANN';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		RETURN TRUE;
  	END check_status_change;
  	FUNCTION check_related_calendars
  	RETURN boolean AS
  	BEGIN
  		IF (v_new_s_cal_status = cst_inactive) OR
  		    (v_new_s_cal_status = cst_planned)
  		THEN
  			-- Check subordinate calendars
  			OPEN 	c_cir_subord_calendars;
  			LOOP
  				FETCH 	c_cir_subord_calendars INTO v_cal_instance_rltshp_rec;
  				EXIT WHEN
  			 		c_cir_subord_calendars%NOTFOUND;
  				FOR  v_cal_instance_rec IN
  			   		 c_cal_instance(v_cal_instance_rltshp_rec.sub_cal_type,
  				  	  v_cal_instance_rltshp_rec.sub_ci_sequence_number) LOOP
  				EXIT WHEN
  					c_cal_instance%NOTFOUND;
  					FOR	v_cal_status_rec IN
  						c_cal_status(v_cal_instance_rec.cal_status) LOOP
  						v_s_cal_status := v_cal_status_rec.s_cal_status;
  					END LOOP;
  					IF (v_new_s_cal_status = cst_inactive)
  					THEN
  						-- if new status is INACTIVE, check ACTIVE or PLANNED sub-ordinate
  						-- calendars do not exist
  						IF (v_s_cal_status = cst_active) OR
  					 	    (v_s_cal_status = cst_planned)
  						THEN
  							CLOSE	c_cir_subord_calendars;
  							p_message_name := 'IGS_CA_ACTIVE_PLAN_SUBORD';
  							RETURN FALSE;
  						END IF;
  					ELSIF (v_new_s_cal_status = cst_planned)
  					THEN
  						-- if new status is PLANNED, check ACTIVE or INACTIVE  sub-ordinate
  						-- calendars do not exist
  						IF (v_s_cal_status = cst_active) OR
  					 	    (v_s_cal_status = cst_inactive)
  						THEN
  							CLOSE	c_cir_subord_calendars;
  							p_message_name := 'IGS_CA_ACTIVE_INACTIVE_SUBORD';
  							RETURN FALSE;
  						END IF;
  					END IF;
  				END LOOP;
  			END LOOP;
  		ELSIF (v_new_s_cal_status = cst_active) THEN
  			-- Check subordinate calendars
  			OPEN 	c_cir_superior_calendars;
  			LOOP
  				FETCH 	c_cir_superior_calendars
  				INTO	v_cal_instance_rltshp_rec;
  				EXIT WHEN
  					c_cir_superior_calendars%NOTFOUND;
  				FOR v_cal_instance_rec IN
  			   		 c_cal_instance(v_cal_instance_rltshp_rec.sup_cal_type,
  		     	   		 v_cal_instance_rltshp_rec.sup_ci_sequence_number) LOOP
  				EXIT WHEN
  					c_cal_instance%NOTFOUND;
  					FOR	v_cal_status_rec IN
  				       		 c_cal_status(v_cal_instance_rec.cal_status) LOOP
  						v_s_cal_status := v_cal_status_rec.s_cal_status;
  					END LOOP;
  					-- new status is ACTIVE, check superior calendars are not
  					-- INACTIVE or PLANNED
  					IF(v_s_cal_status = cst_inactive) OR
  					   (v_s_cal_status = cst_planned) THEN
  						CLOSE 	c_cir_superior_calendars;
  						p_message_name :='IGS_CA_SUPCAL_INACTIVE_PLAN';
  						RETURN FALSE;
  					END IF;
  				END LOOP;
  			END LOOP;
  		END IF;
  		IF(c_cir_subord_calendars%ISOPEN) THEN
  			CLOSE c_cir_subord_calendars;
  		END IF;
  		IF(c_cir_superior_calendars%ISOPEN) THEN
  			CLOSE c_cir_superior_calendars;
  		END IF;
  		RETURN TRUE;
  	END check_related_calendars;
  	FUNCTION check_dt_alias_instances
  	RETURN boolean AS
  	BEGIN
  		-- check date alias's have an alias value
  		IF (v_new_s_cal_status = cst_active)
  		THEN
  			OPEN 	c_dt_alias_instance;
  			LOOP
  				FETCH	c_dt_alias_instance
  				INTO	v_dt_alias_instance_rec;
  				EXIT WHEN
  					c_dt_alias_instance%NOTFOUND;
  				IF (v_dt_alias_instance_rec.alias_val IS NULL) THEN
  					CLOSE	c_dt_alias_instance;
  				  	p_message_name :='IGS_CA_STATUS_NOTCHG_ACTIVE';
  					RETURN FALSE;
  				END IF;
  			END LOOP;
  			IF (c_dt_alias_instance%ISOPEN) THEN
  				CLOSE c_dt_alias_instance;
  			END IF;
  		END IF;
  		RETURN TRUE;
  	END check_dt_alias_instances;
  BEGIN
  	-- check if the calendar status has changed
  	IF (p_new_cal_status = p_old_cal_status)
  	THEN
  		p_message_name :=NULL;
  		RETURN TRUE;
  	END IF;
  	FOR	v_cal_status_rec IN c_cal_status(p_new_cal_status) LOOP
  		-- check calendar status is not closed
  		IF (v_cal_status_rec.closed_ind = 'Y') THEN
  			p_message_name := 'IGS_CA_CAL_STATUS_CLOSED';
  			RETURN FALSE;
  		END IF;
  		v_new_s_cal_status := v_cal_status_rec.s_cal_status;
  	END LOOP;
  	-- p_old_cal_status may not have been passed
  	IF (NVL(p_old_cal_status,' ')  <> ' ')
  	THEN
  		IF check_status_change = FALSE
  		THEN
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- p_cal_type and p_sequence_number may not have been passed
  	IF (NVL(p_cal_type,' ')  <> ' ') AND
  	    (NVL(to_char(p_sequence_number),' ')  <> ' ')
  	THEN
  		IF check_related_calendars = FALSE
  		THEN
  			RETURN FALSE;
  		END IF;
  		IF  check_dt_alias_instances = FALSE
  		THEN
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
    END calp_val_ci_status;
  --
  -- To validate columns on insert or update of calendar instance.
  FUNCTION calp_val_ci_upd(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_alternate_code IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	cst_teaching_period	CONSTANT VARCHAR2(15) := 'TEACHING';
  	cst_academic_period	CONSTANT VARCHAR2(15) := 'ACADEMIC';
  	CURSOR	c_cal_instance (
  		cp_cal_type IGS_CA_INST.cal_type%TYPE,
  		cp_cal_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
  	SELECT 	*
  	FROM	IGS_CA_INST
  	WHERE	cal_type = cp_cal_type
  	AND	sequence_number = cp_cal_sequence_number ;
  	CURSOR	c_cal_inst_rltshp_sup(
  		cp_sub_cal_type IGS_CA_INST_REL.sup_cal_type%TYPE,
  		cp_sub_ci_sequence_number
  			IGS_CA_INST_REL.sup_ci_sequence_number%TYPE) IS
  	SELECT 	*
  	FROM	IGS_CA_INST_REL
  	WHERE	sub_cal_type = cp_sub_cal_type
  	AND	sub_ci_sequence_number = cp_sub_ci_sequence_number;
  	CURSOR	c_cal_inst_rltshp_sub(
  		cp_sup_cal_type IGS_CA_INST_REL.sup_cal_type%TYPE,
  		cp_sup_ci_sequence_number
  			 IGS_CA_INST_REL.sup_ci_sequence_number%TYPE) IS
  	SELECT 	*
  	FROM	IGS_CA_INST_REL
  	WHERE	sup_cal_type = cp_sup_cal_type
  	AND	sup_ci_sequence_number = cp_sup_ci_sequence_number;
  	CURSOR	c_cal_type(
  		cp_cal_type IGS_CA_TYPE.cal_type%TYPE)
  	IS
  	SELECT 	*
  	FROM	IGS_CA_TYPE
  	WHERE	cal_type = cp_cal_type
  	AND	s_cal_cat = cst_academic_period;
  	CURSOR	c_cal_typ(
  		cp_cal_type IGS_CA_TYPE.cal_type%TYPE)
  	IS
  	SELECT 	*
  	FROM	IGS_CA_TYPE
  	WHERE	cal_type = cp_cal_type
  	AND	s_cal_cat = cst_teaching_period;
  	v_other_detail		VARCHAR2(255);
  BEGIN
  	FOR c_cal_inst_rltshp_sup_rec IN c_cal_inst_rltshp_sup(
  		p_cal_type,
  		p_sequence_number)
  	LOOP
  		FOR c_cal_type_rec IN c_cal_type(c_cal_inst_rltshp_sup_rec.sup_cal_type)
  		LOOP
  			FOR	c_cal_inst_rltshp_sub_rec IN c_cal_inst_rltshp_sub(
  				c_cal_inst_rltshp_sup_rec.sup_cal_type,
  				c_cal_inst_rltshp_sup_rec.sup_ci_sequence_number)
  			LOOP
  				FOR c_cal_typ_rec IN c_cal_typ(
  						c_cal_inst_rltshp_sub_rec.sub_cal_type)
  				LOOP
  					FOR	  c_cal_instance_rec IN c_cal_instance(
  				          		  c_cal_inst_rltshp_sub_rec.sub_cal_type,
  						  c_cal_inst_rltshp_sub_rec.sub_ci_sequence_number)
  					LOOP
  						IF ((c_cal_instance_rec.alternate_code = p_alternate_code) AND
  						     (NOT(c_cal_instance_rec.cal_type = p_cal_type AND
  						     c_cal_instance_rec.sequence_number = p_sequence_number))) THEN
  							p_message_name := 'IGS_CA_ALTCD_EXISTS_TEACHING';
  							RETURN TRUE;
  						END IF;
  					END LOOP; --c_cal_instance
                 		      		END LOOP; --c_cal_typ
  			END LOOP;-- c_cal_inst_rltshp_sub
  		END LOOP; --c_cal_type
    	END LOOP; --c_cal_inst_rltshp_sup
  	p_message_name := NULL;
  	RETURN TRUE;
  	EXCEPTION
  	WHEN OTHERS THEN

    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_CI.calp_val_ci_upd');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END calp_val_ci_upd;
END IGS_CA_VAL_CI;

/
