--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_SCFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_SCFT" AUTHID CURRENT_USER AS
/* $Header: IGSAD69S.pls 115.4 2002/11/28 21:39:39 nsidana ship $ */

-------------------------------------------------------------------
--  Change History :
--  Who             When            What
--  avenkatr        30-AUG-2001     Bug Id : 1956374. Removed Procedure "crsp_val_fs_closed"
--  avenkatr        30-AUG-2001     Bug Id : 1956374. Removed Procedure "crsp_val_iud_crv_dtl"
------------------------------------------------------------------
  --
  -- Validate SCFT optional values unique across records
  FUNCTION admp_val_scft_uniq(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate crs fund target course version in a valid course off pattern
  FUNCTION admp_val_scft_cop(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate crs fund target funding source is within restriction
  FUNCTION admp_val_scft_fs(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate crs fund target IGS_PS_UNIT set in a valid course offering IGS_PS_UNIT set
  FUNCTION admp_val_scft_cous(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate crs fund target detail in a valid course offering pattern
  FUNCTION admp_val_scft_dtl(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_SCFT;

 

/
