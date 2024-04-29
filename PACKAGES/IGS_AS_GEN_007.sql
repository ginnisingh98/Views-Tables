--------------------------------------------------------
--  DDL for Package IGS_AS_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GEN_007" AUTHID CURRENT_USER AS
/* $Header: IGSAS07S.pls 120.0 2005/07/05 11:44:52 appldev noship $ */
  PROCEDURE assp_ins_suaai_tri (
    p_acad_perd_cal_type           IN     VARCHAR2,
    p_acad_perd_sequence_number    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_teach_perd_cal_type          IN     VARCHAR2,
    p_teach_perd_sequence_number   IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_person_id                    IN     NUMBER,
    p_ass_id                       IN     NUMBER,
    p_tracking_type                IN     VARCHAR2,
    p_tracking_status              IN     VARCHAR2,
    p_tracking_start_dt            IN     DATE,
    p_tracking_item_originator     IN     NUMBER,
    p_creation_dt                  OUT NOCOPY DATE
  );

  PROCEDURE assp_ins_suao_hist (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_outcome_dt                   IN     DATE,
    p_new_grading_schema_cd        IN     VARCHAR2,
    p_new_version_number           IN     NUMBER,
    p_new_grade                    IN     VARCHAR2,
    p_new_s_grade_crtn_mthd_tp     IN     VARCHAR2,
    p_new_finalised_outcome_ind    IN     VARCHAR2,
    p_new_mark                     IN     NUMBER,
    p_new_number_times_keyed       IN     NUMBER,
    p_new_trnsltd_grdng_schema_cd  IN     VARCHAR2,
    p_new_trnsltd_version_number   IN     NUMBER,
    p_new_translated_grade         IN     VARCHAR2,
    p_new_translated_dt            IN     DATE,
    p_new_update_who               IN     VARCHAR2,
    p_new_update_on                IN     DATE,
    p_old_grading_schema_cd        IN     VARCHAR2,
    p_old_version_number           IN     NUMBER,
    p_old_grade                    IN     VARCHAR2,
    p_old_s_grade_crtn_mthd_tp     IN     VARCHAR2,
    p_old_finalised_outcome_ind    IN     VARCHAR2,
    p_old_mark                     IN     NUMBER,
    p_old_number_times_keyed       IN     NUMBER,
    p_old_trnsltd_grdng_schema_cd  IN     VARCHAR2,
    p_old_trnsltd_version_number   IN     NUMBER,
    p_old_translated_grade         IN     VARCHAR2,
    p_old_translated_dt            IN     DATE,
    p_old_update_who               IN     VARCHAR2,
    p_old_update_on                IN     DATE,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  );

  PROCEDURE assp_prc_suaai_todo (
    p_acad_perd_cal_type           IN     VARCHAR2,
    p_acad_perd_sequence_number    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_teach_perd_cal_type          IN     VARCHAR2,
    p_teach_perd_sequence_number   IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_creation_dt                  OUT NOCOPY DATE,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER DEFAULT NULL
  );

  PROCEDURE assp_prc_uai_actn_dt (
    p_acad_perd_cal_type           IN     VARCHAR2,
    p_acad_perd_sequence_number    IN     NUMBER,
    p_teach_perd_cal_type          IN     VARCHAR2,
    p_teach_perd_sequence_number   IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_assessment_type              IN     VARCHAR2,
    p_ass_id                       IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_creation_dt                  OUT NOCOPY DATE
  );

  PROCEDURE assp_prc_uap_actn_dt (
    p_acad_perd_cal_type           IN     VARCHAR2,
    p_acad_perd_sequence_number    IN     NUMBER,
    p_teach_perd_cal_type          IN     VARCHAR2,
    p_teach_perd_sequence_number   IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_creation_dt                  IN OUT NOCOPY DATE
  );

  PROCEDURE assp_upd_finls_outcm (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_assess_calendar              IN     VARCHAR2,
    p_teaching_calendar            IN     VARCHAR2,
    p_crs_grp_cd                   IN     VARCHAR2,
    p_crs_cd                       IN     VARCHAR2,
    p_crs_org_unt_cd               IN     VARCHAR2,
    p_crs_lctn_cd                  IN     VARCHAR2,
    p_crs_attd_md                  IN     VARCHAR2,
    p_unt_cd                       IN     VARCHAR2,
    p_unt_org_unt_cd               IN     VARCHAR2,
    p_unt_lctn_cd                  IN     VARCHAR2,
    p_u_mode                       IN     VARCHAR2,
    p_u_class                      IN     VARCHAR2,
    p_allow_invalid_ind            IN     VARCHAR2,
    p_org_id                       IN     NUMBER
  );

  PROCEDURE assp_ins_suaai_todo (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                            VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_old_unit_attempt_status      IN     VARCHAR2,
    p_new_unit_attempt_status      IN     VARCHAR2,
    p_old_location_cd              IN     VARCHAR2,
    p_new_location_cd              IN     VARCHAR2,
    p_old_unit_class               IN     VARCHAR2,
    p_new_unit_class               IN     VARCHAR2,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  );
END igs_as_gen_007;

 

/
