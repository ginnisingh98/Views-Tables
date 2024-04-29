--------------------------------------------------------
--  DDL for Package Body HR_VIEW_ALERT_TRNSLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_VIEW_ALERT_TRNSLT" AS
/* $Header: pervatsl.pkb 115.3 2003/05/27 09:43:32 jrstewar noship $ */
--
-- -----------------------------------------------------------------------------
--
-- Get's a transalted location code for a language and location_id
--
FUNCTION location(p_language IN VARCHAR2
                 ,p_location_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.location(p_language
                                     ,p_location_id);
  --
END location;
--
-- -----------------------------------------------------------------------------
--
-- Get's an Organization Name for a language and organization_id
--
FUNCTION organization(p_language IN VARCHAR2
                     ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.organization(p_language
                                         ,p_organization_id);
  --
END organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a job name for a job_id
--
FUNCTION job(p_job_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.job(p_job_id);
  --
END job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position name for a job_id
--
FUNCTION position(p_position_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.position(p_position_id);
  --
END position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade name for a job_id
--
FUNCTION grade(p_grade_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.grade(p_grade_id);
  --
END grade;
--
--------------------------------------------------------------------------------
--
-- Get the meaning of a lookup in the language of a particular person.
--
--
FUNCTION psn_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                              ,p_lookup_code   IN VARCHAR2
                              ,p_person_id     IN NUMBER)
          RETURN fnd_lookup_values.meaning%TYPE IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_lng_decode_lookup(p_lookup_type
                                                  ,p_lookup_code
                                                  ,p_person_id);
  --
END psn_lng_decode_lookup;
--
--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for a person and location_id
--
FUNCTION psn_lng_location(p_person_id   IN NUMBER
                         ,p_location_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_lng_location(p_person_id
                                             ,p_location_id);
  --
END psn_lng_location;
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for the primary assignment supervisor of a person_id
-- for a given location_id
--
FUNCTION psn_sup_lng_location(p_person_id   IN NUMBER
                             ,p_location_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_sup_lng_location(p_person_id
                                                 ,p_location_id);
  --
END psn_sup_lng_location;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name for a person and organization_id
--
FUNCTION psn_lng_organization(p_person_id   IN NUMBER
                             ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_lng_organization(p_person_id
                                                 ,p_organization_id);
  --
END psn_lng_organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name for the primary assignment supervisor of
-- a person_id for a given organization_id
--
FUNCTION psn_sup_lng_organization(p_person_id       IN NUMBER
                                 ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_sup_lng_organization(p_person_id
                                                     ,p_organization_id);
  --
END psn_sup_lng_organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Job Name for a person and job_id
--
FUNCTION psn_lng_job(p_person_id      IN NUMBER
                    ,p_job_id         IN NUMBER)
          RETURN VARCHAR2 IS
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_lng_job(p_person_id
                                        ,p_job_id);
  --
END psn_lng_job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Job Name for a person and job_id
--
FUNCTION psn_sup_lng_job(p_person_id     IN NUMBER
                        ,p_job_id        IN NUMBER)
          RETURN VARCHAR2 IS
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_sup_lng_job(p_person_id
                                            ,p_job_id);
  --
END psn_sup_lng_job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position Name for a person and position_id
--
--
FUNCTION psn_lng_position(p_person_id         IN NUMBER
                         ,p_position_id       IN NUMBER)
          RETURN VARCHAR2 IS
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_lng_position(p_person_id
                                             ,p_position_id);
  --
END psn_lng_position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position Name for a person and position_id
--
--
FUNCTION psn_sup_lng_position(p_person_id     IN NUMBER
                             ,p_position_id   IN NUMBER)
          RETURN VARCHAR2 IS
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_sup_lng_position(p_person_id
                                                 ,p_position_id);
  --
END psn_sup_lng_position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade Name for a person and grade_id
--
--
FUNCTION psn_lng_grade(p_person_id      IN NUMBER
                      ,p_grade_id       IN NUMBER)
          RETURN VARCHAR2 IS
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_lng_grade(p_person_id
                                          ,p_grade_id);
  --
END psn_lng_grade;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade Name for a person and grade_id
--
--
FUNCTION psn_sup_lng_grade(p_person_id  IN NUMBER
                          ,p_grade_id   IN NUMBER)
          RETURN VARCHAR2 IS
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.psn_sup_lng_grade(p_person_id
                                              ,p_grade_id);
  --
END psn_sup_lng_grade;
--
--------------------------------------------------------------------------------
--  Returns Lookup Meaning for a given assignment language.
--
--
FUNCTION asg_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                              ,p_lookup_code   IN VARCHAR2
                              ,p_assignment_id IN NUMBER)
          RETURN fnd_lookup_values.meaning%TYPE IS
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.asg_lng_decode_lookup(
                               p_lookup_type
                              ,p_lookup_code
                              ,p_assignment_id);
  --
END asg_lng_decode_lookup;
--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for a given assignment_id and location_id
--
FUNCTION asg_lng_location(p_assignment_id   IN NUMBER
                         ,p_location_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.asg_lng_location(p_assignment_id
                                             ,p_location_id);
  --
END asg_lng_location;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name in the language required by for the assignment_id
-- and organization_id
--
FUNCTION asg_lng_organization(p_assignment_id   IN NUMBER
                             ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.asg_lng_organization(p_assignment_id
                                                 ,p_organization_id);
  --
END asg_lng_organization;
--
--------------------------------------------------------------------------------
-- Returns Lookup Meaning for a given language for a assignment supervisor.
--
--
FUNCTION asg_sup_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                                  ,p_lookup_code   IN VARCHAR2
                                  ,p_assignment_id IN NUMBER)

           RETURN fnd_lookup_values.meaning%TYPE IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.asg_sup_lng_decode_lookup(p_lookup_type
                                                      ,p_lookup_code
                                                      ,p_assignment_id);
  --
END  asg_sup_lng_decode_lookup;
--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for the assignment supervisor of an assignment_id
-- for a given location_id
--
FUNCTION asg_sup_lng_location(p_assignment_id   IN NUMBER
                             ,p_location_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.asg_sup_lng_location(p_assignment_id
                                                 ,p_location_id);
  --
END asg_sup_lng_location;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name in the language required by the assignment
-- supervisor for a given assignment_id and organization_id
--
FUNCTION asg_sup_lng_organization(p_assignment_id       IN NUMBER
                                 ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.asg_sup_lng_organization(p_assignment_id
                                                     ,p_organization_id);
  --
END asg_sup_lng_organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a job Name in the language required by the assignment
-- supervisor for a given assignment_id and job_id
--
--
FUNCTION asg_sup_lng_job(p_assignment_id    IN NUMBER
                        ,p_job_id           IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.asg_sup_lng_job(p_assignment_id
                                            ,p_job_id);
  --
END asg_sup_lng_job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position Name in the language required by the assignment
-- supervisor for a given assignment_id and position_id
--
--
FUNCTION asg_sup_lng_position(p_assignment_id  IN NUMBER
                             ,p_position_id    IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.asg_sup_lng_position(p_assignment_id
                                                 ,p_position_id);
  --
END asg_sup_lng_position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade Name in the language required by the assignment
-- supervisor for a given assignment_id and grade_id
--
--
FUNCTION asg_sup_lng_grade(p_assignment_id  IN NUMBER
                          ,p_grade_id       IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.asg_sup_lng_grade(p_assignment_id
                                              ,p_grade_id);
  --
END asg_sup_lng_grade;
--
--
--------------------------------------------------------------------------------
-- Returns Lookup Meaning for a given language for a primary assignment
-- supervisor.
--
--
FUNCTION pasg_sup_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                                   ,p_lookup_code   IN VARCHAR2
                                   ,p_assignment_id IN NUMBER)

          RETURN fnd_lookup_values.meaning%TYPE IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.pasg_sup_lng_decode_lookup(p_lookup_type
                                                       ,p_lookup_code
                                                       ,p_assignment_id);
  --
END pasg_sup_lng_decode_lookup;
--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for the primary assignment supervisor of an
-- assignment_id for a given location_id
--
FUNCTION pasg_sup_lng_location(p_assignment_id   IN NUMBER
                             ,p_location_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.pasg_sup_lng_location(p_assignment_id
                                                  ,p_location_id);
  --
END pasg_sup_lng_location;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name in the language required by the primary assignment
-- supervisor for a given assignment_id and organization_id
--
FUNCTION pasg_sup_lng_organization(p_assignment_id   IN NUMBER
                                  ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.pasg_sup_lng_organization(p_assignment_id
                                                      ,p_organization_id);
  --
END pasg_sup_lng_organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a job Name in the language required by the primary assignment
-- job for a given assignment_id and job_id
--
FUNCTION pasg_sup_lng_job(p_assignment_id IN NUMBER
                         ,p_job_id        IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.pasg_sup_lng_job(p_assignment_id
                                             ,p_job_id);
  --
END pasg_sup_lng_job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position Name in the language required by the primary assignment
-- for a given assignment_id and position_id
--
FUNCTION pasg_sup_lng_position(p_assignment_id IN NUMBER
                              ,p_position_id   IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.pasg_sup_lng_position(p_assignment_id
                                                 ,p_position_id);
  --
END pasg_sup_lng_position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade Name in the language required by the primary assignment
-- for a given assignment_id and grade_id
--
FUNCTION pasg_sup_lng_grade(p_assignment_id IN NUMBER
                           ,p_grade_id      IN NUMBER)
          RETURN VARCHAR2 IS
--
BEGIN
  --
  RETURN hr_bpl_alert_trnslt.pasg_sup_lng_grade(p_assignment_id
                                               ,p_grade_id);
  --
END pasg_sup_lng_grade;

END HR_VIEW_ALERT_TRNSLT;

/
