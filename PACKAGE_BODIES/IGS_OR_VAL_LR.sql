--------------------------------------------------------
--  DDL for Package Body IGS_OR_VAL_LR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_VAL_LR" AS
/* $Header: IGSOR07B.pls 115.4 2002/11/29 01:47:32 nsidana ship $ */
/* change history
   who                             when                        what
   npalanis                        20-apr-2002               The call to IGS_OR_VAL_LR.assp_val_lr_dflt_one  in  assp_val_lr_dfltslot
                                                             is removed because the code is now transferred to post forms commit
							     BUG - 2322096
*/

  -- Validate the location relationship.
  FUNCTION orgp_val_lr(
  p_location_cd IN VARCHAR2 ,
  p_sub_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	-- Local function : to perform recursive loop of the location relationship.
  	FUNCTION orgp_val_lr_loop (
  		p_location_cd	IN	IGS_AD_LOCATION.location_cd%TYPE)
  	RETURN BOOLEAN
  	IS
  		CURSOR	c_lr IS
  		SELECT	location_cd
  		FROM	IGS_AD_LOCATION_REL
  		WHERE	sub_location_cd = p_location_cd;
  		v_valid		BOOLEAN 	DEFAULT TRUE;
  		v_other_detail	VARCHAR2(255);
  	BEGIN
  		FOR lr IN c_lr  LOOP
  			IF lr.location_cd = p_sub_location_cd THEN
  				v_valid := FALSE;
  				EXIT;
  			END IF;
  			IF orgp_val_lr_loop (lr.location_cd) = FALSE THEN
  				v_valid := FALSE;
  				EXIT;
  			END IF;
  		END LOOP;
  		RETURN v_valid;
  		EXCEPTION
  		WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  	END orgp_val_lr_loop;
  BEGIN
  	p_message_name := NULL;
  	-- Validate the closed indicator for the owning location code.
  	IF orgp_val_loc_cd (p_location_cd, p_message_name) = FALSE THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the closed indicator for the sub-location code.
  	IF orgp_val_loc_cd (p_sub_location_cd, p_message_name) = FALSE THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the sub-location is not the same as the location
  	IF p_location_cd = p_sub_location_cd THEN
  		p_message_name := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	END IF;
  	-- Validate the location structure to ensure the sub-location
  	-- does not appear further up the structure.
  	IF orgp_val_lr_loop (p_location_cd) = FALSE THEN
  		p_message_name := 'IGS_OR_OWN_SUB_LOC_REL_XS';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END orgp_val_lr;
  --
  -- Validate the location.
  FUNCTION orgp_val_loc_cd(
  p_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	CURSOR c_loc IS
  	SELECT	closed_ind
  	FROM	IGS_AD_LOCATION
  	WHERE	location_cd = p_location_cd
  	AND	closed_ind = 'Y';
  	v_other_detail	VARCHAR2(255);
  BEGIN
  	p_message_name := NULL;
  	FOR loc IN c_loc LOOP
  		p_message_name := 'IGS_OR_LOCATION_CLOSED';
  		RETURN FALSE;
  	END LOOP;
  	RETURN TRUE;
  	EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END orgp_val_loc_cd;
  --
  -- Retrofitted
  FUNCTION assp_val_lr_dfltslot(
  p_location_cd  IGS_AD_LOCATION_REL.location_cd%TYPE ,
  p_sub_location_cd  IGS_AD_LOCATION_REL.sub_location_cd%TYPE ,
  p_dflt_ind  IGS_AD_LOCATION_REL.dflt_ind%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_lr_dfltslot
  	-- Can only set the default indicator when:
  	-- parent location has an s_location_type = CAMPUS and
  	-- child location has an s_location_type = EXAM_CTR or GRD_CTR
  DECLARE
  	v_s_location_type		IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
  	v_sub_s_location_type		IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
  	v_message_name			VARCHAR2(30);
  BEGIN
  	-- 1. Set the default message number
  	p_message_name := NULL;
  	IF (p_dflt_ind = 'Y') THEN
  		-- 1. Validate system location types are appropriate for setting
  		-- the default indicator
  		-- Fetch system location type for parent location.
  		v_s_location_type := IGS_OR_GEN_001.ORGP_GET_S_LOC_TYPE(
  				p_location_cd);
  		IF (NVL(v_s_location_type, '-1') <> 'CAMPUS') THEN
  			-- The system location type for the parent location must be
  			-- of type 'CAMPUS' when setting the default indicator.
  			p_message_name := 'IGS_AS_SYS_LOCTYPE_CAMPUS';
  			RETURN FALSE;
  		END IF;
  		-- Fetch system location type for a child locations.
  		v_sub_s_location_type := IGS_OR_GEN_001.ORGP_GET_S_LOC_TYPE(
  				p_sub_location_cd);
  		IF (NVL(v_sub_s_location_type, '-1') <> 'EXAM_CTR' AND
  		  NVL(v_sub_s_location_type, '-1') <> 'GRD_CTR') THEN
  			-- The system location type for the child location must be
  			-- of type EXAM_CTR or GRD_CTR when setting the default indicator.
  			p_message_name := 'IGS_AS_SYS_LOCTYPE_EXAMCTR';
  			RETURN FALSE;
  		END IF;

  	END IF;
  	-- 3. Validation successful
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END assp_val_lr_dfltslot;
  --
  -- Retrofitted
  FUNCTION assp_val_lr_dflt_one(
  p_location_cd  IGS_AD_LOCATION_REL.location_cd%TYPE ,
  p_sub_location_cd  IGS_AD_LOCATION_REL.sub_location_cd%TYPE ,
  p_sub_s_location_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_lr_dflt_one
  	-- This module validates that a single location (system location type of
  	-- CAMPUS) can only have <= 1 default exam location (system location type
  	-- of EXAM_CTR or GRD_CTR). This validation is invoked from
  	-- ASSP_VAL_LR_DFLTSLOT validation.
  DECLARE
  	CURSOR c_lr IS
  	SELECT	'x'
  	FROM	IGS_AD_LOCATION_REL	lr,
  		IGS_AD_LOCATION			loc,
  		IGS_AD_LOCATION_TYPE		lot
  	WHERE	lr.location_cd	= p_location_cd	AND
  		lr.sub_location_cd	<> p_sub_location_cd AND
  		lr.dflt_ind	= 'Y' AND
  		lr.sub_location_cd = loc.location_cd AND
  		loc.location_type = lot.location_type AND
  		lot.s_location_type = p_sub_s_location_type;
  	v_lr_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	OPEN c_lr;
  	FETCH c_lr INTO v_lr_exists;
  	IF (c_lr%FOUND) THEN
  		CLOSE c_lr;
  		-- Only one location relationship for any particular parent
  		-- location may have the default indicator set.
  		p_message_name := 'IGS_AS_LOC_ONLYONE_SUBLOC';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_lr;
  	-- Validation successful.
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END assp_val_lr_dflt_one;
  --
  -- Retrofitted
  FUNCTION assp_val_lr_lr(
  p_location_cd  IGS_AD_LOCATION_REL.location_cd%TYPE ,
  p_sub_location_cd  IGS_AD_LOCATION_REL.sub_location_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_lr_lr
  	-- Can not make a location with a system location type of CAMPUS
  	-- a child of a location with a system location type of EXAM_CTR or GRD_CTR
  DECLARE
  	v_s_location_type		IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
  	v_sub_s_location_type		IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
  BEGIN
  	-- 1. Set the default message number
  	p_message_name := NULL;
  	-- 2. Check system location type for the locations in the relationship
  	-- Fetch system location type for parent IGS_AD_LOCATION.
  	v_s_location_type := IGS_OR_GEN_001.ORGP_GET_S_LOC_TYPE(
  			p_location_cd);
  	-- Fetch system location type for a child locations.
  	v_sub_s_location_type := IGS_OR_GEN_001.ORGP_GET_S_LOC_TYPE(
  			p_sub_location_cd);
  	IF (	(NVL(v_s_location_type, '-1') = 'GRD_CTR' OR
  		NVL(v_s_location_type, '-1') = 'EXAM_CTR')	AND
  		NVL(v_sub_s_location_type, '-1') = 'CAMPUS')	THEN
  		-- The system location type for the parent location can not be
  		-- of type EXAM_CTR or GRD_CTR when the system location type for the child
  		-- location is of type 'CAMPUS'.
  		p_message_name := 'IGS_AS_SYS_LCOTYPE_GRD_CTR';
  		RETURN FALSE;
  	END IF;
  	-- 3. Validation successful
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END assp_val_lr_lr;
END IGS_OR_VAL_LR;

/
