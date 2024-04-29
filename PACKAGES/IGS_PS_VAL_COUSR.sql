--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_COUSR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_COUSR" AUTHID CURRENT_USER AS
/* $Header: IGSPS29S.pls 115.3 2002/11/29 03:01:01 nsidana ship $ */

  -- Validate IGS_PS_UNIT set status for ins/upd/del of detail records
  FUNCTION crsp_val_iud_us_dtl(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate COUSR hierarchy for duplicate ancestors/descendants
  FUNCTION crsp_val_cousr_tree(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_sup_unit_set_cd IN VARCHAR2 ,
  p_sup_us_version_number IN NUMBER ,
  p_sub_unit_set_cd IN VARCHAR2 ,
  p_sub_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate COUSR can only be created with US as superior if appropriate
  FUNCTION crsp_val_cousr_sub(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_sup_unit_set_cd IN VARCHAR2 ,
  p_sup_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate COUSR can only be created as sub if CACUS rec does not exist
  FUNCTION crsp_val_cousr_cacus(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_sub_unit_set_cd IN VARCHAR2 ,
  p_sub_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_COusr;

 

/
