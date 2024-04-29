--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_POSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_POSP" AUTHID CURRENT_USER AS
/* $Header: IGSPS51S.pls 115.4 2002/11/29 03:06:30 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 added the pragma

  -- Validate the calendar type is categorised teaching and is not closed.
  FUNCTION crsp_val_posp_cat(
  p_cal_type IN IGS_CA_TYPE.CAL_TYPE%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(crsp_val_posp_cat,WNDS);

  -- Validate future relationship between IGS_CA_TYPE and teach_cal_type.
  FUNCTION crsp_val_posp_cir(
  p_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_teach_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate pattern of study period record is unique.
  FUNCTION crsp_val_posp_iu(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_pos_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_acad_period_num IN NUMBER ,
  p_teach_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
END IGS_PS_VAL_POSp;

 

/
