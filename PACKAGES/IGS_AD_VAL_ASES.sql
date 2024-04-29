--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ASES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ASES" AUTHID CURRENT_USER AS
/* $Header: IGSAD45S.pls 115.4 2002/11/28 21:33:40 nsidana ship $ */
  -- Validate the secondary school type closed indicator.
  FUNCTION admp_val_ssst_closed(
  p_s_scndry_school_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_ASES;

 

/
