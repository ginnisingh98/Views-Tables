--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_DI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_DI" AUTHID CURRENT_USER AS
 /* $Header: IGSPS40S.pls 115.3 2002/11/29 03:03:21 nsidana ship $ */

  --
  -- Validate government IGS_PS_DSCP group code for IGS_PS_DSCP records.
  FUNCTION crsp_val_di_govt_dg(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
END IGS_PS_VAL_DI;

 

/
