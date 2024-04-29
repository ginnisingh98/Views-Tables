--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_CRTJO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_CRTJO" AS
/* $Header: IGSCO10B.pls 115.4 2002/11/28 23:05:05 nsidana ship $ */
  -- Validate CORTJO record only created when Sys Gen indicator is set.
  FUNCTION corp_val_cortjo_sysg(
  p_correspondence_type IN VARCHAR2 ,
  p_sysgen_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
  BEGIN
  	--
  	-- Validate CORTJO record only created when Sys Gen indicator is set.
  	--
  	p_message_name	:= Null;
  	IF  p_sysgen_ind = 'N' THEN
  	    p_message_name := 'IGS_CO_SYSGEN_SET_CORTYPE';
  	    RETURN FALSE;
  	END IF;
  	RETURN TRUE;

  END corp_val_cortjo_sysg;
END IGS_CO_VAL_CRTJO;

/
