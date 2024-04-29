--------------------------------------------------------
--  DDL for Package PAY_AE_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AE_SOE" AUTHID CURRENT_USER AS
/* $Header: pyaesoer.pkh 120.0.12000000.1 2007/01/17 15:24:47 appldev noship $ */

/*Function to pick up employee details*/
 FUNCTION employees (p_assignment_action_id NUMBER) RETURN LONG;

 FUNCTION balances (p_assignment_action_id NUMBER) RETURN LONG;

 FUNCTION period (p_assignment_action_id NUMBER) RETURN LONG;

 FUNCTION ae_loan_type (p_assignment_action_id NUMBER, p_run_result_id NUMBER , p_effective_date date) RETURN VARCHAR2;

 function getElements(p_assignment_action_id number
                    ,p_element_set_name varchar2) return long;

 function Elements2(p_assignment_action_id number) return long;

END pay_ae_soe;

 

/
