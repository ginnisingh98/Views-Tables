--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_CORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_CORD" AS
/* $Header: IGSCO07B.pls 115.4 2002/11/28 23:04:25 nsidana ship $ */
  -- Validate that detail format type can only  be changed when 'UNDEFINED'
  FUNCTION corp_val_cord_fmtype(
  p_format_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  BEGIN
  	-- This module validates the format type is initially
  	-- 'UNDEFINED' if it is being changed
  	p_message_name   := null;
  	IF (p_format_type <> 'UNDEFINED') THEN
  			p_message_name := 'IGS_CO_FMTTYPE_CHG_UNDEFINED';
  			RETURN FALSE;
  	END IF;
  	RETURN TRUE;

  END;
  END corp_val_cord_fmtype;
  --
  -- Validate that ext ref is specified when format type is 'REFERENCE'
  FUNCTION corp_val_cord_extref(
  p_format_type IN VARCHAR2 ,
  p_extref IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  BEGIN
  	-- This module validates the external reference is specified
  	-- if detail format type is 'REFERENCE'
  	p_message_name := Null;
  	IF  (p_format_type = 'REFERENCE' AND p_extref IS NULL) THEN
  	    p_message_name := 'IGS_CO_EXTREF_FMTTYP_REF';
  	    RETURN FALSE;
  	ELSE
  	    IF	(p_format_type <> 'REFERENCE' AND p_extref IS NOT NULL) THEN
  		p_message_name := 'IGS_CO_EXTREF_DTLFMT_REF';
  		RETURN FALSE;
  	    END IF;
  	END IF;
  	RETURN TRUE;

  END;
  END corp_val_cord_extref;
END IGS_CO_VAL_CORD;

/
