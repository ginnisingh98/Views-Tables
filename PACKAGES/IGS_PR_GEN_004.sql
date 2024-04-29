--------------------------------------------------------
--  DDL for Package IGS_PR_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSPR25S.pls 115.7 2003/05/30 07:17:02 kdande ship $ */
--
-- kdande; 23-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the PROCEDURE IGS_PR_ins_suao_todo
--
PROCEDURE igs_pr_ins_suao_todo (
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_version_number IN NUMBER,
  p_unit_cd IN VARCHAR2,
  p_cal_type IN VARCHAR2,
  p_ci_sequence_number IN NUMBER,
  p_old_grading_schema_cd IN VARCHAR2,
  p_new_grading_schema_cd IN VARCHAR ,
  p_old_gs_version_number IN NUMBER,
  p_new_gs_version_number IN NUMBER,
  p_old_grade IN VARCHAR2,
  p_new_grade IN VARCHAR2,
  p_old_mark IN NUMBER,
  p_new_mark IN NUMBER,
  p_old_finalised_outcome_ind IN VARCHAR2,
  p_new_finalised_outcome_ind IN VARCHAR2,
  p_uoo_id IN NUMBER DEFAULT NULL
);
PROCEDURE igs_pr_upd_out_apply (
  p_prg_cal_type IN VARCHAR2,
  p_prg_sequence_number IN NUMBER,
  p_course_type IN VARCHAR2,
  p_org_unit_cd IN VARCHAR2,
  p_ou_start_dt IN DATE ,
  p_course_cd IN VARCHAR2,
  p_location_cd IN VARCHAR2,
  p_attendance_mode IN VARCHAR2,
  p_progression_status IN VARCHAR2,
  p_enrolment_cat IN VARCHAR2,
  p_group_id IN NUMBER,
  p_spo_person_id IN NUMBER,
  p_spo_course_cd IN VARCHAR2,
  p_spo_sequence_number IN NUMBER,
  p_message_text IN OUT NOCOPY VARCHAR2,
  p_message_level IN OUT NOCOPY VARCHAR2,
  p_log_creation_dt OUT NOCOPY DATE
);
PROCEDURE igs_pr_upd_rule_apply (
  p_prg_cal_type IN VARCHAR2,
  p_prg_sequence_number IN NUMBER,
  p_course_type IN VARCHAR2,
  p_org_unit_cd IN VARCHAR2,
  p_ou_start_dt IN DATE ,
  p_course_cd IN VARCHAR2,
  p_location_cd IN VARCHAR2,
  p_attendance_mode IN VARCHAR2,
  p_progression_status IN VARCHAR2,
  p_enrolment_cat IN VARCHAR2,
  p_group_id IN NUMBER,
  p_processing_type IN VARCHAR2,
  p_log_creation_dt OUT NOCOPY DATE
);
PROCEDURE igs_pr_upd_sca_apply (
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_prg_cal_type IN VARCHAR2,
  p_prg_sequence_number IN NUMBER,
  p_application_type IN VARCHAR2,
  p_log_creation_dt IN DATE ,
  p_recommended_outcomes IN OUT NOCOPY NUMBER,
  p_approved_outcomes IN OUT NOCOPY NUMBER,
  p_removed_outcomes IN OUT NOCOPY NUMBER,
  p_message_name OUT NOCOPY VARCHAR2
);
PROCEDURE igs_pr_upd_spo_aply_dt (
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_sequence_number IN NUMBER
);
PROCEDURE igs_pr_upd_spo_maint (
   errbuf  OUT NOCOPY VARCHAR2,
   retcode OUT NOCOPY NUMBER
);
END IGS_PR_GEN_004;

 

/
