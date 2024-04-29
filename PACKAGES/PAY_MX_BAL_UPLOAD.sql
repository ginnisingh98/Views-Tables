--------------------------------------------------------
--  DDL for Package PAY_MX_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_BAL_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pymxupld.pkh 120.0 2005/05/29 06:51 appldev noship $ */

FUNCTION expiry_date
		(p_upload_date		IN	DATE,
		 p_dimension_name	IN	VARCHAR2,
		 p_assignment_id	IN	NUMBER,
		 p_original_entry_id	IN	NUMBER)
RETURN DATE;

-- PRAGMA RESTRICT_REFERENCES(expiry_date, WNDS, WNPS);

FUNCTION is_supported ( p_dimension_name  IN  VARCHAR2)
RETURN NUMBER;


FUNCTION include_adjustment
 	( p_balance_type_id     NUMBER
	 ,p_dimension_name      VARCHAR2
	 ,p_original_entry_id   NUMBER
	 ,p_upload_date	        DATE
	 ,p_batch_line_id	NUMBER
	 ,p_test_batch_line_id	NUMBER
	 )
RETURN NUMBER;

PROCEDURE validate_batch_lines ( p_batch_id  IN  NUMBER );

END pay_mx_bal_upload;

 

/
