--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AODS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AODS" AUTHID CURRENT_USER AS
/* $Header: IGSAD34S.pls 115.3 2002/11/28 21:30:18 nsidana ship $ */
  --
  --

  -- Validate against system adm offer deferement status closed indicator.
  FUNCTION admp_val_saods_clsd(
  p_s_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

  -- Process AODS rowids in a PL/SQL TABLE for the current commit.

  -- Validate the admission offer deferement status system default ind.
  FUNCTION admp_val_aods_dflt(
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_s_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_AD_VAL_AODS;

 

/
