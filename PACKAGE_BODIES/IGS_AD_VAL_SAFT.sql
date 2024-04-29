--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_SAFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_SAFT" AS
/* $Header: IGSAD68B.pls 115.4 2002/11/28 21:39:17 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_am_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_fs_closed"
  -------------------------------------------------------------------------------------------


  --
  -- Validate if IGS_FI_FUND_SRC.funding_source is closed.
  FUNCTION crsp_val_fs_closed(
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_fs_closed
  	-- Description: Validate if IGS_FI_FUND_SRC.funding_source is closed.
  DECLARE
  	v_fs_rec	IGS_FI_FUND_SRC.closed_ind%TYPE;
  	CURSOR	c_fs IS
  		SELECT	fs.closed_ind
  		FROM	IGS_FI_FUND_SRC	fs
  		WHERE	fs.funding_source = p_funding_source;
  BEGIN
  	p_message_name := null;
  	OPEN c_fs;
  	FETCH c_fs INTO v_fs_rec;
  	IF (c_fs%FOUND) THEN
  		IF (v_fs_rec = 'Y') THEN
			p_message_name := 'IGS_PS_FUND_SOURCE_CLOSED';
  			CLOSE c_fs;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_fs;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_fs%ISOPEN) THEN
  		CLOSE c_fs;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SAFT.crsp_val_fs_closed');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_fs_closed;
  --
  -- Validate target AOU codes are active and at the local INSTITUTION.
  FUNCTION admp_val_trgt_aou(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_trgt_aou
  	-- This module validates the organisational UNIT is from the local
  	-- INSTITUTION in not inactive.
  DECLARE
  	cst_inactive	CONSTANT	VARCHAR2(10) := 'INACTIVE';
  	cst_active	CONSTANT	VARCHAR2(10) := 'ACTIVE';
  	v_institution_cd		IGS_OR_UNIT.institution_cd%TYPE;
  	v_dummy				VARCHAR2(1);
  	CURSOR c_ou_os IS
  		SELECT	ou.institution_cd
  		FROM	IGS_OR_UNIT			ou,
  			IGS_OR_STATUS			os
  		WHERE	ou.org_unit_cd			= p_org_unit_cd AND
  			ou.start_dt			= p_ou_start_dt AND
  			os.org_status			= ou.org_status AND
  			os.s_org_status			<> cst_inactive;
  	CURSOR c_ins_ist (cp_institution_cd	IGS_OR_UNIT.institution_cd%TYPE) IS
  		SELECT	'X'
  		FROM	IGS_OR_INSTITUTION			ins,
  			IGS_OR_INST_STAT		ist
  		WHERE	ins.institution_cd		= cp_institution_cd AND
  			ins.local_institution_ind 	= 'Y' AND
  			ins.institution_status		= ist.institution_status AND
  			ist.s_institution_status 	= cst_active;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_ou_os;
  	FETCH c_ou_os INTO v_institution_cd;
  	IF c_ou_os%NOTFOUND THEN
  		CLOSE c_ou_os;
		p_message_name := 'IGS_AD_ORGUNIT_NOT_ACTIVE';
  		RETURN FALSE;
  	ELSE
  		CLOSE c_ou_os;
  		OPEN c_ins_ist(v_institution_cd);
  		FETCH c_ins_ist INTO v_dummy;
  		IF c_ins_ist%NOTFOUND THEN
  			CLOSE c_ins_ist;
			p_message_name := 'IGS_AD_ORGUNIT_NOTBELONG_INST';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_ins_ist;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ou_os%ISOPEN THEN
  			CLOSE c_ou_os;
  		END IF;
  		IF c_ins_ist%ISOPEN THEN
  			CLOSE c_ins_ist;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	   FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SAFT.admp_val_trgt_aou');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_trgt_aou;
  --
  -- Validate if course type group is closed.
  FUNCTION crsp_val_ctg_closed(
  p_course_type_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- crsp_val_ctg_closed
  	-- This module checks if a course type group is open.
  DECLARE
  	v_closed_ind		IGS_PS_TYPE_GRP.closed_ind%TYPE;
  	CURSOR c_ctg IS
  		SELECT 	ctg.closed_ind
  		FROM	IGS_PS_TYPE_GRP		ctg
  		WHERE	ctg.course_type_group_cd	= p_course_type_group_cd;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_ctg;
  	FETCH c_ctg INTO v_closed_ind;
  	IF c_ctg%FOUND THEN
  		CLOSE c_ctg;
  		IF v_closed_ind = 'Y' THEN
			p_message_name := 'IGS_PS_PRGTYPE_GRP_CLOSED';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_ctg;
  	END IF;
  	RETURN TRUE ;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ctg%ISOPEN THEN
  			CLOSE c_ctg;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SAFT.crsp_val_ctg_closed');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_ctg_closed;
  --
  -- Validate if unit internal course level is closed.
  FUNCTION crsp_val_uicl_closed(
  p_unit_int_course_level_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- crsp_val_uicl_closed
  	-- This module checks if a course type group is open.
  DECLARE
  	v_closed_ind		IGS_PS_UNIT_INT_LVL.closed_ind%TYPE;
  	CURSOR c_uicl IS
  		SELECT 	uicl.closed_ind
  		FROM	IGS_PS_UNIT_INT_LVL		uicl
  		WHERE	uicl.unit_int_course_level_cd	= p_unit_int_course_level_cd;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_uicl;
  	FETCH c_uicl INTO v_closed_ind;
  	IF c_uicl%FOUND THEN
  		CLOSE c_uicl;
  		IF v_closed_ind = 'Y' THEN
			p_message_name := 'IGS_PS_PRGTYPE_GRP_CLOSED';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_uicl;
  	END IF;
  	RETURN TRUE ;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uicl%ISOPEN THEN
  			CLOSE c_uicl;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	   FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SAFT.crsp_val_uicl_closed');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_uicl_closed;
END IGS_AD_VAL_SAFT;

/
