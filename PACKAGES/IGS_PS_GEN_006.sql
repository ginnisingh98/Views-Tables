--------------------------------------------------------
--  DDL for Package IGS_PS_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GEN_006" AUTHID CURRENT_USER AS
 /* $Header: IGSPS06S.pls 120.0 2005/06/01 12:37:17 appldev noship $ */

-- Who                  When                             What
--sarakshi              30-Apr-2004                      Bug#3568858, Added parameters ovrd_wkld_val_flag, workload_val_code to crsp_ins_uv_hist .
--sarakshi              03-Nov-2003                      Enh#3116171,Modified the procedure crsp_ins_uv_hist to include a new parameter p_billing_credit_points
--sarakshi              02-Sep-2003                      Enh#3052452,removed the reference of the column sup_unit_allowed_ind and sub_unit_allowed_ind
-- shtatiko		25-OCT-2002			 Added auditable_ind, audit_permission_ind and max_auditors_allowed
--							 to crsp_ins_uv procedure. This has been done as per Bug# 2636716.
-- jbegum               18 April 02                      As part of bug fix of bug #2322290 and bug#2250784
--                                                       Removed the following 4 columns
--                                                       BILLING_CREDIT_POINTS,BILLING_HRS,FIN_AID_CP,FIN_AID_HRS
--                                                       from crsp_ins_uv_hist procedure.
 -- rgangara 03-May-2001 modified by adding 2 parameters to crsp_ins_uv_hist as per DLD Unit Section Enrollment INfo.
