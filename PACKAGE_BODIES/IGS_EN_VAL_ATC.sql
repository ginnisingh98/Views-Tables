--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_ATC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_ATC" AS
/* $Header: IGSEN24B.pls 115.3 2002/11/28 23:54:55 nsidana ship $ */

  --
  -- Validate the aborig/torres government aborig/torres code.
  FUNCTION enrp_val_atc_govt(
  p_govt_aborig_torres_cd IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	gv_other_detail		VARCHAR(255);
  	gv_closed_ind		IGS_PE_GOV_ABRGRESCD.closed_ind%TYPE;
  	CURSOR	gc_gat_cd(
  		  cp_gat_cd IGS_PE_GOV_ABRGRESCD.govt_aborig_torres_cd%TYPE) IS
  		SELECT	IGS_PE_GOV_ABRGRESCD.closed_ind
  		FROM	IGS_PE_GOV_ABRGRESCD
  		WHERE	IGS_PE_GOV_ABRGRESCD.govt_aborig_torres_cd = cp_gat_cd;
  BEGIN
  	-- This module validates if IGS_PE_GOV_ABRGRESCD.govt_aborig_torres_cd
  	-- is closed
  	p_message_name := null;
  	OPEN gc_gat_cd(p_govt_aborig_torres_cd);
  	FETCH gc_gat_cd INTO gv_closed_ind;
  	IF (gc_gat_cd%FOUND) THEN
  		IF (gv_closed_ind = 'Y' ) THEN
  			CLOSE gc_gat_cd;
  			p_message_name := 'IGS_EN_GOV_AB/TORRES_CD_CLOSE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE gc_gat_cd;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_ATC.enrp_val_atc_govt');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_atc_govt;
END IGS_EN_VAL_ATC;

/
