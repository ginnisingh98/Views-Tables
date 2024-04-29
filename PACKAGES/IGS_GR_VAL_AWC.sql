--------------------------------------------------------
--  DDL for Package IGS_GR_VAL_AWC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_VAL_AWC" AUTHID CURRENT_USER AS
/* $Header: IGSGR05S.pls 115.4 2002/11/29 00:40:13 nsidana ship $ */
  --
  -- Validate the award has the correct system award type
  FUNCTION grdp_val_award_type(
  p_award_cd IN VARCHAR2 ,
  p_s_award_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the award ceremony has related student course attempts
  FUNCTION grdp_val_awc_sca(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the award is not closed.
  FUNCTION crsp_val_aw_closed(
  p_award_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the award ceremony order in ceremony
  FUNCTION grdp_val_awc_order(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_order_in_ceremony IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate if the award ceremony us group order in award.
  FUNCTION grdp_val_acusg_order(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_us_group_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_GR_VAL_AWC;

 

/
