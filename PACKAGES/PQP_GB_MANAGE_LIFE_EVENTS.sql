--------------------------------------------------------
--  DDL for Package PQP_GB_MANAGE_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_MANAGE_LIFE_EVENTS" AUTHID CURRENT_USER AS
/* $Header: pqpgbmle.pkh 115.3 2004/05/11 09:51:36 rrazdan noship $ */
--
-- Public Global Variables
--
--
-- Cursors
--
  CURSOR csr_last_ben_report
   (p_person_id     IN NUMBER
   ,p_process_date  IN DATE
   ) IS
  SELECT rep.reporting_id
        ,rep.rep_typ_cd
        ,rep.text
  FROM   ben_reporting       rep
        ,ben_benefit_actions bac
  WHERE  rep.person_id         = p_person_id
    AND  bac.benefit_action_id = rep.benefit_action_id
    AND  bac.process_date      = p_process_date
  ORDER BY rep.creation_date DESC; -- DESC order by to get latest row
--
--
--
  CURSOR csr_benmngle_batch_parameter
    (p_business_group_id  IN NUMBER
    ) IS
  SELECT batch_parameter_id
        ,max_err_num      -- NUMBER(15)
  FROM   ben_batch_parameter
  WHERE  BATCH_EXE_CD = 'BENMNGLE'
    AND  business_group_id = p_business_group_id;
--
--
--
  PROCEDURE abse_process
    (p_business_group_id        IN     NUMBER
    ,p_person_id                IN     NUMBER
    ,p_effective_date           IN     DATE
    ,p_absence_attendance_id    IN     NUMBER       DEFAULT NULL
    ,p_absence_start_date       IN     DATE         DEFAULT NULL
    ,p_absence_end_date         IN     DATE         DEFAULT NULL
    ,p_errbuf                      OUT NOCOPY VARCHAR2
    ,p_retcode                     OUT NOCOPY NUMBER
    );
--
--
--
END pqp_gb_manage_life_events;

 

/
