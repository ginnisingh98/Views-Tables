--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_FSR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_FSR" AUTHID CURRENT_USER AS
 /* $Header: IGSPS43S.pls 115.3 2002/11/29 03:04:08 nsidana ship $ */
  --
  -- Validate the funding source restriction restricted indicator.
  FUNCTION CRSP_VAL_FSR_RSTRCT(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the funding source restriction indicators.
  FUNCTION crsp_val_fsr_inds(
  p_dflt_ind IN VARCHAR2 DEFAULT 'N',
  p_restricted_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the funding source restriction funding source.
  FUNCTION crsp_val_fsr_fnd_src(
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate the funding source restriction default indicator.
  FUNCTION crsp_val_fsr_default(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_FSr;

 

/
