--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AEQS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AEQS" AUTHID CURRENT_USER AS
/* $Header: IGSAD32S.pls 115.3 2002/11/28 21:29:51 nsidana ship $ */

  -- Check against the system adm entry qualification status closed ind.
  FUNCTION admp_val_saeqs_clsd(
  p_s_adm_entry_qual_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

  -- Process AEQS rowids in a PL/SQL TABLE for the current commit.


  -- Validate the admission entry qualification status system default ind.
  FUNCTION admp_val_aeqs_dflt(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_s_adm_entry_qual_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_AD_VAL_AEQS;

 

/
