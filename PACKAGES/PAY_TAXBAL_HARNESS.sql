--------------------------------------------------------
--  DDL for Package PAY_TAXBAL_HARNESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TAXBAL_HARNESS" AUTHID CURRENT_USER AS
/*  $Header: pyvw941b.pkh 115.0 99/07/17 06:49:09 porting ship $ */
PROCEDURE get_tax_bals(	p_tax_balance_category1 IN VARCHAR2,
		       	p_tax_type1	   	IN VARCHAR2,
			p_bal_result1		IN OUT NUMBER,
			p_tax_balance_category2 IN VARCHAR2,
		       	p_tax_type2	   	IN VARCHAR2,
			p_bal_result2		IN OUT NUMBER,
			p_tax_balance_category3 IN VARCHAR2,
		       	p_tax_type3	   	IN VARCHAR2,
			p_bal_result3		IN OUT NUMBER,
			p_tax_balance_category4 IN VARCHAR2,
		       	p_tax_type4	   	IN VARCHAR2,
			p_bal_result4		IN OUT NUMBER,
			p_tax_balance_category5 IN VARCHAR2,
		       	p_tax_type5	   	IN VARCHAR2,
			p_bal_result5		IN OUT NUMBER,
			p_time_type		IN VARCHAR2,
			p_asg_type		IN VARCHAR2,
			p_gre_id_context	IN NUMBER,
			p_virtual_date		IN DATE);

FUNCTION get_defined_balance_id(p_user_entity_name IN VARCHAR2) RETURN
		NUMBER;

END pay_taxbal_harness;

 

/
