--------------------------------------------------------
--  DDL for Package Body IGS_GR_VAL_CRDP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VAL_CRDP" AS
/* $Header: IGSGR07B.pls 115.4 2002/11/29 00:40:39 nsidana ship $ */
  --
  -- Warn if ins/upd/del on crdp if after start date of crd.
  FUNCTION grdp_val_crdp_iud(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- func_module
  DECLARE
  	v_crd_daiv_exists	VARCHAR2(1);
  	CURSOR c_crd_daiv IS
  		SELECT	'x'
  		FROM	IGS_GR_CRMN_ROUND		crd,
  			IGS_CA_DA_INST_V	daiv
  		WHERE	crd.grd_cal_type  		= p_grd_cal_type AND
  			crd.grd_ci_sequence_number 	= p_grd_ci_sequence_number AND
  			crd.end_dt_alias 		= daiv.dt_alias AND
  			crd.end_dai_sequence_number 	= daiv.sequence_number AND
  			crd.grd_cal_type  		= daiv.cal_type AND
  			crd.grd_ci_sequence_number 	= daiv.ci_sequence_number AND
  			TRUNC(daiv.alias_val) 		< TRUNC(SYSDATE);
  	CURSOR c_crd_daiv2 IS
  		SELECT	'x'
  		FROM	IGS_GR_CRMN_ROUND		crd,
  			IGS_CA_DA_INST_V	daiv
  		WHERE	crd.grd_cal_type  		= p_grd_cal_type AND
  			crd.grd_ci_sequence_number 	= p_grd_ci_sequence_number AND
  			crd.start_dt_alias 		= daiv.dt_alias AND
  			crd.start_dai_sequence_number 	= daiv.sequence_number AND
  			crd.grd_cal_type  		= daiv.cal_type AND
  			crd.grd_ci_sequence_number 	= daiv.ci_sequence_number AND
  			TRUNC(daiv.alias_val) 		< TRUNC(SYSDATE);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters :
  	IF p_grd_cal_type IS NULL OR
  			p_grd_ci_sequence_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	--2. Return an error if IGS_GR_CRMN_ROUND end_dt_alias has a
  	-- value earlier than the current date.
  	OPEN c_crd_daiv;
  	FETCH c_crd_daiv INTO v_crd_daiv_exists;
  	IF c_crd_daiv%FOUND THEN
  		CLOSE c_crd_daiv;
  		p_message_name := 'IGS_GR_CANNOT_UPD_DT_EXPIRED';
  		RETURN FALSE; -- Error
  	END IF;
  	CLOSE c_crd_daiv;
  	--3. Return a warning if IGS_GR_CRMN_ROUND start_dt_alias has a
  	-- value earlier than the current date.
  	OPEN c_crd_daiv2;
  	FETCH c_crd_daiv2 INTO v_crd_daiv_exists;
  	IF c_crd_daiv2%FOUND THEN
  		CLOSE c_crd_daiv2;
  		p_message_name := 'IGS_GR_PROC_ST_DATE_EXPIRED';
  		RETURN TRUE;  -- Warning only
  	END IF;
  	CLOSE c_crd_daiv2;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_crd_daiv%ISOPEN THEN
  			CLOSE c_crd_daiv;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_crdp_iud;
END IGS_GR_VAL_CRDP;

/
