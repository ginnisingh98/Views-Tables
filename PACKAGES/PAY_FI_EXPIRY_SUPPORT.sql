--------------------------------------------------------
--  DDL for Package PAY_FI_EXPIRY_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_EXPIRY_SUPPORT" AUTHID CURRENT_USER AS
 /* $Header: pyfiepst.pkh 120.1 2006/01/24 22:12:20 dbehera noship $ */
 --
 --
 -- --------------------------------------------------------------------------
 -- This is the procedure called by the core logic that manages the expiry of
 -- latest balances. Its interface is fixed as it is called dynamically.
 --
 -- It will return the following output indicating the latest balance expiration
 -- status ...
 --
 -- p_expiry_information = 1  - Expired
 -- p_expiry_information = 0  - OK
 -- --------------------------------------------------------------------------
 --
 PROCEDURE court_order_ec
 (p_owner_payroll_action_id    NUMBER
 ,p_user_payroll_action_id     NUMBER
 ,p_owner_assignment_action_id NUMBER
 ,p_user_assignment_action_id  NUMBER
 ,p_owner_effective_date       DATE
 ,p_user_effective_date        DATE
 ,p_dimension_name             VARCHAR2
 ,p_expiry_information         OUT  NOCOPY NUMBER);

 PROCEDURE court_order_ec
 (p_owner_payroll_action_id    NUMBER
 ,p_user_payroll_action_id     NUMBER
 ,p_owner_assignment_action_id NUMBER
 ,p_user_assignment_action_id  NUMBER
 ,p_owner_effective_date       DATE
 ,p_user_effective_date        DATE
 ,p_dimension_name             VARCHAR2
 ,p_expiry_information         OUT  NOCOPY DATE);

 PROCEDURE holiday_pay_ec
 (p_owner_payroll_action_id    NUMBER
 ,p_user_payroll_action_id     NUMBER
 ,p_owner_assignment_action_id NUMBER
 ,p_user_assignment_action_id  NUMBER
 ,p_owner_effective_date       DATE
 ,p_user_effective_date        DATE
 ,p_dimension_name             VARCHAR2
 ,p_expiry_information         OUT  NOCOPY NUMBER);

 PROCEDURE holiday_pay_ec
 (p_owner_payroll_action_id    NUMBER
 ,p_user_payroll_action_id     NUMBER
 ,p_owner_assignment_action_id NUMBER
 ,p_user_assignment_action_id  NUMBER
 ,p_owner_effective_date       DATE
 ,p_user_effective_date        DATE
 ,p_dimension_name             VARCHAR2
 ,p_expiry_information         OUT  NOCOPY DATE);

END pay_fi_expiry_support;

 

/
