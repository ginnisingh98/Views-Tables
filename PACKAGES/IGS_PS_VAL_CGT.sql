--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CGT" AUTHID CURRENT_USER AS
/* $Header: IGSPS22S.pls 115.3 2002/11/29 02:59:11 nsidana ship $ */

  --
  -- Validate the IGS_PS_COURSE group type system IGS_PS_COURSE group type.
  FUNCTION crsp_val_cgt_sys_cgt(
  p_s_course_group_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_PS_VAL_CGT;

 

/
