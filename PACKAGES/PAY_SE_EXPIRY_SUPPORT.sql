--------------------------------------------------------
--  DDL for Package PAY_SE_EXPIRY_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_EXPIRY_SUPPORT" AUTHID CURRENT_USER AS
/*$Header: pyseexsu.pkh 120.0.12000000.1 2007/04/24 06:57:56 rlingama noship $*/

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

 FUNCTION  hyear_ec
 (p_assignment_action_id IN number,
 p_effective_date IN date
 ) RETURN DATE ;

END PAY_SE_EXPIRY_SUPPORT;


 

/
