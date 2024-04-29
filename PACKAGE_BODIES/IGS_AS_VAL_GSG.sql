--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_GSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_GSG" AS
/* $Header: IGSAS24B.pls 115.3 2002/11/28 22:45:30 nsidana ship $ */

  --
  -- Validate grade's gs date range is current or future
  FUNCTION assp_val_gs_cur_fut(
  p_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_gsg IS
  		SELECT 	start_dt,
  			end_dt
  		FROM	IGS_AS_GRD_SCHEMA
  		WHERE	grading_schema_cd = p_grading_schema_cd AND
  			version_number = p_version_number;
  	v_gsg_rec			c_gsg%ROWTYPE;
  	v_fnc_return_value		BOOLEAN;
  BEGIN
  	-- Validate the IGS_AS_GRD_SCHEMA's date range is current or future
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_gsg;
  	FETCH c_gsg INTO  v_gsg_rec;
  	IF c_gsg%NOTFOUND THEN
  		CLOSE c_gsg;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_gsg  ;
  	-- Check if the grading schema is obsolete.
  	v_fnc_return_value := IGS_AS_VAL_GSG.GENP_VAL_DT_RANGE(v_gsg_rec.start_dt,
  							v_gsg_rec.end_dt,
  							p_message_name);
  	IF (NOT v_fnc_return_value) THEN
  		p_message_name := 'IGS_AS_GRD_SCHEMA_OBSLETE';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSG.assp_val_gs_cur_fut');
	        IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END assp_val_gs_cur_fut;
  --
  -- Retrofitted
  FUNCTION genp_val_dt_range(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  BEGIN
  	-- Validate the date range specified is current or future.
  	-- Set the default message number
  	p_message_name := null;
  	IF (p_end_dt IS NOT NULL) THEN
  		IF (p_start_dt <= TRUNC(SYSDATE) AND
  				p_end_dt < TRUNC(SYSDATE)) THEN
  			p_message_name := 'IGS_GE_INVALID_DATE_RANGE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSG.genp_val_dt_range');
	        IGS_GE_MSG_STACK.ADD;
      	       App_Exception.Raise_Exception;
  END genp_val_dt_range;
  --
  -- Validate upper mark range >= lower mark range and both set if one set
  FUNCTION assp_val_gsg_mrk_rng(
  p_lower_mark_range IN IGS_AS_GRD_SCH_GRADE.lower_mark_range%TYPE ,
  p_upper_mark_range IN IGS_AS_GRD_SCH_GRADE.upper_mark_range%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  BEGIN
  	-- Validate the grade's mark range.
  	-- Set the default message number
  	p_message_name := null;
  	-- Lower mark is set if upper mark is set
  	IF (p_upper_mark_range IS NOT NULL AND
  			p_lower_mark_range IS NULL) THEN
  		p_message_name := 'IGS_AS_LOWER_MARKRANGE_SPEC';
  		RETURN FALSE;
  	END IF;
  	-- Upper mark is set if lower mark is set
  	IF (p_upper_mark_range IS NULL AND
  			p_lower_mark_range IS NOT NULL) THEN
  		p_message_name := 'IGS_AS_UPP_MARKRANGE_SPEC';
  		RETURN FALSE;
  	END IF;
  	-- Lower mark is greater than or equal to the lower mark range
  	IF (p_upper_mark_range IS NOT NULL) THEN
  		IF (p_upper_mark_range < p_lower_mark_range) THEN
  			p_message_name := 'IGS_AS_UPP_MARKRANGE_GE_LOWER';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSG.assp_val_gsg_mrk_rng');
	        IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END assp_val_gsg_mrk_rng;
  --
  -- Validate max percentage >= min percentage
  FUNCTION assp_val_gsg_min_max(
  p_min_percentage IN IGS_AS_GRD_SCH_GRADE.min_percentage%TYPE ,
  p_max_percentage IN IGS_AS_GRD_SCH_GRADE.max_percentage%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  BEGIN
  	-- Validate the maximum percentage is greater than the minimum percentage.
  	-- Set the default message number
  	p_message_name := null;
  	IF (p_max_percentage < p_min_percentage) THEN
  		p_message_name := 'IGS_AS_MAXPER_GE_MINPER';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSG.assp_val_gsg_min_max');
	        IGS_GE_MSG_STACK.ADD;
	      	App_Exception.Raise_Exception;
  END assp_val_gsg_min_max;
  --
  -- Validate mark range does not overlap with other grades in GS version
  FUNCTION assp_val_gsg_m_ovrlp(
  p_grading_schema_cd IN IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCH_GRADE.version_number%TYPE ,
  p_grade IN IGS_AS_GRD_SCH_GRADE.grade%TYPE ,
  p_lower_mark_range IN IGS_AS_GRD_SCH_GRADE.lower_mark_range%TYPE ,
  p_upper_mark_range IN IGS_AS_GRD_SCH_GRADE.upper_mark_range%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_gsg IS
  		SELECT	lower_mark_range,
  			upper_mark_range
  		FROM	IGS_AS_GRD_SCH_GRADE
  		WHERE	grading_schema_cd = p_grading_schema_cd AND
  			version_number = p_version_number AND
  			grade <> p_grade AND
  			p_lower_mark_range IS NOT NULL AND
  			p_upper_mark_range IS NOT NULL;
  	v_gsg_rec			c_gsg%ROWTYPE;
  BEGIN
  	-- Validate that the mark range for the grade does not overlap with the mark
  	-- range for another grade within the same version of the grading schema.
  	-- Set the default message number
  	p_message_name := null;
  	FOR v_gsg_rec IN c_gsg LOOP
  		-- The lower mark range is within an existing range (inclusive).
  		IF (p_lower_mark_range >= v_gsg_rec.lower_mark_range AND
  				p_lower_mark_range <= v_gsg_rec.upper_mark_range) THEN
  			p_message_name := 'IGS_AS_LOWER_MARKRANGE_WITHIN';
  			RETURN FALSE;
  		END IF;
  		-- The upper mark range is within an existing range (inclusive).
  		IF (p_upper_mark_range >= v_gsg_rec.lower_mark_range AND
  				p_upper_mark_range <= v_gsg_rec.upper_mark_range) THEN
  			p_message_name := 'IGS_AS_UPP_MARKRANGE_WITHIN';
  			RETURN FALSE;
  		END IF;
  		-- The lower mark range is less than the lower mark range of an
  		-- existing range and the upper mark range is greater than the
  		-- upper mark range of an existing range.
  		IF (p_lower_mark_range < v_gsg_rec.lower_mark_range AND
  				p_upper_mark_range > v_gsg_rec.upper_mark_range) THEN
  			p_message_name := 'IGS_AS_MARKRANGE_ENCOMPASS';
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSG.assp_val_gsg_m_ovrlp');
	        IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END assp_val_gsg_m_ovrlp;
  --
  -- Validate only 1 grade exists in a GS with the dflt outstanding ind set
  FUNCTION assp_val_gsg_dflt(
  p_grading_schema_cd IN IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCH_GRADE.version_number%TYPE ,
  p_grade IN IGS_AS_GRD_SCH_GRADE.grade%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_gsg IS
  		SELECT	COUNT(*)
  		FROM	IGS_AS_GRD_SCH_GRADE
  		WHERE	grading_schema_cd = p_grading_schema_cd AND
  			version_number = p_version_number AND
  			grade <> p_grade AND
  			dflt_outstanding_ind = 'Y';
  	v_gsg_count		NUMBER;
  BEGIN
  	-- Validate only one grade exists within a version of the grading schema
  	-- with the default outstanding indicator set.
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_gsg  ;
  	FETCH c_gsg INTO v_gsg_count;
  	IF c_gsg%NOTFOUND THEN
  		CLOSE c_gsg  ;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_gsg  ;
  	IF (v_gsg_count > 0) THEN
  		p_message_name := 'IGS_AS_ONE_GRADE_VERSION_GRD';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSG.assp_val_gsg_dflt');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
  END assp_val_gsg_dflt;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  --
  -- Process GSG rowids in a PL/SQL TABLE for the current commit.
  --
  -- Validate the result for a grade cannot be chngd when translat'ns exist
  FUNCTION assp_val_gsg_gsgt(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_gsg_gsgt
  DECLARE
  	v_gsgt_exists		VARCHAR2(1);
  	CURSOR c_gsgt IS
  		SELECT	'x'
  		FROM	IGS_AS_GRD_SCH_TRN	gsgt
  		WHERE	gsgt.grading_schema_cd	= p_grading_schema_cd	AND
  			gsgt.version_number	= p_version_number	AND
  			gsgt.grade		= p_grade;
  	CURSOR c_gsgt2 IS
  		SELECT	'x'
  		FROM	IGS_AS_GRD_SCH_TRN	gsgt
  		WHERE	gsgt.to_grading_schema_cd	= p_grading_schema_cd	AND
  			gsgt.to_version_number		= p_version_number	AND
  			gsgt.to_grade			= p_grade;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_gsgt;
  	FETCH c_gsgt INTO v_gsgt_exists;
  	IF c_gsgt%FOUND THEN
  		CLOSE c_gsgt;
  		p_message_name :='IGS_AS_GRDRSLT_TYPE_MAP_FROM';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gsgt;
  	OPEN c_gsgt2;
  	FETCH c_gsgt2 INTO v_gsgt_exists;
  	IF c_gsgt2%FOUND THEN
  		CLOSE c_gsgt2;
  		p_message_name :='IGS_AS_GRDRSLT_TYPE_MAP_TO';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gsgt2;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gsgt%ISOPEN THEN
  			CLOSE c_gsgt;
  		END IF;
  		IF c_gsgt2%ISOPEN THEN
  			CLOSE c_gsgt2;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSG.assp_val_gsg_gsgt');
	        IGS_GE_MSG_STACK.ADD;
 	        App_Exception.Raise_Exception;
  END assp_val_gsg_gsgt;
  --
  -- Validate special grade type.
  FUNCTION assp_val_gsg_ssgt(
  p_s_special_grade_type IN VARCHAR2 ,
  p_s_result_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_gsg_ssgt
  	-- This module validates the special grade type. If the special grade
  	-- type is 'CONCEDED-PASS' then the s_result_type must be 'PASS'.
  DECLARE
  	cst_conceded_pass	CONSTANT
  						IGS_AS_GRD_SCH_GRADE.s_special_grade_type%TYPE := 'CONCEDED-PASS';
  	cst_pass		CONSTANT	IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE := 'PASS';
  BEGIN
  	IF p_s_special_grade_type = cst_conceded_pass AND
  			p_s_result_type <> cst_pass THEN
  		p_message_name := 'IGS_AS_SPL_GRDTYPE_CONCEDED';
  		RETURN FALSE;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       	        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_GSG.assp_val_gsg_ssgt');
	        IGS_GE_MSG_STACK.ADD;
    	        App_Exception.Raise_Exception;
  END assp_val_gsg_ssgt;
END IGS_AS_VAL_GSG;

/
