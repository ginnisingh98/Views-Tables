--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_GD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_GD" AUTHID CURRENT_USER AS
/* $Header: IGSPS47S.pls 115.3 2002/11/29 03:05:11 nsidana ship $ */
  --
  -- Validate update of government IGS_PS_DSCP record
  FUNCTION crsp_val_gd_upd(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_PS_VAL_GD;

 

/
