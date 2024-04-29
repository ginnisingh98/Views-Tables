--------------------------------------------------------
--  DDL for Package PAY_SA_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SA_SOE" AUTHID CURRENT_USER AS
/* $Header: pysasoer.pkh 120.0.12000000.2 2007/06/29 06:28:04 spendhar noship $ */

/*Function to pick up Reference Salary*/
 FUNCTIOn get_reference_salary (p_effective_date	DATE
			       ,p_assignment_action_id NUMBER) RETURN NUMBER;

/*Function to pick up GOSI information */
 FUNCTION gosi_info(p_assignment_action_id NUMBER) RETURN LONG;

/*Function to pick up balances*/

function Balances(p_assignment_action_id number) return long ;

/*Function to pick up employee details*/

 FUNCTION employees (p_assignment_action_id NUMBER) RETURN LONG;

END pay_sa_soe;


 

/
