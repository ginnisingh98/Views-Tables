--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AORS" AUTHID CURRENT_USER AS
/* $Header: IGSAD35S.pls 115.3 2002/11/28 21:30:42 nsidana ship $ */
  -- Validate against the system adm offer response status closed indicator
  FUNCTION admp_val_saors_clsd(
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;


  -- Validate the admission offer response status system default indicator.
  FUNCTION admp_val_aors_dflt(
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

 END IGS_AD_VAL_AORS;

 

/
