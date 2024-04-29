--------------------------------------------------------
--  DDL for Package IGS_AS_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSAS04S.pls 120.0 2005/07/05 11:30:26 appldev noship $ */
  --
  --
  --
  FUNCTION assp_get_uap_cd (
    p_ass_pattern_id               IN NUMBER
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (assp_get_uap_cd, WNDS);

  FUNCTION assp_ins_dflt_evsa (
    p_venue_cd                     IN     VARCHAR2,
    p_exam_cal_type                IN     VARCHAR2,
    p_exam_ci_sequence_number      IN     NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION assp_ins_get (
    p_keying_who                   IN     VARCHAR2,
    p_sheet_number                 IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_sequence_number              IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_location_cd                  IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_include_discont_ind          IN     VARCHAR2,
    p_sort_by                      IN     VARCHAR2,
    p_keying_time                  OUT NOCOPY DATE
  ) RETURN BOOLEAN;

  FUNCTION assp_ins_mark_sheet (
    p_assess_cal_type              IN     VARCHAR2,
    p_assess_sequence_number       IN     NUMBER,
    p_teach_cal_type               IN     VARCHAR2,
    p_teach_sequence_number        IN     NUMBER,
    p_unit_org_unit_cd             IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_location_cd                  IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_include_discont_ind          IN     VARCHAR2,
    p_sort_by                      IN     VARCHAR2,
    p_group_sequence_number        OUT NOCOPY NUMBER,
    p_grading_period_cd            IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_call_number                  IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION assp_ins_scap_lovall (
    p_person_id                    IN     igs_as_spl_cons_appl.person_id%TYPE,
    p_course_cd                    IN     igs_as_spl_cons_appl.course_cd%TYPE,
    p_unit_cd                      IN     igs_as_spl_cons_appl.unit_cd%TYPE,
    p_cal_type                     IN     igs_as_spl_cons_appl.cal_type%TYPE,
    p_ci_sequence_number           IN     NUMBER,
    p_received_dt                  IN     DATE,
    p_spcl_consideration_cat       IN     VARCHAR2,
    p_estimated_processing_days    IN     NUMBER,
    p_sought_outcome               IN     VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER,
    /*ijeddy, 19-June-2003 2884615*/
    p_notified_date                IN     DATE
  ) RETURN BOOLEAN;

  FUNCTION assp_ins_suaai_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_ass_id                       IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_ass_id_usec_unit_ind         IN     VARCHAR2 DEFAULT 'UNIT', -- Added by DDEY as a part of enhancement Bug # 2162831
    p_creation_dt                  IN     DATE,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_ass_item_id                  IN NUMBER DEFAULT NULL,
    p_group_id                     IN NUMBER DEFAULT NULL,
    p_midterm_mandatory_type_code  IN VARCHAR2 DEFAULT NULL,
    p_midterm_weight_qty           IN NUMBER DEFAULT NULL,
    p_final_mandatory_type_code IN VARCHAR2 DEFAULT NULL,
    p_final_weight_qty IN NUMBER DEFAULT NULL,
    p_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    p_gs_version_number  IN NUMBER DEFAULT NULL,
    p_uoo_id            IN  NUMBER DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION assp_ins_suaap_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_ass_pattern_id               IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION assp_ins_suaap_suaai (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_creation_dt                  IN     DATE,
    p_s_default_ind                IN     VARCHAR2 DEFAULT 'N',
    p_call_from_db_trg             IN     VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION assp_ins_transcript (
    p_course_org_unit_cd           IN     VARCHAR2,
    p_course_group_cd              IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_course_location_cd           IN     VARCHAR2,
    p_course_attendance_mode       IN     VARCHAR2,
    p_course_award                 IN     VARCHAR2 DEFAULT 'BOTH',
    p_course_attempt_status        IN     VARCHAR2,
    p_progression_status           IN     VARCHAR2,
    p_graduand_status              IN     VARCHAR2,
    p_person_id_group              IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_transcript_type              IN     VARCHAR2,
    p_include_fail_grades_ind      IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    p_extract_course_cd            IN     VARCHAR2,
    p_include_related_crs_ind      IN     VARCHAR2 DEFAULT 'N',
    p_order_by                     IN     VARCHAR2 DEFAULT 'YEAR',
    p_external_order_by            IN     VARCHAR2 DEFAULT 'SURNAME',
    p_correspondence_ind           IN     VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_reference_number             OUT NOCOPY NUMBER
  ) RETURN BOOLEAN;

  FUNCTION assp_get_uapi_ap (
    p_ass_pattern_id               IN NUMBER,
    p_ass_id                       IN NUMBER
  ) RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (assp_get_uapi_ap, WNDS, WNDS);

  PROCEDURE asss_ins_transcript (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_course_org_unit_cd           IN     VARCHAR2,
    p_course_group_cd              IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_course_location_cd           IN     VARCHAR2,
    p_course_attendance_mode       IN     VARCHAR2,
    p_course_award                 IN     VARCHAR2 DEFAULT 'BOTH',
    p_course_attempt_status        IN     VARCHAR2,
    p_progression_status           IN     VARCHAR2,
    p_graduand_status              IN     VARCHAR2,
    p_person_id_group              IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_transcript_type              IN     VARCHAR2,
    p_include_fail_grades_ind      IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    p_extract_course_cd            IN     VARCHAR2,
    p_include_related_crs_ind      IN     VARCHAR2 DEFAULT 'N',
    p_order_by                     IN     VARCHAR2 DEFAULT 'YEAR',
    p_external_order_by            IN     VARCHAR2 DEFAULT 'SURNAME',
    p_correspondence_ind           IN     VARCHAR2 DEFAULT 'N',
    p_org_id                       IN     NUMBER
  );

END igs_as_gen_004;

 

/
