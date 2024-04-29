--------------------------------------------------------
--  DDL for Package IGS_GR_VAL_GAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_VAL_GAC" AUTHID CURRENT_USER AS
/* $Header: IGSGR08S.pls 115.7 2002/11/29 00:41:03 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of GRDP_VAL_ACUSG_CLOSE
  --                            removed .
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of grdp_val_awc_closed
  --                            removed .
  -------------------------------------------------------------------------------------------
  -- Validate graduand award ceremony insert.
  FUNCTION grdp_val_gac_insert(
  p_person_id  IGS_GR_AWD_CRMN.person_id%TYPE ,
  p_create_dt  IGS_GR_AWD_CRMN.create_dt%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate inserting or updating a IGS_GR_GRADUAND IGS_PS_AWD ceremony.
  FUNCTION grdp_val_gac_iu(
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CRMN.ceremony_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate inserting or updating a graduand award ceremony.
  FUNCTION grdp_val_gac_rqrd(
  p_award_course_cd  IGS_GR_AWD_CRMN.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CRMN.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CRMN.award_cd%TYPE ,
  p_us_group_number  IGS_GR_AWD_CRMN.us_group_number%TYPE ,
  p_academic_dress_rqrd_ind  VARCHAR2 DEFAULT 'N',
  p_academic_gown_size  VARCHAR2 ,
  p_academic_hat_size  VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate graduand seat number is unique for the person.
  FUNCTION grdp_val_gac_seat(
  p_person_id  IGS_GR_AWD_CRMN.person_id%TYPE ,
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CRMN.ceremony_number%TYPE ,
  p_graduand_seat_number  IGS_GR_AWD_CRMN.graduand_seat_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate Graduand  Student Unit Set Attempts.
  FUNCTION grdp_val_gac_susa(
  p_person_id  IGS_GR_AWD_CRMN.person_id%TYPE ,
  p_create_dt  IGS_GR_AWD_CRMN.create_dt%TYPE ,
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_course_cd  IGS_PS_COURSE.course_cd%TYPE ,
  p_graduand_status  VARCHAR2 ,
  p_ceremony_number  IGS_GR_AWD_CRMN.ceremony_number%TYPE ,
  p_award_course_cd  IGS_GR_AWD_CRMN.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CRMN.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CRMN.award_cd%TYPE ,
  p_us_group_number  IGS_GR_AWD_CRMN.us_group_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate Graduand Award Ceremony graduation calendar instance.
  FUNCTION grdp_val_gac_grd_ci(
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate graduand award ceremony order in presentation is unique.
  FUNCTION grdp_val_gac_order(
  p_person_id IN NUMBER ,
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_order_in_presentation IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  --
  -- Validate a measurement code is not closed.
  FUNCTION GRDP_VAL_MSR_CLOSED(
  p_measurement_cd  IGS_GE_MEASUREMENT.measurement_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_GR_VAL_GAC;

 

/
