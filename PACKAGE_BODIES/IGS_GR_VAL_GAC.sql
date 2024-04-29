--------------------------------------------------------
--  DDL for Package Body IGS_GR_VAL_GAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VAL_GAC" AS
/* $Header: IGSGR08B.pls 115.6 2002/11/29 00:40:56 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function GRDP_VAL_ACUSG_CLOSE removed
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function grdp_val_awc_closed removed
  -------------------------------------------------------------------------------------------
  -- Validate graduand award ceremony insert.
  FUNCTION grdp_val_gac_insert(
  p_person_id  IGS_GR_AWD_CRMN.person_id%TYPE ,
  p_create_dt  IGS_GR_AWD_CRMN.create_dt%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gac_insert
  	-- Description: This routine validates inserting a graduand_award_ceremony
  	-- record based on the graduand details.
  DECLARE
  	v_gr_rec		IGS_GR_GRADUAND.s_graduand_type%TYPE;
  	cst_unknown		CONSTANT VARCHAR2(10) := 'UNKNOWN';
  	cst_attending		CONSTANT VARCHAR2(10) := 'ATTENDING';
  	cst_inabsentia		CONSTANT VARCHAR2(10) := 'INABSENTIA';
  	CURSOR	c_gr IS
  		SELECT	'X'
  		FROM 	IGS_GR_GRADUAND		gr
  		WHERE	gr.person_id		= p_person_id AND
  			gr.create_dt 		= p_create_dt AND
  			gr.s_graduand_type 	NOT IN (cst_unknown,
  						cst_attending,
  						cst_inabsentia);
  BEGIN
  	p_message_name := NULL;
  	IF p_person_id IS NULL OR
     			p_create_dt IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_gr;
  	FETCH c_gr INTO v_gr_rec;
  	IF (c_gr%FOUND) THEN
  		CLOSE c_gr;
  		p_message_name := 'IGS_GR_TYPE_ATT_INABS_UNKNOWN';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gr;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gac_insert;
  --
  -- Validate inserting or updating a graduand award ceremony.
  FUNCTION grdp_val_gac_iu(
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CRMN.ceremony_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gac_iu
  	-- Validate that the insert or update of a graduand_award_ceremony record
  	--	does not fall outside the graduation_ceremony update window.
  DECLARE
  	CURSOR c_crd IS
  		SELECT	crd.start_dt_alias,
  			crd.start_dai_sequence_number,
  			crd.end_dt_alias,
  			crd.end_dai_sequence_number
  		FROM	IGS_GR_CRMN_ROUND		crd
  		WHERE	crd.grd_cal_type		= p_grd_cal_type AND
  			crd.grd_ci_sequence_number	= p_grd_ci_sequence_number;
  	v_crd_rec	c_crd%ROWTYPE;
  	CURSOR	c_gc IS
  		SELECT	gc.ceremony_dt_alias,
  			gc.ceremony_dai_sequence_number,
  			gc.closing_dt_alias,
  			gc.closing_dai_sequence_number
  		FROM	IGS_GR_CRMN	gc
  		WHERE	gc.grd_cal_type			= p_grd_cal_type AND
  			gc.grd_ci_sequence_number 	= p_grd_ci_sequence_number AND
  			gc.ceremony_number		= p_ceremony_number;
  	v_gc_rec	c_gc%ROWTYPE;
  	v_start_dt	DATE DEFAULT NULL;
  	v_end_dt	DATE DEFAULT NULL;
  	v_ceremony_dt	DATE DEFAULT NULL;
  	v_closing_dt	DATE DEFAULT NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_grd_cal_type IS NULL OR
  			p_grd_ci_sequence_number IS NULL OR
  			p_ceremony_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_crd;
  	FETCH c_crd INTO v_crd_rec;
  	IF c_crd%FOUND THEN
  	CLOSE c_crd;
  		v_start_dt := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  						v_crd_rec.start_dt_alias,
  						v_crd_rec.start_dai_sequence_number,
  						p_grd_cal_type,
  						p_grd_ci_sequence_number);
  		v_end_dt := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  						v_crd_rec.end_dt_alias,
  						v_crd_rec.end_dai_sequence_number,
  						p_grd_cal_type,
  						p_grd_ci_sequence_number);
  		IF v_start_dt IS NULL OR
  				v_end_dt IS NULL THEN
  			p_message_name := NULL;
  			RETURN TRUE;
  		END IF;
  		IF TRUNC(SYSDATE) < TRUNC(v_start_dt) OR
  				TRUNC(SYSDATE) > TRUNC(v_end_dt) THEN
  			p_message_name := 'IGS_GR_INVALID_PROC_PERIOD';
  			RETURN FALSE;
  		END IF;
  	ELSE
  	CLOSE c_crd;
  	END IF;
  	OPEN c_gc;
  	FETCH c_gc INTO v_gc_rec;
  	IF c_gc %FOUND THEN
  	CLOSE c_gc;
  		v_ceremony_dt := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  						v_gc_rec.ceremony_dt_alias,
  						v_gc_rec.ceremony_dai_sequence_number,
  						p_grd_cal_type,
  						p_grd_ci_sequence_number);
  		v_closing_dt := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  						v_gc_rec.closing_dt_alias,
  						v_gc_rec.closing_dai_sequence_number,
  						p_grd_cal_type,
  						p_grd_ci_sequence_number);
  		IF v_ceremony_dt IS NULL OR
  				v_closing_dt IS NULL THEN
  			p_message_name := NULL;
  			RETURN TRUE;
  		END IF;
  		IF TRUNC(SYSDATE) > TRUNC(v_ceremony_dt) THEN
  			p_message_name := 'IGS_GR_INV_DT_GRAD_CERM';
  			RETURN TRUE;
  		END IF;
  		IF TRUNC(SYSDATE) > TRUNC(v_closing_dt) THEN
  			p_message_name := 'IGS_GR_CLOSING_DT_REACHED';
  			RETURN TRUE;
  		END IF;
  	ELSE
  	CLOSE c_gc;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_crd %ISOPEN THEN
  			CLOSE c_crd;
  		END IF;
  		IF c_gc %ISOPEN THEN
  			CLOSE c_gc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gac_iu;
  --
  -- Validate Graduand Award Ceremony required details have been specified.
  FUNCTION grdp_val_gac_rqrd(
  p_award_course_cd  IGS_GR_AWD_CRMN.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CRMN.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CRMN.award_cd%TYPE ,
  p_us_group_number  IGS_GR_AWD_CRMN.us_group_number%TYPE ,
  p_academic_dress_rqrd_ind  VARCHAR2 DEFAULT 'N',
  p_academic_gown_size  VARCHAR2 ,
  p_academic_hat_size  VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gac_rqrd
  	-- Validate that the graduand_award_ceremony record required details;
  	-- 	us_group_number can only be specified when a course award
  	--	is being conferred.
  DECLARE
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_award_cd IS NULL OR
  		p_academic_dress_rqrd_ind IS NULL then
  		RETURN TRUE;
  	END IF;
  	IF p_us_group_number IS NOT NULL THEN
  		IF p_award_course_cd IS NULL AND
  			p_award_crs_version_number IS NULL THEN
  			p_message_name := 'IGS_GR_UNT_GRP_CANNNOT_BE_SET';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF p_academic_dress_rqrd_ind = 'N' THEN
  		IF p_academic_gown_size IS NOT NULL OR
  			p_academic_hat_size IS NOT NULL THEN
  			p_message_name := 'IGS_GR_SET_DRESS_INDICATOR';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gac_rqrd;
  --
  -- Validate graduand seat number is unique for the person.
  FUNCTION grdp_val_gac_seat(
  p_person_id  IGS_GR_AWD_CRMN.person_id%TYPE ,
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CRMN.ceremony_number%TYPE ,
  p_graduand_seat_number  IGS_GR_AWD_CRMN.graduand_seat_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gac_seat
  	-- This routine validates the allocation of seats to graduands.  It checks
  	-- that the same seat isn't allocated to more than one graduand at the
  	-- same graduation ceromony.
  DECLARE
  	v_gac_found		VARCHAR2(1);
  	CURSOR	c_gac IS
  		SELECT	'x'
  		FROM	IGS_GR_AWD_CRMN	gac
  		WHERE	gac.grd_cal_type		= p_grd_cal_type AND
  			gac.grd_ci_sequence_number	= p_grd_ci_sequence_number AND
  			gac.ceremony_number		= p_ceremony_number AND
  			gac.person_id			<> p_person_id AND
  			gac.graduand_seat_number	= p_graduand_seat_number;
  BEGIN
  	-- Initialise p_message_name.
  	p_message_name := NULL;
  	-- Check parameters.
  	IF p_person_id IS NULL OR
     			p_grd_cal_type IS NULL OR
    			p_grd_ci_sequence_number IS NULL OR
     			p_ceremony_number IS NULL OR
     			p_graduand_seat_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Check seat number is not being used by another graduand.
  	OPEN c_gac;
  	FETCH c_gac INTO v_gac_found;
  	IF c_gac%FOUND THEN
  		CLOSE c_gac;
  		p_message_name := 'IGS_GR_SEAT_ALREADY_ALLOCATED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gac;
  	-- Return no error.
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gac%ISOPEN THEN
  			CLOSE c_gac;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gac_seat;
  --
  -- Validate Graduand  Student Unit Set Attempts.
  FUNCTION grdp_val_gac_susa(
  p_person_id  IGS_GR_AWD_CRMN.person_id%TYPE ,
  p_create_dt  IGS_GR_AWD_CRMN.create_dt%TYPE ,
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_course_cd  IGS_PS_COURSE.course_cd%TYPE ,
  p_graduand_status  VARCHAR2 ,
  p_ceremony_number  IGS_GR_AWD_CRMN.ceremony_number%TYPE ,
  p_award_course_cd  IGS_GR_AWD_CRMN.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CRMN.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CRMN.award_cd%TYPE ,
  p_us_group_number  IGS_GR_AWD_CRMN.us_group_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gac_susa
  	-- This routine validates the award ceremony unit sets belonging to a unit
  	-- set group match with student unit set attempts belonging to the graduand
  	-- under the course of the award being conferred.
  DECLARE
  	cst_eligible	CONSTANT	VARCHAR2(10) := 'ELIGIBLE';
  	cst_graduated	CONSTANT	VARCHAR2(10) := 'GRADUATED';
  	cst_surrender	CONSTANT	VARCHAR2(10) := 'SURRENDER';
  	v_incomplete_unit_sets 		BOOLEAN DEFAULT FALSE;
  	v_rqrmnts_complete_ind		IGS_AS_SU_SETATMPT.rqrmnts_complete_ind%TYPE;
  	v_course_cd			IGS_GR_GRADUAND.course_cd%TYPE;
  	v_graduand_status		IGS_GR_GRADUAND.graduand_status%TYPE;
  	v_s_graduand_status		IGS_GR_STAT.s_graduand_status%TYPE;
  	CURSOR	c_gr IS
  		SELECT 	gr.course_cd,
  			gr.graduand_status
  		FROM 	IGS_GR_GRADUAND	gr
  		WHERE	gr.person_id = p_person_id AND
  			gr.create_dt = p_create_dt;
  	CURSOR	c_acus IS
  		SELECT	acus.unit_set_cd,
  			acus.us_version_number
  		FROM	IGS_GR_AWD_CRM_UT_ST	acus
  		WHERE	acus.grd_cal_type 		= p_grd_cal_type 		AND
  			acus.grd_ci_sequence_number 	= p_grd_ci_sequence_number 	AND
  			acus.ceremony_number 		= p_ceremony_number 		AND
  			acus.award_course_cd 		= p_award_course_cd 		AND
  			acus.award_crs_version_number 	= p_award_crs_version_number 	AND
  			acus.award_cd 			= p_award_cd 			AND
  			acus.us_group_number 		= p_us_group_number;
  	CURSOR	c_susa (
  		cp_course_cd			IGS_GR_GRADUAND.course_cd%TYPE,
  		cp_unit_set_cd			IGS_GR_AWD_CRM_UT_ST.unit_set_cd%TYPE,
  		cp_us_version_number		IGS_GR_AWD_CRM_UT_ST.us_version_number%TYPE)
  	IS
  		SELECT	susa.rqrmnts_complete_ind
  		FROM 	IGS_AS_SU_SETATMPT	susa
  		WHERE	susa.person_id 			= p_person_id 		AND
  			susa.course_cd 			= cp_course_cd 		AND
  			susa.unit_set_cd 		= cp_unit_set_cd	AND
  			susa.us_version_number 		= cp_us_version_number	AND
  			susa.student_confirmed_ind	= 'Y'			AND
  			susa.primary_set_ind		= 'Y'			AND
  			susa.end_dt			IS NULL;
  	CURSOR	c_gst(
  		cp_graduand_status		IGS_GR_GRADUAND.graduand_status%TYPE)
  	IS
  		SELECT	gst.s_graduand_status
  		FROM	IGS_GR_STAT gst
  		WHERE	gst.graduand_status = cp_graduand_status;
  BEGIN
  	-- 1. Check parameters :
  	IF p_person_id IS NULL OR
     			p_grd_cal_type 			IS NULL OR
     			p_grd_ci_sequence_number 	IS NULL OR
     			p_ceremony_number 		IS NULL OR
     			p_award_course_cd 		IS NULL OR
  	  		p_award_crs_version_number 	IS NULL OR
     			p_award_cd 			IS NULL OR
     			p_us_group_number 		IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- 2. Get the required graduand details
  	IF p_course_cd IS NULL OR p_graduand_status IS NULL THEN
  		OPEN c_gr;
  		FETCH c_gr INTO v_course_cd,
  				v_graduand_status;
  		CLOSE c_gr;
  	ELSE
  		v_course_cd := p_course_cd;
  		v_graduand_status := p_graduand_status;
  	END IF;
  	-- 3. Match award ceremony unit sets with student unit set attempts
  	FOR v_acus IN c_acus LOOP
  		OPEN c_susa(
  				v_course_cd,
  				v_acus.unit_set_cd,
  				v_acus.us_version_number);
  		FETCH c_susa INTO v_rqrmnts_complete_ind;
  		IF c_susa%NOTFOUND THEN
  			CLOSE c_susa;
  			p_message_name := 'IGS_GR_NOT_ATTEMPTED_ALL_UNIT';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_susa;
  		IF v_rqrmnts_complete_ind = 'N' THEN
  			v_incomplete_unit_sets := TRUE;
  		END IF;
  	END LOOP;
  	IF v_incomplete_unit_sets = TRUE THEN
  		OPEN c_gst(
  				v_graduand_status);
  		FETCH c_gst INTO v_s_graduand_status;
  		CLOSE c_gst;
  		IF v_s_graduand_status = cst_eligible OR
  			v_s_graduand_status = cst_graduated OR
  			v_s_graduand_status = cst_surrender THEN
  			p_message_name := 'IGS_GR_REQUIR_NOT_COMPLETED';
  			RETURN FALSE;
  		ELSE
  			p_message_name := 'IGS_GR_INCOMPLETE_REQUIRMENTS';
  			RETURN TRUE;
  		END IF;
  	END IF;
  	-- 4. Return no error:
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_gr%ISOPEN) THEN
  			CLOSE c_gr;
  		END IF;
  		IF (c_acus%ISOPEN) THEN
  			CLOSE c_acus;
  		END IF;
  		IF (c_susa%ISOPEN) THEN
  			CLOSE c_susa;
  		END IF;
  		IF (c_gst%ISOPEN) THEN
  			CLOSE c_gst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gac_susa;
  --
  -- Validate Graduand Award Ceremony graduation calendar instance.
  FUNCTION grdp_val_gac_grd_ci(
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gac_grd_ci
  	-- Validate that the graduand_award_ceremony is linked
  	-- to a ceremony_round that has an ACTIVE calendar instance.
  DECLARE
  	CURSOR c_ci_cs IS
  		SELECT	'x'
  		FROM	IGS_CA_INST	ci,
  			IGS_CA_STAT	cs
  		WHERE	ci.cal_type		= p_grd_cal_type AND
  			ci.sequence_number	= p_grd_ci_sequence_number AND
  			cs.cal_status		= ci.cal_status AND
  			cs.s_cal_status		= 'ACTIVE';
  	v_ci_cs_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_grd_cal_type IS NULL OR
  			p_grd_ci_sequence_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_ci_cs;
  	FETCH c_ci_cs INTO v_ci_cs_exists;
  	IF c_ci_cs %NOTFOUND THEN
  		CLOSE c_ci_cs;
  		p_message_name :='IGS_GR_CERM_CAL_ACTIVE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ci_cs;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ci_cs %ISOPEN THEN
  			CLOSE c_ci_cs;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gac_grd_ci;
  --
  -- Validate graduand award ceremony order in presentation is unique.
  FUNCTION grdp_val_gac_order(
  p_person_id IN NUMBER ,
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_order_in_presentation IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gac_order
  	-- Description: This routine validates the graduand award ceremony order
  	-- in presentation is unique.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_gac IS
  		SELECT	'X'
  		FROM	IGS_GR_AWD_CRMN
  		WHERE	grd_cal_type 			= p_grd_cal_type AND
  			grd_ci_sequence_number		= p_grd_ci_sequence_number AND
  			ceremony_number			= p_ceremony_number AND
  			person_id 			<> p_person_id AND
  			order_in_presentation		= p_order_in_presentation;
  BEGIN
  	p_message_name := NULL;
  	IF p_person_id IS NULL OR
     			p_grd_cal_type IS NULL OR
    			p_grd_ci_sequence_number IS NULL OR
     			p_ceremony_number IS NULL OR
     			p_order_in_presentation IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_gac;
  	FETCH c_gac INTO v_dummy;
  	IF (c_gac%FOUND) THEN
  		CLOSE c_gac;
  		p_message_name := 'IGS_GR_PRES_ORDER_NOT_UNIQUE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gac;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_gac%ISOPEN) THEN
  			CLOSE c_gac;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gac_order;

  -- Validate if the award ceremony unit set group is closed
  FUNCTION grdp_val_acusg_close(
  p_grd_cal_type  IGS_GR_AWD_CRM_US_GP.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRM_US_GP.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CRM_US_GP.ceremony_number%TYPE ,
  p_award_course_cd  IGS_GR_AWD_CRM_US_GP.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CRM_US_GP.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CRM_US_GP.award_cd%TYPE ,
  p_us_group_number  IGS_GR_AWD_CRM_US_GP.us_group_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_acusg_close
  	-- Description: Validate if the award ceremony unit set group is closed
  DECLARE
  	v_acusg_rec		IGS_GR_AWD_CRM_US_GP.closed_ind%TYPE;
  	CURSOR	c_acusg IS
  		SELECT	acusg.closed_ind
  		FROM	IGS_GR_AWD_CRM_US_GP 	acusg
  		WHERE	acusg.grd_cal_type		= p_grd_cal_type and
  			acusg.grd_ci_sequence_number 	= p_grd_ci_sequence_number and
  			acusg.ceremony_number 		= p_ceremony_number and
  			acusg.award_course_cd 		= p_award_course_cd and
  			acusg.award_crs_version_number 	=p_award_crs_version_number and
  			acusg.award_cd			= p_award_cd and
  			acusg.us_group_number 		= p_us_group_number and
  			acusg.closed_ind 		='Y';
  BEGIN
  	p_message_name := NULL;
  	IF p_grd_cal_type IS NULL OR
    			p_grd_ci_sequence_number IS NULL OR
    			p_ceremony_number IS NULL OR
     			p_award_course_cd IS NULL OR
  	 		p_award_crs_version_number IS NULL OR
     			p_award_cd IS NULL OR
     			p_us_group_number iS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_acusg;
  	FETCH c_acusg INTO v_acusg_rec;
  	IF (c_acusg%FOUND) THEN
  		CLOSE c_acusg;
  		p_message_name := 'IGS_GR_AWD_CERM_GRP_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_acusg;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_acusg%ISOPEN) THEN
  			CLOSE c_acusg;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_acusg_close;
  --
  -- Validate a measurement code is not closed.
  FUNCTION GRDP_VAL_MSR_CLOSED(
  p_measurement_cd  IGS_GE_MEASUREMENT.measurement_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- GRDP_VAL_MSR_CLOSED
  	-- Validate if the measurement is closed.
  DECLARE
  	CURSOR c_MSR IS
  		SELECT	'X'
  		FROM	IGS_GE_MEASUREMENT	msr
  		WHERE	msr.measurement_cd	= p_measurement_cd AND
  			msr.closed_ind		= 'Y';
  	v_msr_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	OPEN c_msr ;
  	FETCH c_msr INTO  v_msr_exists ;
  	IF c_msr %FOUND THEN
  		CLOSE c_msr ;
  		p_message_name := 'IGS_GR_MEASURMENT_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_msr ;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_msr %ISOPEN THEN
  			CLOSE c_msr;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END GRDP_VAL_MSR_CLOSED;
END IGS_GR_VAL_GAC;

/
