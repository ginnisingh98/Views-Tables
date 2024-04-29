--------------------------------------------------------
--  DDL for Package HR_BPL_ALERT_TRNSLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BPL_ALERT_TRNSLT" AUTHID CURRENT_USER AS
/* $Header: perbatsl.pkh 115.3 2003/06/03 16:00:19 jrstewar noship $ */
--
-- -----------------------------------------------------------------------
--
-- Globals used to cache location code.
--
g_location_code       VARCHAR2(60);
g_location_language   VARCHAR2(10);
g_location_id         NUMBER;
--
-- -----------------------------------------------------------------------
--
-- Globals used to cache organization name.
--
g_organization_id         NUMBER;
g_organization_language   VARCHAR2(10);
g_organization_name       VARCHAR2(240);
--
-- -----------------------------------------------------------------------
--
-- Globals used to cache job_name.
--
g_job_id                  NUMBER;
g_job_code                VARCHAR2(60);
g_job_name                VARCHAR2(240);
--
-- -----------------------------------------------------------------------
--
-- Globals used to cache position_name.
--
g_position_id                  NUMBER;
g_position_code                VARCHAR2(60);
g_position_name                VARCHAR2(240);
--
-- -----------------------------------------------------------------------
--
-- Globals used to cache grade_name.
--
g_grade_id                  NUMBER;
g_grade_code                VARCHAR2(60);
g_grade_name                VARCHAR2(240);

FUNCTION location(p_language     IN VARCHAR2
                 ,p_location_id  IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION organization(p_language         IN VARCHAR2
                     ,p_organization_id  IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION job(p_job_id  IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION position(p_position_id  IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION grade(p_grade_id  IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                              ,p_lookup_code   IN VARCHAR2
                              ,p_person_id     IN NUMBER)

          RETURN fnd_lookup_values.meaning%TYPE;
--
FUNCTION psn_lng_location(p_person_id    IN NUMBER
                         ,p_location_id  IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION psn_sup_lng_location(p_person_id   IN NUMBER
                            ,p_location_id  IN NUMBER)
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
FUNCTION asg_lng_organization(p_assignment_id   IN NUMBER
                                  ,p_organization_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_sup_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                                  ,p_lookup_code   IN VARCHAR2
                                  ,p_assignment_id IN NUMBER)

          RETURN fnd_lookup_values.meaning%TYPE;
--
FUNCTION asg_sup_lng_location(p_assignment_id   IN NUMBER
                             ,p_location_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_sup_lng_organization(p_assignment_id       IN NUMBER
                                 ,p_organization_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_sup_lng_job(p_assignment_id    IN NUMBER
                        ,p_job_id           IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION asg_sup_lng_position(p_assignment_id  IN NUMBER
                             ,p_position_id       IN NUMBER)
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
FUNCTION pasg_sup_lng_location(p_assignment_id   IN NUMBER
                             ,p_location_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION pasg_sup_lng_organization(p_assignment_id   IN NUMBER
                                  ,p_organization_id IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION pasg_sup_lng_job(p_assignment_id IN NUMBER
                         ,p_job_id   IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION pasg_sup_lng_position(p_assignment_id IN NUMBER
                              ,p_position_id   IN NUMBER)
          RETURN VARCHAR2;
--
FUNCTION pasg_sup_lng_grade(p_assignment_id IN NUMBER
                           ,p_grade_id      IN NUMBER)
          RETURN VARCHAR2;

END HR_BPL_ALERT_TRNSLT;

 

/
