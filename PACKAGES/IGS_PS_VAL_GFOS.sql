--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_GFOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_GFOS" AUTHID CURRENT_USER AS
/* $Header: IGSPS48S.pls 115.3 2002/11/29 03:05:35 nsidana ship $ */
  --
  -- To validate the update of a government field of study record
  FUNCTION crsp_val_gfos_upd(
  p_govt_field_of_study IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_PS_VAL_GFOS;

 

/
