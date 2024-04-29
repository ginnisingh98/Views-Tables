--------------------------------------------------------
--  DDL for Package PAY_ZA_EFT_RECONCILIATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_EFT_RECONCILIATION" AUTHID CURRENT_USER AS
--  /* $Header: pyzaeftrecn.pkh 120.0.12010000.1 2009/07/28 09:28:48 dchindar noship $ */
--
FUNCTION get_eft_recon_data    (p_effective_date	DATE,
			        p_identifier_name       VARCHAR2,
			        p_payroll_action_id	NUMBER,
				p_payment_type_id	NUMBER,
				p_org_payment_method_id	NUMBER,
				p_personal_payment_method_id	NUMBER,
				p_assignment_action_id	NUMBER,
				p_pre_payment_id	NUMBER,
				p_delimiter_string   	VARCHAR2)
 RETURN VARCHAR2;


END PAY_ZA_EFT_RECONCILIATION;


/
