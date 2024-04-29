--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AUOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AUOS" AS
/* $Header: IGSAD46B.pls 120.2 2006/05/29 11:06:56 apadegal noship $ */
  -- Validate against the system admission outcome status closed indicator.
  FUNCTION admp_val_saos_clsd(
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	--AMDP_VAL_SAOS_CLSD
  	--Check if the s_adm_outcome_status is closed
  DECLARE
  	v_closed_ind	VARCHAR(1);
  	CURSOR c_saos IS
  		SELECT	saos.closed_ind
  		FROM	IGS_LOOKUP_values saos
  		WHERE   saos.lookup_code = p_s_adm_outcome_status
		AND     saos.lookup_type = 'ADM_OUTCOME_STATUS';
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	OPEN c_saos;
  	FETCH c_saos INTO v_closed_ind;
  	IF (c_saos%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_SYSADM_OUTCOME_ST_CLS';
  			CLOSE c_saos;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_saos;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AUOS.admp_val_saos_clsd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_saos_clsd;

  --
  -- Validate the system admission outcome status unit_outcome_ind is Y .
  FUNCTION ADMP_VAL_SAOS_UNIOUT(
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail	VARCHAR2(255);
  BEGIN	--admp_val_saos_uniout
  	--This module Checks if the s_adm_outcome_status.unit_outcome_ind is set to Yes
  DECLARE
  	v_saos_exists	VARCHAR2(1);
  	CURSOR c_saos IS
  		SELECT 	'X'
  		FROM	IGS_LOOKUPS_VIEW	saos
  		WHERE	saos.lookup_type   = 'ADM_OUTCOME_STATUS' AND
		        saos.lookup_code	= p_s_adm_outcome_status	AND
  			saos.unit_outcome_ind		<> 'Y';
  BEGIN
  	--Set the default message number
  	p_message_name := Null;
  	OPEN c_saos;
  	FETCH c_saos INTO v_saos_exists;
  	IF (c_saos%FOUND) THEN
  		CLOSE c_saos;
  		p_message_name := 'IGS_AD_UNIT_IND_SETTO_YES';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_saos;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_saos%ISOPEN) THEN
  			CLOSE c_saos;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AUOS.admp_val_saos_uniout');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_saos_uniout;

  --
  -- Validate the admission unit outcome status has only one system default
  FUNCTION ADMP_VAL_AUOS_DFLT(
  p_adm_unit_outcome_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail	VARCHAR2(255);
  BEGIN	--admp_val_auos_dflt
  	--This module Checks if another IGS_AD_UNIT_OU_STAT record
  	--exists with the system default indicator set to 'Y'.
  DECLARE
  	v_auos_exists	VARCHAR2(1);
  	CURSOR c_auos IS
  		SELECT 	'X'
  		FROM	IGS_AD_UNIT_OU_STAT	auos
  		WHERE	auos.adm_unit_outcome_status	<> p_adm_unit_outcome_status	AND
  			auos.s_adm_outcome_status	= p_s_adm_outcome_status	AND
  			auos.system_default_ind		= 'Y';
  BEGIN
  	--Set the default message number
  	p_message_name := Null;
  	OPEN c_auos;
  	FETCH c_auos INTO v_auos_exists;
  	IF (c_auos%FOUND) THEN
  		CLOSE c_auos;
  		p_message_name := 'IGS_AD_ONLYONE_SYSADM_STATUS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_auos;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_auos%ISOPEN) THEN
  			CLOSE c_auos;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AUOS.admp_val_auos_dflt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_auos_dflt;

END IGS_AD_VAL_AUOS;

/
