--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_COUSR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_COUSR" AS
/* $Header: IGSPS29B.pls 115.4 2002/11/29 03:00:52 nsidana ship $ */

  -- Validate IGS_PS_UNIT set status for ins/upd/del of detail records
  FUNCTION crsp_val_iud_us_dtl(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
	-- crsp_val_iud_us_dtl
  	-- This module validates whether or not inserts and updates can be made to
  	-- IGS_EN_UNIT_SET
  	-- detail records (ie; record structures underneath the IGS_EN_UNIT_SET table)
  DECLARE
  	v_s_unit_set_status	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	CURSOR c_us IS
  		SELECT  uss.s_unit_set_status
  		FROM	IGS_EN_UNIT_SET us,
  			IGS_EN_UNIT_SET_STAT uss
  		WHERE	us.unit_set_cd 		= p_unit_set_cd	AND
  			us.version_number 	= p_version_number AND
  			us.unit_set_status	= uss.unit_set_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- 1. Select the IGS_EN_UNIT_SET.IGS_EN_UNIT_SET_STAT for the given p_unit_cd and
  	-- p_version_number and
  	--    Select the IGS_EN_UNIT_SET_STAT.s_unit_set_status for the selected
  	-- IGS_EN_UNIT_SET.IGS_EN_UNIT_SET_STAT.
  	OPEN c_us;
  	FETCH c_us INTO v_s_unit_set_status;
  	-- 2.  If no record is found -
  	IF (c_us%NOTFOUND) THEN
  		CLOSE c_us;
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_us;
  	-- 3.  Test the value of the IGS_EN_UNIT_SET_STAT.s_unit_set_status
  	IF v_s_unit_set_status = 'INACTIVE' THEN
  		p_message_name := 'IGS_PS_UNIT_SET_INACTIVE';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_us%ISOPEN) THEN
  			CLOSE c_us;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  END crsp_val_iud_us_dtl;
  --
  -- Validate COUSR hierarchy for duplicate ancestors/descendants
  FUNCTION crsp_val_cousr_tree(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_sup_unit_set_cd IN VARCHAR2 ,
  p_sup_us_version_number IN NUMBER ,
  p_sub_unit_set_cd IN VARCHAR2 ,
  p_sub_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
	-- crsp_val_cousr_tree
  	-- This module validates that a IGS_PS_OF_UNT_SET_RL record can not
  	-- be created such that a IGS_PS_UNIT set is a parent/ancestor or child/descendant
  	-- of itself.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_cous (
  			cp_unit_set_cd		IGS_PS_OFR_UNIT_SET.unit_set_cd%TYPE,
  			cp_us_version_number	IGS_PS_OFR_UNIT_SET.us_version_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_OFR_UNIT_SET	cous
  		WHERE	cous.course_cd		= p_course_cd		AND
  			cous.crv_version_number	= p_crv_version_number	AND
  			cous.cal_type		= p_cal_type		AND
  			cous.unit_set_cd	= cp_unit_set_cd	AND
  			cous.us_version_number	= cp_us_version_number;
  	FUNCTION crspl_val_tree_circle (
  		p_tmp_sup_us_cd			IGS_PS_OF_UNT_SET_RL.sup_unit_set_cd%TYPE,
  		p_tmp_sup_us_ver_num
  				IGS_PS_OF_UNT_SET_RL.sup_us_version_number%TYPE)
  	RETURN BOOLEAN
  	AS
  	BEGIN	-- crspl_val_tree_circle
  		-- This validation function requires recursion.
  	DECLARE
  		v_circle_exists		BOOLEAN	DEFAULT FALSE;
  		CURSOR c_cousr (
  				cp_sup_unit_set_cd		IGS_PS_OF_UNT_SET_RL.sup_unit_set_cd%TYPE,
  				cp_sup_us_version_number
  						IGS_PS_OF_UNT_SET_RL.sup_us_version_number%TYPE) IS
  			SELECT	cousr.sub_unit_set_cd,
  				cousr.sub_us_version_number
  			FROM	IGS_PS_OF_UNT_SET_RL	cousr
  			WHERE	cousr.course_cd			= p_course_cd		AND
  				cousr.crv_version_number	= p_crv_version_number	AND
  				cousr.cal_type			= p_cal_type		AND
  				cousr.sup_unit_set_cd		= cp_sup_unit_set_cd	AND
  				cousr.sup_us_version_number	= cp_sup_us_version_number;
  	BEGIN
  		FOR v_cousr_rec IN c_cousr (
  						p_tmp_sup_us_cd,
  						p_tmp_sup_us_ver_num) LOOP
  			IF v_cousr_rec.sub_unit_set_cd = p_sup_unit_set_cd AND
  					v_cousr_rec.sub_us_version_number = p_sup_us_version_number THEN
  				-- the sub IGS_PS_UNIT set already had the same sup IGS_PS_UNIT set as child.
  				-- find circle in tree.
  				v_circle_exists := TRUE;
  				EXIT;
  			END IF;
  			IF crspl_val_tree_circle (
  						v_cousr_rec.sub_unit_set_cd,
  						v_cousr_rec.sub_us_version_number) = FALSE THEN
  				-- the sub IGS_PS_UNIT set already had the same sup IGS_PS_UNIT set as descendant.
  				-- find circle in subtree.
  				v_circle_exists := TRUE;
  				EXIT;
  			END IF;
  		END LOOP;
  		IF v_circle_exists = TRUE THEN
  			RETURN FALSE;
  		ELSE
  			RETURN TRUE;
  		END IF;
  	EXCEPTION
  		WHEN OTHERS THEN
  			IF c_cousr%ISOPEN THEN
  				CLOSE c_cousr;
  			END IF;
		App_Exception.Raise_Exception;
  	END;
  	END crspl_val_tree_circle;
  BEGIN
  	-- set default vaule
  	p_message_name := NULL;
  	-- 1.  Validate the superior IGS_PS_UNIT set:
  	OPEN c_cous (
  			p_sup_unit_set_cd,
  			p_sup_us_version_number);
  	FETCH c_cous INTO v_dummy;
  	IF c_cous%NOTFOUND THEN
  		CLOSE c_cous;
  		p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cous;
  	-- 2.  Validate the subordinate IGS_PS_UNIT set:
  	OPEN c_cous (
  			p_sub_unit_set_cd,
  			p_sub_us_version_number);
  	FETCH c_cous INTO v_dummy;
  	IF c_cous%NOTFOUND THEN
  		CLOSE c_cous;
  		p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cous;
  	-- 3.  Validate the superior and subordinate IGS_PS_UNIT sets are not the same:
  	IF p_sup_unit_set_cd = p_sub_unit_set_cd AND
  			p_sup_us_version_number = p_sub_us_version_number THEN
  		p_message_name := 'IGS_PS_INVALID_RELATION_SUP';
  		RETURN FALSE;
  	END IF;
  	-- 4.  Validate the IGS_PS_OF_UNT_SET_RL tree to ensure the superior
  	--     IGS_PS_UNIT set of the relationship does not exist anywhere else in the
  	--     relationship tree (ie; a recursive loop). This must cater for branching
  	--     (ie; multiple dependants).
  	IF crspl_val_tree_circle (
  				p_sub_unit_set_cd,
  				p_sub_us_version_number) = FALSE THEN
  		p_message_name := 'IGS_PS_INVALID_RELATION_HIERA';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_cous%ISOPEN THEN
  			CLOSE c_cous;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  END crsp_val_cousr_tree;
  --
  -- Validate COUSR can only be created with US as superior if appropriate
  FUNCTION crsp_val_cousr_sub(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_sup_unit_set_cd IN VARCHAR2 ,
  p_sup_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
	-- crsp_val_cousr_sub
  	-- This module validates that a IGS_PS_OF_UNT_SET_RL record can not
  	-- be created with a IGS_PS_OFR_UNIT_SET as the superior when the
  	-- only_as_sub_ind for that IGS_PS_OFR_UNIT_SET is set to 'Y'.
  BEGIN
  	-- set default vaule
  	p_message_name := NUll;
  	IF IGS_PS_GEN_003.CRSP_GET_COUS_SUBIND (
  				p_course_cd,
  				p_crv_version_number,
  				p_cal_type,
  				p_sup_unit_set_cd,
  				p_sup_us_version_number) = 'Y'	THEN
  		p_message_name := 'IGS_PS_UNIT_SET_NOT_USED';
  		RETURN FALSE;
  	ELSE
  		RETURN TRUE;
  	END IF;
  END;
  END crsp_val_cousr_sub;
  --
  -- Validate COUSR can only be created as sub if CACUS rec does not exist
  FUNCTION crsp_val_cousr_cacus(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_sub_unit_set_cd IN VARCHAR2 ,
  p_sub_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
	-- crsp_val_cousr_cacus
  	-- validate that a crs_off_set_relationship record can't be created
  	-- with a IGS_PS_OFR_UNIT_SET as the subordinate when the IGS_PS_UNIT set is
  	-- restricting an IGS_PS_COURSE offering option admission category
  DECLARE
  	v_unit_set_cd		IGS_PS_COO_AD_UNIT_S.unit_set_cd%TYPE;
  	CURSOR c_cacus IS
  		SELECT	cacus.unit_set_cd
  		FROM	IGS_PS_COO_AD_UNIT_S	cacus
  		WHERE	cacus.course_cd 		= p_course_cd AND
  			cacus.crv_version_number 	= p_crv_version_number AND
  			cacus.cal_type 			= p_cal_type AND
  			cacus.unit_set_cd 		= p_sub_unit_set_cd AND
  			cacus.us_version_number 	= p_sub_us_version_number;
  BEGIN
  	OPEN c_cacus;
  	FETCH c_cacus INTO v_unit_set_cd;
  	IF (c_cacus%FOUND) THEN
  		CLOSE c_cacus;
  		p_message_name := 'IGS_PS_UNIT_SET_NOT_USED_SUB';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cacus;
  	p_message_name := NULL;
  	RETURN TRUE ;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_cacus%ISOPEN) THEN
  			CLOSE c_cacus;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  END crsp_val_cousr_cacus;
  --
END IGS_PS_VAL_COusr;

/
