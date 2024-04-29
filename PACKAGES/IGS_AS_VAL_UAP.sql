--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_UAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_UAP" AUTHID CURRENT_USER AS
/* $Header: IGSAS35S.pls 115.7 2002/11/28 22:48:09 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_loc_cd
-- As part of the bug# 1956374 removed the function crsp_val_ucl_closed
-- As part of the bug# 1956374 removed the function crsp_val_um_closed
-- As part of the bug# 1956374 removed the function crsp_val_uo_cal_type
-- As part of the bug# 1956373 removed the function crsp_val_iud_uv_dtl
  -- Bug No 1956374 , Procedure assp_val_uap_loc_uc is removed
  -- Validate the ass_pattern_cd is unique within a IGS_PS_UNIT offering pattern.
  FUNCTION ASSP_VAL_UAP_UNIQ_CD(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_ass_pattern_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate the IGS_PS_UNIT assessment pattern restrictions can be updated.
  FUNCTION ASSP_VAL_UAP_UOO_UPD(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

 --

  --
  -- Validate IGS_PS_UNIT class and IGS_PS_UNIT mode cannot both be set.
  FUNCTION ASSP_VAL_UC_UM(
  p_unit_mode IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;



  --


  --
  -- Val IGS_PS_UNIT assess pattern applies to stud IGS_PS_UNIT IGS_AD_LOCATION, class and mode.
  FUNCTION ASSP_VAL_SUA_UAP(
  p_student_location_cd IN VARCHAR2 ,
  p_student_unit_class IN VARCHAR2 ,
  p_student_unit_mode IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 )
RETURN CHAR;
 PRAGMA RESTRICT_REFERENCES(ASSP_VAL_SUA_UAP,WNDS,WNPS);


  -- Routine to save rowids in a PL/SQL TABLE for the current commit.

END IGS_AS_VAL_UAP;

 

/
