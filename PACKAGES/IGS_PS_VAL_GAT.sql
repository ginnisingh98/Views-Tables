--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_GAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_GAT" AUTHID CURRENT_USER AS
/* $Header: IGSPS45S.pls 115.3 2002/11/29 03:04:38 nsidana ship $ */
  --
  -- To validate the update of a govt attendance mode record
  FUNCTION crsp_val_gat_upd(
  p_govt_attendance_type IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_PS_VAL_GAT;

 

/
