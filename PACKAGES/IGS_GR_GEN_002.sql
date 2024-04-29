--------------------------------------------------------
--  DDL for Package IGS_GR_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSGR14S.pls 120.0 2005/07/05 12:16:53 appldev noship $ */
PROCEDURE grdp_ins_graduand(
  	errbuf  out NOCOPY  varchar2,
	retcode out NOCOPY  number,
	p_ceremony_round  IN VARCHAR2,
	p_course_cd IGS_PS_COURSE.course_cd%TYPE ,
	p_crs_location_cd IN IGS_AD_LOCATION_ALL.location_cd%TYPE,
	p_award_cd IGS_PS_AWD.award_cd%TYPE ,
	p_nominated_completion  VARCHAR2 ,
	p_derived_completion  VARCHAR2 ,
	p_restrict_rqrmnt_complete  VARCHAR2 ,
	p_potential_graduand_status IGS_GR_STAT.graduand_status%TYPE ,
	p_eligible_graduand_status IGS_GR_STAT.graduand_status%TYPE ,
	p_graduand_appr_status IGS_GR_APRV_STAT.graduand_appr_status%TYPE,
	p_org_id IN NUMBER,
	/* Added next two parameter as per Progression Completion TD. */
  p_graduand_status  IGS_GR_STAT.graduand_status%TYPE DEFAULT NULL,
  p_approval_status IGS_GR_APRV_STAT.graduand_appr_status%TYPE DEFAULT NULL
 ) ;

PROCEDURE grdp_ins_gr_hist(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_old_grd_cal_type  IGS_GR_GRADUAND_ALL.grd_cal_type%TYPE ,
  p_new_grd_cal_type  IGS_GR_GRADUAND_ALL.grd_cal_type%TYPE ,
  p_old_grd_ci_sequence_number  IGS_GR_GRADUAND_ALL.grd_ci_sequence_number%TYPE ,
  p_new_grd_ci_sequence_number  IGS_GR_GRADUAND_ALL.grd_ci_sequence_number%TYPE ,
  p_old_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_new_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_old_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_new_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_old_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_new_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_old_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_new_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_old_honours_level  VARCHAR2 DEFAULT NULL,
  p_new_honours_level  VARCHAR2 DEFAULT NULL,
  p_old_conferral_dt   DATE DEFAULT NULL,
  p_new_conferral_dt   DATE DEFAULT NULL,
  p_old_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_new_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_old_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_new_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_old_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_new_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_old_graduation_name IN IGS_GR_GRADUAND_ALL.graduation_name%TYPE ,
  p_new_graduation_name IN IGS_GR_GRADUAND_ALL.graduation_name%TYPE ,
  p_old_proxy_award_ind  IGS_GR_GRADUAND_ALL.proxy_award_ind%TYPE ,
  p_new_proxy_award_ind  IGS_GR_GRADUAND_ALL.proxy_award_ind%TYPE ,
  p_old_proxy_award_person_id  IGS_GR_GRADUAND_ALL.proxy_award_person_id%TYPE ,
  p_new_proxy_award_person_id  IGS_GR_GRADUAND_ALL.proxy_award_person_id%TYPE ,
  p_old_previous_qualifications  IGS_GR_GRADUAND_ALL.previous_qualifications%TYPE ,
  p_new_previous_qualifications  IGS_GR_GRADUAND_ALL.previous_qualifications%TYPE ,
  p_old_convocation_memb_ind  IGS_GR_GRADUAND_ALL.convocation_membership_ind%TYPE ,
  p_new_convocation_memb_ind  IGS_GR_GRADUAND_ALL.convocation_membership_ind%TYPE ,
  p_old_sur_for_course_cd  IGS_GR_GRADUAND_ALL.sur_for_course_cd%TYPE ,
  p_new_sur_for_course_cd  IGS_GR_GRADUAND_ALL.sur_for_course_cd%TYPE ,
  p_old_sur_for_crs_version_numb  IGS_GR_GRADUAND_ALL.sur_for_crs_version_number%TYPE ,
  p_new_sur_for_crs_version_numb  IGS_GR_GRADUAND_ALL.sur_for_crs_version_number%TYPE ,
  p_old_sur_for_award_cd  IGS_GR_GRADUAND_ALL.sur_for_award_cd%TYPE ,
  p_new_sur_for_award_cd  IGS_GR_GRADUAND_ALL.sur_for_award_cd%TYPE ,
  p_old_update_who  IGS_GR_GRADUAND_ALL.last_updated_by%TYPE ,
  p_new_update_who  IGS_GR_GRADUAND_ALL.last_updated_by%TYPE ,
  p_old_update_on  IGS_GR_GRADUAND_ALL.last_update_date%TYPE ,
  p_new_update_on  IGS_GR_GRADUAND_ALL.last_update_date%TYPE ,
  p_old_comments  IGS_GR_GRADUAND_ALL.comments%TYPE ,
  p_new_comments  IGS_GR_GRADUAND_ALL.comments%TYPE );

PROCEDURE grdp_prc_gac(
  	errbuf  out NOCOPY  varchar2,
	retcode out NOCOPY  number,
	p_ceremony_round IN VARCHAR2,
	p_lctn_cd IN VARCHAR2 ,
	p_grdnd_status IN VARCHAR2 ,
	p_resolve_stalemate_type IN VARCHAR2 ,
	p_ignore_unit_sets_ind IN VARCHAR2 DEFAULT 'N',
	p_org_id IN NUMBER
) ;

PROCEDURE grdp_set_gr_gst(
	errbuf  out NOCOPY  varchar2,
	retcode out NOCOPY  NUMBER,
	p_eligible_graduand_status IGS_GR_STAT.graduand_status%TYPE ,
	p_potential_graduand_status IGS_GR_STAT.graduand_status%TYPE ,
	p_org_id IN NUMBER,
	/* Added next two parameter as per Progression Completion TD. */
        p_graduand_status  IGS_GR_STAT.graduand_status%TYPE DEFAULT NULL,
        p_approval_status IGS_GR_APRV_STAT.graduand_appr_status%TYPE DEFAULT NULL
 ) ;

PROCEDURE grdp_upd_gac_order(
  	errbuf  out NOCOPY  varchar2,
	retcode out NOCOPY  NUMBER,
	p_grd_perd VARCHAR2,
	p_order_by IN VARCHAR2 ,
	p_ignore_unit_sets_ind IN VARCHAR2 DEFAULT 'N',
	p_group_multi_award_ind IN VARCHAR2 DEFAULT 'N',
	p_mode IN VARCHAR2 DEFAULT 'A',  -- Added a new parameter as part of Order in Presentation DLD.
	p_org_id IN NUMBER
) ;

END igs_gr_gen_002;

 

/
