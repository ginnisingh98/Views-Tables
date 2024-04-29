--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ADS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ADS" AUTHID CURRENT_USER AS
/* $Header: IGSAD31S.pls 115.3 2002/11/28 21:29:37 nsidana ship $ */

  -- Check against the system adm documentation status closed indcator.
  FUNCTION admp_val_sads_clsd(
  p_s_adm_doc_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

  -- Validate the admission documentation status system default indicator.
  FUNCTION admp_val_ads_dflt(
  p_adm_doc_status IN VARCHAR2 ,
  p_s_adm_doc_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;


END IGS_AD_VAL_ADS;

 

/
