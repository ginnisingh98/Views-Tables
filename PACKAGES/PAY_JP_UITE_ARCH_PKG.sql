--------------------------------------------------------
--  DDL for Package PAY_JP_UITE_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_UITE_ARCH_PKG" AUTHID CURRENT_USER AS
-- $Header: pyjpuiar.pkh 120.0.12010000.4 2010/04/23 11:19:20 mpothala noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  pyjpuiar.pkh
-- *
-- * DESCRIPTION
-- * This script creates the package specification of pay_jp_uite_arch_pkg
-- *
-- * USAGE
-- *   To install       sqlplus <apps_user>/<apps_pwd> @pyjpuiar.pkh
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC pay_jp_uite_arch_pkg.<procedure name>
-- *
-- * PROGRAM LIST
-- * ==========
-- * NAME                 DESCRIPTION
-- * -----------------    --------------------------------------------------
-- * RANGE_CODE
-- * INITIALIZATION_CODE
-- * ASSIGNMENT_ACTION_CODE
-- * ARCHIVE_CODE
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   08-Feb-2010
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * VERSION            DATE        AUTHOR(S)             DESCRIPTION
-- * -------           ----------- -----------------     -----------------------------
-- * 120.0.12010000.1  08-Feb-2010  RDARASI               Creation
-- * 120.0.12010000.2  16-Apr-2010  RDARASI               Modified as per review comments
-- * 120.0.12010000.3  23-Apr-2010  RDARASI               To Fix bug #
-- *************************************************************************

TYPE parameters IS RECORD (business_group_id              NUMBER
                          ,start_date                     DATE
                          ,end_date                       DATE
                          ,effective_date                 DATE
                          ,assignment_id                  NUMBER
                          ,labor_insorg_id                NUMBER
                          ,termination_date_from          DATE
                          ,termination_date_to            DATE
                          ,assignment_set_id              NUMBER
                         );
--
gr_parameters    parameters;

--+=====================================================================+
--|                                                                     |
--|Name        : range_code                                             |
--|                                                                     |
--|Description : This is the range code                                 |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_payroll_action_id         IN   NUMBER                |
--|              p_sql                       OUT  VARCHAR2              |
--+=====================================================================+
PROCEDURE range_code(p_payroll_action_id        IN         pay_payroll_actions.payroll_action_id%TYPE
                    ,p_sql                      OUT NOCOPY VARCHAR2
                    );
--+=====================================================================+
--|                                                                     |
--|Name        : initialization_code                                    |
--|                                                                     |
--|Description : This is the initialization_code procedure              |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_payroll_action_id         IN    NUMBER               |
--+=====================================================================+
PROCEDURE initialization_code (p_payroll_action_id        in  pay_payroll_actions.payroll_action_id%TYPE);
--+=====================================================================+
--|                                                                     |
--|Name        : assignment_action_code                                 |
--|                                                                     |
--|Description : This is the assignment_action_code procedure           |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_payroll_action_id         IN   NUMBER                |
--|              p_start_person              IN   NUMBER                |
--|              p_end_oerson                IN   NUMBER                |
--|              p_chunk                     IN   NUMBER                |
--+=====================================================================+
PROCEDURE assignment_action_code (p_payroll_action_id        in pay_payroll_actions.payroll_action_id%TYPE
                                 ,p_start_person             in per_all_people_f.person_id%TYPE
                                 ,p_end_person               in per_all_people_f.person_id%TYPE
                                 ,p_chunk                    in NUMBER
                                 );
--+=====================================================================+
--|                                                                     |
--|Name        : archive_code                                           |
--|                                                                     |
--|Description : This is the archive_code  procedure                    |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_assignment_action_id      IN   NUMBER                |
--|              p_payroll_action_id         IN   NUMBER                |
--|              p_effective_date            IN   DATE                  |
--+=====================================================================+
PROCEDURE archive_code( p_assignment_action_id     in pay_assignment_actions.assignment_action_id%TYPE
                      , p_effective_date           in pay_payroll_actions.effective_date%TYPE
                      );

--
--+=====================================================================+
--|                                                                     |
--|Name        : deinitialize_code                                      |
--|                                                                     |
--|Description : This is the deinitialise_code procedure                |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_payroll_action_id         IN   NUMBER                |
--+=====================================================================+
PROCEDURE deinitialize_code      (p_payroll_action_id IN NUMBER);
--+=====================================================================+
--|                                                                     |
--|Name        : get_life_ins_org_id                                    |
--|                                                                     |
--|Description : to get the Labor Insurance Employer                    |
--|                                                                     |
--|Parameters  :                                                        |
--|              p_assignment_id         IN   NUMBER                    |
--|              p_effective_date        IN   DATE                      |
--+=====================================================================+

FUNCTION get_life_ins_org_id(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                            ,p_effective_date        IN   DATE)
RETURN NUMBER;
--+=====================================================================+
--|                                                                     |
--|Name        : get_ui_num                                             |
--|                                                                     |
--|Description : to get the unemployment insurance number               |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_assignment_id         IN   NUMBER                    |
--|              p_effective_date        IN   DATE                      |
--+=====================================================================+

FUNCTION get_ui_num(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                   ,p_effective_date        IN   DATE)
RETURN VARCHAR2;
--+=====================================================================+
--|                                                                     |
--|Name        : get_ei_type                                            |
--|                                                                     |
--|Description : to get the Employee Insurance Type                     |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_assignment_id         IN   NUMBER                    |
--|              p_effective_date        IN   DATE                      |
--+=====================================================================+

FUNCTION get_ei_type(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                    ,p_effective_date        IN   DATE)
RETURN VARCHAR2;
--+=====================================================================+
--|                                                                     |
--|Name        : get_term_rpt_flag                                      |
--|                                                                     |
--|Description : to get the Need Separation Notice flag                 |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_assignment_id         IN   NUMBER                    |
--|              p_effective_date        IN   DATE                      |
--+=====================================================================+

FUNCTION get_term_rpt_flag(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                          ,p_effective_date        IN   DATE)
RETURN VARCHAR2;
--
--+=====================================================================+
--|                                                                     |
--|Name        : get_ei_qualify_date                                    |
--|                                                                     |
--|Description : to get the Employee Insurance Qualify Date             |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_assignment_id         IN   NUMBER                    |
--|              p_effective_date        IN   DATE                      |
--+=====================================================================+
FUNCTION get_ei_qualify_date(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                            ,p_effective_date        IN   DATE)
RETURN DATE;
--+=====================================================================+
--|                                                                     |
--|Name        : get_ei_dis_qual_date                                   |
--|                                                                     |
--|Description : to get the Employee Insurance disqualified date        |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_assignment_id         IN   NUMBER                    |
--|              p_effective_date        IN   DATE                      |
--+=====================================================================+

FUNCTION get_ei_dis_qual_date(p_assignment_id         IN   per_all_assignments_f.assignment_id%TYPE
                             ,p_effective_date        IN   DATE)
RETURN DATE;
--
END pay_jp_uite_arch_pkg;

/
