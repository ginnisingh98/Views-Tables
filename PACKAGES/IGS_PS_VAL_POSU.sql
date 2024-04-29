--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_POSU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_POSU" AUTHID CURRENT_USER AS
/* $Header: IGSPS52S.pls 120.0 2005/06/01 16:14:57 appldev noship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_loc_cd
-- As part of the bug# 1956374 removed the function crsp_val_ucl_closed

  --
  --
  -- Validate pattern of study IGS_PS_UNIT record is unique.
  FUNCTION crsp_val_posu_iu(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_pos_sequence_number IN NUMBER ,
  p_posp_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_location_cd  IN VARCHAR2,
  p_unit_class   IN VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the pattern of study IGS_PS_UNIT record has the required fields.
  FUNCTION crsp_val_posu_rqrd(
  p_unit_cd IN VARCHAR2 ,
  p_unit_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_description IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Warn if no IGS_PS_UNIT offering option exists for the specified options.
  FUNCTION crsp_val_posu_uoo(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_pos_sequence_number IN NUMBER ,
  p_posp_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_unit_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate a least one version of the IGS_PS_UNIT is active.
  FUNCTION crsp_val_uv_active(
  p_unit_cd IN IGS_PS_UNIT_VER_ALL.unit_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(crsp_val_uv_active,WNDS);

END IGS_PS_VAL_POSu;

 

/
