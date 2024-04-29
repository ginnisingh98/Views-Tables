--------------------------------------------------------
--  DDL for Package GHR_CPDF_EHRIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_EHRIS" AUTHID CURRENT_USER AS
/* $Header: ghrehris.pkh 120.3.12010000.3 2009/07/27 10:13:45 vmididho ship $ */

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

  PROCEDURE get_from_per_wrkadd --Bug# 4725292
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
             p_sr_assignment_id  IN NUMBER
            ,p_sr_report_date    IN DATE
            ,p_sr_ghr_cpdf_temp  IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
             );
  PROCEDURE calc_is_foreign_duty_station
             (p_report_date  IN DATE
             );
  PROCEDURE get_suffix_lname(p_last_name   in  varchar2,
                             p_report_date in  date,
                             p_suffix      out  NOCOPY varchar2,
                             p_lname       out  NOCOPY varchar2);

  PROCEDURE insert_row;
  PROCEDURE purge_suppression;

  PROCEDURE populate_ghr_cpdf_temp (p_agency       IN VARCHAR2,
                                    -- 8486208 added new parameter
                                    p_agency_group IN VARCHAR2,
                                    p_report_date  IN DATE,
                                    p_count_only   IN BOOLEAN);

  TYPE t_tag_type IS RECORD
	(tagname VARCHAR2(240),
	 tagvalue VARCHAR2(4000));
  TYPE t_tags IS TABLE OF t_tag_type INDEX BY BINARY_INTEGER;
  PROCEDURE WriteTagValues(p_cpdf_status GHR_CPDF_TEMP%rowtype,p_tags OUT NOCOPY t_tags);
  PROCEDURE WriteXMLvalues(p_l_fp utl_file.file_type, p_tags t_tags );
  PROCEDURE WriteAsciivalues(p_l_fp utl_file.file_type, p_tags t_tags,p_gen_txt_file IN VARCHAR2);

  PROCEDURE ehri_status_main
  ( errbuf              OUT NOCOPY VARCHAR2
   ,retcode             OUT NOCOPY NUMBER
   ,p_report_name       IN VARCHAR2
   ,p_agency_code       IN VARCHAR2
   ,p_agency_subelement IN VARCHAR2
   -- 8486208 Added new parameter
   ,p_agency_group      IN VARCHAR2
   ,p_report_date       IN VARCHAR2
   ,p_gen_xml_file IN VARCHAR2 DEFAULT 'N'
   ,p_gen_txt_file IN VARCHAR2 DEFAULT 'Y'
   );

  PROCEDURE WritetoFile (p_input_file_name VARCHAR2
						 ,p_gen_xml_file IN VARCHAR2
						 ,p_gen_txt_file IN VARCHAR2);

  g_ghr_cpdf_temp          GHR_CPDF_TEMP%ROWTYPE;
  g_agency                 VARCHAR2(04);
  g_report_date            DATE;
  g_assignment_id          PER_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
  g_person_id              PER_ASSIGNMENTS_F.PERSON_ID%TYPE;
  g_position_id            PER_ASSIGNMENTS_F.POSITION_ID%TYPE;
  g_grade_id               PER_ASSIGNMENTS_F.GRADE_ID%TYPE;
  g_job_id                 PER_ASSIGNMENTS_F.JOB_ID%TYPE;
  g_location_id            PER_ASSIGNMENTS_F.LOCATION_ID%TYPE;
  g_appointment_date       PER_PEOPLE_V.HIRE_DATE%TYPE;
  g_business_group_id      PER_ASSIGNMENTS_F.business_group_id%TYPE;
  -- Begin Bug# 4753092
  g_message_name           	ghr_process_log.message_name%type;
  -- End Bug# 4753092
END ghr_cpdf_ehris;

/
