--------------------------------------------------------
--  DDL for Package PAY_JP_WL_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_WL_ARCH_PKG" AUTHID CURRENT_USER as
-- $Header: payjpwlarchpkg.pkh 120.0.12010000.4 2009/10/23 11:09:36 mpothala noship $
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
-- *   To install       sqlplus <apps_user>/<apps_pwd> @PAYJPWLARCHPKG.pkh
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC PAY_JP_WL_ARCH_PKG.<procedure name>
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
-- * LAST UPDATE DATE   09-Aug-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * VERSION            DATE        AUTHOR(S)             DESCRIPTION
-- * -------           ----------- -----------------     -----------------------------
-- * 120.0.12010000.1  09-Aug-2009  MPOTHALA               Creation
-- * 120.0.12010000.2  11-Aug-2009  MPOTHALA               Updation
-- * 120.0.12010000.3  22-Oct-2009  MPOTHALA               Fix for bug 8911281
-- * 120.0.12010000.4  23-Oct-2009  MPOTHALA               Fix for bug 9044516
-- *************************************************************************

TYPE parameters IS RECORD (payroll_id                     NUMBER
                          ,organization_id                NUMBER
                          ,location_id                    NUMBER
                          ,business_group_id              NUMBER
                          ,start_date                     DATE
                          ,end_date                       DATE
                          ,pact_id                        NUMBER
                          ,legal_employer                 NUMBER
                          ,assignment_id                  NUMBER
                          ,effective_date                 DATE
                          ,assignment_set_id              NUMBER
                          ,withholding_agent_id           NUMBER
                          ,delete_actions                 VARCHAR2(1)
                          ,subject_yyyymm                 VARCHAR2(50)
                          ,archive_option                 VARCHAR2(50)
                         );
--
gr_parameters    parameters;
--
--+=====================================================================+
--|                                                                     |
--|Name        : t_wage_ledger_info                                     |
--|                                                                     |
--|Description :  To store wage ledger information                      |
--+=====================================================================+
TYPE t_wage_ledger_info IS RECORD (org_information_id    NUMBER
                                  ,organization_id       NUMBER
                                  ,org_information1      VARCHAR2(150)
                                  ,org_information2      VARCHAR2(150)
                                  ,org_information3      VARCHAR2(150)
                                  ,org_information4      VARCHAR2(150)
                                  ,org_information5      VARCHAR2(150)
                                  ,org_information6      VARCHAR2(150)
                                  ,org_information7      VARCHAR2(150)
                                  ,org_information8      VARCHAR2(150)
                                  ,org_information9      VARCHAR2(150)
                                  ,org_information10     VARCHAR2(150)
                                  ,org_information11     VARCHAR2(150)
                                  ,org_information12     VARCHAR2(150)
                                  ,org_information13     VARCHAR2(150)
                                  );
--
type t_wage_ledger is table of t_wage_ledger_info index by binary_integer;
--
gt_wage_ledger t_wage_ledger;
--+=====================================================================+
--|                                                                     |
--|Name        : g_def_bal_c                                            |
--|                                                                     |
--|Description :  To Populate the Defined Balance IDs                   |
--+=====================================================================+
g_def_bal_c     pay_balance_pkg.t_balance_value_tab;
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
                            ,p_effective_date  IN   DATE) -- 9044516
RETURN NUMBER;
--
--+=====================================================================+
--|                                                                     |
--|Name        : get_person_address_type                                |
--|                                                                     |
--|Description : This is the get_person_address_type procedure          |
--|                                                                     |
--|Parameters  :                                                        |
--|                                                                     |
--|              p_person_id                 IN   NUMBER                |
--+=====================================================================+
FUNCTION get_person_address_type(p_person_id  IN   per_all_people_f.person_id%TYPE)
RETURN VARCHAR2;
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
END pay_jp_wl_arch_pkg;

/
