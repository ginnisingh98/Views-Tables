--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CRFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CRFC" AS
 /* $Header: IGSPS32B.pls 115.3 2002/11/29 03:01:38 nsidana ship $ */
  --
  -- Validate the reference code type
  FUNCTION crsp_val_ref_cd_type(
  p_reference_cd_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_GE_REF_CD_TYPE.closed_ind%TYPE;
  	CURSOR	c_reference_cd_type IS
   		SELECT 	closed_ind
  		FROM	IGS_GE_REF_CD_TYPE
  		WHERE	reference_cd_type = p_reference_cd_type;
  BEGIN
  	OPEN c_reference_cd_type;
  	FETCH c_reference_cd_type INTO v_closed_ind;
  	IF c_reference_cd_type%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_reference_cd_type;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_reference_cd_type;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_REFCD_TYPE_CLOSED';
  		CLOSE c_reference_cd_type;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRFC.crsp_val_ref_cd_type');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_ref_cd_type;
  --
  -- Validate that only one open reference code type exists
  FUNCTION crsp_val_crfc_rct(
  p_course_cd IN IGS_PS_REF_CD.course_cd%TYPE ,
  p_version_number IN IGS_PS_REF_CD.version_number%TYPE ,
  p_reference_cd_type IN VARCHAR2 ,
  p_reference_cd IN IGS_PS_REF_CD.reference_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_crfc_rct
  	-- This module validates whether an open Reference Code Type
  	-- already exists for the System Reference Code Type.
  DECLARE
  	v_s_reference_cd_type	IGS_GE_REF_CD_TYPE.s_reference_cd_type%TYPE;
  	v_count			NUMBER DEFAULT 0;
  	CURSOR	c_rct IS
  		SELECT	rct.s_reference_cd_type
  		FROM	IGS_GE_REF_CD_TYPE	rct
  		WHERE	rct.reference_cd_type = p_reference_cd_type;
  	CURSOR c_crfc_rct (
  		cp_s_reference_cd_type		IGS_GE_REF_CD_TYPE.s_reference_cd_type%TYPE) IS
  		SELECT	COUNT(*)
  		FROM	IGS_PS_REF_CD	crfc,
  			IGS_GE_REF_CD_TYPE	rct
  		WHERE	crfc.course_cd		= p_course_cd AND
  			crfc.version_number	= p_version_number AND
  			(crfc.reference_cd_type	<> p_reference_cd_type OR
  			crfc.reference_cd	<> p_reference_cd) AND
  			rct.reference_cd_type	= crfc.reference_cd_type AND
  			rct.s_reference_cd_type	= cp_s_reference_cd_type AND
  			rct.closed_ind		= 'N';
  BEGIN
  	OPEN c_rct;
  	FETCH c_rct INTO v_s_reference_cd_type;
  	CLOSE c_rct;
  	OPEN c_crfc_rct(v_s_reference_cd_type);
  	FETCH c_crfc_rct INTO v_count;
  	CLOSE c_crfc_rct;
  	IF v_count > 0 THEN
  		p_message_name := 'IGS_PS_OPEN_REFCDTYPE_EXIST';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_rct%ISOPEN) THEN
  			CLOSE c_rct;
  		END IF;
  		IF (c_crfc_rct%ISOPEN) THEN
  			CLOSE c_crfc_rct;
  		END IF;
  		APP_EXCEPTION.RAISE_EXCEPTION;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRFC.crsp_val_crfc_rct');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crfc_rct;
END IGS_PS_VAL_CRFC;

/
