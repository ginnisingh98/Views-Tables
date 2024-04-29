--------------------------------------------------------
--  DDL for Package IGS_AS_DERIVE_GRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_DERIVE_GRADE" AUTHID CURRENT_USER AS
/* $Header: IGSAS59S.pls 115.1 2004/01/29 12:26:32 kdande noship $ */
  --
  -- Procedure to validate the Assessment Item and Unit Section Grading Schema's
  -- mark range and return an error message in case mark range has null values
  -- or gaps
  --
  PROCEDURE validate_ai_us_grd_mark_range (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_unit_cd                      IN VARCHAR2,
    p_usec_grading_schema          IN VARCHAR2,
    p_usec_grading_schema_version  IN NUMBER,
    p_validate_ai_grd_schema       IN VARCHAR2 DEFAULT 'Y',
    p_message_name                 OUT NOCOPY VARCHAR2
  );
  --
  -- Procedure to derive the Student Unit Attempt Outcome Mark and Grade from
  -- Student Unit Attempt Assessment Item Outcome
  --
  PROCEDURE derive_suao_mark_grade_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N',
    p_mark                         OUT NOCOPY NUMBER,
    p_grade                        OUT NOCOPY VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2
  );
  --
  -- Function to derive the Student Unit Attempt Outcome Mark from Student Unit
  -- Attempt Assessment Item Outcome
  --
  -- This function is a overloaded so that it can be called from SQL and PL/SQL
  -- or Java separately so that the error message can be shown to the user in
  -- case of PL/SQL or Java
  --
  FUNCTION derive_suao_mark_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN NUMBER;
  --
  -- Function to derive the Student Unit Attempt Outcome Mark from Student Unit
  -- Attempt Assessment Item Outcome
  --
  FUNCTION derive_suao_mark_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N'
  ) RETURN NUMBER;
  --
  -- Function to check 'Derive Unit Mark from Assessment Item Mark' and if the
  -- Unit Section is not Submitted then derive the Student Unit Attempt Outcome
  -- Mark from Student Unit Attempt Assessment Item Outcome Marks if the Outcome
  -- is neither Finalized nor Manually Overridden. If the Mark and Grade are not
  -- to be derived then the passed on mark and grade will be returned back.
  --
  FUNCTION derive_suao_mark_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_mark                         IN NUMBER,
    p_grade                        IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N'
  ) RETURN NUMBER;
  --
  -- Function to derive the Student Unit Attempt Outcome Grade from Student Unit
  -- Attempt Assessment Item Outcome
  --
  -- This function is a overloaded so that it can be called from SQL and PL/SQL
  -- or Java separately so that the error message can be shown to the user in
  -- case of PL/SQL or Java
  --
  FUNCTION derive_suao_grade_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2;
  --
  -- Function to derive the Student Unit Attempt Outcome Grade from Student Unit
  -- Attempt Assessment Item Outcome
  --
  FUNCTION derive_suao_grade_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2;
  --
  -- Function to check 'Derive Unit Mark from Assessment Item Mark' and if the
  -- Unit Section is not Submitted then derive the Student Unit Attempt Outcome
  -- Grade from Student Unit Attempt Assessment Item Outcome Marks if the Outcome
  -- is neither Finalized nor Manually Overridden. If the Mark and Grade are not
  -- to be derived then the passed on mark and grade will be returned back.
  --
  FUNCTION derive_suao_grade_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_mark                         IN NUMBER,
    p_grade                        IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2;
  --
  -- Function to derive Student's Assessment Status
  --
  -- 1st time the student enrolls in unit; Assessment Status = 'First Attempt'
  -- 2nd time the student enrolls in unit section; Assessment Status =
  -- 'Second Attempt', so and so forth
  --
  FUNCTION get_assessment_status (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_unit_cd                      IN VARCHAR2
  ) RETURN VARCHAR2;
  --
  -- Function that derives the Grading Period for a given Teaching Calendar
  --
  FUNCTION get_grading_period_code (
    p_teach_cal_type               IN VARCHAR2,
    p_teach_ci_sequence_number     IN NUMBER
  ) RETURN VARCHAR2;
END igs_as_derive_grade;

 

/
