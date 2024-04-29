--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ITT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ITT" AUTHID CURRENT_USER AS
/* $Header: IGSAD63S.pls 115.3 2002/11/28 21:38:11 nsidana ship $ */

   -- Validate if system intake target type is closed.
  FUNCTION admp_val_sitt_closed(
  p_s_intake_target_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate unique system values for intake target type.
  FUNCTION admp_val_sitt_uniq(
  p_intake_target_type IN VARCHAR2 ,
  p_s_intake_target_type IN VARCHAR2 ,
  p_s_amount_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_ITT;

 

/
