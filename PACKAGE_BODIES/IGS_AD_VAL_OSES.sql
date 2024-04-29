--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_OSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_OSES" AS
/* $Header: IGSAD65B.pls 120.0 2005/06/01 18:04:32 appldev noship $ */

  --
  -- Validate that at least one of subject_cd or subject_desc is entered
  FUNCTION ADMP_VAL_OSES_SUBJ(
  p_subject_cd IN VARCHAR2 ,
  p_subject_desc IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_oses_subj
  	-- This module validates IGS_AD_OS_SEC_EDU_SUB.subject_cd and
  	-- IGS_AD_OS_SEC_EDU_SUB.subject_desc to ensure that at least one
  	-- of these is entered.
  DECLARE
  BEGIN
  	p_message_name := null;
  	IF 	p_subject_cd	IS NULL AND
  		p_subject_desc	IS NULL THEN
		p_message_name := 'IGS_AD_ONE_SUBCD_SUBDESC';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_OSES.admp_val_oses_subj');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_oses_subj;
  --
  -- Validate tertiary edu unit attempt result type.
  FUNCTION admp_val_teua_sret(
  p_result_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_teua_sret
  	-- validate the IGS_AD_TER_EDU_UNI_AT result_type
  DECLARE
  	v_check		CHAR;
  	CURSOR c_srt IS
  		SELECT	'x'
  		FROM	IGS_LOOKUP_VALUES
  		WHERE	lookup_type = 'RESULT_TYPE'
		  AND   lookup_code = p_result_type;
  BEGIN
  	p_message_name := null;
  	IF p_result_type IS NULL THEN
  		-- This is an error, but will be handled outside this module
  		RETURN TRUE;
  	END IF;
  	IF p_result_type = 'UNKNOWN' THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_srt;
  	FETCH c_srt INTO v_check;
  	IF (c_srt%NOTFOUND) THEN
  		CLOSE c_srt;
		p_message_name := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_srt;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_OSES.admp_val_teua_sret');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_teua_sret;
END IGS_AD_VAL_OSES;

/
