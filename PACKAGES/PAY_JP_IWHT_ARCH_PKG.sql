--------------------------------------------------------
--  DDL for Package PAY_JP_IWHT_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_IWHT_ARCH_PKG" AUTHID CURRENT_USER AS
-- $Header: pyjpiwar.pkh 120.1.12010000.2 2010/04/16 10:25:47 mpothala noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  PAYJLWL.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of PAY_JP_WL_ARCH_PKG
-- *
-- * USAGE
-- *   To install       sqlplus <apps_user>/<apps_pwd> @payjpiwhtarchpkg.pkh
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC payjpiwhtarchpkg.<procedure name>
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
-- * LAST UPDATE DATE   05-Feb-2010
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * VERSION            DATE        AUTHOR(S)             DESCRIPTION
-- * -------           ----------- -----------------     -----------------------------
-- * 120.0.12010000.1  05-Feb-2010  MPOTHALA               Creation
-- * 120.0.12010000.1  16-Apr-2010  MPOTHALA               Update to add commit
-- *************************************************************************

TYPE parameters IS RECORD (business_group_id              NUMBER
                          ,effective_date                 DATE
                          ,withholding_agent_id           NUMBER
                          ,payroll_id                     NUMBER
                          ,termination_date_from          DATE
                          ,termination_date_to            DATE
                          ,assignment_set_id              NUMBER
                          ,rearchive_flag                 VARCHAR2(10)
                           );
--
gr_parameters    parameters;
--
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
PROCEDURE range_code
(p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type
,p_sql                      out NOCOPY varchar2
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
PROCEDURE initialization_code
(p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type);
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
PROCEDURE assignment_action_code
(p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type
,p_start_person             in per_all_people_f.person_id%type
,p_end_person               in per_all_people_f.person_id%type
,p_chunk                    in number
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
PROCEDURE archive_code
(
 p_assignment_action_id     in pay_assignment_actions.assignment_action_id%type
,p_effective_date           in pay_payroll_actions.effective_date%type
);
--+=====================================================================+
--|                                                                     |
--|Name        : get_with_hold_agent                                    |
--|                                                                     |
--|Description : This is the get_with_hold_agent  procedure             |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_assignment_id             IN   NUMBER                |
--+=====================================================================+
FUNCTION get_with_hold_agent(p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE
                            ,p_effective_date        IN   DATE)
RETURN NUMBER;
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
--
END pay_jp_iwht_arch_pkg;

/
