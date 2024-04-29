--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CGR" AUTHID CURRENT_USER AS
/* $Header: IGSPS21S.pls 115.4 2002/11/29 02:58:49 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_ou_sys_sts


  -- Validate the IGS_PS_COURSE group type for the IGS_PS_COURSE group.
  FUNCTION crsp_val_cgr_type(
  p_course_group_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_CGR;

 

/
