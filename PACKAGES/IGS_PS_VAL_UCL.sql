--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_UCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_UCL" AUTHID CURRENT_USER AS
/* $Header: IGSPS60S.pls 115.3 2002/11/29 03:08:47 nsidana ship $ */

  --
  -- Validate the IGS_PS_UNIT mode for IGS_PS_UNIT class.
  FUNCTION crsp_val_ucl_um(
  p_unit_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the start and end times when set for the IGS_PS_UNIT class.
  FUNCTION crsp_val_ucl_st_end(
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_PS_VAL_UCl;

 

/
