--------------------------------------------------------
--  DDL for Package BEN_TCS_STMT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TCS_STMT_PROCESS" 
/* $Header: bentcssg.pkh 120.2 2007/09/21 07:46:02 vkodedal noship $ */
AUTHID CURRENT_USER AS
TYPE g_rep_rec   IS RECORD (
    P_TYPE                                      NUMBER(15),
    BENEFIT_ACTION_ID                         NUMBER(15),
    ASSIGNMENT_NUMBER                         VARCHAR2(30),
    EMPLOYEE_NUMBER                           VARCHAR2(30),
    JOB_NAME                                  VARCHAR2(240),
    BUSINESS_GROUP_ID                         NUMBER(15),
    BUSINESS_GROUP_NAME                       VARCHAR2(240),
    FULL_NAME                                 VARCHAR2(240),
    STMT_CREATED                              VARCHAR2(30),
    ERROR                                     VARCHAR2(2000),
    ELIGY_ID                                  NUMBER(15),
    ELIGY_PROF_NAME                           VARCHAR2(240),
    STMT_ID                                   NUMBER(15),
    STMT_NAME                                 VARCHAR2(240),
    SETUP_VALID                               VARCHAR2(30),
    TOTAL_PERSONS                             NUMBER(15),
    BEN_TCS_RPT_DET_ID                        NUMBER(15),
    ASSIGNMENT_ID                             NUMBER(15),
    PERSON_ID                                 NUMBER(15),
    PERIOD_ID                                 NUMBER(15)
  );

  TYPE g_rep_rec_tab IS TABLE OF g_rep_rec
    INDEX BY BINARY_INTEGER;


   PROCEDURE do_multithread (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      NUMBER,
      p_validate            IN              VARCHAR2 DEFAULT 'N',
      p_benefit_action_id   IN              NUMBER,
      p_thread_id           IN              NUMBER,
      p_effective_date      IN              VARCHAR2,
      p_audit_log           IN              VARCHAR2 DEFAULT 'N',
      p_run_type            IN              VARCHAR2,
      p_start_date          IN              DATE,
      p_end_date            IN              DATE
   );

   PROCEDURE process (
      errbuf              OUT NOCOPY      VARCHAR2,
      retcode             OUT NOCOPY      NUMBER,
      p_validate          IN              VARCHAR2 DEFAULT 'N',
      p_run_type          IN              VARCHAR2,
      p_stmt_name         IN              VARCHAR2,
      p_stmt_id           IN              VARCHAR2 ,
      p_person_id         IN              VARCHAR2 DEFAULT NULL,
      p_period_id         IN              VARCHAR2 ,
      p_partial_end       IN              VARCHAR2 DEFAULT NULL,
      p_audit_log         IN              VARCHAR2 DEFAULT 'Y',
      p_business_group_id IN              NUMBER DEFAULT NULL,
      p_org_id            IN              NUMBER DEFAULT NULL,
      p_location_id       IN              NUMBER DEFAULT NULL,
      p_ben_grp_id        IN              NUMBER DEFAULT NULL,
      p_payroll_id        IN              NUMBER DEFAULT NULL,
      p_job_id            IN              NUMBER DEFAULT NULL,
      p_position_id       IN              NUMBER DEFAULT NULL,
      p_supervisor_id     IN              NUMBER DEFAULT NULL
   );
END BEN_TCS_STMT_PROCESS;


/
