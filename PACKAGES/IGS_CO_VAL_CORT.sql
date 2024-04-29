--------------------------------------------------------
--  DDL for Package IGS_CO_VAL_CORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_VAL_CORT" AUTHID CURRENT_USER AS
/* $Header: IGSCO09S.pls 115.4 2002/11/28 23:04:53 nsidana ship $ */
  -- Validate CORT Sys Gen indicator can not be unset while job recs exist.
  FUNCTION corp_val_cort_jobctr(
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_cort_jobctr,WNDS);
END IGS_CO_VAL_CORT;

 

/
