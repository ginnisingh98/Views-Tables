--------------------------------------------------------
--  DDL for Package Body HR_NZ_TAX_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_TAX_API" AS
/* $Header: hrnzwrtx.pkb 120.2 2005/10/06 05:03:56 rpalli noship $ */
--
-- Package Variables
--
--
  PROCEDURE maintain_tax_info
  	(p_validate						IN	  BOOLEAN
	,p_assignment_id        		IN    NUMBER
	,p_effective_date         		IN    DATE
	,p_mode                 		IN    VARCHAR2
	,p_business_group_id			IN	  NUMBER
	,p_cost_allocation_keyflex_id	IN	  NUMBER 	DEFAULT hr_api.g_number
	,p_updating_action_id           IN    NUMBER    DEFAULT hr_api.g_number
	,p_updating_action_type         IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_original_entry_id            IN    NUMBER    DEFAULT hr_api.g_number
	,p_creator_type                 IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_comment_id					IN	  NUMBER 	DEFAULT hr_api.g_number
	,p_creator_id                   IN    NUMBER    DEFAULT hr_api.g_number
	,p_reason						IN	  VARCHAR2	DEFAULT hr_api.g_varchar2
	,p_subpriority                  IN    NUMBER    DEFAULT hr_api.g_number
	,p_date_earned                  IN    DATE      DEFAULT hr_api.g_date
	,p_personal_payment_method_id   IN    NUMBER    DEFAULT hr_api.g_number
	,p_attribute_category         	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute1                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute2                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute3                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute4                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute5                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute6                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute7                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute8                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute9                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute10                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute11                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute12                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute13                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute14                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute15                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute16                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute17                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute18                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute19                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
  	,p_attribute20                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_tax_code			  		 	IN    VARCHAR2	DEFAULT 'ND'
	,p_special_tax_code	  		 	IN    VARCHAR2	DEFAULT 'N'
	,p_paye_special_rate	  		IN    NUMBER	DEFAULT hr_api.g_number
	,p_acc_special_rate	  		 	IN    NUMBER	DEFAULT hr_api.g_number
	,p_student_loan_rate    		IN    NUMBER	DEFAULT hr_api.g_number
	,p_all_extra_emol_at_high_rate	IN    VARCHAR2	DEFAULT 'N'
	,p_effective_start_date 		  OUT NOCOPY DATE
	,p_effective_end_date   		  OUT NOCOPY DATE
	,p_update_warning				  OUT NOCOPY BOOLEAN
	) IS

	l_proc VARCHAR2(72);

        /*Bug 3648883: removed upper on element_name to improve performance*/
	CURSOR csr_paye_tax_element(c_effective_date DATE) IS
        SELECT pet.element_type_id
        FROM   pay_element_types_f pet
        WHERE  pet.element_name	= 'PAYE Information'
        AND    c_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
        AND    legislation_code = 'NZ';


	CURSOR csr_paye_tax_input_values(c_element_type_id pay_input_values_f.element_type_id%TYPE
									,c_effective_date DATE) IS
        SELECT piv.input_value_id
			  ,piv.name
        FROM   pay_input_values_f  piv
        WHERE  piv.element_type_id = c_element_type_id
        AND    c_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date;


	CURSOR csr_ele_entry (p_element_link NUMBER
						 ,p_inp_val NUMBER
						 ,c_effective_date DATE)IS
    	SELECT 	pee.element_entry_id,
                object_version_number
    	FROM  	pay_element_entries_f pee,
              	pay_element_entry_values_f pev
       	WHERE  	pee.assignment_id        = p_assignment_id
       	AND    	c_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date
       	AND    	pee.element_link_id      = p_element_link
       	AND    	pev.element_entry_id     = pee.element_entry_id
       	AND    	c_effective_date BETWEEN pev.effective_start_date AND pev.effective_end_date
		AND    	pev.input_value_id       = p_inp_val;


	l_inp_value_id_table   hr_entry.number_table;
	l_scr_value_table      hr_entry.varchar2_table;

	l_dummy	                NUMBER;
 	l_element_type_id       NUMBER;
   	l_element_link_id       NUMBER;
   	l_element_entry_id      NUMBER;
        l_object_version_number NUMBER;
	l_effective_date		DATE;


  BEGIN
       l_proc := 'hr_nz_tax_api.maintain_tax_info';
    hr_utility.set_location('Entering:'|| l_proc, 5);
	--
	-- Get the element type id for the Tax element
	--

	l_effective_date := TRUNC(p_effective_date);
        l_element_type_id  :=0;
        l_element_link_id  :=0;
        l_element_entry_id :=0;

	OPEN csr_paye_tax_element(l_effective_date);
	FETCH csr_paye_tax_element INTO l_element_type_id;
	IF (csr_paye_tax_element%NOTFOUND)
	THEN
		CLOSE csr_paye_tax_element;
		hr_utility.set_message(801,'HR_AU_NZ_ELE_TYP_NOT_FND');
		hr_utility.raise_error;
	END IF;
	CLOSE csr_paye_tax_element;

	hr_utility.set_location(l_proc, 10);

	--
	-- Get the Input Value Id for each Tax Input
	--
	FOR rec_paye_tax_element in csr_paye_tax_input_values(l_element_type_id, l_effective_date)
	LOOP
		IF UPPER(rec_paye_tax_element.name) = 'TAX CODE'
	    THEN
			l_inp_value_id_table(1) := rec_paye_tax_element.input_value_id;
	    ELSIF UPPER(rec_paye_tax_element.name) = 'SPECIAL TAX CODE'
        THEN
            l_inp_value_id_table(2) := rec_paye_tax_element.input_value_id;
        ELSIF UPPER(rec_paye_tax_element.name) = 'TAX RATE'
	    THEN
	        l_inp_value_id_table(3) := rec_paye_tax_element.input_value_id;
        ELSIF UPPER(rec_paye_tax_element.name) = 'ACC EP SPECIAL RATE'
	    THEN
	        l_inp_value_id_table(4) := rec_paye_tax_element.input_value_id;
        ELSIF UPPER(rec_paye_tax_element.name) = 'STUDENT LOAN SPECIAL RATE'
	    THEN
	        l_inp_value_id_table(5) := rec_paye_tax_element.input_value_id;
        ELSIF UPPER(rec_paye_tax_element.name) = 'ALL EXTRA EMOL AT HIGH RATE'
	    THEN
	        l_inp_value_id_table(6) := rec_paye_tax_element.input_value_id;
	    END IF;
	END LOOP;

	hr_utility.set_location(l_proc, 15);

	--
	-- Check that an input value is present for each input value
	--
	--  *** PM :- Removed to conserve error messages on direction of BB ***
	--
    -- FOR i IN 1..l_inp_value_id_table.COUNT
	-- LOOP
	-- 	IF (l_inp_value_id_table(i) = NULL OR l_inp_value_id_table(i) = 0)
	-- 	THEN
	-- 		hr_utility.set_message(801,'HR_NZ_INVALID_INPUT_VALUE_ID');
	-- 		hr_utility.raise_error;
	-- 	END IF;
	-- END LOOP;

	hr_utility.set_location(l_proc, 20);

	--
	-- Get the element link id for the PAYE information element
	--
	l_element_link_id := hr_entry_api.get_link
							(p_assignment_id    => p_assignment_id
							,p_element_type_id  => l_element_type_id
							,p_session_date		=> l_effective_date);

	IF (l_element_link_id IS NULL OR l_element_link_id = 0)
	THEN
		hr_utility.set_message(801,'HR_AU_NZ_ELE_LNK_NOT_FND');
		hr_utility.raise_error;
	END IF;

	hr_utility.set_location(l_proc, 25);

	IF (p_mode IN ('CORRECTION','UPDATE','UPDATE_CHANGE_INSERT','UPDATE_OVERRIDE'))
	THEN
		-----------------------------------------------------------------------------
		-- Get the element entry of the tax element entry that is to be updated
		------------------------------------------------------------------------------

		hr_utility.set_location(l_proc, 30);

		OPEN csr_ele_entry(l_element_link_id, l_inp_value_id_table(1),l_effective_date);
        FETCH csr_ele_entry INTO l_element_entry_id,l_object_version_number;
        IF (csr_ele_entry%NOTFOUND)
		THEN
        	CLOSE csr_ele_entry;
           	hr_utility.set_message(801, 'HR_AU_NZ_ELE_ENT_NOT_FND');
           	hr_utility.raise_error;
		END IF;
        CLOSE csr_ele_entry;

		hr_utility.set_location(l_proc, 35);

		py_element_entry_api.update_element_entry
			(p_validate					=> p_validate
			,p_datetrack_update_mode    => p_mode
			,p_effective_date           => l_effective_date
			,p_business_group_id		=> p_business_group_id
			,p_element_entry_id         => l_element_entry_id
			,p_object_version_number	=> l_object_version_number
			,p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id
			,p_updating_action_id           => p_updating_action_id
			,p_updating_action_type         => p_updating_action_type
			,p_original_entry_id            => p_original_entry_id
			,p_creator_type                 => p_creator_type
			,p_comment_id				=> p_comment_id
			,p_creator_id                   => p_creator_id
			,p_reason         			=> p_reason
			,p_subpriority                  => p_subpriority
			,p_date_earned                  => p_date_earned
			,p_personal_payment_method_id   => p_personal_payment_method_id
  			,p_attribute_category 		=> p_attribute_category
  			,p_attribute1				=> p_attribute1
  			,p_attribute2				=> p_attribute2
  			,p_attribute3				=> p_attribute3
  			,p_attribute4				=> p_attribute4
  			,p_attribute5				=> p_attribute5
  			,p_attribute6				=> p_attribute6
  			,p_attribute7				=> p_attribute7
  			,p_attribute8				=> p_attribute8
  			,p_attribute9				=> p_attribute9
  			,p_attribute10				=> p_attribute10
  			,p_attribute11				=> p_attribute11
  			,p_attribute12				=> p_attribute12
  			,p_attribute13				=> p_attribute13
  			,p_attribute14				=> p_attribute14
  			,p_attribute15				=> p_attribute15
  			,p_attribute16				=> p_attribute16
  			,p_attribute17				=> p_attribute17
  			,p_attribute18				=> p_attribute18
  			,p_attribute19				=> p_attribute19
  			,p_attribute20				=> p_attribute20
  			,p_input_value_id1			=> l_inp_value_id_table(1)
  			,p_input_value_id2			=> l_inp_value_id_table(2)
  			,p_input_value_id3			=> l_inp_value_id_table(3)
  			,p_input_value_id4			=> l_inp_value_id_table(4)
  			,p_input_value_id5			=> l_inp_value_id_table(5)
  			,p_input_value_id6			=> l_inp_value_id_table(6)
  			,p_entry_value1				=> p_tax_code
  			,p_entry_value2				=> p_special_tax_code
  			,p_entry_value3				=> p_paye_special_rate
  			,p_entry_value4				=> p_acc_special_rate
  			,p_entry_value5				=> p_student_loan_rate
  			,p_entry_value6				=> p_all_extra_emol_at_high_rate
			,p_effective_start_date		=> p_effective_start_date
			,p_effective_end_date		=> p_effective_end_date
                        ,p_override_user_ent_chk                => 'Y'
			,p_update_warning			=> p_update_warning);

--  *** PM :- Removed to conserve error messages on direction of BB ***
--	ELSE
--           	hr_utility.set_message(801, 'HR_NZ_UPDATE_ENTRY_FAILED');
--           	hr_utility.raise_error;

	END IF;

    hr_utility.set_location(' Leaving:'||l_proc, 40);

  END maintain_tax_info;

END hr_nz_tax_api;

/
