--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_GBFAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_GBFAT" AUTHID CURRENT_USER AS
/* $Header: IGSAD62S.pls 115.3 2002/11/28 21:37:56 nsidana ship $ */

  -- Validate the update of a government basis for admission type record
  FUNCTION admp_val_gbfat_upd(
  p_govt_basis_for_adm_type IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_GBFAT;

 

/
