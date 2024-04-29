--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CFOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CFOS" AUTHID CURRENT_USER AS
/* $Header: IGSPS19S.pls 115.3 2002/11/29 02:58:08 nsidana ship $ */

  --
  -- Validate the IGS_PS_COURSE field of study.
  FUNCTION crsp_val_cfos_fos(
  p_field_of_study IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate IGS_PS_COURSE field of study percentage for the IGS_PS_COURSE version.
  FUNCTION crsp_val_cfos_perc(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_COURSE field of study major indicator.
  FUNCTION crsp_val_cfos_major(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  --
  -- Cross-table validation on IGS_PS_COURSE field of study and IGS_PS_COURSE IGS_PS_AWD.
  FUNCTION crsp_val_cfos_caw(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END IGS_PS_VAL_CFOS;

 

/
