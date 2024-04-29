--------------------------------------------------------
--  DDL for Package PER_JP_EMPDET_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_EMPDET_ARCHIVE_PKG" AUTHID CURRENT_USER
-- $Header: pejpearc.pkh 120.0.12010000.5 2009/08/19 14:40:01 rdarasi noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  pejpearc.pkh
-- *
-- * DESCRIPTION
-- * This script creates the package header of per_jp_empdet_archive_pkg.
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   15-JUN-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * DATE        AUTHOR(S)  VERSION             BUG NO    DESCRIPTION
-- * -----------+---------+-------------------+----------+------------------
-- * 19-MAR-2009 SPATTEM    120.0.12010000.1    8558615   Creation
-- * 08-JUN-2009 SPATTEM    120.0.12010000.3    8558615   Changed as per review Comments
-- *                                                     ,Included Table type for Job History
-- * 13-AUG-2009 RDARASI    120.4.12010000.4    8774235   Changed job_hist_type Record
--*  14-Aug-2009 MPOTHALA   120.4.12010000.5	8766629   Changed  Termination Allowance Query
-- *************************************************************************
AS
--
TYPE job_hist_type IS RECORD(position_id     per_assignments_f.position_id%TYPE
                            ,job_id          per_assignments_f.job_id%TYPE
                            ,assignment_id   per_assignments_f.assignment_id%TYPE
                            ,start_date      per_assignments_f.effective_start_date%TYPE
                            ,end_date        per_assignments_f.effective_end_date%TYPE
                            ,position        per_positions.name%TYPE
                            ,job             per_jobs_tl.name %TYPE
                            ,organization    hr_organization_units.name%TYPE
                            ,organization_id hr_organization_units.organization_id%TYPE -- Added by RDARASI for BUG#8774235
                            );

TYPE gt_job_tbl IS TABLE of job_hist_type INDEX BY binary_integer;
--
TYPE assign_hist_type IS RECORD(position_id     per_assignments_f.position_id%TYPE
                               ,job_id          per_assignments_f.job_id%TYPE
                               ,assignment_id   per_assignments_f.assignment_id%TYPE
                               ,start_date      per_assignments_f.effective_start_date%TYPE
                               ,end_date        per_assignments_f.effective_end_date%TYPE
                               ,position        per_positions.name%TYPE
                               ,job             per_jobs_tl.name %TYPE
                               ,organization    hr_organization_units.name%TYPE
                               ,organization_id hr_organization_units.organization_id%TYPE
                               ,grade_id        per_grades.grade_id%TYPE
                               ,grade           per_grades.name%TYPE  -- Added by MPOTHALA for BUG#8761443
                               ,assignment_number per_all_assignments_f.assignment_number%TYPE
                              );

TYPE assign_job_tbl IS TABLE of assign_hist_type INDEX BY binary_integer;
--

TYPE parameters IS RECORD (business_group_id     NUMBER
                          ,organization_id       NUMBER
                          ,location_id           NUMBER
                          ,assignment_set_id     NUMBER
                          ,effective_date        DATE
                          ,include_org_hierarchy VARCHAR2(1)
                          ,include_term_emp      VARCHAR2(10)
                          ,term_date_from        DATE
                          ,term_date_to          DATE
                          );

gr_parameters parameters;
--
PROCEDURE range_code             ( p_payroll_action_id        IN pay_payroll_actions.payroll_action_id%type
                                  ,p_sql                      OUT NOCOPY VARCHAR2
                                 );
--
PROCEDURE initialization_code    ( p_payroll_action_id        IN pay_payroll_actions.payroll_action_id%type);
--
PROCEDURE assignment_action_code ( p_payroll_action_id        IN pay_payroll_actions.payroll_action_id%TYPE
                                  ,p_start_person             IN per_all_people_f.person_id%TYPE
                                  ,p_end_person               IN per_all_people_f.person_id%TYPE
                                  ,p_chunk                    IN NUMBER
                                 );
--
PROCEDURE archive_code           ( p_assignment_action_id     IN pay_assignment_actions.assignment_action_id%TYPE
                                  ,p_effective_date           IN pay_payroll_actions.effective_date%TYPE
                                 );
--
END per_jp_empdet_archive_pkg;

/
