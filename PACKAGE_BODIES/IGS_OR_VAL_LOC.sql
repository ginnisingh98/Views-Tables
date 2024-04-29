--------------------------------------------------------
--  DDL for Package Body IGS_OR_VAL_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_VAL_LOC" AS
/* $Header: IGSOR05B.pls 115.7 2002/11/29 01:46:53 nsidana ship $ */
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
-- Validate the IGS_AD_LOCATION type.
  FUNCTION orgp_val_loc_type(
  p_location_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	CURSOR c_lot IS
  	SELECT	closed_ind
  	FROM	IGS_AD_LOCATION_TYPE
  	WHERE	location_type = p_location_type
  	AND	closed_ind = 'Y';
  	v_other_detail	VARCHAR2(255);
  BEGIN
  	p_message_name := NULL;
  	FOR lot IN c_lot LOOP
  		p_message_name := 'IGS_OR_LOC_TYPE_CLOSED';
  		RETURN FALSE;
  	END LOOP;
  	RETURN TRUE;
  	EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END orgp_val_loc_type;
  --
  -- Retrofitted
  FUNCTION assp_val_loc_coord(
  p_location_type  IGS_AD_LOCATION_ALL.location_type%TYPE ,
  p_coord_person_id  IGS_AD_LOCATION_ALL.coord_person_id%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN  AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_loc_coord
  	-- Validate that the co-ordinator has been specified when the location
  	-- is an examination IGS_AD_LOCATION (ie; the system location type is 'EXAM_CTR').
  DECLARE
  	v_s_location_type		IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Fetch system location type.
  	v_s_location_type := IGS_OR_GEN_001.ORGP_GET_S_LOC_TYPE2(
  				p_location_type);
  	IF (NVL(v_s_location_type, '-1') = 'EXAM_CTR')	THEN
  		IF (p_coord_person_id IS NULL)	THEN
  			-- The co-ordinator must be set for an examination location.
  			p_message_name := 'IGS_AS_COORD_SET_EXAMLOC';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validation successful
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END assp_val_loc_coord;
  --
  -- Retrofitted
  FUNCTION assp_val_loc_ve_open(
  p_location_cd  IGS_AD_LOCATION_ALL.location_cd%TYPE ,
  p_location_type  IGS_AD_LOCATION_ALL.location_type%TYPE ,
  p_closed_ind  IGS_AD_LOCATION_ALL.closed_ind%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_loc_ve_open
  	-- Validate that an examination location can not be closed if any
  	-- related IGS_GR_VENUE records are not closed.
  DECLARE
  	v_s_location_type		IGS_AD_LOCATION.location_type%TYPE;
  	CURSOR c_ve IS
  	SELECT	'x'
  	FROM	IGS_GR_VENUE
  	WHERE	exam_location_cd	= p_location_cd AND
  		closed_ind		= 'N';
  	v_ve_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF (p_closed_ind = 'Y')	THEN
  		-- Fetch system location type.
  		v_s_location_type := IGS_OR_GEN_001.ORGP_GET_S_LOC_TYPE2(
  				p_location_type);
  		IF (NVL(v_s_location_type, '-1') = 'EXAM_CTR')	THEN
  			OPEN c_ve;
  			FETCH c_ve INTO v_ve_exists;
  			IF (c_ve%FOUND)	THEN
  				-- An examination location may not be
  				-- closed while open venue records exist.
  				CLOSE c_ve;
  				p_message_name := 'IGS_AS_EXAMLOC_NOTBE_CLOSED';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_ve;
  		END IF;
  	END IF;
  	-- Validation successful
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END assp_val_loc_ve_open;
  --
  -- Retrofitted
  FUNCTION assp_val_loc_ve_xist(
  p_location_cd  IGS_AD_LOCATION_ALL.location_cd%TYPE ,
  p_new_location_type  IGS_AD_LOCATION_ALL.location_type%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN  AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_loc_ve_xist
  	-- Validate that the exam location can not be changed to a non-exam
  	-- location once venue or other examination related tables are related.
  DECLARE
  	cst_exam_ctr		CONSTANT VARCHAR2(10) := 'EXAM_CTR';
  	v_s_location_type	IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
  	CURSOR c_ve IS
  	SELECT	'x'
  	FROM	IGS_GR_VENUE
  	WHERE	exam_location_cd	= p_location_cd;
  	v_ve_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Fetch system location type for p_new_location_type.
  	v_s_location_type := IGS_OR_GEN_001.ORGP_GET_S_LOC_TYPE2(
  			p_new_location_type);
  	IF (NVL(v_s_location_type, '-1') <> cst_exam_ctr)	THEN
  		OPEN c_ve;
  		FETCH c_ve INTO v_ve_exists;
  		IF (c_ve%FOUND)	THEN
  			-- An examination location may not be changed to a
  			-- non-exam location because venue details already exist.
  			CLOSE c_ve;
  			p_message_name := 'IGS_AS_EXAMLOC_NOTCHG';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_ve;
  	END IF;
  	-- Validation successful
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END assp_val_loc_ve_xist;

  --

END IGS_OR_VAL_LOC;

/
