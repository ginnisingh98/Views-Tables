--------------------------------------------------------
--  DDL for Package PAY_IP_EXPIRY_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IP_EXPIRY_SUPPORT" AUTHID CURRENT_USER AS
 /* $Header: pyipexps.pkh 120.0 2005/05/29 05:59:43 appldev noship $ */
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
 PROCEDURE date_ec
 (p_owner_payroll_action_id    NUMBER
 ,p_user_payroll_action_id     NUMBER
 ,p_owner_assignment_action_id NUMBER
 ,p_user_assignment_action_id  NUMBER
 ,p_owner_effective_date       DATE
 ,p_user_effective_date        DATE
 ,p_dimension_name             VARCHAR2
 ,p_expiry_information         OUT  NOCOPY NUMBER);
 --
 -- ----------------------------------------------------------------------------
 -- This is the overloaded procedure which returns actual expiry date
 -- ----------------------------------------------------------------------------
 --
 PROCEDURE date_ec
 (p_owner_payroll_action_id    NUMBER
 ,p_user_payroll_action_id     NUMBER
 ,p_owner_assignment_action_id NUMBER
 ,p_user_assignment_action_id  NUMBER
 ,p_owner_effective_date       DATE
 ,p_user_effective_date        DATE
 ,p_dimension_name             VARCHAR2
 ,p_expiry_information         OUT  NOCOPY DATE);
END pay_ip_expiry_support;

 

/
