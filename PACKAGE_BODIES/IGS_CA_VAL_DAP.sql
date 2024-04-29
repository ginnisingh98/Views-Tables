--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_DAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_DAP" AS
/* $Header: IGSCA13B.pls 115.3 2002/11/28 22:59:07 nsidana ship $ */
  -- Validate IGS_CA_DA_PAIR
  FUNCTION calp_val_dap_da(
  p_related_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	gv_other_detail		VARCHAR(255);
  BEGIN
  	-- Module to validate IGS_CA_DA_PAIR.related_dt_alias
  	-- closed indicator
  DECLARE
  	v_closed_ind	IGS_CA_DA.closed_ind%TYPE;
  	CURSOR	c_dt_alias (cp_dt_alias IGS_CA_DA.DT_ALIAS%TYPE) IS
  		SELECT	IGS_CA_DA.closed_ind
  		FROM	IGS_CA_DA
  		WHERE	IGS_CA_DA.DT_ALIAS = cp_dt_alias;
  BEGIN
  	p_message_name := NULL;
  	OPEN  c_dt_alias(p_related_dt_alias);
  	FETCH c_dt_alias INTO v_closed_ind;
  	IF (v_closed_ind = 'N') THEN
  		CLOSE c_dt_alias;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_dt_alias;
  		p_message_name := 'IGS_CA_DTALIAS_CLOSED';
  		RETURN FALSE;
  	END IF;
    END;
  END calp_val_dap_da;
END IGS_CA_VAL_DAP;

/
