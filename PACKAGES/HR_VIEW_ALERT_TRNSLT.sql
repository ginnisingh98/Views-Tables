--------------------------------------------------------
--  DDL for Package HR_VIEW_ALERT_TRNSLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_VIEW_ALERT_TRNSLT" AUTHID CURRENT_USER AS
/* $Header: pervatsl.pkh 115.2 2003/05/27 09:43:09 jrstewar noship $ */
--
-- -----------------------------------------------------------------------
--
-- Globals used to cache location code.
--
g_location_code       VARCHAR2(60);
g_location_language   VARCHAR2(4);
g_location_id         NUMBER;
--
FUNCTION location(p_language IN VARCHAR2
                 ,p_location_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION organization(p_language         IN VARCHAR2
                     ,p_organization_id  IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION job(p_job_id IN  NUMBER)
          RETURN VARCHAR2;
--
FUNCTION position(p_position_id IN  NUMBER)
          RETURN VARCHAR2;
--
FUNCTION grade(p_grade_id IN  NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                              ,p_lookup_code   IN VARCHAR2
                              ,p_person_id     IN NUMBER)

          RETURN fnd_lookup_values.meaning%TYPE;
--
FUNCTION psn_sup_lng_location(p_person_id   IN NUMBER
                            ,p_location_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_lng_location(p_person_id   IN NUMBER
                     ,p_location_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_lng_organization(p_person_id       IN NUMBER
                             ,p_organization_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_sup_lng_organization(p_person_id       IN NUMBER
                                 ,p_organization_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_lng_job(p_person_id      IN NUMBER
                    ,p_job_id         IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_sup_lng_job(p_person_id     IN NUMBER
                        ,p_job_id        IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_lng_position(p_person_id         IN NUMBER
                         ,p_position_id       IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_sup_lng_position(p_person_id     IN NUMBER
                             ,p_position_id   IN NUMBER)
          RETURN VARCHAR2;

FUNCTION psn_lng_grade(p_person_id      IN NUMBER
                      ,p_grade_id       IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_sup_lng_grade(p_person_id  IN NUMBER
                          ,p_grade_id   IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                              ,p_lookup_code   IN VARCHAR2
                              ,p_assignment_id IN NUMBER)
          RETURN fnd_lookup_values.meaning%TYPE;
--
FUNCTION asg_lng_location(p_assignment_id   IN NUMBER
                         ,p_location_id     IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_lng_organization(p_assignment_id        IN NUMBER
                                  ,p_organization_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_sup_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                                  ,p_lookup_code   IN VARCHAR2
                                  ,p_assignment_id IN NUMBER)
         RETURN fnd_lookup_values.meaning%TYPE;
--
FUNCTION asg_sup_lng_location(p_assignment_id   IN NUMBER
                             ,p_location_id     IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_sup_lng_organization(p_assignment_id   IN NUMBER
                                 ,p_organization_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_sup_lng_job(p_assignment_id    IN NUMBER
                        ,p_job_id           IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_sup_lng_position(p_assignment_id  IN NUMBER
                             ,p_position_id    IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_sup_lng_grade(p_assignment_id  IN NUMBER
                          ,p_grade_id       IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION pasg_sup_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                                   ,p_lookup_code   IN VARCHAR2
                                   ,p_assignment_id IN NUMBER)
          RETURN fnd_lookup_values.meaning%TYPE;
--
FUNCTION pasg_sup_lng_location(p_assignment_id IN NUMBER
                              ,p_location_id   IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION pasg_sup_lng_organization(p_assignment_id   IN NUMBER
                                  ,p_organization_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION pasg_sup_lng_job(p_assignment_id IN NUMBER
                         ,p_job_id        IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION pasg_sup_lng_position(p_assignment_id IN NUMBER
                              ,p_position_id   IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION pasg_sup_lng_grade(p_assignment_id IN NUMBER
                           ,p_grade_id      IN NUMBER)
          RETURN VARCHAR2;
--
END HR_VIEW_ALERT_TRNSLT;

 

/
