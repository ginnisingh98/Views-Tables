--------------------------------------------------------
--  DDL for Package PAY_IP_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IP_BAL_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pyipupld.pkh 115.1 2002/10/10 15:07:11 atrivedi noship $ */

FUNCTION international_payroll
			(p_dimension_name	IN	VARCHAR2,
			 p_legislation_code	IN	VARCHAR2) RETURN BOOLEAN;

FUNCTION expiry_date
		(p_upload_date		IN	DATE,
		 p_dimension_name	IN	VARCHAR2,
		 p_assignment_id	IN	NUMBER,
		 p_original_entry_id	IN	NUMBER,
		 p_business_group_id	IN	NUMBER,
		 p_legislation_code	IN	VARCHAR2) RETURN DATE;

FUNCTION include_adjustment
 	(
	  p_balance_type_id     NUMBER
	 ,p_dimension_name      VARCHAR2
	 ,p_original_entry_id   NUMBER
	 ,p_upload_date	        DATE
	 ,p_batch_line_id	NUMBER
	 ,p_test_batch_line_id	NUMBER
	 ,p_legislation_code	VARCHAR2
	 ) RETURN BOOLEAN;

END pay_ip_bal_upload;

 

/
