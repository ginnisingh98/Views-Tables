--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ACOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ACOS" AUTHID CURRENT_USER AS
/* $Header: IGSAD30S.pls 115.3 2002/11/28 21:29:20 nsidana ship $ */
  -- Validate against the system adm conditional offer status closed ind.
  FUNCTION admp_val_sacoos_clsd(
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;
  -- Process ACOS rowids in a PL/SQL TABLE for the current commit.

  -- Validate the admission conditional offer status system default ind.
  FUNCTION admp_val_acos_dflt(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_AD_VAL_ACOS;

 

/
