--------------------------------------------------------
--  DDL for Package PQH_FR_SPEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_SPEED" AUTHID CURRENT_USER AS
/* $Header: pqchgspd.pkh 120.0 2005/05/29 01:43:38 appldev noship $ */
--
--Function overloaded with Varchar2 so that it can be used in VO Query.
  FUNCTION get_increased_index(p_comments       IN VARCHAR2
                              ,p_gross_index    IN NUMBER
                              ,p_effective_date IN DATE) RETURN NUMBER;
--
--Function to check whether Notification is to be sent for due appraisals.
  FUNCTION chk_notify(p_ben_pgm_id     NUMBER
                     ,p_mgr_id         NUMBER
                     ,p_review_date    DATE
                     ,p_effective_date DATE) RETURN VARCHAR2;
--
--Function to get latest Appraisal Id for Employee as on effective date.
  FUNCTION get_appraisal(p_ben_pgm_id           NUMBER
                        ,p_person_id            NUMBER
                        ,p_assignment_id        NUMBER
                        ,p_appraisal_status     VARCHAR2
                        ,p_appraisal_start_date DATE
                        ,p_appraisal_end_date   DATE
                        ,p_effective_date       DATE) RETURN NUMBER;
--
--Function to get the Appraisal Score (Marks) for an Appraisal.
  FUNCTION get_marks(p_appraisal_id NUMBER) RETURN NUMBER;
--
--Procedure to check whether Speed Quota Check is success or failure.
  PROCEDURE chk_speed_quota(p_ben_pgm_id     IN            NUMBER
                           ,p_grade_id       IN            NUMBER
                           ,p_speed          IN            VARCHAR2
                           ,p_effective_date IN            DATE
                           ,p_num_allowed       OUT NOCOPY NUMBER
                           ,p_speed_meaning     OUT NOCOPY VARCHAR2
                           ,p_return_status     OUT NOCOPY VARCHAR2);
--
--Procedure to update Progression Speed.
  PROCEDURE update_speed(p_place_id   IN            NUMBER
                        ,p_speed      IN            VARCHAR2
                        ,p_eff_dt     IN            DATE
                        ,p_ovn        IN OUT NOCOPY NUMBER
                        ,p_eff_st_dt     OUT NOCOPY DATE
                        ,p_eff_end_dt    OUT NOCOPY DATE);
--
--Procedure to send WorkFlow Notification.
  PROCEDURE notify_manager(p_ItemType    IN VARCHAR2
                          ,p_ProcessName IN VARCHAR2
                          ,p_EmpNumber   IN VARCHAR2
                          ,p_EmpName     IN VARCHAR2
                          ,p_UserName    IN VARCHAR2
                          ,p_MgrUserName IN VARCHAR2
                          ,p_Corps       IN VARCHAR2
                          ,p_Grade       IN VARCHAR2
                          ,p_Step        IN VARCHAR2
                          ,p_Speed       IN VARCHAR2
                          ,p_LastApprDt  IN DATE
                          ,p_EffDt       IN DATE
                          ,p_Duration    IN NUMBER);
--
--Function defined in Formula Function for checking Speed Length in Fast Formula.
  FUNCTION chk_speed_length(p_assignment_id  IN NUMBER
                           ,p_effective_date IN DATE) RETURN VARCHAR2;
--
--Procedure to get FNDUSER for Manager
  PROCEDURE get_mgr_user(p_effective_date IN            DATE
                        ,p_mgr_id         IN            NUMBER
                        ,p_mgr_username      OUT NOCOPY VARCHAR2);
--
END pqh_fr_speed;

 

/
