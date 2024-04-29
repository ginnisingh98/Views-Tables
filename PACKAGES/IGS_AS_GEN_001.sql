--------------------------------------------------------
--  DDL for Package IGS_AS_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSAS01S.pls 120.0 2005/07/05 12:17:00 appldev noship $ */

  FUNCTION assp_clc_esu_ese_num (
    p_person_id                    IN NUMBER,
    p_exam_cal_type                IN VARCHAR2,
    p_exam_ci_sequence_number      IN NUMBER
  ) RETURN NUMBER;

  FUNCTION assp_clc_suaai_valid (
    p_person_id                    IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_ass_id                       IN     NUMBER,
    p_logical_delete_dt            IN     DATE,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (assp_clc_suaai_valid, WNDS, WNPS);

  FUNCTION assp_clc_week_extnsn (
    p_week_ending_due_dt           IN DATE,
    p_override_due_dt              IN DATE,
    p_num_week_extnsn              IN NUMBER
  ) RETURN NUMBER;

  FUNCTION assp_del_suaai (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION assp_del_suaai_dflt (
    p_person_id                    IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_ass_id                       IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                        IN     NUMBER,
    p_unit_ass_id                   IN NUMBER DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION assp_del_suaap_dflt (
    p_person_id                    IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_ass_pattern_id               IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION assp_del_suaap_suaai (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_creation_dt                  IN     DATE,
    p_ass_id                       IN     NUMBER,
    p_call_from_db_trg             IN     VARCHAR2 DEFAULT 'N',
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION assp_get_actn_msg (
    p_action_type                  IN VARCHAR2,
    p_s_student_todo_type          IN VARCHAR2
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (assp_get_actn_msg, WNDS, WNPS);

  FUNCTION assp_get_ai_a_type (
    p_ass_id IN NUMBER
  ) RETURN VARCHAR2;

  FUNCTION assp_val_sua_display (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_unit_attempt_status          IN     VARCHAR2,
    p_administrative_unit_status   IN     VARCHAR2,
    p_finalised_ind                IN     VARCHAR2 DEFAULT 'N',
    p_include_fail_grade_ind       IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (assp_val_sua_display, WNDS, WNPS);
END igs_as_gen_001;

 

/
