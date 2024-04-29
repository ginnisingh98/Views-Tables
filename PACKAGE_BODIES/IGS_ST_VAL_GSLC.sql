--------------------------------------------------------
--  DDL for Package Body IGS_ST_VAL_GSLC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_VAL_GSLC" AS
/* $Header: IGSST11B.pls 115.6 2002/11/29 04:12:29 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (STAP_VAL_GSC_SDT_UPD) - from the spec and body. -- kdande
*/
  -- Validate the govt semester load calendar is type Load and is Active.
  FUNCTION stap_val_gslc(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	cst_load		CONSTANT	VARCHAR2(4) 	 := 'LOAD';
  	cst_active		CONSTANT 	IGS_CA_STAT.s_cal_status%TYPE  := 'ACTIVE';
  	v_s_cal_cat		IGS_CA_TYPE.s_cal_cat%TYPE;
  	v_s_cal_status		IGS_CA_STAT.s_cal_status%TYPE;
  	CURSOR c_ci IS
  		SELECT	ct.s_cal_cat,
  			cs.s_cal_status
  		FROM	IGS_CA_INST	ci,
  			IGS_CA_STAT	cs,
  			IGS_CA_TYPE	ct
  		WHERE	ci.cal_type = p_cal_type AND
  			ci.sequence_number = p_ci_sequence_number AND
  			cs.cal_status = ci.cal_status AND
  			ct.cal_type = ci.cal_type;
  BEGIN
  	--Validate the government semester load calender.  The calender must:
  	--	*be a load calender
  	--	*have a sustem status of active.
  	OPEN c_ci;
  	FETCH c_ci INTO v_s_cal_cat,
  			v_s_cal_status;
  	IF (c_ci%FOUND)  THEN
  		--Validate the calender
  		CLOSE c_ci;
  		IF v_s_cal_cat <> cst_load THEN
  			p_message_name := 'IGS_ST_CAL_TYPE_MUST_BE_LOAD';
  			RETURN FALSE;
  		END IF;
  		IF v_s_cal_status <> cst_active THEN
  			p_message_name := 'IGS_CA_CAL_INST_MUST_BE_ACTIV';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_ci;
  	END IF;
  	--- Set the default message number
  	p_message_name := Null;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_GSLC.stap_val_gslc');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END stap_val_gslc;
END IGS_ST_VAL_GSLC;

/
