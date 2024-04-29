--------------------------------------------------------
--  DDL for Package IGS_AS_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GEN_005" AUTHID CURRENT_USER AS
/* $Header: IGSAS05S.pls 120.0 2005/07/05 11:43:50 appldev noship $ */

  FUNCTION assp_mnt_suaai_uap (
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN OUT NOCOPY VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION assp_mnt_uapi_suaai (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION assp_set_suao_trans (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_outcome_dt                   IN     DATE,
    p_grade                        IN     VARCHAR2,
    p_grading_schema_cd            IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_translated_grading_schema_cd IN OUT NOCOPY VARCHAR2,
    p_translated_version_number    IN OUT NOCOPY NUMBER,
    p_translated_grade             IN OUT NOCOPY VARCHAR2,
    p_translated_dt                IN OUT NOCOPY DATE,
    p_message_name                 OUT NOCOPY VARCHAR2,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION assp_upd_suaai_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_version_number               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                       IN  NUMBER DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION assp_upd_suaap_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_version_number               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION assp_upd_uai_action (p_ass_id IN igs_as_unitass_item_all.ass_id%TYPE, p_message_name OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN;

  FUNCTION assp_upd_uap_uoo (
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_call_by_db_trg               IN     VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION assp_val_sca_comm (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_include_fail_grade_ind       IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    p_include_related_crs_ind      IN     VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2;

  FUNCTION assp_val_sca_final (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_include_fail_grade_ind       IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    p_include_related_crs_ind      IN     VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (assp_val_sca_final, WNDS, WNPS);

  FUNCTION assp_mnt_suaai_uai (
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_id                       IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN OUT NOCOPY VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_ass_id_usec_unit_ind         IN     VARCHAR2 DEFAULT 'UNIT',
    p_ass_item_id                  IN NUMBER DEFAULT NULL,
    p_group_id                     IN NUMBER DEFAULT NULL,
    p_midterm_mandatory_type_code IN VARCHAR2 DEFAULT NULL,
    p_midterm_weight_qty IN NUMBER  DEFAULT NULL,
    p_final_mandatory_type_code IN VARCHAR2 DEFAULT NULL,
    p_final_weight_qty IN NUMBER DEFAULT NULL,
    p_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    p_gs_version_number  IN NUMBER DEFAULT NULL,
    p_uoo_id IN NUMBER DEFAULT NULL
  ) RETURN BOOLEAN;
  --
  -- Added by DDEY as a part of enhancement Bug # 2162831
  --
  FUNCTION assp_upd_usec_suaai_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;
  --
END igs_as_gen_005;

 

/
