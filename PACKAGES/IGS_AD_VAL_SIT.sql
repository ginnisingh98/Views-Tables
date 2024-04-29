--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_SIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_SIT" AUTHID CURRENT_USER AS
/* $Header: IGSAD70S.pls 115.3 2002/11/28 21:39:54 nsidana ship $ */

  -- Validate override amount type != amount type
  FUNCTION admp_val_trgt_amttyp(
  p_s_amount_type IN VARCHAR2 ,
  p_overrride_s_amount_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if intake target type is closed.
  FUNCTION admp_val_itt_closed(
  p_intake_target_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate target type amounts are in correct ranges.
  FUNCTION admp_val_trgt_amt(
  p_s_amount_type IN VARCHAR2 ,
  p_target IN NUMBER ,
  p_max_target IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_SIT;

 

/
