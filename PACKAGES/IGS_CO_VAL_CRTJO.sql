--------------------------------------------------------
--  DDL for Package IGS_CO_VAL_CRTJO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_VAL_CRTJO" AUTHID CURRENT_USER AS
/* $Header: IGSCO10S.pls 115.4 2002/11/28 23:05:18 nsidana ship $ */
  -- Validate CORTJO record only created when Sys Gen indicator is set.
  FUNCTION corp_val_cortjo_sysg(
  p_correspondence_type IN VARCHAR2 ,
  p_sysgen_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_cortjo_sysg,WNDS);
END IGS_CO_VAL_CRTJO;

 

/
