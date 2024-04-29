--------------------------------------------------------
--  DDL for Package Body PAY_TAXBAL_HARNESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TAXBAL_HARNESS" AS
/* $Header: pyvw941b.pkb 115.1 99/07/17 06:49:05 porting sh $ */
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
			p_virtual_date		IN DATE) IS

l_creator_id			NUMBER;
l_gross_earnings_gre_qtd	NUMBER;
l_def_comp_401k_gre_qtd		NUMBER;
l_section_125_gre_qtd		NUMBER;
l_dependent_care_gre_qtd 	NUMBER;

BEGIN

  pay_balance_pkg.set_context('TAX_UNIT_ID', p_gre_id_context);
  pay_balance_pkg.set_context('DATE_EARNED',
                              fnd_date.date_to_canonical(p_virtual_date));
/*this was changed for bug 407699*/
 -- l_creator_id := get_defined_balance_id('REGULAR_EARNINGS_GRE_QTD');
  l_creator_id := get_defined_balance_id('GROSS_EARNINGS_GRE_QTD');

  l_gross_earnings_gre_qtd := pay_balance_pkg.get_value(
				l_creator_id,
				0,
				TRUE);

  l_creator_id := get_defined_balance_id('DEF_COMP_401K_GRE_QTD');
  l_def_comp_401k_gre_qtd :=  pay_balance_pkg.get_value(
				l_creator_id,
				0,
				TRUE);

  l_creator_id := get_defined_balance_id('SECTION_125_GRE_QTD');
  l_section_125_gre_qtd := pay_balance_pkg.get_value(
				l_creator_id,
				0,
				TRUE);

  l_creator_id := get_defined_balance_id('DEPENDENT_CARE_GRE_QTD');
  l_dependent_care_gre_qtd := pay_balance_pkg.get_value(
				l_creator_id,
				0,
				TRUE);

  /*this balance was modified for 407699*/
  p_bal_result1 := (  l_gross_earnings_gre_qtd)
                  -(  l_def_comp_401k_gre_qtd
                    + l_section_125_gre_qtd
  		    + l_dependent_care_gre_qtd );

  l_creator_id := get_defined_balance_id('FIT_WITHHELD_GRE_QTD');
  p_bal_result2 := pay_balance_pkg.get_value(
				l_creator_id,
				0,
				TRUE);

  l_creator_id := get_defined_balance_id('SS_EE_TAXABLE_GRE_QTD');
  p_bal_result3 := pay_balance_pkg.get_value(
				l_creator_id,
				0,
				TRUE);

  l_creator_id := get_defined_balance_id('MEDICARE_EE_TAXABLE_GRE_QTD');
  p_bal_result4 := pay_balance_pkg.get_value(
				l_creator_id,
				0,
				TRUE);

  l_creator_id := get_defined_balance_id('EIC_ADVANCE_GRE_QTD');
  p_bal_result5 := pay_balance_pkg.get_value(
				l_creator_id,
				0,
				TRUE);

END get_tax_bals;
--
FUNCTION get_defined_balance_id(p_user_entity_name IN VARCHAR2) RETURN
		NUMBER IS

l_defined_balance_id	NUMBER;

BEGIN

  SELECT creator_id
  INTO l_defined_balance_id
  FROM   ff_user_entities
  WHERE  user_entity_name LIKE p_user_entity_name;

  RETURN l_defined_balance_id;

  EXCEPTION WHEN NO_DATA_FOUND THEN
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('FUNCTION',
                  'pay_taxbal_harness.'||'get_defined_balance_id');
     hr_utility.raise_error;

END get_defined_balance_id;


END pay_taxbal_harness;

/
