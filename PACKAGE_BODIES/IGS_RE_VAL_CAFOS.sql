--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_CAFOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_CAFOS" AS
/* $Header: IGSRE05B.pls 120.1 2006/07/25 15:04:15 sommukhe noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  --skpandey	10-JUL-2006	Bug#5343912, changed cursor c_cafos definition to include 'per fos_type_code' percentage check for all non CIP type
  -------------------------------------------------------------------------------------------
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (RESP_VAL_CA_CHILDUPD) - from the spec and body. -- kdande
*/
  -- Validate IGS_RE_CANDIDATURE field of study percentage.
  FUNCTION resp_val_cafos_perc(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_cafos_perc
  	-- Description: This module validates IGS_RE_CDT_FLD_OF_SY.percentage.
  	-- Validations are:
  	-- Total percentage for research IGS_RE_CANDIDATURE must be 100.
  DECLARE

	CURSOR	c_cafos IS
		SELECT NVL(Sum(cafos.percentage), 0) total, cafos.fos_type_code
		FROM     igs_re_cdt_fld_of_sy_v cafos
		WHERE    cafos.fos_type_code <> 'CIP'
		AND      cafos.person_id = p_person_id
		AND      cafos.ca_sequence_number = p_ca_sequence_number
		GROUP BY cafos.fos_type_code
		HAVING Sum(cafos.percentage)<>100;

	c_cafos_rec c_cafos%rowtype;

  BEGIN
  	p_message_name := null;
  	OPEN c_cafos;
  	FETCH c_cafos INTO c_cafos_rec;
  	CLOSE c_cafos;
  	IF (c_cafos_rec.total = 0) THEN
  	--'No values for research IGS_RE_CANDIDATURE field of study entered yet');
  		p_message_name := null;
  		RETURN TRUE;
  	ELSIF (c_cafos_rec.total <> 100) THEN
  		p_message_name := 'IGS_RE_CAND_FIELD_OF_STUDY';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_cafos_perc;
  --
  -- Validate IGS_RE_CANDIDATURE field of study.
  FUNCTION resp_val_cafos_fos(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_field_of_study IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_cafos_fos
  	-- This module validate IGS_RE_CDT_FLD_OF_SY.IGS_PS_FLD_OF_STUDY. Validations are:
  	-- . IGS_PS_FLD_OF_STUDY is not closed.
  	-- . IGS_RE_GV_FLD_OF_SDY.res_fcd_class_ind is the same for all
  	--   IGS_RE_CDT_FLD_OF_SY for a research IGS_RE_CANDIDATURE.
  DECLARE
  	v_dummy			VARCHAR2(1);
  	v_message_name		VARCHAR2(30);
  	v_res_fcd_class_ind	IGS_RE_GV_FLD_OF_SDY.res_fcd_class_ind%TYPE;
  	CURSOR c_get_rfci IS
  		SELECT	gfos.res_fcd_class_ind
  		FROM	IGS_PS_FLD_OF_STUDY		fos,
  			IGS_RE_GV_FLD_OF_SDY	gfos
  		WHERE	fos.field_of_study	= p_field_of_study	AND
  			Fos.govt_field_of_study = gfos.govt_field_of_study;
  	CURSOR c_not_same(
  			cp_res_fcd_class_ind	IGS_RE_GV_FLD_OF_SDY.res_fcd_class_ind%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_RE_CDT_FLD_OF_SY	cafos,
  			IGS_PS_FLD_OF_STUDY		fos,
  			IGS_RE_GV_FLD_OF_SDY	gfos
  		WHERE	cafos.person_id			= p_person_id			AND
  			cafos.ca_sequence_number	= p_ca_sequence_number		AND
  			cafos.field_of_study		<> p_field_of_study		AND
  			cafos.field_of_study		= fos.field_of_study		AND
  			fos.govt_field_of_study		= gfos.govt_field_of_study	AND
  			gfos.res_fcd_class_ind		<> cp_res_fcd_class_ind;
  BEGIN
  	-- Set initial value
  	p_message_name := NULL;
  	-- Validate that field of study is not closed
  	IF IGS_RE_VAL_CAFOS.crsp_val_fos_closed(
  				p_field_of_study,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate field of study is of the same coding scheme as others
  	-- specified (if any) for the research IGS_RE_CANDIDATURE.
  	OPEN c_get_rfci;
  	FETCH c_get_rfci INTO v_res_fcd_class_ind;
  	IF c_get_rfci%NOTFOUND THEN
  		-- If no record found, invalid parameter, this will be handled elsewhere
  		p_message_name := NULL;
  		CLOSE c_get_rfci;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_rfci;
  	OPEN c_not_same(
  		v_res_fcd_class_ind);
  	FETCH c_not_same INTO v_dummy;
  	IF c_not_same%FOUND THEN
  		p_message_name := 'IGS_RE_FLD_STDY_BE_SAME_CODE';
  		CLOSE c_not_same;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_not_same;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_get_rfci%ISOPEN THEN
  			CLOSE c_get_rfci;
  		END IF;
  		IF c_not_same%ISOPEN THEN
  			CLOSE c_not_same;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END; -- resp_val_cafos_fos
  --
  -- Validate if IGS_PS_FLD_OF_STUDY.field_of_study is closed.
  FUNCTION crsp_val_fos_closed(
  p_field_of_study IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--crsp_val_fos_closed
  	--validate if IGS_PS_FLD_OF_STUDY.field_of_study is closed
  DECLARE
  	v_fos_exists	VARCHAR2(1);
  	CURSOR c_fos IS
  		SELECT 	'X'
  		FROM	IGS_PS_FLD_OF_STUDY fos
  		WHERE	fos.field_of_study	= p_field_of_study AND
  			fos.closed_ind = 'Y';
  BEGIN
  	--Set the default message number
  	p_message_name := NULL;
  	--If the closed indicator is 'Y' then set p_message_name
  	OPEN c_fos;
  	FETCH c_fos INTO v_fos_exists;
  	IF (c_fos%FOUND) THEN
  		p_message_name := 'IGS_PS_FIELD_OF_STUDY_CLOSED';
  		CLOSE c_fos;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_fos;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_fos_closed;
END IGS_RE_VAL_CAFOS;

/
