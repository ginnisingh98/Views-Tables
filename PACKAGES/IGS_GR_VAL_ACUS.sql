--------------------------------------------------------
--  DDL for Package IGS_GR_VAL_ACUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_VAL_ACUS" AUTHID CURRENT_USER AS
/* $Header: IGSGR03S.pls 115.4 2002/11/29 00:39:57 nsidana ship $ */
  --
  -- Validate if the award ceremony unit set group is closed
  FUNCTION grdp_val_acusg_close(
  p_grd_cal_type  IGS_GR_AWD_CRM_US_GP.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRM_US_GP.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CRM_US_GP.ceremony_number%TYPE ,
  p_award_course_cd  IGS_GR_AWD_CRM_US_GP.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CRM_US_GP.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CRM_US_GP.award_cd%TYPE ,
  p_us_group_number  IGS_GR_AWD_CRM_US_GP.us_group_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the award ceremony unit set has related unit set attempts
  FUNCTION grdp_val_acus_susa(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate if the award ceremony is closed.
  FUNCTION grdp_val_awc_closed(
  p_grd_cal_type  IGS_GR_AWD_CEREMONY_ALL.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CEREMONY_ALL.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CEREMONY_ALL.ceremony_number%TYPE ,
  p_award_course_cd  IGS_GR_AWD_CEREMONY_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CEREMONY_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CEREMONY_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the unit set has related course offering unit set records
  FUNCTION grdp_val_crv_us(
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_GR_VAL_ACUS;

 

/
