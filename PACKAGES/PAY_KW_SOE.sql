--------------------------------------------------------
--  DDL for Package PAY_KW_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KW_SOE" AUTHID CURRENT_USER AS
/* $Header: pykwsoer.pkh 120.0.12000000.1 2007/01/17 22:34:51 appldev noship $ */
/*Function to pick up employee details*/
 FUNCTION employees (p_assignment_action_id NUMBER) RETURN LONG;
 FUNCTION balances (p_assignment_action_id NUMBER) RETURN LONG;
 FUNCTION period (p_assignment_action_id NUMBER) RETURN LONG;
 FUNCTION kw_loan_type (p_assignment_action_id NUMBER, p_run_result_id NUMBER , p_effective_date date)
  RETURN VARCHAR2;
 function getElements(p_assignment_action_id number
                    ,p_element_set_name varchar2) return long;
 function Elements2(p_assignment_action_id number) return long;
END pay_kw_soe;

 

/
