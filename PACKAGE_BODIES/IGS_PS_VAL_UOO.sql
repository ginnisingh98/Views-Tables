--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_UOO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_UOO" AS
/* $Header: IGSPS65B.pls 120.1 2006/01/31 01:52:34 sommukhe noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sommukhe    12-JAN-2006     Bug #4926548, In crsp_val_uoo_contact for cursor replaced IGS_PE_PERSON with HZ_PARTIES
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed
  --avenkatr    30-AUG-2001     Bug No 1956374. Removed procedure "crsp_val_crs_ci"
  -------------------------------------------------------------------------------------------
  --

  -- Validate IGS_PS_COURSE IGS_AD_LOCATION code.
  FUNCTION crsp_val_loc_cd(
  p_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_location_closed_ind	IGS_AD_LOCATION.closed_ind%TYPE;
  	v_location_type		IGS_AD_LOCATION.location_type%TYPE;
  	v_s_location_type		IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
  	CURSOR 	c_location_cd(
  			cp_location_cd		IGS_AD_LOCATION.location_cd%TYPE) IS
  		SELECT 	IGS_AD_LOCATION.closed_ind,
  			location_type
  		FROM	IGS_AD_LOCATION
  		WHERE	location_cd = cp_location_cd;
  	CURSOR 	c_location_type(
  			cp_location_type	IGS_AD_LOCATION_TYPE.location_type%TYPE) IS
  		SELECT 	s_location_type
  		FROM	IGS_AD_LOCATION_TYPE
  		WHERE	location_type = cp_location_type;
  BEGIN
  	-- This module based on the parameter performs validations
  	-- for for the IGS_AD_LOCATION code within the CS and P subsystem
  	p_message_name := NULL;
  	v_location_closed_ind := NULL;
  	-- Test the value of closed indicator
  	OPEN  c_location_cd(
  			p_location_cd);
  	FETCH c_location_cd INTO v_location_closed_ind,
  				 v_location_type;
         	CLOSE c_location_cd;
  	IF (v_location_closed_ind IS NULL) THEN
  		RETURN TRUE;
  	ELSE
  		IF(v_location_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_PS_LOC_CODE_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Test the value of system IGS_AD_LOCATION type
  	OPEN  c_location_type(
  			v_location_type);
  	FETCH c_location_type INTO v_s_location_type;
         	CLOSE c_location_type;
  	IF (NVL(v_s_location_type,'NULL') <> 'CAMPUS') THEN
  		p_message_name := 'IGS_PS_LOC_NOT_TYPE_CAMPUS';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;

  END crsp_val_loc_cd;
  --
  -- Validate the IGS_PS_UNIT class for IGS_PS_UNIT offering option.
  FUNCTION crsp_val_uoo_uc(
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_AS_UNIT_CLASS.closed_ind%TYPE;
  	CURSOR	c_unit_cls_closed_ind IS
  	SELECT	closed_ind
  	FROM	IGS_AS_UNIT_CLASS
  	WHERE	unit_class = p_unit_class AND
  		closed_ind = 'Y';
  BEGIN
  	OPEN c_unit_cls_closed_ind;
  	FETCH c_unit_cls_closed_ind INTO v_closed_ind;
  	--- If a record was found, then return TRUE, else return FALSE
  	IF c_unit_cls_closed_ind%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_unit_cls_closed_ind;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_UNIT_CLASS_CLOSED';
  		CLOSE c_unit_cls_closed_ind;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UOo.crsp_val_uoo_uc');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_uoo_uc;
  --

  --
  -- Validate the IGS_PS_UNIT contact for IGS_PS_UNIT offering option is a staff member.
  FUNCTION crsp_val_uoo_contact(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN
  DECLARE
  	v_staff_member_ind	IGS_PE_PERSON.staff_member_ind%TYPE;
  	CURSOR	c_staff_member_ind IS
  		SELECT  IGS_EN_GEN_003.Get_Staff_Ind(party_id) staff_member_ind
  		FROM    hz_parties
  		WHERE   party_id = p_person_id;
  BEGIN
  	OPEN 	c_staff_member_ind;
  	FETCH	c_staff_member_ind INTO v_staff_member_ind;
  	-- this validates whether the IGS_PE_PERSON is a staff
  	-- member or not
  	IF (v_staff_member_ind = 'Y') THEN
  		CLOSE c_staff_member_ind;
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_staff_member_ind;
  		p_message_name := 'IGS_PS_UNIT_CONTATC_UOP';
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UOo.crsp_val_uoo_contact');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END;
  END crsp_val_uoo_contact;
  --
  -- Validate IGS_PS_UNIT Offering Option is active.
  FUNCTION CRSP_VAL_UOO_INACTIV(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	--- Check for an INACTIVE IGS_PS_UNIT version
  	IF IGS_PS_VAL_UNIT.crsp_val_iud_uv_dtl(p_unit_cd,
  		p_version_number,
  		p_message_name) = FALSE THEN
  		RETURN FALSE;
  	END IF;
  	--- Check that the calendar type is not closed.
  	-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UOo.crsp_val_uo_cal_type
  	IF IGS_AS_VAL_UAI.crsp_val_uo_cal_type(p_cal_type,
  		p_message_name) = FALSE THEN
  		RETURN FALSE;
  	END IF;
  	--- Check for active calendar instance.
  	IF IGS_as_VAL_uai.crsp_val_crs_ci(p_cal_type,
  		p_ci_sequence_number,
  		p_message_name) = FALSE THEN
  		RETURN FALSE;
  	END IF;
  	--- Check for closed IGS_AD_LOCATION code.
  	IF IGS_PS_VAL_UOo.crsp_val_loc_cd(p_location_cd,
  		p_message_name) = FALSE THEN
  		RETURN FALSE;
  	END IF;
  	--- Check for closed IGS_PS_UNIT class.
  	IF IGS_PS_VAL_UOo.crsp_val_uoo_uc(p_unit_class,
  		p_message_name) = FALSE THEN
  		RETURN FALSE;
  	END IF;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	        FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UOo.crsp_val_uoo_inactiv');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_uoo_inactiv;
  --

END IGS_PS_VAL_UOo;

/
