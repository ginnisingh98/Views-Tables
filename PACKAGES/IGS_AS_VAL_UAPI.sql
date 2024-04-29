--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_UAPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_UAPI" AUTHID CURRENT_USER AS
/* $Header: IGSAS36S.pls 115.4 2002/11/28 22:48:24 nsidana ship $ */
  -- Val IGS_PS_UNIT offering option restrictions match at pattern and item level.
  FUNCTION ASSP_VAL_UAPI_UOO(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_ass_id IN NUMBER ,
  p_uai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the to apportionment percentage does not exceed 100 for uap.
  FUNCTION ASSP_VAL_UAPI_AP(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;



END IGS_AS_VAL_UAPI;

 

/
