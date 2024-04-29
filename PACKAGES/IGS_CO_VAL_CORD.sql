--------------------------------------------------------
--  DDL for Package IGS_CO_VAL_CORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_VAL_CORD" AUTHID CURRENT_USER AS
/* $Header: IGSCO07S.pls 115.4 2002/11/28 23:04:34 nsidana ship $ */
  -- Validate that detail format type can only  be changed when 'UNDEFINED'
  FUNCTION corp_val_cord_fmtype(
  p_format_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2)
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_cord_fmtype,WNDS);
  --
  -- Validate that ext ref is specified when format type is 'REFERENCE'
  FUNCTION corp_val_cord_extref(
  p_format_type IN VARCHAR2 ,
  p_extref IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2)
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_cord_extref,WNDS);
END IGS_CO_VAL_CORD;

 

/
