--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_CC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_CC" AS
/* $Header: IGSCO05B.pls 115.4 2002/11/28 23:03:56 nsidana ship $ */
  -- Validate update of correspondence category closed indicator.
  FUNCTION corp_val_cc_clsd_upd(
  p_correspondence_cat IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS

  BEGIN	-- corp_val_cc_clsd_upd
  	-- Validate update of the IGS_CO_CAT.closed_ind.
  DECLARE
  	v_check		CHAR;
  	v_ret_val	BOOLEAN	DEFAULT TRUE;
  	CURSOR c_ccm IS
  		SELECT	'x'
  		FROM	IGS_CO_CAT_MAP
  		WHERE	correspondence_cat = p_correspondence_cat AND
  			dflt_cat_ind = 'Y';
  BEGIN
  	p_message_name   := null;
  	IF (p_closed_ind = 'Y') THEN
  		-- Validate if the correspondence category is the default for an admission
  		-- category.
  		OPEN c_ccm;
  		FETCH c_ccm INTO v_check;
  		IF (c_ccm%FOUND) THEN
  			p_message_name   := 'IGS_CO_CORCAT_CANNOT_CLOSE';
  			v_ret_val := FALSE;
  		END IF;
  		CLOSE c_ccm;
  	END IF;
  	RETURN v_ret_val;
  END;

  END corp_val_cc_clsd_upd;
END IGS_CO_VAL_CC;

/
