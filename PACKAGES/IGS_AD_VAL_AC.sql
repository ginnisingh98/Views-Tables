--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AC" AUTHID CURRENT_USER AS
/* $Header: IGSAD20S.pls 115.4 2002/11/28 21:26:44 nsidana ship $ */

  --
  -- Validate if the IGS_AD_CAT record can be updated.
  FUNCTION admp_val_ac_upd(
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_AC;

 

/
