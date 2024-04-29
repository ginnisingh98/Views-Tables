--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AAS" AUTHID CURRENT_USER AS
/* $Header: IGSAD19S.pls 115.4 2002/11/28 21:26:31 nsidana ship $ */

  --
  -- Validate against the system adm application status closed indicator.
  FUNCTION admp_val_saas_clsd(
  p_s_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the admission application status system default indicator.
  FUNCTION admp_val_aas_dflt(
  p_adm_appl_status IN VARCHAR2 ,
  p_s_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_AAS;

 

/
