--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_SUAAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_SUAAP" AUTHID CURRENT_USER AS
/* $Header: IGSAS31S.pls 120.0 2005/07/05 11:24:30 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .Added Pragma restrict reference to function
  --                            GENP_VAL_SDTT_SESS
  -------------------------------------------------------------------------------------------

  -- Val IGS_PS_UNIT assess pattern applies to stud IGS_PS_UNIT IGS_AD_LOCATION, class and mode.
  FUNCTION ASSP_VAL_UAP_LOC_UC(
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_uap_location_cd IN VARCHAR2 ,
  p_uap_unit_class IN VARCHAR2 ,
  p_uap_unit_mode IN VARCHAR2 ,
  p_message_NAME OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(ASSP_VAL_UAP_LOC_UC,WNDS,WNPS);
  --
  -- Validate able to create stdnt_unit_atmp_ass_pattern.
  FUNCTION ASSP_VAL_SUAAP_INS(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_message_NAME OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER DEFAULT NULL )
RETURN BOOLEAN;

-- Validate only one active instance of the assessment pattern for suaap.
  FUNCTION ASSP_VAL_SUAAP_ACTV(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_creation_dt IN DATE ,
  p_message_NAME OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER DEFAULT NULL )
RETURN BOOLEAN;

-- Validate that an entry exist in s_disable_table_trigger.
  FUNCTION GENP_VAL_SDTT_SESS(
  p_table_name IN VARCHAR2 )
RETURN BOOLEAN;

PRAGMA RESTRICT_REFERENCES (GENP_VAL_SDTT_SESS,WNDS);
  --

END IGS_AS_VAL_SUAAP;

 

/
