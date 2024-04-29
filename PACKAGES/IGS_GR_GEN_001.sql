--------------------------------------------------------
--  DDL for Package IGS_GR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSGR13S.pls 115.4 2002/11/29 00:41:49 nsidana ship $ */

FUNCTION grdp_del_gac_hist(
  p_person_id IN IGS_GR_AWD_CRMN.person_id%TYPE ,
  p_create_dt IN IGS_GR_AWD_CRMN.create_dt%TYPE ,
  p_grd_cal_type IN IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number IN IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_ceremony_number IN IGS_GR_AWD_CRMN.ceremony_number%TYPE ,
  p_award_course_cd IN IGS_GR_AWD_CRMN.award_course_cd%TYPE ,
  p_award_crs_version_number IN IGS_GR_AWD_CRMN.award_crs_version_number%TYPE ,
  p_award_cd IN IGS_GR_AWD_CRMN.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


PROCEDURE grdp_del_gr_gac(
  errbuf  out NOCOPY varchar2,
  retcode out NOCOPY NUMBER,
  p_grd_period IN VARCHAR2,
  p_org_id IN NUMBER
);

FUNCTION grdp_get_acusg_title(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN CHAR ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_us_group_number IN NUMBER )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(grdp_get_acusg_title, WNDS);

FUNCTION grdp_get_grad_name(
  p_person_id IN NUMBER )
RETURN VARCHAR2 ;

FUNCTION grdp_get_gr_ghl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2 ;

PROCEDURE grdp_ins_gac_hist(
  p_person_id  IGS_GR_AWD_CRMN.person_id%TYPE ,
  p_create_dt  IGS_GR_AWD_CRMN.create_dt%TYPE ,
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_ceremony_number  IGS_GR_AWD_CRMN.ceremony_number%TYPE ,
  p_award_course_cd  IGS_GR_AWD_CRMN.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_AWD_CRMN.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_AWD_CRMN.award_cd%TYPE ,
  p_old_us_group_number  IGS_GR_AWD_CRMN.us_group_number%TYPE ,
  p_new_us_group_number  IGS_GR_AWD_CRMN.us_group_number%TYPE ,
  p_old_order_in_presentation  IGS_GR_AWD_CRMN.order_in_presentation%TYPE ,
  p_new_order_in_presentation  IGS_GR_AWD_CRMN.order_in_presentation%TYPE ,
  p_old_graduand_seat_number  IGS_GR_AWD_CRMN.graduand_seat_number%TYPE ,
  p_new_graduand_seat_number  IGS_GR_AWD_CRMN.graduand_seat_number%TYPE ,
  p_old_name_pronunciation  IGS_GR_AWD_CRMN.name_pronunciation%TYPE ,
  p_new_name_pronunciation  IGS_GR_AWD_CRMN.name_pronunciation%TYPE ,
  p_old_name_announced  IGS_GR_AWD_CRMN.name_announced%TYPE ,
  p_new_name_announced  IGS_GR_AWD_CRMN.name_announced%TYPE ,
  p_old_academic_dress_rqrd_ind  IGS_GR_AWD_CRMN.academic_dress_rqrd_ind%TYPE ,
  p_new_academic_dress_rqrd_ind  IGS_GR_AWD_CRMN.academic_dress_rqrd_ind%TYPE ,
  p_old_academic_gown_size  IGS_GR_AWD_CRMN.academic_gown_size%TYPE ,
  p_new_academic_gown_size  IGS_GR_AWD_CRMN.academic_gown_size%TYPE ,
  p_old_academic_hat_size  IGS_GR_AWD_CRMN.academic_hat_size%TYPE ,
  p_new_academic_hat_size  IGS_GR_AWD_CRMN.academic_hat_size%TYPE ,
  p_old_guest_tickets_requested  IGS_GR_AWD_CRMN.guest_tickets_requested%TYPE ,
  p_new_guest_tickets_requested  IGS_GR_AWD_CRMN.guest_tickets_requested%TYPE ,
  p_old_guest_tickets_allocated  IGS_GR_AWD_CRMN.guest_tickets_allocated%TYPE ,
  p_new_guest_tickets_allocated  IGS_GR_AWD_CRMN.guest_tickets_allocated%TYPE ,
  p_old_guest_seats  IGS_GR_AWD_CRMN.guest_seats%TYPE ,
  p_new_guest_seats  IGS_GR_AWD_CRMN.guest_seats%TYPE ,
  p_old_fees_paid_ind  IGS_GR_AWD_CRMN.fees_paid_ind%TYPE ,
  p_new_fees_paid_ind  IGS_GR_AWD_CRMN.fees_paid_ind%TYPE ,
  p_old_update_who  IGS_GR_AWD_CRMN.last_updated_by%TYPE ,
  p_new_update_who  IGS_GR_AWD_CRMN.last_updated_by%TYPE ,
  p_old_update_on  IGS_GR_AWD_CRMN.last_update_date%TYPE ,
  p_new_update_on  IGS_GR_AWD_CRMN.last_update_date%TYPE ,
  p_old_special_requirements  IGS_GR_AWD_CRMN.special_requirements%TYPE ,
  p_new_special_requirements  IGS_GR_AWD_CRMN.special_requirements%TYPE ,
  p_old_comments  IGS_GR_AWD_CRMN.comments%TYPE ,
  p_new_comments  IGS_GR_AWD_CRMN.comments%TYPE ) ;

END IGS_GR_GEN_001 ;

 

/
