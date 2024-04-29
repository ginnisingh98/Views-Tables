--------------------------------------------------------
--  DDL for Package PAY_ES_ONLINE_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_ONLINE_SOE" AUTHID CURRENT_USER AS
/* $Header: pyessoer.pkh 120.1 2005/07/26 05:16:39 grchandr noship $ */

  FUNCTION Employees (p_assignment_action_id NUMBER) RETURN LONG;
  --
  FUNCTION Balances (p_assignment_action_id NUMBER) RETURN LONG;
  --
  FUNCTION Period (p_assignment_action_id NUMBER) RETURN LONG;
  --
  FUNCTION getElements(p_assignment_action_id NUMBER
                      ,p_element_set_name     VARCHAR2) RETURN LONG;
  --
  FUNCTION Elements1(p_assignment_action_id NUMBER) RETURN LONG;
  --
  FUNCTION Elements2(p_assignment_action_id NUMBER) RETURN LONG;
  --
  FUNCTION Get_Input_Value (p_element_type_id     NUMBER
                           ,p_run_result_id        NUMBER
                           ,p_effective_date       DATE
            	    	       ,p_name                 VARCHAR2
			                     ,p_lookup_name VARCHAR2) RETURN VARCHAR2;
  --
END pay_es_online_soe;

 

/
