--------------------------------------------------------
--  DDL for Package Body HR_DE_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_VALIDATE_PKG" AS
/* $Header: pedevald.pkb 120.1 2007/04/05 09:28:58 spendhar noship $ */


   PROCEDURE create_element_entry_validate
	(p_effective_date		IN		DATE
	,p_assignment_id		IN		NUMBER
	,p_entry_information_category	IN		VARCHAR2
	,p_entry_information1		IN		VARCHAR2) IS

	l_table PAY_ELEMENT_ENTRIES_F.ENTRY_INFORMATION9%TYPE;

	CURSOR csr_get_table IS
	SELECT entry_information9
	FROM pay_element_entries_f entry
	WHERE entry.assignment_id = p_assignment_id
	AND p_effective_date between entry.effective_start_date and entry.effective_end_date
	AND entry.element_type_id = (SELECT element_type_id
				     FROM pay_element_types_f ele
				     WHERE p_effective_date between ele.effective_start_date and ele.effective_end_date
				     AND ele.element_name = 'Tax Information'
				     AND ele.legislation_code = 'DE')
	AND entry.entry_information_category = 'DE_TAX INFORMATION';

  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'DE') THEN

	OPEN csr_get_table;
	FETCH csr_get_table INTO l_table;
	CLOSE csr_get_table;

	If P_ENTRY_INFORMATION_CATEGORY ='DE_SOCIAL INSURANCE' then
	   If  P_ENTRY_INFORMATION1 = '0000' and l_table = 'DE_TAX_TABLE_A' then
	   	   	hr_utility.set_message(800, 'HR_78912_DE_NO_PENSION_CONT');
	          	hr_utility.raise_error;
	   End If;
	End If;

  END IF;

  END create_element_entry_validate;


	PROCEDURE update_element_entry_validate
	(p_effective_date		IN		DATE
	,p_element_entry_id		IN		NUMBER
	,p_entry_information_category	IN		VARCHAR2
	,p_entry_information1		IN		VARCHAR2) IS

	l_table PAY_ELEMENT_ENTRIES_F.ENTRY_INFORMATION9%TYPE;
	l_assignment_id	number;

	CURSOR csr_get_asg_id IS
	SELECT assignment_id
	FROM	pay_element_entries_f ENTRY
	WHERE p_effective_date between entry.effective_start_date and entry.effective_end_date
	AND entry.element_entry_id = p_element_entry_id;

	CURSOR csr_get_table (l_assignment_id number)  IS
	SELECT entry_information9
	FROM pay_element_entries_f entry
	WHERE entry.assignment_id = l_assignment_id
	AND p_effective_date between entry.effective_start_date and entry.effective_end_date
	AND entry.element_type_id = (SELECT element_type_id
				     FROM pay_element_types_f ele
				     WHERE p_effective_date between ele.effective_start_date and ele.effective_end_date
				     AND ele.element_name = 'Tax Information'
				     AND ele.legislation_code = 'DE')
	AND entry.entry_information_category = 'DE_TAX INFORMATION';

	BEGIN

	/* Added for GSI Bug 5472781 */
	IF hr_utility.chk_product_install('Oracle Human Resources', 'DE') THEN

	OPEN csr_get_asg_id;
	FETCH csr_get_asg_id INTO l_assignment_id;
	CLOSE csr_get_asg_id;

	OPEN csr_get_table(l_assignment_id);
	FETCH csr_get_table INTO l_table;
	CLOSE csr_get_table;

	If P_ENTRY_INFORMATION_CATEGORY ='DE_SOCIAL INSURANCE' then
	   If  P_ENTRY_INFORMATION1 = '0000' and l_table = 'DE_TAX_TABLE_A' then
			hr_utility.set_message(800, 'HR_78912_DE_NO_PENSION_CONT');
			hr_utility.raise_error;
	   End If;
	End If;

	END IF;

	END update_element_entry_validate;

END hr_de_validate_pkg;

/
