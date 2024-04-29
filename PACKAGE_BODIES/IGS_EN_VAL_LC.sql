--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_LC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_LC" AS
/* $Header: IGSEN47B.pls 115.3 2002/11/29 00:01:06 nsidana ship $ */
  --
  -- To validate the delete of a language code record
  FUNCTION enrp_val_lc_del(
  p_language_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE
  	v_person_id	IGS_PE_PERSON.person_id%TYPE;
  	CURSOR	gc_person_statistics(
  			cp_language_cd IGS_PE_LANGUAGE_CD.language_cd%TYPE) IS
  		SELECT	person_id
  		FROM	IGS_PE_STATISTICS
  		WHERE	NVL(home_language_cd, 'NULL') = cp_language_cd;
  BEGIN
  	-- validate the deletion of IGS_PE_LANGUAGE_CD record
  	p_message_name := null;
  	IF(p_language_cd IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN gc_person_statistics(
  			p_language_cd);
  	FETCH gc_person_statistics INTO v_person_id;
  	IF(gc_person_statistics%FOUND) THEN
  		CLOSE gc_person_statistics;
  		p_message_name := 'IGS_EN_NOTDEL_LANGCD';
  		RETURN FALSE;
  	ELSE
  		CLOSE gc_person_statistics;
  		RETURN TRUE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_LC.enrp_val_lc_del');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;


  END;
  END enrp_val_lc_del;
  --
  -- Validate the language government language code.
  FUNCTION enrp_val_lang_govt(
  p_govt_language_cd IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE
  	gv_closed_ind		IGS_PE_GOV_LANG_CD.closed_ind%TYPE;
  	CURSOR	gc_govt_lang_cd(
  			cp_govt_lang_cd IGS_PE_LANGUAGE_CD.govt_language_cd%TYPE) IS
  		SELECT	IGS_PE_GOV_LANG_CD.closed_ind
  		FROM	IGS_PE_GOV_LANG_CD
  		WHERE	IGS_PE_GOV_LANG_CD.govt_language_cd = cp_govt_lang_cd;
  BEGIN
  	-- This module validates if IGS_PE_GOV_LANG_CD.govt_language_cd
  	-- is closed
  	p_message_name := null;
  	OPEN gc_govt_lang_cd(
  			p_govt_language_cd);
  	FETCH gc_govt_lang_cd INTO gv_closed_ind;
  	IF (gc_govt_lang_cd%FOUND) THEN
  		IF (gv_closed_ind = 'Y' ) THEN
  			CLOSE gc_govt_lang_cd;
  			p_message_name := 'IGS_EN_NOTDEL_LANGCD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE gc_govt_lang_cd;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_LC.enrp_val_lang_govt');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_lang_govt;
END IGS_EN_VAL_LC;

/
