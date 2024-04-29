--------------------------------------------------------
--  DDL for Package IGS_PR_ACAD_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_ACAD_DETAILS" AUTHID CURRENT_USER AS
/* $Header: IGSPR34S.pls 120.0 2005/07/05 12:57:55 appldev noship $ */

  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added uoo_id field to the r_sua_record RECORD
  --
  TYPE r_sua_record IS RECORD (
    person_id                 igs_en_su_attempt.person_id%TYPE,
    course_cd                 igs_en_su_attempt.course_cd%TYPE,
    unit_cd                   igs_en_su_attempt.unit_cd%TYPE,
    version_number            igs_en_su_attempt.version_number%TYPE,
    teach_cal_type            igs_en_su_attempt.cal_type%TYPE,
    teach_ci_sequence_number  igs_en_su_attempt.ci_sequence_number%TYPE,
    grade                     igs_as_su_stmptout.grade%TYPE,
    mark                      igs_as_su_stmptout.mark%TYPE,
    gpa                       igs_as_grd_sch_grade.gpa_val%TYPE,
    gpa_cp                    igs_ps_unit_ver.achievable_credit_points%TYPE,
    gpa_qp                    igs_ps_unit_ver.achievable_credit_points%TYPE,
    earned_cp                 igs_ps_unit_ver.achievable_credit_points%TYPE,
    attempted_cp              igs_ps_unit_ver.achievable_credit_points%TYPE,
    uoo_id                    igs_en_su_attempt.uoo_id%TYPE DEFAULT NULL
  );

  TYPE t_sua_table IS TABLE OF r_sua_record INDEX BY BINARY_INTEGER;

  sua_table t_sua_table;

  TYPE r_load_record IS RECORD (
    person_id                igs_en_su_attempt.person_id%TYPE,
    course_cd                igs_en_su_attempt.course_cd%TYPE,
    load_cal_type            igs_en_su_attempt.cal_type%TYPE,
    load_ci_sequence_number  igs_en_su_attempt.ci_sequence_number%TYPE,
    load_gpa                 igs_as_grd_sch_grade.gpa_val%TYPE,
    load_gpa_cp              igs_ps_unit_ver.achievable_credit_points%TYPE,
    load_gpa_qp              igs_ps_unit_ver.achievable_credit_points%TYPE,
    load_earned_cp           igs_ps_unit_ver.achievable_credit_points%TYPE,
    load_attempted_cp        igs_ps_unit_ver.achievable_credit_points%TYPE,
    cum_gpa                  igs_as_grd_sch_grade.gpa_val%TYPE,
    cum_gpa_cp               igs_ps_unit_ver.achievable_credit_points%TYPE,
    cum_gpa_qp               igs_ps_unit_ver.achievable_credit_points%TYPE,
    cum_earned_cp            igs_ps_unit_ver.achievable_credit_points%TYPE,
    cum_attempted_cp         igs_ps_unit_ver.achievable_credit_points%TYPE);

  TYPE t_load_table IS TABLE OF r_load_record INDEX BY BINARY_INTEGER;

  load_table t_load_table;

  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the PROCEDURE populate_sua_table
  --
  PROCEDURE populate_sua_table
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE DEFAULT NULL
  );

  PROCEDURE populate_load_table
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  );
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_gpa
  --
  FUNCTION get_sua_gpa
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE DEFAULT NULL
  ) RETURN NUMBER;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_gpa_cp
  --
  FUNCTION get_sua_gpa_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE DEFAULT NULL
  ) RETURN NUMBER;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_gpa_qp
  --
  FUNCTION get_sua_gpa_qp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE DEFAULT NULL
  ) RETURN NUMBER;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_earned_cp
  --
  FUNCTION get_sua_earned_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE DEFAULT NULL
  ) RETURN NUMBER;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_attempted_cp
  --
  FUNCTION get_sua_attempted_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE DEFAULT NULL
  ) RETURN NUMBER;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_grade
  --
  FUNCTION get_sua_grade
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE DEFAULT NULL
  ) RETURN VARCHAR2;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_mark
  --
  FUNCTION get_sua_mark
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_sua_yop
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE
  ) RETURN VARCHAR2;

  FUNCTION get_load_gpa
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_load_gpa_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_load_gpa_qp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_load_earned_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_load_attempted_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_cum_gpa
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_cum_gpa_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_cum_gpa_qp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_cum_earned_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_cum_attempted_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

END IGS_PR_ACAD_DETAILS;

 

/
