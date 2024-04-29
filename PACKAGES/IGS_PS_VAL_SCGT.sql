--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_SCGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_SCGT" AUTHID CURRENT_USER AS
/* $Header: IGSPS54S.pls 115.3 2002/11/29 03:07:18 nsidana ship $ */
  --
  -- To validate the update of a system IGS_PS_COURSE group type record
  FUNCTION crsp_val_scgt_upd(
  p_s_course_group_type IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_PS_VAL_SCGT;

 

/
