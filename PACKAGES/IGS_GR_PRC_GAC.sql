--------------------------------------------------------
--  DDL for Package IGS_GR_PRC_GAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_PRC_GAC" AUTHID CURRENT_USER AS
/* $Header: IGSGR01S.pls 115.4 2002/11/29 00:39:26 nsidana ship $ */
  --
  -- Create graduand award ceremony records for graduands
  FUNCTION grdp_ins_gac(
  p_person_id IN NUMBER ,
  p_create_dt IN DATE ,
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_name_pronunciation IN VARCHAR2 ,
  p_name_announced IN VARCHAR2 ,
  p_academic_dress_rqrd_ind IN VARCHAR2 DEFAULT 'N',
  p_academic_gown_size IN VARCHAR2 ,
  p_academic_hat_size IN VARCHAR2 ,
  p_guest_tickets_requested IN NUMBER ,
  p_guest_tickets_allocated IN NUMBER ,
  p_guest_seats IN VARCHAR2 ,
  p_fees_paid_ind IN VARCHAR2 DEFAULT 'N',
  p_special_requirements IN VARCHAR2 ,
  p_resolve_stalemate_type IN VARCHAR2 ,
  p_ignore_unit_sets_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Process the close of a Award Ceremony Unit Set Group
  FUNCTION grdp_prc_acusg_close(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_us_group_number IN NUMBER ,
  p_resolve_stalemate_type IN VARCHAR2 ,
  p_ignore_unit_sets_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Process the close of a Award Ceremony
  FUNCTION grdp_prc_awc_close(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_resolve_stalemate_type IN VARCHAR2 ,
  p_ignore_unit_sets_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_GR_PRC_GAC;

 

/
