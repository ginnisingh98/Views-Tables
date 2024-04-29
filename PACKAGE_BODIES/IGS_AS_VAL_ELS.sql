--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_ELS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_ELS" AS
/* $Header: IGSAS18B.pls 115.6 2002/11/28 22:43:57 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------

  --
  -- Retrofitted
  FUNCTION assp_val_ve_lot(
  p_exam_location_cd  IGS_GR_VENUE_ALL.exam_location_cd%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_ve_lot
  	-- Validate s_loc_type = 'EXAM_CTR'.
  DECLARE
  	CURSOR	c_lot IS
  	SELECT	'x'
  	FROM	IGS_AD_LOCATION_TYPE	lot,
  		IGS_AD_LOCATION	loc
  	WHERE	lot.location_type	= loc.location_type AND
  		loc.location_cd		= p_exam_location_cd AND
  		lot.s_location_type <> 'EXAM_CTR';
  	v_lot_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	OPEN c_lot;
  	FETCH c_lot INTO v_lot_exists;
  	IF (c_lot%FOUND) THEN
  		CLOSE c_lot;
  		-- The system location type must be specified as 'EXAM_CTR'.
  		P_MESSAGE_NAME := 'IGS_AS_SYS_LOCTYPE_EXAM_CTR';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_lot;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	  	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
	  	FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ELS.assp_val_ve_lot');
		IGS_GE_MSG_STACK.ADD;
  END assp_val_ve_lot;
  --

  --
  -- Validate location closed indicator.
  FUNCTION orgp_val_loc_closed(
  p_location_cd IN IGS_AD_LOCATION_ALL.location_cd%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN 	-- orgp_val_loc_closed
  	-- Validate the location closed indicator
  DECLARE
  	CURSOR c_loc(
  			cp_location_cd	IGS_AD_LOCATION.location_cd%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AD_LOCATION
  		WHERE	location_cd = cp_location_cd;
  	v_loc_rec			c_loc%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- Cursor handling
  	OPEN c_loc(
  			p_location_cd);
  	FETCH c_loc INTO v_loc_rec;
  	IF c_loc%NOTFOUND THEN
  		CLOSE c_loc;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_loc;
  	IF (v_loc_rec.closed_ind = cst_yes) THEN
  		P_MESSAGE_NAME := 'IGS_OR_LOCATION_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	  	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ELS.orgp_val_loc_closed');
		IGS_GE_MSG_STACK.ADD;

  END orgp_val_loc_closed;
END IGS_AS_VAL_ELS;

/
