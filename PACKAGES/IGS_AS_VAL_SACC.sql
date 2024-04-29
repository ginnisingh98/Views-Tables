--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_SACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_SACC" AUTHID CURRENT_USER AS
/* $Header: IGSAS27S.pls 115.4 2002/11/28 22:46:19 nsidana ship $ */

  --
  -- Validate the IGS_AS_CAL_CONF date alias values.
  FUNCTION assp_val_sacc_da(
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_SACC;

 

/
