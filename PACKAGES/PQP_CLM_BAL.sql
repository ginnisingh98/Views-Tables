--------------------------------------------------------
--  DDL for Package PQP_CLM_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_CLM_BAL" AUTHID CURRENT_USER as
/* $Header: pqpvmbal.pkh 115.1 2003/06/16 13:38:34 jcpereir noship $*/

 FUNCTION get_vehicletype_balance
  (p_assignment_id                    IN number
  ,p_business_group_id                IN number
  ,p_vehicle_type                     IN varchar2
  ,p_ownership                        IN varchar2
  ,p_usage_type                       IN varchar2
  ,p_balance_name                     IN varchar2
  ,p_element_entry_id                 IN NUMBER
  ,p_assignment_action_id             IN NUMBER
  ) RETURN NUMBER;


 FUNCTION get_balance_value
  (p_element_name          IN VARCHAR2
  ,p_assignment_action_id  IN NUMBER
  ,p_element_entry_id      IN NUMBER
  ,p_business_group_id     IN NUMBER
  ,p_payroll_action_id     IN NUMBER
  ,p_balance_name          IN VARCHAR2
  ) RETURN NUMBER;

TYPE r_balance_cache is Record
   ( balance_name           VARCHAR2(80)
    ,balance_type_id        NUMBER
);

TYPE t_balance_cache is Table of r_balance_cache
                   INDEX BY binary_integer;

g_balance_cache   t_balance_cache;

end pqp_clm_bal;

 

/
