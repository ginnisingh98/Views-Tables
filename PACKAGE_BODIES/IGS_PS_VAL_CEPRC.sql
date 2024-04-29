--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CEPRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CEPRC" AS
/* $Header: IGSPS18B.pls 120.1 2006/01/31 01:54:15 sommukhe noship $ */

/***********************************************************************************************
Created By:
Date Created By:
Purpose:

Known limitations,enhancements,remarks:

Change History
Who           When       What
sommukhe   16-Jan-2006   Bug #4926548 changed the cursor definition for c_uss in the function  crsp_val_ceprc_coous
                         and added cursor c_uss1
sarakshi   20-Apr-2002   Removed the function crsp_val_ceprc_uref as a part of bug#2146753
                         which validates the reference type uniqueness across program offering
                         option
********************************************************************************************** */

  -- Validate unique combination of IGS_PS_UNIT set and IGS_PS_COURSE offerning option
  FUNCTION crsp_val_ceprc_uniq(
  p_coo_id IN NUMBER ,
  p_reference_cd_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
	-- crsp_val_ceprc_uniq
  	-- Validate that the IGS_PS_UNIT set is unique in combination with the IGS_PS_COURSE
  	-- offering option.
  DECLARE
  	v_dummy			VARCHAR2(1);
  	CURSOR c_ceprc IS
  		SELECT	'X'
  		FROM	IGS_PS_ENT_PT_REF_CD ceprc
  		WHERE	ceprc.coo_id			= p_coo_id AND
  			NVL(ceprc.unit_set_cd, 'NONE') 	= NVL(p_unit_set_cd, 'NONE') AND
  			NVL(ceprc.us_version_number, 0)	= NVL(p_us_version_number, 0) AND
  			ceprc.reference_cd_type		= p_reference_cd_type AND
  			ceprc.sequence_number		<> p_sequence_number;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_ceprc;
  	FETCH c_ceprc INTO v_dummy;
  	IF (c_ceprc%FOUND) THEN
  		CLOSE c_ceprc;
  		p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  		RETURN FALSE;
  	ELSE
  		CLOSE c_ceprc;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_ceprc%ISOPEN) THEN
  			CLOSE c_ceprc;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  END crsp_val_ceprc_uniq;

  --obsoleted the function crsp_val_ceprc_uref, bug#2146753

  -- Validate crs  entry point IGS_PS_UNIT set against crs offer option IGS_PS_UNIT set
  FUNCTION crsp_val_ceprc_coous(
  p_coo_id IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 AS
  BEGIN
	-- crsp_val_ceprc_coous
  	-- This module validates the IGS_PS_UNIT set of the IGS_PS_COURSE entry
  	-- point of reference code can be used for this IGS_PS_COURSE
  	-- offering option.
  DECLARE
  	v_uss_found		VARCHAR2(1);
  	cst_false		CONSTANT VARCHAR2(5) := 'FALSE';
  	cst_true		CONSTANT VARCHAR2(5) := 'TRUE';
  	cst_active		CONSTANT VARCHAR2(10) := 'ACTIVE';
	  CURSOR	c_uss IS
	  SELECT 'X'
	    FROM IGS_PS_OFR_UNIT_SET cous,IGS_PS_OFR_OPT coo,igs_en_unit_set_stat uss1,IGS_EN_UNIT_SET_ALL US
	    WHERE coo.coo_id  =  p_coo_id
	    AND us.version_number = p_us_version_number
	    AND us.unit_set_cd = p_unit_set_cd
	    AND us.expiry_dt   IS NULL
	    AND coo.course_cd = cous.course_cd
	    AND coo.version_number = cous.crv_version_number
	    AND coo.CAL_TYPE = cous.CAL_TYPE
	    AND us.unit_set_cd = cous.unit_set_cd
	    AND us.version_number = cous.us_version_number
	    AND us.unit_set_status = uss1.unit_set_status
	    AND uss1.s_unit_set_status =cst_active
	    AND NOT EXISTS (SELECT   1
			    FROM   IGS_PS_OF_OPT_UNT_ST coous
				      WHERE  coous.course_cd = cous.course_cd
				      AND coous.crv_version_number = cous.crv_version_number
				      AND coous.CAL_TYPE = cous.CAL_TYPE
				      AND coous.unit_set_cd = cous.unit_set_cd
				      AND coous.us_version_number = cous.us_version_number
				     );
	CURSOR	c_uss1 IS
	SELECT 'X'
	FROM IGS_PS_OF_OPT_UNT_ST coous,IGS_EN_UNIT_SET_ALL US,igs_en_unit_set_stat uss1
	WHERE coous.coo_id  = p_coo_id
	AND us.version_number = p_us_version_number
	AND us.unit_set_cd = p_unit_set_cd
	AND us.expiry_dt   IS NULL
	AND us.unit_set_cd = coous.unit_set_cd
	AND us.version_number = coous.us_version_number
	AND us.unit_set_status = uss1.unit_set_status
	AND uss1.s_unit_set_status = cst_active;
  BEGIN
  	p_message_name := NULL;
        OPEN c_uss;
  	FETCH c_uss INTO v_uss_found;
	IF (c_uss%FOUND) THEN
	  CLOSE c_uss;
	  RETURN cst_true;
	ELSE
	  OPEN c_uss1;
	  FETCH c_uss1 INTO v_uss_found;
           IF (c_uss1%FOUND) THEN
	     CLOSE c_uss1;CLOSE c_uss;
	     RETURN cst_true;
	   ELSE
	     p_message_name := 'IGS_PS_UNITSET_NOT_VALID';
             CLOSE c_uss1;CLOSE c_uss;
	     RETURN cst_false;
	   END IF;
	 CLOSE c_uss;   RETURN cst_true;
	 END IF;

  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_uss%ISOPEN) THEN
  			CLOSE c_uss;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  END crsp_val_ceprc_coous;
END IGS_PS_VAL_CEPRC;

/
