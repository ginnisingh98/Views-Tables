--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_UM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_UM" AUTHID CURRENT_USER AS
/* $Header: IGSPS62S.pls 115.3 2002/11/29 03:09:14 nsidana ship $ */

  --
  -- To validate the update of a IGS_PS_UNIT mode record
  FUNCTION crsp_val_um_upd(
  p_unit_mode IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

END IGS_PS_VAL_UM;

 

/