FUNCTION CRSP_GET_UCL_MODE(
  p_unit_class IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(CRSP_GET_UCL_MODE,WNDS,WNPS);

FUNCTION CRSP_GET_UOO_ID(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(CRSP_GET_UOO_ID,WNDS,WNPS);

PROCEDURE crsp_get_uoo_key(
  p_unit_cd IN OUT NOCOPY VARCHAR2 ,
  p_version_number IN OUT NOCOPY NUMBER ,
  p_cal_type IN OUT NOCOPY VARCHAR2 ,
  p_ci_sequence_number IN OUT NOCOPY NUMBER ,
  p_location_cd IN OUT NOCOPY VARCHAR2 ,
  p_unit_class IN OUT NOCOPY VARCHAR2 ,
  p_uoo_id IN OUT NOCOPY NUMBER )
;

FUNCTION crsp_get_us_admin(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2;

FUNCTION crsp_get_us_sys_sts(
  p_unit_set_status IN VARCHAR2 )
RETURN VARCHAR2;

PROCEDURE crsp_ins_ci_uop_uoo(
errbuf  out NOCOPY  varchar2,
retcode out NOCOPY  number,
p_source_cal  IN VARCHAR2 ,
p_dest_cal  IN VARCHAR2 ,
p_org_unit   IN VARCHAR2,
p_org_id IN NUMBER)
;

PROCEDURE crsp_ins_us_hist(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_new_unit_set_status IN VARCHAR2 ,
  p_old_unit_set_status IN VARCHAR2 ,
  p_new_unit_set_cat IN VARCHAR2 ,
  p_old_unit_set_cat IN VARCHAR2 ,
  p_new_start_dt IN DATE ,
  p_old_start_dt IN DATE ,
  p_new_review_dt IN DATE ,
  p_old_review_dt IN DATE ,
  p_new_expiry_dt IN DATE ,
  p_old_expiry_dt IN DATE ,
  p_new_end_dt IN DATE ,
  p_old_end_dt IN DATE ,
  p_new_title IN VARCHAR2 ,
  p_old_title IN VARCHAR2 ,
  p_new_short_title IN VARCHAR2 ,
  p_old_short_title IN VARCHAR2 ,
  p_new_abbreviation IN VARCHAR2 ,
  p_old_abbreviation IN VARCHAR2 ,
  p_new_responsible_org_unit_cd IN VARCHAR2 ,
  p_old_responsible_org_unit_cd IN VARCHAR2 ,
  p_new_responsible_ou_start_dt IN DATE ,
  p_old_responsible_ou_start_dt IN DATE ,
  p_new_administrative_ind IN VARCHAR2 DEFAULT 'N',
  p_old_administrative_ind IN VARCHAR2 DEFAULT 'N',
  p_new_authorisation_rqrd_ind IN VARCHAR2 DEFAULT 'N',
  p_old_authorisation_rqrd_ind IN VARCHAR2 DEFAULT 'N',
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE );

PROCEDURE crsp_ins_uv_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_review_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_end_dt IN DATE ,
  p_unit_status IN VARCHAR2 ,
  p_title IN VARCHAR2 ,
  p_short_title IN VARCHAR2 ,
  p_title_override_ind IN VARCHAR2 DEFAULT 'N',
  p_abbreviation IN VARCHAR2 ,
  p_unit_level IN VARCHAR2 ,
  p_credit_point_descriptor IN VARCHAR2 ,
  p_achievable_credit_points IN NUMBER ,
  p_enrolled_credit_points IN NUMBER ,
  p_supp_exam_permitted_ind IN VARCHAR2 DEFAULT 'N',
  p_points_increment IN NUMBER ,
  p_points_min IN NUMBER ,
  p_points_max IN NUMBER ,
  p_points_override_ind IN VARCHAR2 DEFAULT 'N',
  p_coord_person_id IN NUMBER ,
  p_owner_org_unit_cd IN VARCHAR2 ,
  p_owner_ou_start_dt IN DATE ,
  p_award_course_only_ind IN VARCHAR2 DEFAULT 'N',
  p_research_unit_ind IN VARCHAR2 DEFAULT 'N',
  p_industrial_ind IN VARCHAR2 DEFAULT 'N',
  p_practical_ind IN VARCHAR2 DEFAULT 'N',
  p_repeatable_ind IN VARCHAR2 DEFAULT 'N',
  p_assessable_ind IN VARCHAR2 DEFAULT 'N',
  p_unit_int_course_level_cd IN VARCHAR2,
  p_ss_enrol_ind IN VARCHAR2 DEFAULT 'N',
  p_ivr_enrol_ind IN VARCHAR2 DEFAULT 'N',
  p_advance_maximum IN NUMBER,
  p_approval_date IN DATE,
  p_cal_type_enrol_load_cal IN VARCHAR2,
  p_cal_type_offer_load_cal IN VARCHAR2,
  p_clock_hours IN NUMBER,
  p_contact_hrs_lab IN NUMBER,
  p_contact_hrs_lecture IN NUMBER,
  p_contact_hrs_other IN NUMBER,
  p_continuing_education_units IN NUMBER,
  p_curriculum_id IN VARCHAR2 ,
  p_enrollment_expected IN NUMBER,
  p_enrollment_maximum IN NUMBER,
  p_enrollment_minimum IN NUMBER,
  p_exclude_from_max_cp_limit IN VARCHAR2 DEFAULT 'N',
  p_federal_financial_aid IN VARCHAR2 DEFAULT 'N',
  p_institutional_financial_aid IN VARCHAR2 DEFAULT 'N',
  p_lab_credit_points IN NUMBER,
  p_lecture_credit_points IN NUMBER,
  p_max_repeat_credit_points IN NUMBER,
  p_max_repeats_for_credit IN NUMBER,
  p_max_repeats_for_funding IN NUMBER,
  p_non_schd_required_hrs IN NUMBER,
  p_other_credit_points IN NUMBER,
  p_override_enrollment_max IN NUMBER,
  p_record_exclusion_flag IN VARCHAR2 DEFAULT 'N',
  p_ss_display_ind IN VARCHAR2 DEFAULT 'N',
  p_rpt_fmly_id IN NUMBER,
  p_same_teach_period_repeats IN NUMBER DEFAULT 'N',
  p_same_teach_period_repeats_cp IN NUMBER,
  p_same_teaching_period IN VARCHAR2,
  p_sequence_num_enrol_load_cal IN NUMBER,
  p_sequence_num_offer_load_cal IN NUMBER,
  p_special_permission_ind IN VARCHAR2 DEFAULT 'N',
  p_state_financial_aid IN VARCHAR2 DEFAULT 'N',
  p_subtitle_id IN NUMBER,
  p_subtitle_modifiable_flag IN VARCHAR2 DEFAULT 'N',
  p_unit_type_id IN NUMBER,
  p_work_load_cp_lab IN NUMBER,
  p_work_load_cp_lecture IN NUMBER,
  p_work_load_other IN NUMBER,
  p_claimable_hours IN NUMBER DEFAULT NULL ,
  p_auditable_ind IN VARCHAR2 DEFAULT 'N',
  p_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
  p_max_auditors_allowed IN NUMBER DEFAULT NULL,
  p_billing_credit_points IN NUMBER DEFAULT NULL,
  p_ovrd_wkld_val_flag IN VARCHAR2 ,
  p_workload_val_code IN VARCHAR2 ,
  p_billing_hrs IN NUMBER
  );

END IGS_PS_GEN_006;

 

/
