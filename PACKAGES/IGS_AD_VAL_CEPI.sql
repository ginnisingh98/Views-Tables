--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_CEPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_CEPI" AUTHID CURRENT_USER AS
/* $Header: IGSAD49S.pls 115.3 2002/11/28 21:34:59 nsidana ship $ */
  -- Validate that the course version exists.
  FUNCTION crsp_val_crv_exists(
    p_course_cd IN VARCHAR2 ,
    p_version_number IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;


  -- Validate unit version system status.
  FUNCTION crsp_val_crv_sys_sts(
    p_course_cd IN VARCHAR2 ,
    p_version_number IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

END IGS_AD_VAL_CEPI;

 

/
