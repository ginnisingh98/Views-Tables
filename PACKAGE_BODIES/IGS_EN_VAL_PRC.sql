--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PRC" AS
/* $Header: IGSEN56B.pls 115.3 2002/11/29 00:03:48 nsidana ship $ */
  --
  -- Validate the permanent resident government permanent resident code.
  FUNCTION enrp_val_prc_govt(
  p_govt_perm_resident_cd IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	gv_other_detail		VARCHAR(255);
  	gv_closed_ind		IGS_PE_GOV_PER_RESCD.closed_ind%TYPE;
  	CURSOR	gc_gpr_cd(
  		  cp_gpr_cd IGS_PE_GOV_PER_RESCD.govt_perm_resident_cd%TYPE) IS
  		SELECT	IGS_PE_GOV_PER_RESCD.closed_ind
  		FROM	IGS_PE_GOV_PER_RESCD
  		WHERE	IGS_PE_GOV_PER_RESCD.govt_perm_resident_cd = cp_gpr_cd;
  BEGIN
  	-- This module validates if IGS_PE_GOV_PER_RESCD.govt_perm_resident_cd
  	-- is closed
  	p_message_name := null;
  	OPEN gc_gpr_cd(p_govt_perm_resident_cd);
  	FETCH gc_gpr_cd INTO gv_closed_ind;
  	IF (gc_gpr_cd%FOUND) THEN
  		IF (gv_closed_ind = 'Y' ) THEN
  			CLOSE gc_gpr_cd;
  			p_message_name := 'IGS_EN_GOV_PRM_RES_CD_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE gc_gpr_cd;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PRC.enrp_val_prc_govt');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_prc_govt;
END IGS_EN_VAL_PRC;

/
