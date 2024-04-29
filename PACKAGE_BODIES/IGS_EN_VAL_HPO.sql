--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_HPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_HPO" AS
/* $Header: IGSEN45B.pls 115.3 2002/11/29 00:00:22 nsidana ship $ */
  --
  -- Validate the government hecs payment option closed ind
  FUNCTION enrp_val_hpo_govt(
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  	v_ghpo_ind		IGS_FI_GOV_HEC_PA_OP.closed_ind%TYPE;
  	CURSOR	c_ghpo_ind IS
  		SELECT 	closed_ind
  		FROM	IGS_FI_GOV_HEC_PA_OP
  		WHERE	govt_hecs_payment_option   = p_govt_hecs_payment_option;
  BEGIN
  	-- This module validates whether a IGS_FI_HECS_PAY_OPTN
  	-- record could be mapped to a IGS_FI_GOV_HEC_PA_OP
  	-- record
  	OPEN  c_ghpo_ind;
  	FETCH c_ghpo_ind INTO v_ghpo_ind;
  	-- if a record doesn't exist, then it could
  	-- be created and a IGS_FI_HECS_PAY_OPTN record
  	-- could be mapped to it
  	IF (c_ghpo_ind%NOTFOUND) THEN
  		CLOSE c_ghpo_ind;
  		p_message_name := null;
  		RETURN TRUE;
  	ELSE
  		IF (v_ghpo_ind = 'N') THEN
  			-- this record isn't closed off
  			-- so hecs_paymetn_option records
  			-- can be mapped to it
  			CLOSE c_ghpo_ind;
  			p_message_name := null;
  			RETURN TRUE;
  		ELSE
  			-- this record is closed, so no
  			-- records can be mapped to it
  			CLOSE c_ghpo_ind;
  			p_message_name := 'IGS_EN_GOVT_HECS_PAY_OPT_CLOS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_HPO.enrp_val_hpo_govt');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_hpo_govt;
END IGS_EN_VAL_HPO;

/
