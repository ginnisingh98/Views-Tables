--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_GCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_GCT" AUTHID CURRENT_USER AS
/* $Header: IGSPS46S.pls 115.3 2002/11/29 03:04:54 nsidana ship $ */
  --
  -- Validate update of government IGS_PS_COURSE type record
  FUNCTION crsp_val_gct_upd(
  p_govt_course_type IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_PS_VAL_GCT;

 

/
