--------------------------------------------------------
--  DDL for Package IGS_DA_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_XML_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDA10S.pls 120.0 2005/07/05 11:41:31 appldev noship $ */

  TYPE r_sua_record IS RECORD (
    person_id                 igs_en_su_attempt.person_id%TYPE,
    course_cd                 igs_en_su_attempt.course_cd%TYPE,
    uoo_id                    igs_en_su_attempt.uoo_id%TYPE,
    grade                     igs_as_su_stmptout.grade%TYPE,
    mark                      igs_as_su_stmptout.mark%TYPE,
    s_result_type             igs_as_grd_sch_grade.s_result_type%TYPE,
    gpa                       igs_as_grd_sch_grade.gpa_val%TYPE,
    gpa_cp                    igs_ps_unit_ver.achievable_credit_points%TYPE,
    gpa_qp                    igs_ps_unit_ver.achievable_credit_points%TYPE,
    earned_cp                 igs_ps_unit_ver.achievable_credit_points%TYPE,
    attempted_cp              igs_ps_unit_ver.achievable_credit_points%TYPE
  );

  TYPE t_sua_table IS TABLE OF r_sua_record INDEX BY BINARY_INTEGER;

  sua_table t_sua_table;

  TYPE r_load_record IS RECORD (
    person_id                igs_en_su_attempt.person_id%TYPE,
    course_cd                igs_en_su_attempt.course_cd%TYPE,
    load_cal_type            igs_en_su_attempt.cal_type%TYPE,
    load_ci_sequence_number  igs_en_su_attempt.ci_sequence_number%TYPE,
    cum_gpa                  igs_as_grd_sch_grade.gpa_val%TYPE,
    cum_gpa_cp               igs_ps_unit_ver.achievable_credit_points%TYPE,
    cum_gpa_qp               igs_ps_unit_ver.achievable_credit_points%TYPE,
    cum_earned_cp            igs_ps_unit_ver.achievable_credit_points%TYPE,
    cum_attempted_cp         igs_ps_unit_ver.achievable_credit_points%TYPE);

  TYPE t_load_table IS TABLE OF r_load_record INDEX BY BINARY_INTEGER;

  load_table t_load_table;

-----------------------------------------------------------------------------
--  Record and Table types for
--  student_type_list function
--
  TYPE r_student_type_rec IS RECORD (
     person_type_code      igs_pe_typ_instances_all.person_type_code%TYPE);

  TYPE t_student_type_table IS TABLE OF
     r_student_type_rec INDEX BY BINARY_INTEGER;

   student_type_table t_student_type_table;
-----------------------------------------------------------------------------

  PROCEDURE populate_sua_table
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  );

  PROCEDURE populate_load_table
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  );

  FUNCTION get_sua_gpa_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_sua_gpa_qp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_sua_earned_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_sua_attempted_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_sua_grade
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN VARCHAR2;

  FUNCTION get_sua_mark
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_sua_result_type
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN VARCHAR2;

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

-- ====================================================================================

 FUNCTION get_course_abbr_num
  (
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_evaluation_type              IN CHAR DEFAULT 'A'
  ) RETURN VARCHAR2;

 FUNCTION student_type_list
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE
  ) RETURN VARCHAR2;


 FUNCTION get_unit_repeatable
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE DEFAULT NULL
  ) RETURN VARCHAR2;

 PROCEDURE get_person_details
  (
  p_person_id_code                 IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type            IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id                      OUT NOCOPY hz_parties.party_id%TYPE,
  p_person_number                  OUT NOCOPY hz_parties.party_number%TYPE
  );

 PROCEDURE update_stdnts_err
  (
  p_batch_id   IN igs_da_req_stdnts.batch_id%TYPE,
  p_person_id_code  IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type IN igs_pe_alt_pers_id.person_id_type%TYPE,
  p_report_text IN igs_da_req_stdnts.report_text%TYPE,
  p_error_code IN igs_da_req_stdnts.error_code%TYPE,
  x_return_status  OUT NOCOPY VARCHAR2
  ) ;


 PROCEDURE update_req_students (
  p_batch_id   IN igs_da_req_stdnts.batch_id%TYPE,
  p_person_id_code  IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type IN igs_pe_alt_pers_id.person_id_type%TYPE,
  p_report_text IN igs_da_req_stdnts.report_text%TYPE,
  p_academicsubprogram_codes IN VARCHAR2,
  p_program_code IN igs_da_req_stdnts.program_code%TYPE,
  p_error_code IN igs_da_req_stdnts.error_code%TYPE,
  x_return_status  OUT NOCOPY VARCHAR2
  ) ;

 PROCEDURE insert_gpa
 (
  p_batch_id                       IN igs_pr_stu_acad_stat_int.batch_id%TYPE,
  p_person_id_code                 IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type            IN igs_pe_alt_pers_id.person_id_type%TYPE,
  p_program_code                   IN igs_da_req_stdnts.program_code%TYPE,
  p_alternate_code                 IN igs_pr_stu_acad_stat_int.alternate_code%TYPE,
  p_stat_type                      IN igs_pr_stu_acad_stat_int.stat_type%TYPE,
  p_timeframe                      IN igs_pr_stu_acad_stat_int.timeframe%TYPE,
  p_attempted_credit_points        IN igs_pr_stu_acad_stat_int.attempted_credit_points%TYPE,
  p_earned_credit_points           IN igs_pr_stu_acad_stat_int.earned_credit_points%TYPE,
  p_gpa                            IN igs_pr_stu_acad_stat_int.gpa%TYPE,
  p_gpa_credit_points              IN igs_pr_stu_acad_stat_int.gpa_credit_points%TYPE,
  p_gpa_quality_points             IN igs_pr_stu_acad_stat_int.gpa_quality_points%TYPE,
  x_return_status                  OUT NOCOPY VARCHAR2
  );

PROCEDURE insert_program_completion
  (
  p_batch_id                       IN igs_pr_spa_complete_int.batch_id%TYPE,
  p_person_id_code                 IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type            IN igs_pe_alt_pers_id.person_id_type%TYPE,
  p_program_code                   IN igs_da_req_stdnts.program_code%TYPE,
  p_program_complete               IN VARCHAR2,
  p_program_complete_date          IN VARCHAR2,
  x_return_status                  OUT NOCOPY VARCHAR2
  );

PROCEDURE Submit_Event (
  p_batch_id   IN IGS_DA_REQ_STDNTS.BATCH_ID%TYPE
);

PROCEDURE process_reply_failure
(p_batch_id   IN igs_da_req_stdnts.batch_id%TYPE
);

PROCEDURE update_request_status
( p_batch_id   IN  igs_da_req_stdnts.batch_id%TYPE
);


PROCEDURE Pre_Submit_Event (
  p_batch_id   IN IGS_DA_REQ_STDNTS.BATCH_ID%TYPE
);


END IGS_DA_XML_PKG;

 

/
