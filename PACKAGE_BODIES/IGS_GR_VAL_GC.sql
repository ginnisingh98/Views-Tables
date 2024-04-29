--------------------------------------------------------
--  DDL for Package Body IGS_GR_VAL_GC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VAL_GC" AS
/* $Header: IGSGR02B.pls 115.4 2002/11/29 00:39:34 nsidana ship $ */
  --
  -- Validate the graduation ceremony date aliases
  FUNCTION grdp_val_gc_dai(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_dt_alias IN VARCHAR2 ,
  p_ceremony_dai_sequence_number IN NUMBER ,
  p_closing_dt_alias IN VARCHAR2 ,
  p_closing_dai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- grdp_val_gc_dai
  	-- Validate that closing_dt_alias and closing_dai_sequence_number relate to a
  	-- IGS_CA_DA_INST with an alias_val less than or equal to the alias_val for
  	-- the IGS_CA_DA_INST for the ceremony_dt_alias and
  	-- ceremony_dai_sequence_number.
  DECLARE
  	v_gc_dai_found		VARCHAR2(1);
  	CURSOR	c_ceremony_daiv IS
  		SELECT	'X'
  		FROM	IGS_CA_DA_INST_V 		daiv
	   	WHERE	daiv.dt_alias 		= p_ceremony_dt_alias AND
  			daiv.sequence_number 	= p_ceremony_dai_sequence_number AND
  			daiv.cal_type 		= p_grd_cal_type AND
  			daiv.ci_sequence_number 	= p_grd_ci_sequence_number AND
  			TRUNC(daiv.alias_val)	< TRUNC(SYSDATE);
  	CURSOR	c_closing_daiv IS
  		SELECT	'X'
  		FROM	IGS_CA_DA_INST_V 		daiv
  		WHERE	daiv.dt_alias 		= p_closing_dt_alias AND
  			daiv.sequence_number 	= p_closing_dai_sequence_number AND
  			daiv.cal_type 		= p_grd_cal_type AND
  			daiv.ci_sequence_number 	= p_grd_ci_sequence_number AND
  			TRUNC(daiv.alias_val)	< TRUNC(SYSDATE);
  	CURSOR	c_daiv IS
  		SELECT	'X'
  		FROM	IGS_CA_DA_INST_V 		ceremony_daiv,
  			IGS_CA_DA_INST_V 		closing_daiv
  		WHERE	ceremony_daiv.dt_alias 		= p_ceremony_dt_alias AND
  			ceremony_daiv.sequence_number 	= p_ceremony_dai_sequence_number AND
  			ceremony_daiv.cal_type 		= p_grd_cal_type AND
  			ceremony_daiv.ci_sequence_number 	= p_grd_ci_sequence_number AND
  			closing_daiv.dt_alias 		= p_closing_dt_alias AND
  			closing_daiv.sequence_number 	= p_closing_dai_sequence_number AND
  			closing_daiv.cal_type 		= p_grd_cal_type AND
  			closing_daiv.ci_sequence_number 	= p_grd_ci_sequence_number AND
  			closing_daiv.alias_val 		<= ceremony_daiv.alias_val;
  BEGIN
  	p_message_name := NULL;
  	IF p_grd_cal_type IS NULL OR
  	    p_grd_ci_sequence_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_ceremony_dt_alias IS NOT NULL AND
  	    p_ceremony_dai_sequence_number IS NOT NULL  THEN
  		OPEN c_ceremony_daiv;
  		FETCH c_ceremony_daiv INTO v_gc_dai_found;
  		IF c_ceremony_daiv%FOUND THEN
  			CLOSE c_ceremony_daiv;
  			p_message_name := 'IGS_GR_GRAD_DT_CANNOT_LT_CUR';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_ceremony_daiv;
  	END IF;
  	IF p_closing_dt_alias IS NOT NULL AND
  	    p_closing_dai_sequence_number IS NOT NULL  THEN
  		OPEN c_closing_daiv;
  		FETCH c_closing_daiv INTO v_gc_dai_found;
  		IF c_closing_daiv%FOUND THEN
  			CLOSE c_closing_daiv;
  			p_message_name := 'IGS_GR_CERCL_DT_CANNOT_LT_CUR';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_closing_daiv;
  	END IF;
  	IF p_ceremony_dt_alias IS NULL OR
  	    p_ceremony_dai_sequence_number IS NULL OR
  	    p_closing_dt_alias IS NULL OR
  	    p_closing_dai_sequence_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_daiv;
  	FETCH c_daiv INTO v_gc_dai_found;
  	IF c_daiv%NOTFOUND THEN
  		CLOSE c_daiv;
  		p_message_name := 'IGS_GR_CER_CL_DT_LE_CERM_DT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_daiv;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_daiv%ISOPEN THEN
  			CLOSE c_daiv;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;

  END grdp_val_gc_dai;
  --
  -- Validate the graduation ceremony can be updated
  FUNCTION grdp_val_gc_upd(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- grdp_val_gc_upd
  	-- Description: Check if any IGS_GR_AWD_CRMN records exist
  	-- for this IGS_GR_CRMN.
  DECLARE
  	v_gac_exists	VARCHAR2(1);
  	CURSOR	c_gac IS
  		SELECT	'X'
  		FROM	IGS_GR_AWD_CRMN		gac
  		WHERE	gac.grd_cal_type		= p_grd_cal_type AND
  			gac.grd_ci_sequence_number	= p_grd_ci_sequence_number AND
  			gac.ceremony_number		= p_ceremony_number;
  BEGIN
  	p_message_name := NULL;
  	IF p_grd_cal_type IS NULL OR
     			p_grd_ci_sequence_number IS NULL OR
     			p_ceremony_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_gac;
  	FETCH c_gac INTO v_gac_exists;
  	IF (c_gac%FOUND) THEN
  		CLOSE c_gac;
  		p_message_name := 'IGS_GR_DATES_CANNOT_BE_CHANGE';
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
  END grdp_val_gc_upd;
  --
  -- Validate the ceremony round linked to the graduation ceremony
  FUNCTION grdp_val_gc_crd(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- grdp_val_gc_crd
  DECLARE
  	v_crdp_exists		VARCHAR2(1);
  	CURSOR c_crdp IS
  		SELECT	'x'
  		FROM	IGS_GR_CRM_ROUND_PRD crdp
  		WHERE	crdp.grd_cal_type		= p_grd_cal_type AND
  			crdp.grd_ci_sequence_number	= p_grd_ci_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters :
  	IF p_grd_cal_type IS NULL OR
  			p_grd_ci_sequence_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	--2. Return a warning if no IGS_GR_CRMN_ROUND_PRD records exist for the
  	--specified IGS_GR_CRMN_ROUND.
  	OPEN c_crdp;
  	FETCH c_crdp INTO v_crdp_exists;
  	IF c_crdp%NOTFOUND THEN
  		CLOSE c_crdp;
  		p_message_name := 'IGS_GR_NO_CERM_ROUND_PERIOD';
  		RETURN TRUE;		-- Warning only
  	END IF;
  	CLOSE c_crdp;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_crdp%ISOPEN THEN
  			CLOSE c_crdp;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gc_crd;
  --
  -- Validate the start and end time of the graduation ceremony
  FUNCTION grdp_val_gc_times(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  p_ceremony_dt_alias IN VARCHAR2 ,
  p_ceremony_dai_sequence_number IN NUMBER ,
  p_ceremony_start_time IN DATE ,
  p_ceremony_end_time IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gc_times
  	-- Check if the ceremony_start_time is after the ceremony_end_time.
  	-- Check if the graduation_ceremony ceremony date(ceremony_dt_alias,
  	--ceremony_dai_sequence_number), venue_cd, ceremony_start_time and
  	--ceremony_end_time overlap with another graduation_ceremony.
  DECLARE
  	v_gc_daiv_exists	VARCHAR2(1);
  	CURSOR c_gc_daiv IS
  		SELECT	'x'
  		FROM	IGS_GR_CRMN	gc,
  			IGS_CA_DA_INST_V	daiv1,
  			IGS_CA_DA_INST_V	daiv2
  		WHERE	gc.grd_cal_type			= p_grd_cal_type			AND
  			gc.grd_ci_sequence_number	= p_grd_ci_sequence_number		AND
  			gc.ceremony_number		<> p_ceremony_number			AND
  			gc.venue_cd			= p_venue_cd				AND
  			gc.ceremony_dt_alias		= daiv1.dt_alias			AND
  			gc.ceremony_dai_sequence_number	= daiv1.sequence_number			AND
  			gc.grd_cal_type			= daiv1.cal_type			AND
  			gc.grd_ci_sequence_number	= daiv1.ci_sequence_number		AND
  			daiv2.dt_alias			= p_ceremony_dt_alias			AND
  			daiv2.sequence_number		= p_ceremony_dai_sequence_number	AND
  			daiv2.cal_type			= p_grd_cal_type			AND
  			daiv2.ci_sequence_number	= p_grd_ci_sequence_number		AND
  			TRUNC(daiv1.alias_val)		= TRUNC(daiv2.alias_val)		AND
  			((TO_CHAR(p_ceremony_start_time, 'HH24:MI') >
  				TO_CHAR(gc.ceremony_start_time, 'HH24:MI')		AND
  			TO_CHAR(p_ceremony_start_time, 'HH24:MI') <
  				TO_CHAR(gc.ceremony_end_time, 'HH24:MI'))			OR
  			(TO_CHAR(p_ceremony_end_time, 'HH24:MI') >
  				 TO_CHAR(gc.ceremony_start_time, 'HH24:MI')		AND
  			TO_CHAR(p_ceremony_end_time, 'HH24:MI') <=
  				TO_CHAR(gc.ceremony_end_time, 'HH24:MI'))		OR
  			(TO_CHAR(p_ceremony_start_time, 'HH24:MI') <=
  				TO_CHAR(gc.ceremony_start_time, 'HH24:MI')		AND
  			TO_CHAR(p_ceremony_end_time, 'HH24:MI') >=
  				TO_CHAR(gc.ceremony_end_time, 'HH24:MI')));
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters :
  	IF p_grd_cal_type	IS NULL OR
  			p_grd_ci_sequence_number	IS NULL OR
  			p_ceremony_number		IS NULL OR
  			p_venue_cd			IS NULL OR
  			p_ceremony_dt_alias		IS NULL OR
  			p_ceremony_dai_sequence_number	IS NULL OR
  			p_ceremony_start_time		IS NULL OR
  			p_ceremony_end_time		IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	--Check if ceremony_start_time is after the ceremony_end_time..
  	IF TO_CHAR(p_ceremony_start_time, 'HH24:MI') >
  	    TO_CHAR(p_ceremony_end_time, 'HH24:MI') THEN
  		p_message_name := 'IGS_GR_CERM_TIME_LT_END_TIME';
  		RETURN FALSE;
  	END IF;
  	--Check if the start and end times overlap with another ceremony on the
  	--same day at the same venue.
  	OPEN c_gc_daiv;
  	FETCH c_gc_daiv INTO v_gc_daiv_exists;
  	IF c_gc_daiv%FOUND THEN
  		CLOSE c_gc_daiv;
  		p_message_name := 'IGS_GR_CERM_DT_TIME_OVERLAPS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gc_daiv;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gc_daiv%ISOPEN THEN
  			CLOSE c_gc_daiv;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gc_times;
  --
  -- Validate the ins/upd/del to the graduation ceremony
  FUNCTION grdp_val_gc_iud(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gc_iud
  DECLARE
  	v_gc_daiv_exists	VARCHAR2(1);
  	CURSOR c_gc_daiv IS
  		SELECT	'x'
  		FROM	IGS_GR_CRMN	gc,
  			IGS_CA_DA_INST_V	daiv
  		WHERE	gc.grd_cal_type			= p_grd_cal_type		AND
  			gc.grd_ci_sequence_number	= p_grd_ci_sequence_number	AND
  			gc.ceremony_number		= p_ceremony_number		AND
  			gc.ceremony_dt_alias		= daiv.dt_alias			AND
  			gc.ceremony_dai_sequence_number	= daiv.sequence_number		AND
  			gc.grd_cal_type			= daiv.cal_type			AND
  			gc.grd_ci_sequence_number	= daiv.ci_sequence_number	AND
  			TRUNC(daiv.alias_val)		< TRUNC(SYSDATE);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters :
  	IF p_grd_cal_type IS NULL OR
  			p_grd_ci_sequence_number	IS NULL OR
  			p_ceremony_number		IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	--2. Return a warning if ceremony_round start_dt_alias has a value earlier
  	-- than the current date.
  	OPEN c_gc_daiv;
  	FETCH c_gc_daiv INTO v_gc_daiv_exists;
  	IF c_gc_daiv%FOUND THEN
  		CLOSE c_gc_daiv;
  		p_message_name := 'IGS_GR_CERMONY_DT_EXPIRED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gc_daiv;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gc_daiv%ISOPEN THEN
  			CLOSE c_gc_daiv;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gc_iud;
  --
  -- Validate if the venue has a system location type of CRD_CTR
  FUNCTION grdp_val_ve_lot(
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_ve_lot
  	-- Validate that the venue relates to a location which has a
  	-- location_type.s_location_type of GRD_CTR
  DECLARE
  	v_ve_lot_found		VARCHAR2(1);
  	cst_grd_ctr		CONSTANT VARCHAR2(10) := 'GRD_CTR';
  	CURSOR	c_ve IS
  		SELECT	'x'
  		FROM	IGS_GR_VENUE		ve,
  			IGS_AD_LOCATION	loc,
  			IGS_AD_LOCATION_TYPE	lot
  		WHERE	ve.venue_cd		= p_venue_cd AND
  			ve.exam_location_cd	= loc.location_cd AND
  			loc.location_type	= lot.location_type AND
  			lot.s_location_type	= cst_grd_ctr;
  BEGIN
  	p_message_name := NULL;
  	IF p_venue_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_ve;
  	FETCH c_ve INTO v_ve_lot_found;
  	IF c_ve%NOTFOUND THEN
  		CLOSE c_ve;
  		p_message_name := 'IGS_GR_TYPE_MUST_BE_GRD_CTR';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ve;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ve%ISOPEN THEN
  			CLOSE c_ve;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_ve_lot;
  --
  -- To validate the venue closed indicator
  FUNCTION ASSP_VAL_VE_CLOSED(
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  BEGIN	-- assp_val_ve_closed
  	-- Validate the venue closed indicator
  DECLARE
  	v_venue_cd	IGS_GR_VENUE.venue_cd%TYPE;
  	v_ve_closed_ind	IGS_GR_VENUE.closed_ind%TYPE;
  	v_ret_val	BOOLEAN	DEFAULT TRUE;
  	CURSOR	c_ve IS
  		SELECT closed_ind
  		FROM	IGS_GR_VENUE
  		WHERE	venue_cd = p_venue_cd;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_ve;
  	FETCH c_ve INTO v_ve_closed_ind;
  	IF (c_ve%FOUND) THEN
  		IF (v_ve_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AS_VENUE_CLOSED';
  			v_ret_val := FALSE;
  		END IF;
  	END IF;
  	CLOSE c_ve;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END assp_val_ve_closed;
END IGS_GR_VAL_GC;

/
