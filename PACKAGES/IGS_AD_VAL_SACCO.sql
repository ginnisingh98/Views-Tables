--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_SACCO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_SACCO" AUTHID CURRENT_USER AS
/* $Header: IGSAD67S.pls 115.3 2002/11/28 21:39:10 nsidana ship $ */

  -- Validate the IGS_AD_CAL_CONF date alias values.
  FUNCTION admp_val_sacco_da(
  p_dt_alias IN VARCHAR2 ,
  p_dt_alias_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_SACCO;

 

/
