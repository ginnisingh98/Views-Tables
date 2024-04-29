--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AFS" AUTHID CURRENT_USER AS
/* $Header: IGSAD33S.pls 115.3 2002/11/28 21:30:04 nsidana ship $ */
  -- Validate against the system admission fee status closed indicator.
  FUNCTION admp_val_safs_clsd(
  p_s_adm_fee_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;
  -- Process AFS rowids in a PL/SQL TABLE for the current commit.


  -- Validate the admission fee status system default indicator.
  FUNCTION admp_val_afs_dflt(
  p_adm_fee_status IN VARCHAR2 ,
  p_s_adm_fee_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_AD_VAL_AFS;

 

/
