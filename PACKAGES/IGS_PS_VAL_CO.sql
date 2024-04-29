--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CO" AUTHID CURRENT_USER AS
/* $Header: IGSPS23S.pls 115.3 2002/11/29 02:59:28 nsidana ship $ */

  --
  -- Validate IGS_PS_COURSE Offering Calendar Type.
  FUNCTION crsp_val_co_cal_type(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_CO;

 

/
