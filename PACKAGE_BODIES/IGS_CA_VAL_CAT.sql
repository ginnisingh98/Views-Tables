--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_CAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_CAT" AS
/* $Header: IGSCA04B.pls 115.3 2002/11/28 22:56:59 nsidana ship $ */
  -- Validate when System Calendar Category is changed.
  FUNCTION calp_val_sys_cal_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	cst_active		CONSTANT VARCHAR2(10) := 'ACTIVE';
  	cst_inactive	CONSTANT VARCHAR2(10) := 'INACTIVE';
  	CURSOR c_cal_instance_rec (
  			cp_cal_type	IGS_CA_TYPE.CAL_TYPE%TYPE) IS
  		SELECT  DISTINCT 'x'
  		FROM	IGS_CA_INST ci,
  			IGS_CA_STAT cs
  		WHERE 	ci.CAL_TYPE     = cp_cal_type   AND
  			cs.CAL_STATUS   = ci.CAL_STATUS AND
  			cs.s_cal_status IN (cst_active, cst_inactive);
  	v_other_detail	VARCHAR2(255);
  	v_cal_instance_rec	IGS_CA_INST%ROWTYPE;
  	v_check		CHAR;
  BEGIN
  	-- This module validates that IGS_CA_TYPE.S_CAL_CAT
  	-- cannot be changed if ACTIVE calendar instances
  	-- exist for the calendar type.
  	-- validate the input parameters
  	IF (p_cal_type IS NULL) THEN
  		p_message_name := 'IGS_GE_MANDATORY_FLD';
  		RETURN FALSE;
  	END IF;
  	-- check for the existance of IGS_CA_INST
  	-- other than planned
  	OPEN c_cal_instance_rec(p_cal_type);
  	FETCH c_cal_instance_rec INTO v_check;
  	IF (c_cal_instance_rec%NOTFOUND) THEN
  		CLOSE c_cal_instance_rec;
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_cal_instance_rec;
  		p_message_name := 'IGS_CA_SYSCALCAT_CANNOT_CHG';
  		RETURN FALSE;
  	END IF;

  END;
  END calp_val_sys_cal_cat;
  --
  -- Validate if ARTS teaching calendar type code is closed.
  FUNCTION calp_val_atctc_clsd(
  p_arts_teaching_cal_type_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_closed_ind		IGS_CA_ARTS_TC_CA_CD.closed_ind%TYPE;
  	CURSOR c_atctc IS
  		SELECT	atctc.closed_ind
  		FROM	IGS_CA_ARTS_TC_CA_CD	atctc
  		WHERE	atctc.ARTS_TEACHING_CAL_TYPE_CD = p_arts_teaching_cal_type_cd;
  BEGIN
  	-- Validate if IGS_CA_ARTS_TC_CA_CD.ARTS_TEACHING_CAL_TYPE_CD is closed.
  	OPEN c_atctc;
  	FETCH c_atctc INTO v_closed_ind;
  	IF (c_atctc%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_atctc;
  			p_message_name := 'IGS_CA_ARTS_TYPECD_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_atctc;
  	p_message_name := NULL;
  	RETURN TRUE;

  END;
  END calp_val_atctc_clsd;
  --
  -- Validate Calendar Type ARTS Teaching Code.
  FUNCTION calp_val_cat_arts_cd(
  p_s_cal_cat IN VARCHAR2 ,
  p_arts_teaching_cal_type_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	cst_teaching		CONSTANT IGS_CA_TYPE.S_CAL_CAT%TYPE := 'TEACHING';
  BEGIN
  	-- Validate if IGS_CA_TYPE.ARTS_TEACHING_CAL_TYPE_CD exists,
  	-- and only exists for IGS_CA_TYPE.S_CAL_CAT 'TEACHING'.
  	IF (p_arts_teaching_cal_type_cd IS NULL) THEN
  		IF (p_s_cal_cat = cst_teaching) THEN
  			p_message_name := 'IGS_CA_ARTS_CALTYPE_TEACHING';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF (p_s_cal_cat <> cst_teaching) THEN
  			p_message_name := 'IGS_CA_ARTS_CALTYPE_NOTCAT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name :=NULL;
  	RETURN TRUE;
   END;
  END calp_val_cat_arts_cd;
END IGS_CA_VAL_CAT;

/
