--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_CORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_CORT" AS
/* $Header: IGSCO09B.pls 115.4 2002/11/28 23:04:43 nsidana ship $ */
  -- Validate CORT Sys Gen indicator can not be unset while job recs exist.
  FUNCTION corp_val_cort_jobctr(
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_rec_count	NUMBER;
  	CURSOR	c_jobctr IS
  		SELECT	CORRESPONDENCE_TYPE
  		FROM	IGS_CO_TYPE_JO
  		WHERE	CORRESPONDENCE_TYPE = p_correspondence_type;
  BEGIN
  	--
  	-- Validate CORT Sys Gen indicator can not be unset while job recs exist.
  	--
  	p_message_name	:= Null;
  	v_rec_count	:= 0;
  	FOR c_jobrec IN c_jobctr
  	LOOP
  		v_rec_count := v_rec_count + 1;
  	END LOOP;
  	IF  (v_rec_count > 0) THEN
  		p_message_name := 'IGS_CO_SYSGEN_REMAINSET_CORTY';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;

  END;
  END corp_val_cort_jobctr;
END IGS_CO_VAL_CORT;

/
