--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_TELOQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_TELOQ" AUTHID CURRENT_USER AS
/* $Header: IGSAD74S.pls 115.4 2002/11/28 21:40:57 nsidana ship $ */

  --
  -- Validate the TAC level of qualification closed ind
  FUNCTION admp_val_tloq_closed(
  p_tac_level_of_qual IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_TELOQ;

 

/
