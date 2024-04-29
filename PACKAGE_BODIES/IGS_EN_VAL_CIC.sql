--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_CIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_CIC" AS
/* $Header: IGSEN29B.pls 115.3 2002/11/28 23:56:15 nsidana ship $ */


  --
  -- Validate the citizenship government citizenship code.
  FUNCTION enrp_val_cic_govt(
  p_govt_citizenship_cd IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	gv_other_detail		VARCHAR(255);
  	gv_closed_ind		IGS_PE_GOVCITIZEN_CD.closed_ind%TYPE;
  	CURSOR	gc_govt_ctznshp_cd(
  		  cp_govt_ctznshp_cd IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE) IS
  		SELECT	IGS_PE_GOVCITIZEN_CD.closed_ind
  		FROM	IGS_PE_GOVCITIZEN_CD
  		WHERE	IGS_PE_GOVCITIZEN_CD.govt_citizenship_cd =
  			cp_govt_ctznshp_cd;
  BEGIN
  	-- This module validates if IGS_PE_GOVCITIZEN_CD.govt_citizenship_cd
  	-- is closed
  	p_message_name := null;
  	OPEN gc_govt_ctznshp_cd(
  			p_govt_citizenship_cd);
  	FETCH gc_govt_ctznshp_cd INTO gv_closed_ind;
  	IF (gc_govt_ctznshp_cd%FOUND) THEN
  		IF (gv_closed_ind = 'Y' ) THEN
  			CLOSE gc_govt_ctznshp_cd;
  			p_message_name := 'IGS_EN_GOV_CITIZEN_CD_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE gc_govt_ctznshp_cd;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_CIC.enrp_val_cic_govt');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_cic_govt;
END IGS_EN_VAL_CIC;

/
