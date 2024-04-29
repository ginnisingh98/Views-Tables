--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_UV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_UV" AS
/* $Header: IGSPS72B.pls 120.0 2005/06/01 19:29:58 appldev noship $ */
/*-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When             What
    sarakshi     12-Jul-2004     Bug#3729462, Added the DELETE_FLAG predicate in the cursor c_unit_offering_pattern of procedure crsp_val_uv_quality.
    ijeddy       03-nov-2003     Bug# 3181938; Modified this object as per Summary Measurement Of Attainment FD.
    sarakshi    02-sep-2003      Enh#3052452,removed functions crsp_val_uv_sub_ind  and crsp_val_uv_sup_ind.Also removed
                                 local procedures crsp_val_non_inactive_subs,crsp_val_non_active_sups and crsp_val_non_active_subs and their calls also
    smvk        10-Dec-2002      Bug # 2699913, Modified function crsp_val_uv_unit_sts not to do the
                                 validations associated with following error messages for legacy data.
                                 IGS_PS_UNIT_STATUS_CLOSED, IGS_PS_UNITSTATUS_NOT_ALTERED and IGS_PS_NEWUNITVER_ST_PLANNED
    sarakshi    14-nov-2002      bug#2649028,modified function crsp_val_uv_pnt_ovrd,
                                 crsp_val_uv_unit_sts
    jbegum      21 Mar 02        As part of big fix of bug #2192616
                                 Removed the exception handling part of the
                                 function enrp_get_sua_incur.This was done in order
                                 to allow the user defined exception NO_AUSL_RECORD_FOUND
                                 coming from IGS_EN_GEN_007.ENRP_GET_SUA_INCUR which in turn gets it
                                 from IGS_EN_PRC_LOAD.ENRP_GET_LOAD_INCUR and
                                 to propagate to the form IGSPS047 and be handled accordingly
                                 instead of coming as an unhandled exception.

  --jbegum       12 Mar 02      As part of bug fix of bug #2192616
  --                            Modified the procedure crsp_val_uv_pnt_ovrd
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed
  -- smvk       16-Dec-2002     Function Call IGS_PS_VAL_TR.crsp_val_tr_perc,IGS_PS_VAL_UD.crsp_val_ud_perc are modified with
  --                            additional parameter value 'FALSE'. for Bug # 2696207
  --bdeviset    21-JUL-2004     Added a new procedure GET_CP_VALUES for Bug # 3782329
  -------------------------------------------------------------------------------------------*/
  --
  -- Validate the IGS_PS_UNIT level
  FUNCTION crsp_val_unit_lvl(
  p_unit_level IN CHAR ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_PS_UNIT_LEVEL.closed_ind%TYPE;
  	CURSOR	c_unit_lvl_closed_ind IS
  	SELECT	closed_ind
  	FROM	IGS_PS_UNIT_LEVEL
  	WHERE	unit_level = p_unit_level AND
  		closed_ind = 'Y';
  BEGIN
  	OPEN c_unit_lvl_closed_ind;
  	FETCH c_unit_lvl_closed_ind INTO v_closed_ind;
  	--- If a record was not found, then return TRUE, else FALSE
  	IF c_unit_lvl_closed_ind%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_unit_lvl_closed_ind;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_UNITLVL_CLOSED';
  		CLOSE c_unit_lvl_closed_ind;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
   WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_unit_lvl');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_unit_lvl;
  --
  -- Validate the credit point descritor for IGS_PS_UNIT version.
  FUNCTION crsp_val_uv_cp_desc(
  P_CREDIT_POINT_DESCRIPTOR IN VARCHAR2,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_LOOKUPS_VIEW.closed_ind%TYPE;
  	CURSOR	c_cp_desc_closed_ind IS
  	SELECT	closed_ind
  	FROM	IGS_LOOKUPS_VIEW
  	WHERE	lookup_code = p_credit_point_descriptor AND
  		closed_ind = 'Y'  AND
  		lookup_type = 'CREDIT_POINT_DSCR';
  BEGIN
  	OPEN c_cp_desc_closed_ind;
  	FETCH c_cp_desc_closed_ind INTO v_closed_ind;
  	IF c_cp_desc_closed_ind%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_cp_desc_closed_ind;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_CRDPNT_DESCRIPTOR_CLS';
  		CLOSE c_cp_desc_closed_ind;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_cp_desc');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_cp_desc;
  --
  -- Validate the IGS_PS_UNIT internal IGS_PS_COURSE level for IGS_PS_UNIT version.
  FUNCTION crsp_val_uv_uicl(
  p_unit_int_course_level_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_PS_UNIT_INT_LVL.closed_ind%TYPE;
  	CURSOR	c_uv_uicl_closed_ind IS
  	SELECT	closed_ind
  	FROM	IGS_PS_UNIT_INT_LVL
  	WHERE	unit_int_course_level_cd = p_unit_int_course_level_cd AND
  		closed_ind = 'Y';
  BEGIN
  	OPEN c_uv_uicl_closed_ind;
  	FETCH c_uv_uicl_closed_ind INTO v_closed_ind;
  	IF c_uv_uicl_closed_ind%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_uv_uicl_closed_ind;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_UNIT_INTPRG_LVL_CLOSED';
  		CLOSE c_uv_uicl_closed_ind;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_uicl');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_uicl;

  --
  -- Validate IGS_PS_UNIT version end date and IGS_PS_UNIT version status
  FUNCTION crsp_val_uv_end_sts(
  p_end_dt IN DATE ,
  p_unit_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	v_s_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	CURSOR c_get_s_unit_status IS
  		SELECT s_unit_status
  		FROM	IGS_PS_UNIT_STAT
  		WHERE	unit_status = p_unit_status;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_get_s_unit_status;
  	FETCH c_get_s_unit_status INTO v_s_unit_status;
  	IF (c_get_s_unit_status%NOTFOUND) THEN
  		CLOSE c_get_s_unit_status;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_s_unit_status;
  	-- end date can only be set if the
  	-- IGS_PS_UNIT system status is INACTIVE
  	IF (p_end_dt IS NOT NULL) THEN
  		IF (v_s_unit_status = 'INACTIVE') THEN
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_PS_STSET_INACTIVE_UNITVER';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF (v_s_unit_status <> 'INACTIVE') THEN
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_PS_STNOTSET_INACTIVE_UNIT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_end_sts');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_end_sts;
  --
  -- Validate IGS_PS_UNIT version expiry date and IGS_PS_UNIT version status.
  FUNCTION crsp_val_uv_exp_sts(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_expiry_dt IN DATE ,
  p_unit_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_s_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	v_check			CHAR;
  	CURSOR c_get_s_unit_status IS
  		SELECT s_unit_status
  		FROM	IGS_PS_UNIT_STAT
  		WHERE	unit_status = p_unit_status;
  	CURSOR c_check_uv_us IS
  		SELECT 'x'
  		FROM	IGS_PS_UNIT_VER	uv,
  			IGS_PS_UNIT_STAT	us
  		WHERE	unit_cd		= p_unit_cd		AND
  			version_number 	<> p_version_number	AND
  			expiry_dt		IS NULL			AND
  			uv.unit_status	= us.unit_status		AND
  			us.s_unit_status	= 'ACTIVE';
  BEGIN
  	p_message_name := NULL;
  	OPEN c_get_s_unit_status;
  	FETCH c_get_s_unit_status INTO v_s_unit_status;
  	IF (c_get_s_unit_status%NOTFOUND) THEN
  		CLOSE c_get_s_unit_status;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_s_unit_status;
  	-- Check that no other versions of the IGS_PS_UNIT exist that
  	-- have a system status of ACTIVE and expiry date not set.
  	IF (v_s_unit_status = 'ACTIVE') AND (p_expiry_dt IS NULL) THEN
  		OPEN c_check_uv_us;
  		FETCH c_check_uv_us INTO v_check;
  		IF (c_check_uv_us%FOUND) THEN
  			CLOSE c_check_uv_us;
  			p_message_name := 'IGS_PS_ANOTHERVER_EXISTS';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_uv_us;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_exp_sts');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_exp_sts;
  --
  -- Validate points increment, min and max fields against points override.
  FUNCTION crsp_val_uv_pnt_ovrd(
  p_points_override_ind IN VARCHAR2 ,
  p_points_increment IN NUMBER ,
  p_points_min IN NUMBER ,
  p_points_max IN NUMBER ,
  p_enrolled_credit_points IN NUMBER ,
  p_achievable_credit_points IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_lgcy_validator IN BOOLEAN )
  RETURN BOOLEAN AS
  /***********************************************************************************************
   Created By    :
   Date Created  :
   Purpose       :
   Known limitations,enhancements,remarks:
   Change History :
   Who          When                 What
   jbegum       12 Mar 02            As part of bug fix of bug #2192616
                                     The If conditions of all the validations have been modified
				     to check for NOT NULL.Earlier the IF conditions were using
				     NVL clause ie. IF (NVL(parameter,0)) <> 0
				     This caused the validation's to fail when the value of the parameter
				     was 0.
  *************************************************************************************************/
  l_ret_status  BOOLEAN :=TRUE;
  BEGIN
  	-- This module performs cross-field validation for points
  	-- increment points minimum and points maximum fields in
  	-- IGS_PS_UNIT version table
  	p_message_name := NULL;
  	IF(p_points_override_ind = 'Y') THEN
  		-- validate that p_points_min <= p_points_max
  		IF p_points_min IS NOT NULL AND
  		   p_points_max IS NOT NULL AND
  		   p_points_min > p_points_max THEN
                   IF p_lgcy_validator THEN
                     igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_CP_MAX_GE_CP_MIN',NULL,NULL,FALSE);
                     l_ret_status :=FALSE;
                   ELSE
  		     p_message_name := 'IGS_PS_CP_MAX_GE_CP_MIN';
  		     RETURN FALSE;
                  END IF;
  		END IF;
  		-- validate that p_points_min >= p_enrolled_credit_points
  		IF p_points_min IS NOT NULL AND
  		   p_points_min > p_enrolled_credit_points THEN
                   IF p_lgcy_validator THEN
                     igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_ENRCP_ME_CPMIN',NULL,NULL,FALSE);
                     l_ret_status :=FALSE;
                   ELSE
  		     p_message_name := 'IGS_PS_ENRCP_ME_CPMIN';
  		     RETURN FALSE;
                  END IF;
  		END IF;
  		-- validate that p_points_max >= p_enrolled_credit_points
  		IF p_points_max IS NOT NULL AND
  		   p_points_max < p_enrolled_credit_points THEN
                   IF p_lgcy_validator THEN
                     igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_CP_MAX_GE_ENR_CP',NULL,NULL,FALSE);
                     l_ret_status :=FALSE;
                   ELSE
  		     p_message_name := 'IGS_PS_CP_MAX_GE_ENR_CP';
  		     RETURN FALSE;
                  END IF;
  		END IF;
  		-- validate that p_points_min <= p_achievable_credit_points
  		IF p_points_min IS NOT NULL AND
  		   p_achievable_credit_points IS NOT NULL AND
  		   p_points_min > p_achievable_credit_points THEN
                   IF p_lgcy_validator THEN
                     igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_ACHCP_GE_CP_MIN',NULL,NULL,FALSE);
                     l_ret_status :=FALSE;
                   ELSE
  		     p_message_name := 'IGS_PS_ACHCP_GE_CP_MIN';
  		     RETURN FALSE;
                  END IF;
  		END IF;
  		-- validate that p_points_max >= p_achievable_credit_points
  		IF p_points_max IS NOT NULL AND
  		   p_achievable_credit_points IS NOT NULL AND
  		   p_points_max < p_achievable_credit_points THEN
                   IF p_lgcy_validator THEN
                     igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_CP_MAX_GE_ACH_CP',NULL,NULL,FALSE);
                     l_ret_status :=FALSE;
                   ELSE
  		     p_message_name := 'IGS_PS_CP_MAX_GE_ACH_CP';
  		     RETURN FALSE;
                  END IF;
  		END IF;
  		-- validate that p_points_min and p_points_max values are in accordance with
  		-- p_enrolled_credit_points and p_points_increment values
  		IF p_points_min IS NOT NULL AND
  		   p_points_increment IS NOT NULL THEN
  			IF(MOD(ABS(p_points_min - p_enrolled_credit_points), p_points_increment)
  				<> 0) THEN
                          IF p_lgcy_validator THEN
                            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_CP_MAX_DECR_ENR_CP',NULL,NULL,FALSE);
                            l_ret_status :=FALSE;
                          ELSE
  			    p_message_name := 'IGS_PS_CP_MAX_DECR_ENR_CP';
  		            RETURN FALSE;
                          END IF;
  			END IF;
  		END IF;
  		IF p_points_max IS NOT NULL AND
  		   p_points_increment IS NOT NULL THEN
  			IF(MOD(ABS(p_points_max - p_enrolled_credit_points), p_points_increment)
  				<> 0) THEN
                          IF p_lgcy_validator THEN
                            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_CP_MAX_INCR_ENR_CP',NULL,NULL,FALSE);
                            l_ret_status :=FALSE;
                          ELSE
  			    p_message_name := 'IGS_PS_CP_MAX_INCR_ENR_CP';
  		            RETURN FALSE;
                          END IF;
  			END IF;
  		END IF;
  	ELSE
  		IF p_points_increment IS NOT NULL OR
  		   p_points_min IS NOT NULL OR
  		   p_points_max IS NOT NULL THEN
                   IF p_lgcy_validator THEN
                     igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_CRDPOINT_INCR_MAX_MIN',NULL,NULL,FALSE);
                     l_ret_status :=FALSE;
                   ELSE
  		     p_message_name := 'IGS_PS_CRDPOINT_INCR_MAX_MIN';
  		     RETURN FALSE;
                  END IF;
  		END IF;
  	END IF;

        IF p_lgcy_validator THEN
          RETURN l_ret_status;
        ELSE
      	  RETURN TRUE;
        END IF;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_pnt_ovrd');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_pnt_ovrd;
  --
  -- Validate the IGS_PS_UNIT status for IGS_PS_UNIT version
  FUNCTION crsp_val_uv_unit_sts(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_new_unit_status IN VARCHAR2 ,
  p_old_unit_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_lgcy_validator IN BOOLEAN )
  RETURN BOOLEAN AS
  	cst_planned_status		VARCHAR2(7);
  	cst_inactive_status		VARCHAR2(8);
  	cst_active_status		VARCHAR2(6);
  	gv_closed_ind			IGS_PS_UNIT_STAT.closed_ind%TYPE;
  	gv_new_sys_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	gv_old_sys_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;

        l_ret_status  BOOLEAN :=TRUE;

  	CURSOR	c_unit_sts_closed_ind IS
  		SELECT	closed_ind
  		FROM	IGS_PS_UNIT_STAT
  		WHERE unit_status = p_new_unit_status;
  	CURSOR	c_new_sys_status IS
  		SELECT	s_unit_status
  		FROM	IGS_PS_UNIT_STAT
  		WHERE	unit_status = p_new_unit_status;
  	CURSOR	c_old_sys_status IS
  		SELECT	s_unit_status
  		FROM	IGS_PS_UNIT_STAT
  		WHERE unit_status = p_old_unit_status;
  BEGIN
        --For gscc warning shifted down
    	cst_planned_status	:= 'PLANNED';
  	cst_inactive_status	:= 'INACTIVE';
  	cst_active_status	:= 'ACTIVE';

  	--- Set default message
  	p_message_name := NULL;
  	--- Check the closed indicator for the new IGS_PS_UNIT
  	OPEN c_unit_sts_closed_ind;
  	FETCH c_unit_sts_closed_ind INTO gv_closed_ind;
  	--- If a record was not found, then return FALSE, else check the
  	--- closed indicator.
  	IF c_unit_sts_closed_ind%NOTFOUND THEN
           IF NOT p_lgcy_validator THEN
             p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
             CLOSE c_unit_sts_closed_ind;
             RETURN FALSE;
           END IF;
        END IF;
  	CLOSE c_unit_sts_closed_ind;
  	IF gv_closed_ind <> 'N' THEN
           IF NOT p_lgcy_validator THEN
             p_message_name := 'IGS_PS_UNIT_STATUS_CLOSED';
  	     CLOSE c_unit_sts_closed_ind;
  	     RETURN FALSE;
           END IF;
  	END IF;
  	--- Validate the system status is not being altered to PLANNED from ACTIVE
  	--- or INACTIVE.
  	--- Retrieve the system status for the new and old IGS_PS_UNIT statuses.
  	OPEN c_new_sys_status;
  	FETCH c_new_sys_status INTO gv_new_sys_unit_status;
  	IF c_new_sys_status%NOTFOUND THEN
           IF NOT p_lgcy_validator THEN
  	     CLOSE c_new_sys_status;
  	     p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  	     RETURN FALSE;
           END IF;
  	END IF;
  	CLOSE c_new_sys_status;
  	OPEN c_old_sys_status;
  	FETCH c_old_sys_status INTO gv_old_sys_unit_status;
  	CLOSE c_old_sys_status;
  	IF p_old_unit_status IS NOT NULL AND
  			p_new_unit_status <> p_old_unit_status THEN
  		IF gv_new_sys_unit_status <> gv_old_sys_unit_status THEN
  			IF gv_new_sys_unit_status = cst_planned_status THEN
                          IF NOT p_lgcy_validator THEN
  			    p_message_name := 'IGS_PS_UNITSTATUS_NOT_ALTERED';
  		            RETURN FALSE;
                          END IF;
  			END IF;
  		END IF;
  	END IF;
  	--- Check that the new system status is not Planned when the old IGS_PS_UNIT
  	--- status is NULL
  	IF p_old_unit_status IS NULL THEN
  		IF gv_new_sys_unit_status <> cst_planned_status THEN
                  IF NOT p_lgcy_validator THEN
  		    p_message_name := 'IGS_PS_NEWUNITVER_ST_PLANNED';
  		    RETURN FALSE;
                  END IF;
  		END IF;
  	END IF;

        --- Additional check must be done to see if students enrolled in this IGS_PS_UNIT are
        --- ACTIVE - waiting on Enrolment sub-system.

  	--- If all validation is successful, then return TRUE and message number 0
        IF p_lgcy_validator THEN
          RETURN l_ret_status;
        ELSE
      	  RETURN TRUE;
        END IF;

  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_unit_sts');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_unit_sts;
  --
  -- Perform quality validation checks on a IGS_PS_UNIT version and its details.
  FUNCTION crsp_val_uv_quality(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_old_unit_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_uv_quality
  	-- Perform a quality validation check on insert.
  	-- 	* Validate that all reference data is open and available for use
  	--	  for IGS_PS_UNIT_VER records (e.g IGS_PS_UNIT_LEVEL is not closed) and also
  	--	  for existing IGS_PS_UNIT_VER detail records such as:
  	-- 		IGS_PS_UNIT_DSCP,
  	-- 		IGS_PS_UNIT_CATEGORY,
  	-- 		IGS_PS_UNIT_LVL,
  	-- 		IGS_PS_UNIT_REF_CD.
  	-- 		If IGS_PS_UNIT version is altered from a system status of planned to
  	--		active then check:
  	-- 			IGS_PS_UNIT_OFR,
  	-- 			IGS_PS_UNIT_OFR_PAT,
  	-- 			IGS_PS_UNIT_OFR_OPT.
  	--	* Validate that where tables contains fields that hold percentages, that
  	--	  the records total 100% for the given IGS_PS_UNIT version. The relevant tables
  	--	  are:
  	-- 		IGS_PS_TCH_RESP,
  	-- 		IGS_PS_TCH_RESP_OVRD,
  	-- 		IGS_PS_UNIT_DSCP.
  	--	* Validate that all referenced organisational units are active.
  DECLARE
  	v_terminate		BOOLEAN := FALSE;
  	v_uv_rec		IGS_PS_UNIT_VER%ROWTYPE;
  	v_s_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	v_message_name		VARCHAR2(30);
  	v_ret			BOOLEAN;
  	CURSOR c_unit_version IS
  		SELECT	*
  		FROM	IGS_PS_UNIT_VER
  		WHERE	unit_cd		= p_unit_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_unit_discipline IS
  		SELECT	discipline_group_cd
  		FROM	IGS_PS_UNIT_DSCP
  		WHERE	unit_cd		= p_unit_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_course_unit_level IS
  		SELECT	course_cd, course_version_number
  		FROM	igs_ps_unit_lvl
  		WHERE	unit_cd		= p_unit_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_unit_categorisation IS
  		SELECT	unit_cat
  		FROM	IGS_PS_UNIT_CATEGORY
  		WHERE	unit_cd		= p_unit_cd	AND
  			version_number	= p_version_number;

-- ijeddy       03-nov-2003     Bug# 3181938; Modified this object as per Summary Measurement Of Attainment FD.
        CURSOR c_unit_reference_cd IS
                SELECT  reference_cd_type
                FROM    IGS_PS_UNIT_REF_CD
                WHERE   unit_cd         = p_unit_cd     AND
                        version_number  = p_version_number;
        CURSOR c_get_s_unit_status IS
  		SELECT	s_unit_status
  		FROM 	IGS_PS_UNIT_STAT
  		WHERE	unit_status	= p_old_unit_status;
  	CURSOR c_unit_offering IS
  		SELECT	cal_type
  		FROM	IGS_PS_UNIT_OFR
  		WHERE	unit_cd		= p_unit_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_unit_offering_pattern IS
  		SELECT	cal_type,
  			ci_sequence_number
  		FROM	IGS_PS_UNIT_OFR_PAT
  		WHERE	unit_cd		= p_unit_cd	AND
  			version_number	= p_version_number
		AND     delete_flag = 'N';
  	CURSOR c_unit_offering_option IS
  		SELECT	location_cd,
  			unit_class,
  			unit_contact
  		FROM	IGS_PS_UNIT_OFR_OPT
  		WHERE	unit_cd		= p_unit_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_teach_res_ovrd IS
  		SELECT	cal_type,
  			ci_sequence_number,
  			location_cd,
  			unit_class
  		FROM 	IGS_PS_UNIT_OFR_OPT
  		WHERE	unit_cd		= p_unit_cd AND
  			version_number	= p_version_number;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_unit_version;
  	FETCH c_unit_version INTO v_uv_rec;
  	IF (c_unit_version%NOTFOUND) THEN
  		CLOSE c_unit_version;
  		p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_unit_version;
  	-- Validate that the IGS_PS_UNIT_LEVEL is not closed
  	IF (IGS_PS_VAL_UV.crsp_val_unit_lvl(
  				v_uv_rec.unit_level,
  				p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_CR_PT_DSCR is not closed
  	IF (IGS_PS_VAL_UV.crsp_val_uv_cp_desc(
  				v_uv_rec.credit_point_descriptor,
  				p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate that the owning_org_unit_cd is ACTIVE

  	-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UV.crsp_val_ou_sys_sts
  	IF (IGS_PS_VAL_CRV.crsp_val_ou_sys_sts(
  				v_uv_rec.owner_org_unit_cd,
  				v_uv_rec.owner_ou_start_dt,
  				p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the records consisting of percentages total 100%
  	IF (IGS_PS_VAL_TR.crsp_val_tr_perc(
  				p_unit_cd,
  				p_version_number,
  				p_message_name,FALSE) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Loop for all offereing options for the IGS_PS_UNIT version.
  	FOR v_teach_res_ovrd_rec IN c_teach_res_ovrd LOOP
  		IF IGS_PS_VAL_TRo.crsp_val_tro_perc (
  						p_unit_cd,
  						p_version_number,
  						v_teach_res_ovrd_rec.cal_type,
  						v_teach_res_ovrd_rec.ci_sequence_number,
  						v_teach_res_ovrd_rec.location_cd,
  						v_teach_res_ovrd_rec.unit_class,
  						v_message_name) = FALSE THEN
  			v_ret := FALSE;
  			EXIT;
  		END IF;
  	END LOOP;
  	 IF v_ret = FALSE THEN
  	  	p_message_name := 'IGS_PS_PRCALLOC_TEACHRESP_100';
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_UNIT_DSCP record percentage total 100%
  	IF (IGS_PS_VAL_UD.crsp_val_ud_perc(
  				p_unit_cd,
  				p_version_number,
  				p_message_name,FALSE) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_UNIT_DSCP table and that the disclipline_group_cd
  	-- is not closed.
  	FOR ud_rec IN c_unit_discipline LOOP
  		IF (IGS_PS_VAL_UD.crsp_val_ud_dg_cd(
  				ud_rec.discipline_group_cd,
  				p_message_name) = FALSE) THEN
  			v_terminate := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF (v_terminate = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_UNIT_LVL table and that IGS_PS_COURSE is not closed
  	FOR cul_rec IN c_course_unit_level LOOP
  		IF (IGS_PS_VAL_CUL.crsp_val_crs_type(
  				cul_rec.course_cd,
          cul_rec.course_version_number,
  				p_message_name) = FALSE) THEN
  			v_terminate := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF (v_terminate = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_UNIT_CATEGORY table and that IGS_PS_UNIT_CAT is not closed
  	FOR uc_rec IN c_unit_categorisation LOOP
  		IF (IGS_PS_VAL_UC.crsp_val_uc_unit_cat(
  				uc_rec.unit_cat,
  				p_message_name) = FALSE) THEN
  			v_terminate := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF (v_terminate = TRUE) THEN
  		RETURN FALSE;
  	END IF;
    -- Validate the IGS_PS_UNIT_REF_CD table and that IGS_GE_REF_CD_TYPE is not
    -- closed
        FOR urc_rec IN c_unit_reference_cd LOOP
        -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_URC.crsp_val_ref_cd_type
          IF (IGS_PS_VAL_CRFC.crsp_val_ref_cd_type(
            urc_rec.reference_cd_type,
            p_message_name) = FALSE) THEN
            v_terminate := TRUE;
            EXIT;
          END IF;
        END LOOP;
        IF (v_terminate = TRUE) THEN
                RETURN FALSE;
        END IF;
    OPEN c_get_s_unit_status;
  	FETCH c_get_s_unit_status INTO v_s_unit_status;
  	-- No IGS_PS_UNIT_STAT found
  	IF (c_get_s_unit_status%NOTFOUND) THEN
  		CLOSE c_get_s_unit_status;
  		p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_get_s_unit_status;
  	IF (v_s_unit_status = 'PLANNED') THEN
  		-- Validate if IGS_PS_UNIT_OFR records exist, then the IGS_CA_TYPE is not closed
  		FOR uo_rec IN c_unit_offering LOOP
  		-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UO.crsp_val_uo_cal_type
  			IF (IGS_AS_VAL_UAI.crsp_val_uo_cal_type(
  					uo_rec.cal_type,
  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT;
  			END IF;
  		END LOOP;
  		IF (v_terminate = TRUE) THEN
  			RETURN FALSE;
  		END IF;
  		-- Validate if unit_ofering_pattern records exist, then the
  		-- IGS_CA_INST.IGS_CA_STAT = 'ACTIVE'
  		FOR uop_rec IN c_unit_offering_pattern LOOP
  			IF (IGS_as_VAL_uai.crsp_val_crs_ci(
  					uop_rec.cal_type,
  					uop_rec.ci_sequence_number,
  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT;
  			END IF;
  		END LOOP;
  		IF (v_terminate = TRUE) THEN
  			RETURN FALSE;
  		END IF;
  		-- Validate that if IGS_PS_UNIT_OFR_OPT records exist, then
  		-- check that location_cd and IGS_AS_UNIT_CLASS is not closed.
  		FOR uoo_rec IN c_unit_offering_option LOOP
  			IF (IGS_PS_VAL_UOo.crsp_val_loc_cd(
  					uoo_rec.location_cd,
  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT;
  			END IF;
  			IF (IGS_PS_VAL_UOo.crsp_val_uoo_uc(
  					uoo_rec.unit_class,
  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT;
  			END IF;
  			IF NVL(uoo_rec.unit_contact, 9999999999) <> 9999999999 THEN
  				-- Validate that the IGS_PS_UNIT contact is a staff member
  				IF (IGS_PS_VAL_UOo.crsp_val_uoo_contact(
  						uoo_rec.unit_contact,
  						p_message_name) = FALSE) THEN
  					v_terminate := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  		IF (v_terminate = TRUE) THEN
  			RETURN FALSE;
  		END IF;
  	END IF; -- (v_s_unit_status = 'PLANNED')
  	-- All validation successful
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_unit_version%ISOPEN) THEN
  			CLOSE c_unit_version;
  		END IF;
  		IF (c_unit_discipline%ISOPEN) THEN
  			CLOSE c_unit_discipline;
  		END IF;
  		IF (c_course_unit_level%ISOPEN) THEN
  			CLOSE c_course_unit_level;
  		END IF;
  		IF (c_unit_categorisation%ISOPEN) THEN
  			CLOSE c_unit_categorisation;
  		END IF;
  		IF (c_unit_reference_cd%ISOPEN) THEN
  			CLOSE c_unit_reference_cd;
  		END IF;
  		IF (c_get_s_unit_status%ISOPEN) THEN
  			CLOSE c_get_s_unit_status;
  		END IF;
  		IF (c_unit_offering%ISOPEN) THEN
  			CLOSE c_unit_offering;
  		END IF;
  		IF (c_unit_offering_pattern%ISOPEN) THEN
  			CLOSE c_unit_offering_pattern;
  		END IF;
  		IF (c_unit_offering_option%ISOPEN) THEN
  			CLOSE c_unit_offering_option;
  		END IF;
  		IF (c_teach_res_ovrd%ISOPEN) THEN
  			CLOSE c_teach_res_ovrd;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_quality');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_quality;
  --
  -- Validate supplementary exam indicator against the assessable indicator
  FUNCTION CRSP_VAL_UV_SUP_EXAM(
  p_supp_exam_permitted_ind IN VARCHAR2 ,
  p_assessable_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	p_message_name := NULL;
  	-- Validate the system status of the IGS_PS_COURSE version
  	IF p_supp_exam_permitted_ind = 'Y' AND
  		p_assessable_ind = 'N' THEN
  		p_message_name:= 'IGS_PS_UNITVER_ASSESSABLE';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_sup_exam');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_sup_exam;
  --

  -- Validate students fall within new override limits set
  FUNCTION crsp_val_uv_cp_ovrd(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_points_override_ind IN VARCHAR2 ,
  p_points_min IN NUMBER ,
  p_points_max IN NUMBER ,
  p_points_increment IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*    Who            When          What
      knaraset       09-May-2003   Modified call to IGS_EN_GEN_007.ENRP_GET_SUA_INCUR to add parameter uoo_id,as part of MUS build bug 2829262
      jbegum         21 Mar 2002   As part of big fix of bug #2192616
                                   Removed the exception handling part of the
                                   function crsp_val_uv_cp_ovrd.This was done in order
                                   to allow the user defined exception NO_AUSL_RECORD_FOUND
                                   coming from IGS_EN_GEN_007.ENRP_GET_SUA_INCUR which in turn gets it
                                   from IGS_EN_PRC_LOAD.ENRP_GET_LOAD_INCUR and
                                   to propagate to the form IGSPS047 and be handled accordingly
                                   instead of coming as an unhandled exception.
  */

  BEGIN	-- crsp_val_uv_cp_ovrd
  	-- Validate that all enrolled students are in accordance with the
  	-- new override credit points fields being specified.
  	-- This routine only returns warnings, and so will only
  	-- return the TRUE return.
  DECLARE
  	cst_enrolled		CONSTANT VARCHAR2(10) := 'ENROLLED';
  	cst_completed		CONSTANT VARCHAR2(10) := 'COMPLETED';
  	cst_discontin		CONSTANT VARCHAR2(10) := 'DISCONTIN';
  	v_uas1_enrolled	 	BOOLEAN := FALSE;
  	v_uas1_completed 	BOOLEAN := FALSE;
  	v_uas1_discontin 	BOOLEAN := FALSE;
  	v_uas2_enrolled	 	BOOLEAN := FALSE;
  	v_uas2_completed 	BOOLEAN := FALSE;
  	v_uas2_discontin 	BOOLEAN := FALSE;
  	NO_AUSL_RECORD_FOUND EXCEPTION;
  	CURSOR c_sua1 IS
  		SELECT	DISTINCT sua.unit_attempt_status
  		FROM	IGS_EN_SU_ATTEMPT sua
  		WHERE	sua.unit_cd 		= p_unit_cd 		AND
  			sua.version_number 	= p_version_number 	AND
  			(sua.unit_attempt_status IN (cst_enrolled,cst_completed)	OR
  			(sua.unit_attempt_status = cst_discontin	AND
  			IGS_EN_GEN_007.ENRP_GET_SUA_INCUR (
  					sua.person_id,
  					sua.course_cd,
  					sua.unit_cd,
  					sua.version_number,
  					sua.cal_type,
  					sua.ci_sequence_number,
  					sua.unit_attempt_status,
  					sua.discontinued_dt,
  					sua.administrative_unit_status,
                    sua.uoo_id) = 'Y')) AND
  			(sua.override_enrolled_cp IS NOT NULL OR
  			sua.override_achievable_cp IS NOT NULL);
  	CURSOR c_sua2 IS
  		SELECT  sua.unit_attempt_status
  		FROM	IGS_EN_SU_ATTEMPT sua
  		WHERE	sua.unit_cd 		= p_unit_cd 			AND
  			sua.version_number 	= p_version_number 		AND
  			(sua.unit_attempt_status IN (cst_enrolled,cst_completed) OR
  			(sua.unit_attempt_status = cst_discontin		AND
  			IGS_EN_GEN_007.ENRP_GET_SUA_INCUR (
  					sua.person_id,
  					sua.course_cd,
  					sua.unit_cd,
  					sua.version_number,
  					sua.cal_type,
  					sua.ci_sequence_number,
  					sua.unit_attempt_status,
  					sua.discontinued_dt,
  					sua.administrative_unit_status,
                    sua.uoo_id) = 'Y')) AND
  			(p_points_min IS NULL OR
  			 NVL(sua.override_enrolled_cp,999999) < p_points_min OR
  			 NVL(sua.override_achievable_cp,999999) < p_points_min) AND
  			(p_points_max IS NULL OR
  			 NVL(sua.override_enrolled_cp,0) > p_points_max OR
  			 NVL(sua.override_achievable_cp,0) > p_points_max) AND
  			(p_points_increment IS NULL OR
  			MOD(NVL(sua.override_enrolled_cp,p_points_increment),
  			 		p_points_increment) <> 0.0 OR
  			MOD(NVL(sua.override_achievable_cp,p_points_increment),
  					p_points_increment) <> 0.0);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- If the new points override indicator is set to N then check whether
  	-- the are any students with overridden credit points
  	IF p_points_override_ind = 'N' THEN
  		FOR v_sua1_rec IN c_sua1 LOOP
  			IF v_sua1_rec.unit_attempt_status = cst_enrolled THEN
  				v_uas1_enrolled := TRUE;
  			ELSIF v_sua1_rec.unit_attempt_status = cst_completed THEN
  				v_uas1_completed := TRUE;
  			ELSIF v_sua1_rec.unit_attempt_status = cst_discontin THEN
  				v_uas1_discontin := TRUE;
  			END IF;
  		END LOOP;
  		-- If all records had a status of 'ENROLLED'
  		IF (v_uas1_enrolled = TRUE AND
  				v_uas1_completed = FALSE AND
  				v_uas1_discontin = FALSE) THEN
  			p_message_name := 'IGS_PS_ENR_UNIT_ATTEMPTS_EXIS';
  		--all records had a status of 'COMPLETED'
  		ElSIF (v_uas1_enrolled = FALSE AND
  				v_uas1_completed = TRUE AND
  				v_uas1_discontin = FALSE) THEN
  			p_message_name := 'IGS_PS_COMPL_UNIT_ATTEMPTS';
  		-- all records contained statuses of 'ENROLLED' & 'COMPLETED'
  		ELSIF (v_uas1_enrolled = TRUE AND
  				v_uas1_completed = TRUE AND
  				v_uas1_discontin = FALSE) THEN
  			p_message_name := 'IGS_PS_ENR_COMPL_UNIT_ATTEMPT';
  		-- all records had a status of 'DISCONTIN'
  		ELSIF ( v_uas1_enrolled = FALSE AND
  				v_uas1_completed = FALSE AND
  				v_uas1_discontin = TRUE) THEN
  			p_message_name := 'IGS_PS_DIS_UA_EXISTS';
  		-- all records contained statuses of 'ENROLLED' & 'DISCONTIN'
  		ELSIF ( v_uas1_enrolled = TRUE AND
  				v_uas1_completed = FALSE AND
  				v_uas1_discontin = TRUE) THEN
  			p_message_name := 'IGS_PS_DIS_ENR_UA_EXISTS';
  		-- all records contained statuses of 'COMPLETED' & 'DISCONTIN'
  		ELSIF ( v_uas1_enrolled = FALSE AND
  				v_uas1_completed = TRUE AND
  				v_uas1_discontin = TRUE) THEN
  			p_message_name := 'IGS_PS_DIS_COMPL_UA_EXISTS';
  		-- all records contained statuses of 'COMPLETED' & 'DISCONTIN' & 'ENROLLED'
  		-- or no records where found
  		ELSIF (v_uas1_enrolled = TRUE AND
  				v_uas1_completed = TRUE AND
  				v_uas1_discontin = TRUE) THEN
  			p_message_name := 'IGS_PS_DIS_ENR_COMP_UA_EXISTS';
  		END IF;
  	ELSE	-- (later checks don't apply if override is not permitted)
  		-- * Check that all student IGS_PS_UNIT attempts which exist are in accordance
  		--   with the new values for the credit point limits.
  		FOR v_sua2_rec IN c_sua2 LOOP
  			IF v_sua2_rec.unit_attempt_status = cst_enrolled THEN
  				v_uas2_enrolled := TRUE;
  			ELSIF v_sua2_rec.unit_attempt_status = cst_completed THEN
  				v_uas2_completed := TRUE;
  			ELSIF v_sua2_rec.unit_attempt_status = cst_discontin THEN
  				v_uas2_discontin := TRUE;
  			END IF;
  		END LOOP;
  		-- If all records had a status of 'ENROLLED'
  		IF (v_uas2_enrolled = TRUE AND
  				v_uas2_completed = FALSE AND
  				v_uas2_discontin = FALSE) THEN
  			p_message_name := 'IGS_PS_ENR_UNIT_ATTEMPTS';
  		--all records had a status of 'COMPLETED'
  		ELSIF (v_uas2_enrolled = FALSE AND
  				v_uas2_completed = TRUE AND
  				v_uas2_discontin = FALSE) THEN
  			p_message_name := 'IGS_PS_COMPL_UNITATT_EXISTS';
  		-- all records contained statuses of 'ENROLLED' & 'COMPLETED'
  		ELSIF ( v_uas2_enrolled = TRUE AND
  				v_uas2_completed = TRUE AND
  				v_uas2_discontin = FALSE ) THEN
  			p_message_name := 'IGS_PS_ENR_COMPL_UNITATT_EXIS';
  		-- all records had a status of 'DISCONTIN'
  		ELSIF (v_uas2_enrolled = FALSE AND
  				v_uas2_completed = FALSE AND
  				v_uas2_discontin = TRUE) THEN
  			p_message_name := 'IGS_PS_DIS_UA_EXISTS_OVERRIDE';
  		-- all records contained statuses of 'ENROLLED' & 'DISCONTIN'
  		ELSIF (v_uas2_enrolled = TRUE AND
  				v_uas2_completed = FALSE AND
  				v_uas2_discontin = TRUE ) THEN
  			p_message_name := 'IGS_PS_DIS_ENR_UA_EXIST';
  		-- all records contained statuses of 'COMPLETED' & 'DISCONTIN'
  		ELSIF (v_uas2_enrolled = FALSE AND
  				v_uas2_completed = TRUE AND
  				v_uas2_discontin = TRUE) THEN
  			p_message_name := 'IGS_PS_DIS_COMP_UA_EXISTS';
  		-- all records contained statuses of 'COMPLETED' & 'DISCONTIN' & 'ENROLLED'
  		-- or no records where found
  		ELSIF (v_uas2_enrolled = TRUE AND
  				v_uas2_completed = TRUE AND
  				v_uas2_discontin = TRUE) THEN
  			p_message_name := 'IGS_PS_ENR_COMP_UA_EXISTS';
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;

  END crsp_val_uv_cp_ovrd;
  --
  -- Validate discont sua with pass grade within new uv overrides.
  FUNCTION crsp_val_uv_dsc_ovrd(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_points_min IN NUMBER ,
  p_points_max IN NUMBER ,
  p_points_increment IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
/*
| Who         When            What
| knaraset  09-May-03   Modified WHERE clause of cursor c_uv_dsc_ovrd to include uoo_id, as part of MUS build bug 2829262
|
|*/
  BEGIN	-- crsp_val_uv_dsc_ovrd
  	-- This module validates student IGS_PS_UNIT attempt credit point override
  	-- values against values in the IGS_PS_UNIT version for students that have
  	-- a unit_attempt status of discontinued but a result type of pass.
  DECLARE
  	cst_discontin	CONSTANT	VARCHAR2(9) := 'DISCONTIN';
  	cst_pass	CONSTANT	VARCHAR2(4) := 'PASS';
  	v_x		VARCHAR2(1);
  	CURSOR c_uv_dsc_ovrd IS
  		SELECT 	'x'
  		FROM	IGS_EN_SU_ATTEMPT sua,
  			IGS_AS_SU_STMPTOUT suao,
  			IGS_AS_GRD_SCH_GRADE gsg
  		WHERE	sua.unit_cd 		= p_unit_cd AND
  			sua.version_number 	= p_version_number AND
  			sua.person_id 		= suao.person_id AND
  			sua.course_cd 		= suao.course_cd AND
  			sua.uoo_id 		= suao.uoo_id	AND
  			sua.unit_attempt_status = cst_discontin AND
  			suao.grading_schema_cd 	= gsg.grading_schema_cd AND
  			suao.grade 		= gsg.grade AND
  			suao.version_number 	= gsg.version_number AND
  			gsg.s_result_type 	= cst_pass AND
  			(p_points_min IS NULL 				OR
  		 	NVL(sua.override_enrolled_cp,999999) < p_points_min OR
  		 	NVL(sua.override_achievable_cp,999999) < p_points_min) AND
  			(p_points_max IS NULL 				OR
  		 	NVL(sua.override_enrolled_cp,0) > p_points_max 	OR
  		 	NVL(sua.override_achievable_cp,0) > p_points_max) AND
  			(p_points_increment IS NULL 			OR
  			MOD(NVL(sua.override_enrolled_cp,p_points_increment),
  		 	p_points_increment) <> 0.0 			OR
  			MOD(NVL(sua.override_achievable_cp,p_points_increment),
  			p_points_increment) <> 0.0) ;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate IGS_PS_UNIT version
  	OPEN c_uv_dsc_ovrd;
  	FETCH c_uv_dsc_ovrd INTO v_x;
  	IF c_uv_dsc_ovrd%FOUND THEN
  		CLOSE c_uv_dsc_ovrd;
  		p_message_name := 'IGS_PS_DISCONT_RESULT_TYPE';
  	ELSE
  		CLOSE c_uv_dsc_ovrd;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uv_dsc_ovrd%ISOPEN THEN
  			CLOSE c_uv_dsc_ovrd;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_dsc_ovrd');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_dsc_ovrd;
  --
  -- Validate IGS_PS_UNIT attempts when ending IGS_PS_UNIT version.
  FUNCTION crsp_val_uv_end(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- crsp_val_uv_end
  	-- Perform checks required prior to the 'ending' of a IGS_PS_UNIT version, being
  	-- - no 'enrolled' attempts can be linked to the version.
  DECLARE
  	cst_enrolled	CONSTANT
  					IGS_LOOKUPS_VIEW.Lookup_Code%TYPE := 'ENROLLED';
  	cst_unconfirm	CONSTANT
  					IGS_LOOKUPS_VIEW.Lookup_Code%TYPE := 'UNCONFIRM';
  	cst_invalid	CONSTANT
  					IGS_LOOKUPS_VIEW.Lookup_Code%TYPE := 'INVALID';
  	cst_error		CONSTANT	VARCHAR2(1) := 'E';
  	cst_warning	CONSTANT	VARCHAR2(1) := 'W';
  	v_sua_enrolled	BOOLEAN := FALSE;
  	v_sua_inv_unc	BOOLEAN := FALSE;
  	CURSOR c_sua IS
  		SELECT 	DISTINCT sua.unit_attempt_status
  		FROM 	IGS_EN_SU_ATTEMPT	sua
  		WHERE 	sua.unit_cd = p_unit_cd AND
  			sua.version_number = p_version_number AND
  			sua.unit_attempt_status in (cst_enrolled, cst_unconfirm, cst_invalid);
  BEGIN
  	FOR v_sua_rec IN c_sua LOOP
  		IF v_sua_rec.unit_attempt_status = cst_enrolled THEN
  			v_sua_enrolled := TRUE;
  		ELSE
  			v_sua_inv_unc := TRUE;
  		END IF;
  	END LOOP;
  	IF v_sua_enrolled = TRUE THEN
  		p_message_name := 'IGS_PS_ENDPRG_ENROLLED';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	IF v_sua_inv_unc = TRUE THEN
  		p_message_name := 'IGS_PS_UNCONFIRMED_INVALID';
  		p_return_type := cst_warning;
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	p_return_type := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sua%ISOPEN) THEN
  			CLOSE c_sua;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_end');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uv_end;
  --
  -- Validate if students have IGS_EN_SU_ATTEMPT IGS_PE_TITLE override set
  FUNCTION crsp_val_uv_ttl_ovrd(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_title_override_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- crsp_val_uv_ttl_ovrd
  	-- validate the IGS_PE_TITLE indicator against student IGS_PS_UNIT attempt records.
  DECLARE
  	cst_enrolled	CONSTANT	VARCHAR(10) := 'ENROLLED';
  	cst_completed	CONSTANT	VARCHAR(10) := 'COMPLETED';
  	cst_discontin	CONSTANT	VARCHAR(10) := 'DISCONTIN';
  	v_unit_attempt_status
  					IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := NULL;
  	CURSOR c_sua IS
  		SELECT	sua.unit_attempt_status
  		FROM 	IGS_EN_SU_ATTEMPT 	sua
  		WHERE	sua.unit_cd = p_unit_cd AND
  			sua.version_number = p_version_number AND
  			sua.unit_attempt_status IN (
  						cst_enrolled,
  						cst_completed,
  						cst_discontin) AND
  			sua.alternative_title IS NOT NULL;
  BEGIN
  	p_message_name := NULL;
  	IF p_title_override_ind = 'N' THEN
  		FOR v_sua_rec IN c_sua LOOP
  			IF c_sua%ROWCOUNT = 1 THEN
  				v_unit_attempt_status := v_sua_rec.unit_attempt_status;
  				IF v_unit_attempt_status = cst_enrolled THEN
  					p_message_name := 'IGS_PS_ENR_UNITATT_EXIST_OVER';
  				ELSIF v_unit_attempt_status = cst_completed THEN
  					p_message_name := 'IGS_PS_COMPL_UNITATT_EXIST_AL';
  				ELSE
  					p_message_name := 'IGS_PS_DISCONT_UNIT_ATTEMPT';
  				END IF;
  			ELSE
  				IF v_sua_rec.unit_attempt_status <> v_unit_attempt_status THEN
  					p_message_name := 'IGS_PS_ENR_COMPL_DISCONT_UA';
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sua%ISOPEN) THEN
  			CLOSE c_sua;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UV.crsp_val_uv_ttl_ovrd');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;

  END crsp_val_uv_ttl_ovrd;


  PROCEDURE get_cp_values(
  p_uoo_id IN IGS_PS_UNIT_OFR_OPT_ALL.uoo_id%TYPE,
  p_enrolled_cp OUT NOCOPY IGS_PS_USEC_CPS.enrolled_credit_points%TYPE,
  p_billable_cp OUT NOCOPY IGS_PS_USEC_CPS.billing_hrs%TYPE,
  p_audit_cp OUT NOCOPY IGS_PS_USEC_CPS.billing_credit_points%TYPE) AS
  /***********************************************************************************************
   Created By    :  bdeviset
   Date Created  :  21-JUL-2004
   Purpose       :  gets Enrolled, Audit and Billable credit point values for the passed unit section.
   Known limitations,enhancements,remarks:
   Change History :
   Who          When                 What
   *************************************************************************************************/

  l_uv_enrolled_cp	IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;
  l_uv_billing_cp	IGS_PS_UNIT_VER.billing_hrs%TYPE;
  l_uv_audit_cp		IGS_PS_UNIT_VER.billing_credit_points%TYPE;
  l_uoo_enrolled_cp	IGS_PS_USEC_CPS.enrolled_credit_points%TYPE;
  l_uoo_billing_cp	IGS_PS_USEC_CPS.billing_hrs%TYPE;
  l_uoo_audit_cp	IGS_PS_USEC_CPS.billing_credit_points%TYPE;

  -- fetches Enrolled, Audit and Billable credit point values from unit version table for given uoo_id
  CURSOR c_uv(cp_uoo_id IN IGS_PS_UNIT_OFR_OPT_ALL.uoo_id%TYPE) IS
  SELECT
	uv.enrolled_credit_points,
	uv.billing_hrs,
	uv.billing_credit_points
  FROM
	IGS_PS_UNIT_VER uv,
	IGS_PS_UNIT_OFR_OPT uoo
  WHERE
	uoo.uoo_id = cp_uoo_id AND
	uoo.unit_cd = uv.unit_cd AND
	uoo.version_number = uv.version_number;

  -- fetches Enrolled, Audit and Billable credit point values from unit section table for given uoo_id
  CURSOR c_uoo(cp_uoo_id IN IGS_PS_UNIT_OFR_OPT_ALL.uoo_id%TYPE) IS
  SELECT
	us.enrolled_credit_points,
	us.billing_hrs,
	us.billing_credit_points
  FROM
	IGS_PS_USEC_CPS  us
  WHERE
	us.uoo_id = cp_uoo_id;

  BEGIN

    -- fetches Enrolled, Audit and Billable credit point values into local variables
    -- for unit version level
    OPEN c_uv(p_uoo_id);
    FETCH c_uv INTO l_uv_enrolled_cp,l_uv_billing_cp,l_uv_audit_cp;
    CLOSE c_uv;

    -- fetches Enrolled, Audit and Billable credit point values into local variables
    -- for unit section level
    OPEN c_uoo(p_uoo_id);
    FETCH c_uoo INTO l_uoo_enrolled_cp,l_uoo_billing_cp,l_uoo_audit_cp;
    CLOSE c_uoo;

    -- gets the Enrolled and Audit  credit point values of unit section
    -- if null takes the value of unit version in out parameter
    p_enrolled_cp := NVL(l_uoo_enrolled_cp, l_uv_enrolled_cp);
    p_audit_cp := NVL(l_uoo_audit_cp, l_uv_audit_cp);

    --If billable cp is defined at unit section level then the same is set in the out parameter.
    --If billable cp is not defined at unit section level but enrolled cp is then out parameter is set as null.
    --If billable cp and enrolled cp is not defined at unit section level and if billable cp at unit version level
    --is defined then billable cp at unit version is set in the out parameter else it is kept null.
    p_billable_cp := l_uoo_billing_cp;
    IF p_billable_cp IS NULL AND l_uoo_enrolled_cp IS NULL THEN
	p_billable_cp := l_uv_billing_cp;
    END IF;

  END get_cp_values;
END IGS_PS_VAL_UV;

/
