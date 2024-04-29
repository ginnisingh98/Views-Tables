--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_USC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_USC" AUTHID CURRENT_USER AS
/* $Header: IGSPS69S.pls 115.4 2002/11/29 03:10:13 nsidana ship $ */

  --
  -- Validate IGS_PS_UNIT set cat rank changes if IGS_PS_UNIT sets exist for the category
  FUNCTION crsp_val_usc_us(
  p_unit_set_cat IN VARCHAR2 ,
  p_old_rank IN NUMBER ,
  p_new_rank IN NUMBER ,
  p_old_s_unit_set_cat IN VARCHAR2,
  p_new_s_unit_set_cat IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_PS_VAL_USc;

 

/
