--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_TRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_TRO" AS
/* $Header: IGSPS58B.pls 115.4 2002/11/29 03:08:10 nsidana ship $ */
  --
  -- Validate teaching responsibility override percentages = 100%
  FUNCTION CRSP_VAL_TRO_PERC(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- crsp_val_tro_perc
  	-- This module validates the IGS_PS_TCH_RESP_OVRD table such that
  	-- the sum of percentages for a IGS_PS_UNIT offering option total 100%.
  DECLARE
  	v_sum_percentages		IGS_PS_TCH_RESP_OVRD.percentage%TYPE;
  	CURSOR c_tro IS
  		SELECT	SUM(tro.percentage)
  		FROM	IGS_PS_TCH_RESP_OVRD tro
  		WHERE	tro.unit_cd		= p_unit_cd AND
  			tro.version_number	= p_version_number AND
  			tro.cal_type		= p_cal_type AND
  			tro.ci_sequence_number	= p_ci_sequence_number AND
  			tro.location_cd		= p_location_cd AND
  			tro.unit_class		= p_unit_class;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_tro;
  	FETCH c_tro INTO v_sum_percentages;
  	IF (c_tro%FOUND) THEN
  		IF v_sum_percentages <> 100.00 THEN
  			CLOSE c_tro;
  			p_message_name := 'IGS_PS_PRCALLOC_TEACH_RESP';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_tro;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_tro%ISOPEN) THEN
  			CLOSE c_tro;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
			Fnd_Message.Set_Token('NAME','IGS_PS_VAL_TRo.crsp_val_tro_perc');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END crsp_val_tro_perc;
END IGS_PS_VAL_TRo;

/
