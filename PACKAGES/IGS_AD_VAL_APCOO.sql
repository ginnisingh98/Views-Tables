--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_APCOO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_APCOO" AUTHID CURRENT_USER AS
/* $Header: IGSAD40S.pls 115.5 2002/11/28 21:31:52 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Added Pragma to function "crsp_val_att_closed"
  -------------------------------------------------------------------------------------------

-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_loc_cd

  -- Validate admission period course offering option course offering.
  FUNCTION admp_val_apcoo_co(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate admission period course offering option optional links.
  FUNCTION admp_val_apcoo_links(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Insert admission period course offering options
  FUNCTION admp_ins_dflt_apcoo(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate course offering option optional links.
  FUNCTION genp_val_optnl_coo(
  p_new_location_cd IN VARCHAR2 ,
  p_new_attendance_mode IN VARCHAR2 ,
  p_new_attendance_type IN VARCHAR2 ,
  p_db_location_cd IN VARCHAR2 ,
  p_db_attendance_mode IN VARCHAR2 ,
  p_db_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate the attendance mode closed indicator.
  FUNCTION crsp_val_am_closed(
  p_attendance_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

 -- Validate the attendance type closed indicator.
   FUNCTION crsp_val_att_closed(
   p_attendance_type IN VARCHAR2 ,
   p_message_name OUT NOCOPY VARCHAR2 )
 RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(crsp_val_att_closed, WNDS);

  -- Validate the admission period course offering option details.
  FUNCTION admp_val_apcoo_opt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_APCOO;

 

/
