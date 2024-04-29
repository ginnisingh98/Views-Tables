--------------------------------------------------------
--  DDL for Package HRI_OPL_ASGN_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_ASGN_EVENTS" AUTHID CURRENT_USER AS
/* $Header: hrioaevt.pkh 120.1.12000000.2 2007/04/12 12:09:27 smohapat noship $ */
--
-- Exceptions raised when there is a problem with a fast formula
--
ff_not_compiled   EXCEPTION;
--
-- Public type declarations
--
-- Assignment change record
--
TYPE g_asg_change_rec_type IS RECORD
 (change_date                DATE
 ,change_end_date            DATE
 ,hire_date                  DATE
 ,termination_date           DATE
 ,assignment_id              NUMBER
 ,person_id                  NUMBER
 ,business_group_id          NUMBER
 ,organization_id            NUMBER
 ,location_id                NUMBER
 ,job_id                     NUMBER
 ,grade_id                   NUMBER
 ,position_id                NUMBER
 ,supervisor_id              NUMBER
 ,payroll_id                 NUMBER
 ,pay_basis_id               NUMBER
 ,prsntyp_sk_fk              NUMBER
 ,summarization_rqd_ind      NUMBER
 ,pow_start_date_adj         DATE
 ,primary_flag               VARCHAR2(30)
 ,type                       VARCHAR2(30)
 ,leaving_reason_code        VARCHAR2(30)
 ,change_reason_code         VARCHAR2(30)
 ,status_code                VARCHAR2(30)
 ,wkth_wktyp_code            VARCHAR2(30));
--
-- Salary change record
--
TYPE g_sal_change_rec_type IS RECORD
 (effective_start_date   DATE
 ,effective_end_date     DATE
 ,anl_slry               NUMBER
 ,pay_proposal_id        NUMBER
 ,anl_slry_currency      VARCHAR2(30));
--
-- Performance band change record
--
TYPE g_perf_change_rec_type IS RECORD
 (effective_start_date   DATE
 ,effective_end_date     DATE
 ,nrmlsd_rating          NUMBER
 ,band                   NUMBER
 ,review_id              NUMBER
 ,review_type_cd         VARCHAR2(30)
 ,rating_cd              VARCHAR2(30));
--
-- Simple table types.
--
  TYPE g_date_tab_type IS TABLE OF DATE
         INDEX BY BINARY_INTEGER;
  TYPE g_number_tab_type IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;
  TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30)
         INDEX BY BINARY_INTEGER;
  TYPE g_varchar2_240_tab_type IS TABLE OF VARCHAR2(240)
         INDEX BY BINARY_INTEGER;
--
-- Assignment change table
--
TYPE g_asg_change_tab_type IS TABLE OF g_asg_change_rec_type
         INDEX BY BINARY_INTEGER;
--
-- Salary change table
--
TYPE g_sal_change_tab_type IS TABLE OF g_sal_change_rec_type
         INDEX BY BINARY_INTEGER;
--
-- Performance band change table
--
TYPE g_perf_change_tab_type IS TABLE OF g_perf_change_rec_type
         INDEX BY BINARY_INTEGER;
--
--
PROCEDURE shared_hrms_dflt_prcss
  (errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  ,p_collect_from_date IN VARCHAR2 DEFAULT NULL
  ,p_collect_to_date   IN VARCHAR2 DEFAULT NULL
  ,p_full_refresh      IN VARCHAR2 DEFAULT NULL
  ,p_attribute1        IN VARCHAR2 DEFAULT NULL
  ,p_attribute2        IN VARCHAR2 DEFAULT NULL);
--
PROCEDURE pre_process
  (p_mthd_action_id    IN NUMBER
  ,p_sqlstr            OUT NOCOPY VARCHAR2);
--
PROCEDURE process_range
  (errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  ,p_mthd_action_id    IN NUMBER
  ,p_mthd_range_id     IN NUMBER
  ,p_start_object_id   IN NUMBER
  ,p_end_object_id     IN NUMBER);
--
PROCEDURE post_process
  (p_mthd_action_id    IN NUMBER);
--
PROCEDURE run_for_asg(p_assignment_id  IN NUMBER);
--
END HRI_OPL_ASGN_EVENTS;

 

/
