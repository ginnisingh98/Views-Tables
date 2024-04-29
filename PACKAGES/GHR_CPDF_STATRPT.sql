--------------------------------------------------------
--  DDL for Package GHR_CPDF_STATRPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_STATRPT" AUTHID CURRENT_USER AS
/* $Header: ghrcpdfs.pkh 120.1.12000000.2 2007/03/01 07:22:25 vmididho noship $ */

  CPDF_STATRPT_ERROR EXCEPTION;
  PROCEDURE initialize_record;
  PROCEDURE cleanup_table;
  PROCEDURE get_from_history_asgnei
             (
             p_sr_assignment_id IN NUMBER
            ,p_sr_report_date IN DATE
            ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE get_from_history_people
             (
             p_sr_person_id IN NUMBER
            ,p_sr_report_date IN DATE
            ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE get_from_history_ancrit
             (
             p_sr_person_id IN NUMBER
            ,p_sr_report_date IN DATE
            ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE get_from_history_peopei
             (
             p_sr_person_id IN NUMBER
            ,p_sr_report_date IN DATE
            ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE get_from_history_posiei
             (
             p_sr_position_id IN NUMBER
            ,p_sr_report_date IN DATE
            ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE get_from_history_gradef
             (
             p_sr_grade_id IN NUMBER
            ,p_sr_report_date IN DATE
            ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE get_from_history_jobdef
             (
             p_sr_job_id IN NUMBER
            ,p_sr_report_date IN DATE
            ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE get_from_history_dutsta
             (
             p_sr_location_id IN NUMBER
            ,p_sr_report_date IN DATE
            ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE get_from_history_payele
             (
             p_sr_assignment_id IN NUMBER
            ,p_sr_report_date IN DATE
            ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE calc_is_foreign_duty_station
             (p_report_date  IN DATE
             );
  PROCEDURE get_suffix_lname(p_last_name   IN  VARCHAR2,
                             p_report_date IN  DATE,
                             p_suffix      OUT NOCOPY VARCHAR2,
                             p_lname       OUT NOCOPY VARCHAR2);
  PROCEDURE insert_row;
  PROCEDURE purge_suppression;
  PROCEDURE populate_ghr_cpdf_temp (p_agency IN VARCHAR2,
                                    p_report_date IN DATE);

  g_ghr_cpdf_temp          GHR_CPDF_TEMP%ROWTYPE;
  g_agency                 VARCHAR2(04);
  g_report_date            DATE;
  g_assignment_id          PER_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
  g_person_id              PER_ASSIGNMENTS_F.PERSON_ID%TYPE;
  g_position_id            PER_ASSIGNMENTS_F.POSITION_ID%TYPE;
  g_grade_id               PER_ASSIGNMENTS_F.GRADE_ID%TYPE;
  g_job_id                 PER_ASSIGNMENTS_F.JOB_ID%TYPE;
  g_location_id            PER_ASSIGNMENTS_F.LOCATION_ID%TYPE;
  g_appointment_date   	   PER_PEOPLE_V.HIRE_DATE%TYPE;
  --Begin Bug# 4168162
  g_message_name           	ghr_process_log.message_name%type;
  --End Bug# 4168162

END ghr_cpdf_statrpt;

 

/
