--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_OC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_OC" AS
/* $Header: IGSCO16B.pls 115.6 2003/04/08 09:16:50 pkpatel ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed.
  --pkpatel     8-APR-2003      Bug 2804863
  --                            Modified procedure genp_val_prsn_id
  -------------------------------------------------------------------------------------------
  -- Validate that the outgoing cor dates are in sequence
  FUNCTION corp_val_oc_dateseq(
  p_creation_dt IN DATE ,
  p_issued_dt IN DATE ,
  p_sent_dt IN DATE ,
  p_returned_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN
  	IF  p_sent_dt IS NOT NULL THEN
  	    IF  TRUNC(p_sent_dt) < TRUNC(p_issued_dt) THEN
  			p_message_name   := 'IGS_CO_COR_SENT_AFTER_ISSUEDT';
  			RETURN FALSE;
  	    ELSE
  			IF  p_returned_dt IS NOT NULL THEN
  		    	IF  TRUNC(p_returned_dt) < TRUNC(p_sent_dt) THEN
  					p_message_name   := 'IGS_CO_COR_RETURN_AFTER_DT';
  					RETURN FALSE;
  		    	END IF;
  			END IF;
  	    END IF;
  	ELSE
  	    IF  p_returned_dt IS NOT NULL THEN
  			p_message_name   := 'IGS_CO_COR_RETURN_AFTER_DT';
  			RETURN FALSE;
  	    END IF;
  	END IF;
  	IF  TRUNC(p_issued_dt) < TRUNC(p_creation_dt) THEN
  	    p_message_name   := 'IGS_CO_COR_ISSUED_AFTER_DT';
  	    RETURN TRUE; -- warning only as this could be a re issue
  	END IF;
  	p_message_name   := Null;
  	RETURN TRUE;

  END corp_val_oc_dateseq;
  --
  -- Validate a person id.
  FUNCTION genp_val_prsn_id(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --pkpatel     8-APR-2003      Bug 2804863
  --                            Replaced igs_pe_person with igs_pe_person_base_v
  -------------------------------------------------------------------------------------------
  BEGIN
  DECLARE
  	v_person_id	igs_pe_person_base_v.person_id%TYPE;
  	CURSOR	c_person IS
	SELECT	person_id
	FROM	igs_pe_person_base_v
	WHERE	person_id = p_person_id;
  BEGIN
  	-- validate the person_id is valid
  	OPEN c_person;
  	FETCH c_person INTO v_person_id;
  	IF (c_person%NOTFOUND) THEN
  		CLOSE c_person;
  		p_message_name   := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_person;
  	p_message_name   := Null;
  	RETURN TRUE;
  END;

  END genp_val_prsn_id;

END IGS_CO_VAL_OC;

/
