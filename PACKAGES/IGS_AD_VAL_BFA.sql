--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_BFA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_BFA" AUTHID CURRENT_USER AS
/* $Header: IGSAD47S.pls 115.4 2002/11/28 21:34:27 nsidana ship $ */
  -- Validate the government basis for admission type closed indicator.
  FUNCTION admp_val_gbfat_clsd(
  p_govt_basis_for_adm_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_BFA;

 

/
