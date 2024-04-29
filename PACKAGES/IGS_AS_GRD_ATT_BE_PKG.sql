--------------------------------------------------------
--  DDL for Package IGS_AS_GRD_ATT_BE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GRD_ATT_BE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAS53S.pls 115.0 2002/12/26 09:49:01 ddey noship $ */

PROCEDURE   Wf_Inform_Admin_CG
                          (
                          p_person_id          IN   VARCHAR2,
                          p_person_number      IN   hz_parties.party_number%TYPE,
                          p_person_name        IN   hz_parties.party_name%TYPE,
                          p_course_cd          IN   igs_as_chn_grd_req.course_cd%TYPE,
                          p_unit_cd            IN   igs_as_chn_grd_req.unit_cd%TYPE,
                          p_unit_section       IN   igs_as_chn_grd_req.unit_class%TYPE,
                          p_title              IN   igs_ps_unit_ver_all.title%TYPE,
                          p_grading_schema     IN   igs_as_chn_grd_req.current_grading_schema_cd%TYPE,
                          p_current_mark       IN   igs_as_chn_grd_req.current_mark%TYPE,
                          p_current_grade      IN   igs_as_chn_grd_req.current_grade%TYPE,
                          p_change_mark        IN   igs_as_chn_grd_req.change_mark%TYPE,
                          p_change_grade       IN   igs_as_chn_grd_req.change_grade%TYPE,
                          p_requester_id       IN   igs_as_chn_grd_req.requester_id%TYPE,
                          p_requester_name     IN   VARCHAR2,
                          p_requester_number   IN   VARCHAR2,
                          p_request_date       IN   igs_as_chn_grd_req.request_date%TYPE,
                          p_requester_comments IN   igs_as_chn_grd_req.requester_comments%TYPE,
                          p_teach_cal_type     IN   igs_as_chn_grd_req.teach_cal_type%TYPE,
                          p_teach_ci_seq_num   IN   igs_as_chn_grd_req.teach_ci_sequence_number%TYPE,
                          p_start_dt           IN   DATE,
                          p_end_dt             IN   DATE,
                          p_load_cal_type      IN   igs_as_chn_grd_req.load_cal_type%TYPE,
                          p_load_seq_num       IN   igs_as_chn_grd_req.load_ci_sequence_number%TYPE,
                          p_grade_ver_num      IN   igs_as_chn_grd_req.current_gs_version_number%TYPE,
                          p_uoo_id             IN   igs_ps_unit_ofr_opt.uoo_id%TYPE,
                          p_grading_period_cd  IN   igs_as_su_stmptout.grading_period_cd%TYPE
                      );
 PROCEDURE  Wf_Inform_Admin_Grd
                        ( p_uoo_id              IN   igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                          p_unit_cd             IN   igs_ps_unit_ver_all.unit_cd%TYPE,
                          p_unit_class          IN   igs_ps_unit_ofr_opt.unit_class%TYPE,
                          p_title               IN   igs_ps_unit_ver_all.title%TYPE,
                          p_instructor          IN   hz_parties.party_name%TYPE,
                          p_submission_date     IN   DATE,
			  p_requestor_id        IN   VARCHAR2 /* Added by aiyer for the bug 2403814 */
                        );
PROCEDURE  Wf_Inform_Admin_Grd_mt
                        ( p_uoo_id              IN   igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                          p_unit_cd             IN   igs_ps_unit_ver_all.unit_cd%TYPE,
                          p_unit_class          IN   igs_ps_unit_ofr_opt.unit_class%TYPE,
                          p_title               IN   igs_ps_unit_ver_all.title%TYPE,
                          p_instructor          IN   hz_parties.party_name%TYPE,
                          p_submission_date     IN   DATE
                        );
PROCEDURE  Wf_Inform_Admin_Attd
                        ( p_uoo_id              IN   igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                          p_unit_cd             IN   igs_ps_unit_ver_all.unit_cd%TYPE,
                          p_unit_class          IN   igs_ps_unit_ofr_opt.unit_class%TYPE,
                          p_title               IN   igs_ps_unit_ver_all.title%TYPE,
                          p_instructor          IN   hz_parties.party_name%TYPE,
                          p_submission_date     IN   DATE
                        );
PROCEDURE  Wf_Inform_Admin_IncGrd
                        ( p_person_id           IN   igs_as_su_stmptout.person_id%TYPE  ,
                          p_course_cd           IN   igs_as_su_stmptout.course_cd%TYPE,
                          p_unit_cd             IN   igs_as_su_stmptout.unit_cd%TYPE,
                          p_cal_type            IN   igs_as_su_stmptout.cal_type%TYPE,
                          p_ci_seq_num          IN   igs_as_su_stmptout.ci_sequence_number%TYPE,
                          p_date_changed        IN   DATE,
                          p_old_grade           IN   igs_as_su_stmptout.grade%TYPE,
                          p_new_grade           IN   igs_as_su_stmptout.incomp_default_grade%TYPE
                        );
PROCEDURE  Wf_Inform_Admin_IncGrdSub
                        ( p_person_id           IN   igs_as_su_stmptout.person_id%TYPE  ,
                          p_course_cd           IN   igs_as_su_stmptout.course_cd%TYPE,
                          p_unit_cd             IN   igs_as_su_stmptout.unit_cd%TYPE,
                          p_cal_type            IN   igs_as_su_stmptout.cal_type%TYPE,
                          p_ci_seq_num          IN   igs_as_su_stmptout.ci_sequence_number%TYPE,
                          p_grade               IN   igs_as_su_stmptout.grade%TYPE,
                          p_incomp_deadline_dt  IN   igs_as_su_stmptout.incomp_deadline_date%TYPE,
                          p_incomp_default_grd  IN   igs_as_su_stmptout.incomp_default_grade%TYPE,
                          p_incomp_default_mark IN   igs_as_su_stmptout.incomp_default_mark%TYPE,
                          p_date_submitted      IN   DATE
                        );
END IGS_AS_GRD_ATT_BE_PKG;

 

/
