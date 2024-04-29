--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CGM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CGM" AUTHID CURRENT_USER AS
/* $Header: IGSPS20S.pls 115.3 2002/11/29 02:58:27 nsidana ship $ */

  --
  -- Validate the IGS_PS_COURSE group member IGS_PS_COURSE group code.
  FUNCTION crsp_val_cgm_crs_grp(
  p_course_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_CGM;

 

/
