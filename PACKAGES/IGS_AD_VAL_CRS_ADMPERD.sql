--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_CRS_ADMPERD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_CRS_ADMPERD" AUTHID CURRENT_USER AS
/* $Header: IGSAD51S.pls 115.3 2002/11/28 21:35:32 nsidana ship $ */
  -- Validate the admission application course version.
  FUNCTION admp_val_coo_crv(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the course offering option against the admission cat.
  FUNCTION admp_val_coo_adm_cat(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate course application to an admission period.
  FUNCTION admp_val_coo_admperd(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES (ADMP_VAL_COO_ADMPERD,WNDS,WNPS);
  PRAGMA RESTRICT_REFERENCES (ADMP_VAL_COO_CRV,WNDS,WNPS);
  PRAGMA RESTRICT_REFERENCES (ADMP_VAL_COO_ADM_CAT,WNDS,WNPS);
END IGS_AD_VAL_CRS_ADMPERD;

 

/
