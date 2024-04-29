--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_GHPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_GHPO" AS
/* $Header: IGSEN42B.pls 115.3 2002/11/28 23:59:25 nsidana ship $ */
  --
  -- Validate update of government hecs payment option
  FUNCTION enrp_val_ghpo_upd(
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  	v_hpo_rec		IGS_FI_HECS_PAY_OPTN%ROWTYPE;
  	CURSOR	c_hpo_rec IS
  		SELECT 	*
  		FROM	IGS_FI_HECS_PAY_OPTN
  		WHERE	govt_hecs_payment_option   = p_govt_hecs_payment_option AND
  			closed_ind	 	   = 'N';
  BEGIN
  	-- This module validates that there are no
  	-- IGS_FI_HECS_PAY_OPTN records open when
  	-- closing a IGS_FI_GOV_HEC_PA_OP record
  	IF (p_closed_ind = 'Y') THEN
  		OPEN  c_hpo_rec;
  		FETCH c_hpo_rec INTO v_hpo_rec;
  		IF (c_hpo_rec%FOUND) THEN
  			-- if there are IGS_FI_HECS_PAY_OPTN records
  			-- that have been found and which aren't yet
  			-- closed (ie. closed_ind = 'N')
  			CLOSE c_hpo_rec;
  			p_message_name := 'IGS_EN_CANT_CLOS_GOVT_HECS';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_hpo_rec;
  	END IF;
  	-- the p_closed_ind = 'N'
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_GHPO.enrp_val_ghpo_upd');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_ghpo_upd;
END IGS_EN_VAL_GHPO;

/
