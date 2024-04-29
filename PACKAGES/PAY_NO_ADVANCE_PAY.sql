--------------------------------------------------------
--  DDL for Package PAY_NO_ADVANCE_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_ADVANCE_PAY" AUTHID CURRENT_USER AS
/* $Header: pynoapay.pkh 120.0.12000000.1 2007/07/13 11:35:07 nmuthusa noship $ */

FUNCTION adv_payment_skip_rule	(p_element_entry_id 	NUMBER,
				 p_date_earned 		DATE,
			  	 p_payroll_action_id 	NUMBER
			  	) RETURN VARCHAR2;

END PAY_NO_ADVANCE_PAY;

 

/
