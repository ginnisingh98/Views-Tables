--------------------------------------------------------
--  DDL for Package Body HR_NL_EXTRA_ASG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_EXTRA_ASG_RULES" AS
/* $Header: penlexar.pkb 120.0.12000000.2 2007/02/28 10:55:01 spendhar ship $ */

--Sets the Global - glo_payroll_id
--For Tax Code Validations to be performed when API is being called implictly from
--People Management Templates - Enter Employee
--Accepts the Payroll ID entered in the Payroll Field on the
--Enter Employee Template and sets the global for usage in
--extra_assignment_checks1 Procedure.

PROCEDURE set_payroll_id(p_payroll_id IN NUMBER) IS
BEGIN
	glo_payroll_id := p_payroll_id;
END set_payroll_id;
--
--
--------------------------------------------------------------------------------
-- Tax Code Validations
--------------------------------------------------------------------------------
-- Tax Code                         - SEGMENT11
-- Tax Reductions Apply             - SEGMENT4
-- Labour Tax Reduction             - SEGMENT7
-- Additional Sr Tax Reduction      - SEGMENT9
--
PROCEDURE validate_tax_code_combinations
    (p_person_id            IN NUMBER
    ,p_assignment_id        IN NUMBER
    ,p_payroll_id           IN NUMBER
    ,p_effective_date       IN DATE
    ,p_tax_code             IN VARCHAR2
    ,p_tax_red_apply        IN VARCHAR2
    ,p_labour_tax_apply     IN VARCHAR2
    ,p_add_sr_tax_apply     IN VARCHAR2) IS
    --
    l_period_type           pay_payrolls_f.period_type%TYPE;
    l_period_code           number;
    p_period_type           VARCHAR2(80);
    l_1_digit               VARCHAR2(1);
    l_2_digit               VARCHAR2(1);
    l_3_digit               VARCHAR2(1);
    l_valid                 BOOLEAN;
    l_mar_status            per_all_people_f.marital_status%TYPE;
    l_lookup_desc           hr_lookups.meaning%TYPE;
    l_age                   NUMBER;
    l_tax_code              VARCHAR2(60);
    l_tax_red_apply         VARCHAR2(60);
    l_labour_tax_apply      VARCHAR2(60);
    l_add_sr_tax_apply      VARCHAR2(60);

    --
    CURSOR get_payroll_period_type(p_payroll_id     NUMBER
                                  ,p_effective_date DATE) IS
    SELECT pp.period_type
    FROM   pay_payrolls_f pp
    WHERE  pp.payroll_id=p_payroll_id
    AND    p_effective_date BETWEEN pp.effective_start_date
                            AND     pp.effective_end_date;
    --
    CURSOR csr_get_marital_status(p_person_id       NUMBER
                                 ,p_effective_date  DATE) IS
    SELECT marital_status
    FROM   per_all_people_f
    WHERE  person_id        = p_person_id
    AND    p_effective_date BETWEEN effective_start_date
                            AND     effective_end_date;
    --
    CURSOR csr_get_lookup_desc(p_lookup_code VARCHAR2) IS
    SELECT UPPER(description)
    FROM   hr_lookups
    WHERE  lookup_type      ='MAR_STATUS'
    AND    lookup_code      = p_lookup_code;

    CURSOR csr_get_asg_tax_details (p_assignment_id  NUMBER
                                   ,p_effective_date DATE) IS
    SELECT scl.segment11 tax_code
           ,scl.segment4  tax_red
           ,scl.segment7  labour_tax
           ,scl.segment9  add_sr_tax
    FROM   per_all_assignments_f            asg
          ,hr_soft_coding_keyflex        scl
    WHERE  asg.assignment_id           = p_assignment_id
    AND    asg.soft_coding_keyflex_id    = scl.soft_coding_keyflex_id
    AND    p_effective_date
    BETWEEN asg.effective_start_date AND     asg.effective_end_date;

    tax_details_rec csr_get_asg_tax_details%ROWTYPE;
    --
BEGIN
	hr_utility.trace('Entering validate_tax_code_combinations');
	/*
	hr_utility.trace('p_payroll_id  '||p_payroll_id 	);
	hr_utility.trace('p_effective_date  '||p_effective_date 	);
	hr_utility.trace('p_tax_code  '||p_tax_code 	);
	hr_utility.trace('p_tax_red_apply  '||p_tax_red_apply 	);
	hr_utility.trace('p_labour_tax_apply  '||p_labour_tax_apply 	);
	hr_utility.trace('p_add_sr_tax_apply  '||p_add_sr_tax_apply 	);
  	*/
	l_tax_code          := NVL(p_tax_code,'940');
	l_tax_red_apply     := NVL(p_tax_red_apply,'N');
	l_labour_tax_apply  := NVL(p_labour_tax_apply,'N');
	l_add_sr_tax_apply  := NVL(p_add_sr_tax_apply,'N');

	/*
	hr_utility.trace('l_tax_code  '||l_tax_code 	);
	hr_utility.trace('l_tax_red_apply  '||l_tax_red_apply 	);
	hr_utility.trace('l_labour_tax_apply  '||l_labour_tax_apply 	);
	hr_utility.trace('l_add_sr_tax_apply  '||l_add_sr_tax_apply 	);
	*/

	IF  p_assignment_id IS NOT NULL THEN
		/*Fetch the Db Values for the Assignment if Update_emp_asg
		is being called */

		OPEN csr_get_asg_tax_details(p_assignment_id,p_effective_date);
		FETCH csr_get_asg_tax_details INTO tax_details_rec;
		/*
		hr_utility.trace('tax_details_rec.tax_code  '||tax_details_rec.tax_code 	);
		hr_utility.trace('tax_details_rec.tax_red  '||tax_details_rec.tax_red 	);
		hr_utility.trace('tax_details_rec.labour_tax  '||tax_details_rec.labour_tax 	);
		hr_utility.trace('tax_details_rec.add_sr_tax  '||tax_details_rec.add_sr_tax 	);
		*/
		IF p_tax_code= hr_api.g_varchar2 THEN
		   l_tax_code := NVL(tax_details_rec.tax_code,'940') ;
		END IF;
		IF p_tax_red_apply= hr_api.g_varchar2 THEN
		   l_tax_red_apply := NVL(tax_details_rec.tax_red,'N') ;
		END IF;
		IF p_labour_tax_apply= hr_api.g_varchar2 THEN
		   l_labour_tax_apply := NVL(tax_details_rec.labour_tax,'N') ;
		END IF;
		IF p_add_sr_tax_apply= hr_api.g_varchar2 THEN
		   l_add_sr_tax_apply := NVL(tax_details_rec.add_sr_tax,'N') ;
		END IF;
	END IF;
	/*
	hr_utility.trace('p_payroll_id      '||p_payroll_id  	);
	hr_utility.trace('l_tax_code  '||l_tax_code 	);
	hr_utility.trace('l_tax_red_apply  '||l_tax_red_apply 	);
	hr_utility.trace('l_labour_tax_apply  '||l_labour_tax_apply 	);
	hr_utility.trace('l_add_sr_tax_apply  '||l_add_sr_tax_apply 	);
	*/
    IF  p_payroll_id IS NULL AND l_tax_code <> '940' THEN
		-- Message Text - "You cannot enter tax information because this
		-- assignment does not have a payroll attached to it."
		hr_utility.set_message(800, 'HR_NL_PAYROLL_IS_NULL');
		hr_utility.raise_error;
		--
    ELSE
		--
		-- Tax code validations
		--
		IF  l_labour_tax_apply  = 'Y' THEN
			IF  l_tax_red_apply = 'N' THEN
			-- Message Text- "The Labour Tax Reduction indicator is
			-- applicable only when Tax Reduction indicator is applicable."
			   -- hr_utility.trace('IN');
			hr_utility.set_message(800, 'HR_NL_LTR_NA_FOR_TR_NA');
			hr_utility.raise_error;
		   END IF;
		END IF;
		IF  l_add_sr_tax_apply   = 'Y' THEN
			IF  (l_tax_red_apply = 'N') THEN
			-- Message Text - "Additional Senior Tax indicator is applicable
			-- only if Tax Reduction is applicable."

			hr_utility.set_message(800, 'HR_STR_NA_IF_LTR_AND_TR_NA');
			hr_utility.raise_error;
			END IF;
		END IF;
		--
		-- hr_utility.trace('INSIDE TAX VALIDATION THREE');

		-- Get Payroll Period Type
		OPEN get_payroll_period_type(p_payroll_id,p_effective_date);
			FETCH get_payroll_period_type INTO l_period_type;
		CLOSE get_payroll_period_type;
		--

		--hr_utility.trace('INSIDE TAX VALIDATION FOUR');

		-- Get Payroll Period Type Code
		pay_nl_tax_pkg.get_period_type_code(l_period_type
						   ,p_period_type
						   ,l_period_code);

		--l_tax_code :='940';
		--hr_utility.trace('INSIDE TAX VALIDATION FIVE'||l_period_code||l_tax_code);

		-- Validate Tax Code
		pay_nl_tax_pkg.chk_tax_code(l_tax_code
					   ,l_period_code
					   ,l_1_digit
					   ,l_2_digit
					   ,l_3_digit
					   ,l_valid);
		--
		IF  l_valid THEN
			--
			IF  l_2_digit = '2' AND l_labour_tax_apply = 'Y' THEN
			-- Message Text
			-- "The Labour Tax Reduction indicator is applicable to the
			-- white tax table only. Please select the white tax table
			-- if the employee is eligible for a labour tax reduction."
			hr_utility.set_message(800, 'HR_NL_LTR_NA_FOR_GREEN_TABLE');
			hr_utility.raise_error;
			END IF;
			--
			IF  l_2_digit = '1' AND l_add_sr_tax_apply = 'Y' THEN
			-- Message Text -
			--"The Additional Senior Tax Reduction indicator is applicable
			-- to the green tax table only. Please select the green tax
			-- table if the employee is eligible for an additional
			-- senior tax reduction."
			hr_utility.set_message(800, 'HR_NL_ASTR_NA_FOR_WHITE_TABLE');
			hr_utility.raise_error;
			END IF;
			--
			IF  l_2_digit= '1' AND (l_1_digit = '6' OR l_1_digit = '7') THEN
			-- Message Text -
			-- "The tax code is invalid, the taxation types 6 and 7 are
			-- applicable for the green tax table only. Please enter a
			-- valid tax code."
			hr_utility.set_message(800, 'HR_NL_TAXATION_TYPES_NA');
			hr_utility.raise_error;
			END IF;
	    	--
			OPEN csr_get_marital_status(p_person_id,p_effective_date);
			FETCH csr_get_marital_status INTO l_mar_status;
			CLOSE csr_get_marital_status;
			--
			OPEN csr_get_lookup_desc(l_mar_status);
			FETCH csr_get_lookup_desc INTO l_lookup_desc;
			CLOSE csr_get_lookup_desc;
			--
			IF  (l_mar_status = 'M' OR INSTR(l_lookup_desc,'NOT SINGLE') >0)
			 AND l_add_sr_tax_apply = 'Y' THEN
			-- Message Text -
			-- "The Additional Senior Tax Reduction indicator is only
			-- applicable for employees who have a status of single."
			hr_utility.set_message(800, 'HR_NL_ASTR_APPLIES_FOR_SINGLE');
			hr_utility.raise_error;
			END IF;
			--
			l_age := pay_nl_tax_pkg.check_age_payroll_period
					   (p_person_id
					   ,p_payroll_id
					   ,p_effective_date);
			--
			IF  l_tax_code = '227' AND l_age < 65 THEN
			-- Message Text -
			-- "The tax code 227 is not applicable for employees who are
			-- under 65 years old. Please enter a valid tax code
			-- for the assignment."
			hr_utility.set_message(800, 'HR_NL_TAX_CODE_227_NA');
			hr_utility.set_message_token('TAX_CODE', '227');
			hr_utility.raise_error;
			ELSIF l_tax_code = '228' AND l_age >= 65 THEN
			-- Message Text -
			-- "The tax code 228 is not applicable for employees who are
			-- 65 years old or over. Please enter a valid tax code
			-- for the assignment."
			hr_utility.set_message(801, 'HR_NL_TAX_CODE_228_NA');
			hr_utility.set_message_token('TAX_CODE', '228');
			hr_utility.raise_error;
			END IF;
			IF  l_add_sr_tax_apply  = 'Y' AND l_age < 65 THEN
			-- Message Text -
			-- "Additional Senior Tax Reduction indicator is not applicable
			-- for employees who are under 65 years old."

			hr_utility.set_message(800, 'HR_NL_ASTR_NA_FOR_AGE_LT_65');
			hr_utility.raise_error;
			END IF;
			--
			--
			--
		ELSE-- Tax code invalid
			-- Message Text -
			-- "This is an invalid Tax Code. Please enter the correct code."
			hr_utility.set_message(800, 'HR_NL_TAX_CODE_INVALID');
			hr_utility.raise_error;
		END IF;
		--
    END IF;

    --
END validate_tax_code_combinations;
--
--------------------------------------------------------------------------------
-- Validate Special Indicators
--------------------------------------------------------------------------------
-- Special Indicators                 - SEGMENT10
--
PROCEDURE validate_spl_indicators(p_special_indicators IN VARCHAR2
                                  ,p_assignment_id number
                                  ,p_effective_date DATE ) IS
    --
    l_set                BOOLEAN;
    l_special_indicators1 VARCHAR2(60);
    l_special_indicators  varchar2(60);
    l_exists              VARCHAR2(30);
    --
    TYPE special_indicators_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

    l_spl_indicator             special_indicators_tab;
    --
    CURSOR csr_lookup_code_exists(p_lookup_type VARCHAR2
                                 ,p_lookup_code VARCHAR2) IS
    SELECT '1'
    FROM   hr_lookups
    WHERE  lookup_code  = p_lookup_code
    AND    lookup_type   = p_lookup_type;

    --

    CURSOR csr_get_spl_indicator_details (p_assignment_id  NUMBER
                                       ,p_effective_date DATE) IS
        SELECT scl.segment10 special_indicator
        FROM   per_all_assignments_f  asg
              ,hr_soft_coding_keyflex scl
        WHERE  asg.assignment_id           = p_assignment_id
        AND    asg.soft_coding_keyflex_id    = scl.soft_coding_keyflex_id
        AND    p_effective_date
        BETWEEN asg.effective_start_date AND     asg.effective_end_date;

    l_special_indicators2 csr_get_spl_indicator_details%ROWTYPE;

BEGIN
    hr_utility.trace('Entering validate_spl_indicators');
    --
    IF p_special_indicators = hr_api.g_varchar2 THEN
       open csr_get_spl_indicator_details(p_assignment_id,p_effective_date);
       fetch csr_get_spl_indicator_details into l_special_indicators2;
       l_special_indicators := l_special_indicators2.special_indicator;
       close csr_get_spl_indicator_details;
    ELSE
       l_special_indicators := p_special_indicators;
    END IF;

    IF  l_special_indicators IS NOT NULL THEN
        --
        IF  mod(length(l_special_indicators),2) <> 0 THEN
            -- Message Text -
            -- "A special indicator value is invalid."

            hr_utility.set_message(800, 'HR_NL_INVALID_FIELD');
            hr_utility.set_message_token('FIELD', 'Special Indicator');

            hr_utility.raise_error;
            --
        ELSE
            --
            pay_nl_tax_pkg.get_spl_inds(l_special_indicators
                                       ,l_spl_indicator(1)
                                       ,l_spl_indicator(2)
                                       ,l_spl_indicator(3)
                                       ,l_spl_indicator(4)
                                       ,l_spl_indicator(5)
                                       ,l_spl_indicator(6)
                                       ,l_spl_indicator(7)
                                       ,l_spl_indicator(8)
                                       ,l_spl_indicator(9)
                                       ,l_spl_indicator(10)
                                       ,l_spl_indicator(11)
                                       ,l_spl_indicator(12)
                                       ,l_spl_indicator(13));
            --
            -- Validate special indicators
            --
            FOR i IN 1..l_spl_indicator.COUNT LOOP
                IF  l_spl_indicator(i) IS NOT NULL THEN
                    OPEN csr_lookup_code_exists('NL_SPECIAL_INDICATORS'
                                               ,l_spl_indicator(i));
                        FETCH csr_lookup_code_exists INTO l_exists;
                        IF  csr_lookup_code_exists%NOTFOUND THEN
                        CLOSE csr_lookup_code_exists;
                        -- Message Text -
                        -- "A special indicator value is invalid."
                        hr_utility.set_message(800, 'HR_NL_INVALID_FIELD');
            		hr_utility.set_message_token('FIELD', 'Special Indicator');
                        hr_utility.raise_error;
                        --
                        END IF;
                    CLOSE csr_lookup_code_exists;
                END IF;
            END LOOP;
            --
            pay_nl_tax_pkg.set_spl_inds(l_spl_indicator(1)
                                       ,l_spl_indicator(2)
                                       ,l_spl_indicator(3)
                                       ,l_spl_indicator(4)
                                       ,l_spl_indicator(5)
                                       ,l_spl_indicator(6)
                                       ,l_spl_indicator(7)
                                       ,l_spl_indicator(8)
                                       ,l_spl_indicator(9)
                                       ,l_spl_indicator(10)
                                       ,l_spl_indicator(11)
                                       ,l_spl_indicator(12)
                                       ,l_spl_indicator(13)
                                       ,l_set
                                       ,l_special_indicators1);
            IF  l_set THEN
                -- Message Text -
                -- "You have already selected this special indicator for
                -- the employee."
                 hr_utility.set_message(800, 'HR_NL_SPL_INDICATOR_SET');
                 hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
    END IF;
    --
    hr_utility.trace('Leaving validate_spl_indicators');

END validate_spl_indicators;
--
--------------------------------------------------------------------------------
-- Other Validations
--------------------------------------------------------------------------------
-- Commencing From /To          - SEGMENT21 and SEGMENT23
-- Employment Type                  - SEGMENT2
-- Employment Sub Type              - SEGMENT3
--
PROCEDURE other_validations(p_assignment_id         IN NUMBER
		,p_effective_date        IN DATE
		,p_commencing_from      IN DATE
		,p_date_ending          IN DATE
		,p_employment_type      IN VARCHAR2
		,p_employment_subtype   IN VARCHAR2
		,p_ind_working_hrs      IN NUMBER
		,p_ind_perc             IN NUMBER
		,p_percentage           IN NUMBER
		,p_frequency            IN VARCHAR2
		,p_normal_hours         IN NUMBER) IS
    --
    CURSOR csr_lookup_code_exists(p_lookup_type VARCHAR2
                                 ,p_lookup_code VARCHAR2) IS
    SELECT '1'
    FROM   hr_lookups
    WHERE  lookup_code  = p_lookup_code
    AND    lookup_type   = p_lookup_type;
    --
    l_lookup_type   hr_lookups.lookup_type%TYPE;
    l_exists         VARCHAR2(30);


	CURSOR csr_get_asg_oth_details (p_assignment_id  NUMBER
				       ,p_effective_date DATE) IS
	SELECT scl.segment2  emp_type
	   ,scl.segment3  emp_sub_type
	   ,scl.segment21 commencing_from
	   ,scl.segment23 date_ending
	FROM   per_all_assignments_f            asg
	  ,hr_soft_coding_keyflex        scl
	WHERE  asg.assignment_id         = p_assignment_id
	AND    asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
	AND    p_effective_date
	BETWEEN asg.effective_start_date AND     asg.effective_end_date;

	oth_details_rec csr_get_asg_oth_details%ROWTYPE;
    --
    l_emp_type varchar2(60);
    l_emp_sub_type varchar2(60);
    l_commencing_from  date;
    l_date_ending date;
    --

BEGIN
    hr_utility.trace('Entering other_validations');
    /*
    hr_utility.trace(' p_effective_date '||p_effective_date);
    hr_utility.trace(' p_commencing_from '||p_commencing_from);
    hr_utility.trace(' p_date_ending '||p_date_ending);
    hr_utility.trace(' p_employment_type '||p_employment_type);
    hr_utility.trace(' p_employment_subtype '||p_employment_subtype);
    hr_utility.trace(' p_ind_working_hrs '||p_ind_working_hrs);
    hr_utility.trace(' p_ind_perc '||p_ind_perc);
    hr_utility.trace(' p_percentage '||p_percentage);
    hr_utility.trace(' p_frequency '||p_frequency);
    hr_utility.trace(' p_normal_hours '||p_normal_hours);
    */

    l_emp_type     := p_employment_type;
    l_emp_sub_type := p_employment_subtype;
    l_commencing_from:= p_commencing_from;
    l_date_ending:= p_date_ending;


	IF  p_assignment_id IS NOT NULL THEN
		/*Fetch the Db Values for the Assignment if Update_emp_asg
		is being called */

		OPEN csr_get_asg_oth_details(p_assignment_id,p_effective_date);
		FETCH csr_get_asg_oth_details INTO oth_details_rec;
		IF  csr_get_asg_oth_details%FOUND THEN
			IF p_employment_type= hr_api.g_varchar2 THEN
			   l_emp_type := oth_details_rec.emp_type ;
			END IF;
			IF p_employment_subtype= hr_api.g_varchar2 THEN
			   l_emp_sub_type := oth_details_rec.emp_sub_type ;
			END IF;
			IF p_commencing_from= hr_api.g_date THEN
			   l_commencing_from := oth_details_rec.commencing_from ;
			END IF;
			IF p_date_ending= hr_api.g_date THEN
			   l_date_ending := oth_details_rec.date_ending ;
			END IF;


		ELSE
			l_emp_type:=NULL;
			l_emp_sub_type:=NULL;
			l_commencing_from:=NULL;
			l_date_ending:=NULL;
		END IF;

	END IF;
    --
    IF  l_emp_type IS NOT NULL AND l_emp_sub_type IS NOT NULL THEN
        --
        IF  l_emp_type = 'RE' THEN
            l_lookup_type := 'NL_REAL_EMPLOYMENT_SUBTYPES';
        ELSIF l_emp_type = 'FE' THEN
            l_lookup_type := 'NL_FICT_EMPLOYMENT_SUBTYPES';
        ELSIF l_emp_type = 'PE' THEN
            l_lookup_type := 'NL_PREV_EMPLOYMENT_SUBTYPES';
        END IF;
        --
        OPEN csr_lookup_code_exists(l_lookup_type
                                   ,l_emp_sub_type);
            FETCH csr_lookup_code_exists INTO l_exists;
            IF  csr_lookup_code_exists%NOTFOUND THEN
                --
                --CLOSE csr_lookup_code_exists;
                -- Message Text
                -- 'Employment Sub Type is invalid. Please enter a valid value.'

                hr_utility.set_message(800, 'HR_NL_INVALID_FIELD');
                hr_utility.set_message_token('FIELD', 'Employment Sub Type');
                hr_utility.raise_error;
                --
            END IF;
        CLOSE csr_lookup_code_exists;
        --
    ELSIF l_emp_type IS NULL AND l_emp_sub_type IS NOT NULL THEN
        -- Message Text -
        -- "You are attempting to save this record without submitting all of the
        -- mandatory information. Please enter a value in  Employment Type."
        hr_utility.set_message(800, 'HR_NL_REQUIRED_FIELD');
        hr_utility.set_message_token('FIELD', 'Employment Type');
        hr_utility.raise_error;
        --
    END IF;
    --

    --
    --
    IF  l_commencing_from IS NOT NULL AND l_date_ending IS NOT NULL THEN
        IF  l_commencing_from > l_date_ending THEN
            -- Message Text -
            -- "The Commencing From date cannot be later than the Date Ending
            -- date. Please enter a Commencing From date earlier than the
            -- Date Ending date."
            hr_utility.set_message(800, 'HR_NL_INVALID_DATE');
            hr_utility.raise_error;
        END IF;
    END IF;

	-- Message Text -
	-- "You are attempting to save this record without submitting all of the
	-- mandatory information. Please enter a value in Frequency."

	IF ((p_ind_working_hrs <> hr_api.g_number OR p_normal_hours <> hr_api.g_number)
	     AND p_frequency IS null)	THEN
		hr_utility.set_message(800, 'HR_NL_REQUIRED_FIELD');
		hr_utility.set_message_token('FIELD', 'Frequency');
		hr_utility.raise_error;
	END IF;


	IF (p_frequency = 'D' AND
	   (p_ind_working_hrs > fnd_number.canonical_to_number('24') OR
	   p_normal_hours > fnd_number.canonical_to_number('24'))) 	 THEN
	   hr_utility.set_message(800, 'HR_NL_INCORRECT_FREQUENCY');
	   hr_utility.raise_error;
	 END IF;

	IF (p_frequency = 'W' AND
	   (p_ind_working_hrs > fnd_number.canonical_to_number('99.99') OR
	   p_normal_hours > fnd_number.canonical_to_number('99.99'))) THEN
	   hr_utility.set_message(800, 'HR_NL_INCORRECT_FREQUENCY');
	   hr_utility.raise_error;
	 END IF;


	IF (p_frequency = 'M' AND
	   (p_ind_working_hrs > fnd_number.canonical_to_number('744') OR
	   p_normal_hours > fnd_number.canonical_to_number('744'))) 	 THEN
	   hr_utility.set_message(800, 'HR_NL_INCORRECT_FREQUENCY');
	   hr_utility.raise_error;
	END IF;


	IF (p_frequency = 'Y' AND
	   (p_ind_working_hrs > fnd_number.canonical_to_number('8784') OR
	   p_normal_hours > fnd_number.canonical_to_number('8784'))) 	 THEN
	   hr_utility.set_message(800, 'HR_NL_INCORRECT_FREQUENCY');
	   hr_utility.raise_error;
	END IF;

	IF (p_ind_perc <> hr_api.g_number)	THEN
		IF (p_ind_perc < fnd_number.canonical_to_number('0.00') OR
		p_ind_perc > fnd_number.canonical_to_number('100.00')) THEN
			hr_utility.set_message(800, 'HR_NL_INVALID_PERCENT');
			hr_utility.raise_error;
		END IF;
	END IF;

	IF (p_percentage <> hr_api.g_number) THEN
		IF (p_percentage < fnd_number.canonical_to_number('0.00') OR
		p_percentage > fnd_number.canonical_to_number('9999.9999')) THEN
			hr_utility.set_message(800, 'HR_NL_REALNUMBER_INVALID');
			hr_utility.set_message_token('MINIMUM', '0.00');
			hr_utility.set_message_token('MAXIMUM', '9999.9999');
			hr_utility.set_message_token('PRECISION', '4');
			hr_utility.raise_error;
		END IF;
	END IF;
    hr_utility.trace('Leaving other_validations');

    --
END other_validations;

 PROCEDURE extra_assignment_checks
 ( p_person_id            IN NUMBER
  ,p_payroll_id           IN NUMBER
  ,p_effective_date       IN DATE
  ,p_frequency            IN VARCHAR2
  ,p_normal_hours         IN NUMBER
  ,p_scl_segment1         IN VARCHAR2
  ,p_scl_segment2         IN VARCHAR2
  ,p_scl_segment3         IN VARCHAR2
  ,p_scl_segment4         IN VARCHAR2
  ,p_scl_segment5         IN VARCHAR2
  ,p_scl_segment6         IN VARCHAR2
  ,p_scl_segment7         IN VARCHAR2
  ,p_scl_segment8         IN VARCHAR2
  ,p_scl_segment9         IN VARCHAR2
  ,p_scl_segment10        IN VARCHAR2
  ,p_scl_segment11        IN VARCHAR2
  ,p_scl_segment12        IN VARCHAR2
  ,p_scl_segment13        IN VARCHAR2
  ,p_scl_segment14        IN VARCHAR2
  ,p_scl_segment15        IN VARCHAR2
  ,p_scl_segment16        IN VARCHAR2
  ,p_scl_segment17        IN VARCHAR2
  ,p_scl_segment18        IN VARCHAR2
  ,p_scl_segment19        IN VARCHAR2
  ,p_scl_segment20        IN VARCHAR2
  ,p_scl_segment21        IN VARCHAR2
  ,p_scl_segment22        IN VARCHAR2
  ,p_scl_segment23        IN VARCHAR2
  ,p_scl_segment24        IN VARCHAR2
  ,p_scl_segment25        IN VARCHAR2
  ,p_scl_segment26        IN VARCHAR2
  ,p_scl_segment27        IN VARCHAR2
  ,p_scl_segment28        IN VARCHAR2
  ,p_scl_segment29        IN VARCHAR2
  ,p_scl_segment30        IN VARCHAR2
)IS


	l_commencing_date DATE;
	l_date_ending     DATE;
	l_frequency 	  varchar2(50);
	l_percentage number;
	l_ind_perc number;
	l_ind_working_hrs number;

BEGIN
  --
  hr_utility.trace('Entering extra_assignment_checks');
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'NL') THEN
    --
	/*
	hr_utility.trace('p_normal_hours  '||p_normal_hours 	);
	hr_utility.trace('p_frequency     '||p_frequency  	);
	hr_utility.trace('p_payroll_id    '||p_payroll_id  	);
	hr_utility.trace('p_scl_segment1      '||p_scl_segment1  );
	hr_utility.trace('p_scl_segment2      '||p_scl_segment2  );
	hr_utility.trace('p_scl_segment3      '||p_scl_segment3  );
	hr_utility.trace('p_scl_segment4      '||p_scl_segment4  );
	hr_utility.trace('p_scl_segment5      '||p_scl_segment5  );
	hr_utility.trace('p_scl_segment6      '||p_scl_segment6  );
	hr_utility.trace('p_scl_segment7      '||p_scl_segment7  );
	hr_utility.trace('p_scl_segment8      '||p_scl_segment8  );
	hr_utility.trace('p_scl_segment9      '||p_scl_segment9  );
	hr_utility.trace('p_scl_segment10     '||p_scl_segment10 );
	hr_utility.trace('p_scl_segment11     '||p_scl_segment11 );
	hr_utility.trace('p_scl_segment12     '||p_scl_segment12 );
	hr_utility.trace('p_scl_segment13     '||p_scl_segment13 );
	hr_utility.trace('p_scl_segment14     '||p_scl_segment14 );
	hr_utility.trace('p_scl_segment15     '||p_scl_segment15 );
	hr_utility.trace('p_scl_segment16     '||p_scl_segment16 );
	hr_utility.trace('p_scl_segment17     '||p_scl_segment17 );
	hr_utility.trace('p_scl_segment18     '||p_scl_segment18 );
	hr_utility.trace('p_scl_segment19     '||p_scl_segment19 );
	hr_utility.trace('p_scl_segment20     '||p_scl_segment20 );
	hr_utility.trace('p_scl_segment21     '||p_scl_segment21 );
	hr_utility.trace('p_scl_segment22     '||p_scl_segment22 );
	hr_utility.trace('p_scl_segment23     '||p_scl_segment23 );
	hr_utility.trace('p_scl_segment24     '||p_scl_segment24 );
	hr_utility.trace('p_scl_segment25     '||p_scl_segment25 );
	hr_utility.trace('p_scl_segment26     '||p_scl_segment26 );
	hr_utility.trace('p_scl_segment27     '||p_scl_segment27 );
	hr_utility.trace('p_scl_segment28     '||p_scl_segment28 );
	hr_utility.trace('p_scl_segment29     '||p_scl_segment29 );
	hr_utility.trace('p_scl_segment30     '||p_scl_segment30 );
	*/
	l_frequency:=p_frequency;

	IF p_scl_segment28 IS NULL then
		l_ind_working_hrs := NULL;
	ELSIF p_scl_segment28 <>  hr_api.g_varchar2 then
		l_ind_working_hrs:=round(FND_NUMBER.CANONICAL_TO_NUMBER(p_scl_segment28),2);
	ELSE
		l_ind_working_hrs := hr_api.g_number;
	END if;

	validate_tax_code_combinations(p_person_id
	,null	,p_payroll_id	,p_effective_date
	,p_scl_segment11,p_scl_segment4,p_scl_segment7 ,p_scl_segment9);



	validate_spl_indicators(p_scl_segment10,null,p_effective_date);



	IF p_scl_segment21 IS NULL then
		l_commencing_date := NULL;
	ELSIF p_scl_segment21 <>  hr_api.g_varchar2 then
		l_commencing_date:=FND_DATE.CANONICAL_TO_DATE(p_scl_segment21);
	ELSE
		l_commencing_date := hr_api.g_date;
	END if;

	IF p_scl_segment23 IS NULL then
		l_date_ending := NULL;
	ELSIF p_scl_segment23 <>  hr_api.g_varchar2 then
		l_date_ending:=FND_DATE.CANONICAL_TO_DATE(p_scl_segment23);
	ELSE
		l_date_ending := hr_api.g_date;
	END if;

	IF p_scl_segment29 IS NULL then
		l_percentage := NULL;
	ELSIF p_scl_segment29 <>  hr_api.g_varchar2 then
		l_percentage:=round(FND_NUMBER.CANONICAL_TO_NUMBER(p_scl_segment29),2);
	ELSE
		l_percentage := hr_api.g_number;
	END if;

	IF p_scl_segment20 IS NULL then
		l_ind_perc := NULL;
	ELSIF p_scl_segment20 <>  hr_api.g_varchar2 then
		l_ind_perc := FND_NUMBER.CANONICAL_TO_NUMBER(p_scl_segment20);
	ELSE
		l_ind_perc := hr_api.g_number;
	END if;


	other_validations(null	,p_effective_date
	,l_commencing_date  	,l_date_ending
	,p_scl_segment2	,p_scl_segment3
	,l_ind_working_hrs	,l_ind_perc
	,l_percentage	,l_frequency	,p_normal_hours);
	--
  END IF;
  --
  hr_utility.trace('Leaving extra_assignment_checks');
  --
END extra_assignment_checks;


PROCEDURE extra_assignment_checks1
 ( p_assignment_id        IN NUMBER
  ,p_effective_date       IN DATE
  ,p_frequency            IN VARCHAR2
  ,p_normal_hours         IN NUMBER
  ,p_segment1             IN VARCHAR2
  ,p_segment2             IN VARCHAR2
  ,p_segment3             IN VARCHAR2
  ,p_segment4             IN VARCHAR2
  ,p_segment5             IN VARCHAR2
  ,p_segment6             IN VARCHAR2
  ,p_segment7             IN VARCHAR2
  ,p_segment8             IN VARCHAR2
  ,p_segment9             IN VARCHAR2
  ,p_segment10            IN VARCHAR2
  ,p_segment11            IN VARCHAR2
  ,p_segment12            IN VARCHAR2
  ,p_segment13            IN VARCHAR2
  ,p_segment14            IN VARCHAR2
  ,p_segment15            IN VARCHAR2
  ,p_segment16            IN VARCHAR2
  ,p_segment17            IN VARCHAR2
  ,p_segment18            IN VARCHAR2
  ,p_segment19            IN VARCHAR2
  ,p_segment20            IN VARCHAR2
  ,p_segment21            IN VARCHAR2
  ,p_segment22            IN VARCHAR2
  ,p_segment23            IN VARCHAR2
  ,p_segment24            IN VARCHAR2
  ,p_segment25            IN VARCHAR2
  ,p_segment26            IN VARCHAR2
  ,p_segment27            IN VARCHAR2
  ,p_segment28            IN VARCHAR2
  ,p_segment29            IN VARCHAR2
  ,p_segment30            IN VARCHAR2
)IS


	CURSOR csr_get_date_details (
				p_assignment_id  NUMBER
				,p_effective_date DATE) IS
	SELECT scl.segment21 commencing_date
	,scl.segment23 date_ending
	FROM   per_all_assignments_f         asg
	,hr_soft_coding_keyflex        scl
	WHERE  asg.assignment_id           = p_assignment_id
	AND    asg.soft_coding_keyflex_id    = scl.soft_coding_keyflex_id
	AND    p_effective_date
	BETWEEN asg.effective_start_date AND     asg.effective_end_date;

	date_details_rec csr_get_date_details%ROWTYPE;

	cursor csr_asg is
	select payroll_id,person_id
	from per_all_assignments_f PAA
	where assignment_id=p_assignment_id and
	p_effective_date between PAA.effective_start_date and PAA.effective_end_date;

	cursor csr_freq is
	select frequency
	from per_all_assignments_f PAA
	where assignment_id=p_assignment_id and
	p_effective_date between PAA.effective_start_date and PAA.effective_end_date;


	v_csr_asg csr_asg%rowtype;

	l_commencing_date DATE;
	l_date_ending     varchar2(50);
	l_frequency 	  varchar2(50);
	l_percentage number;
	l_ind_perc number;
	l_ind_working_hrs number;

BEGIN
  --
  hr_utility.trace('Entering extra_assignment_checks1');
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'NL') THEN
    --
	/*
	hr_utility.trace('p_normal_hours  '||p_normal_hours 	);
	hr_utility.trace('p_frequency     '||p_frequency  	);
	hr_utility.trace('p_segment1      '||p_segment1  	);
	hr_utility.trace('p_segment2      '||p_segment2  	);
	hr_utility.trace('p_segment3      '||p_segment3  	);
	hr_utility.trace('p_segment4      '||p_segment4  	);
	hr_utility.trace('p_segment5      '||p_segment5  	);
	hr_utility.trace('p_segment6      '||p_segment6  	);
	hr_utility.trace('p_segment7      '||p_segment7  	);
	hr_utility.trace('p_segment8      '||p_segment8  	);
	hr_utility.trace('p_segment9      '||p_segment9  	);
	hr_utility.trace('p_segment10     '||p_segment10 	);
	hr_utility.trace('p_segment11     '||p_segment11 	);
	hr_utility.trace('p_segment12     '||p_segment12 	);
	hr_utility.trace('p_segment13     '||p_segment13 	);
	hr_utility.trace('p_segment14     '||p_segment14 	);
	hr_utility.trace('p_segment15     '||p_segment15 	);
	hr_utility.trace('p_segment16     '||p_segment16 	);
	hr_utility.trace('p_segment17     '||p_segment17 	);
	hr_utility.trace('p_segment18     '||p_segment18 	);
	hr_utility.trace('p_segment19     '||p_segment19 	);
	hr_utility.trace('p_segment20     '||p_segment20 	);
	hr_utility.trace('p_segment21     '||p_segment21 	);
	hr_utility.trace('p_segment22     '||p_segment22 	);
	hr_utility.trace('p_segment23     '||p_segment23 	);
	hr_utility.trace('p_segment24     '||p_segment24 	);
	hr_utility.trace('p_segment25     '||p_segment25 	);
	hr_utility.trace('p_segment26     '||p_segment26 	);
	hr_utility.trace('p_segment27     '||p_segment27 	);
	hr_utility.trace('p_segment28     '||p_segment28 	);
	hr_utility.trace('p_segment29     '||p_segment29 	);
	hr_utility.trace('p_segment30     '||p_segment30 	);
	*/
	open csr_asg;
	fetch csr_asg into v_csr_asg;
	close csr_asg;

	IF v_csr_asg.payroll_id is NULL THEN
		v_csr_asg.payroll_id := glo_payroll_id;
	END IF;
	l_frequency:=p_frequency;
	IF p_frequency IS NULL then
		l_frequency := NULL;
	ELSIF p_frequency =hr_api.g_varchar2 then
		open csr_freq;
		fetch csr_freq into l_frequency ;
		close csr_freq;
	END if;

	validate_tax_code_combinations(v_csr_asg.person_id	,p_assignment_id
	,v_csr_asg.payroll_id	,p_effective_date
	,p_segment11	,p_segment4 	,p_segment7  	,p_segment9);

	validate_spl_indicators(p_segment10,p_assignment_id,p_effective_date);

	IF p_segment21 = hr_api.g_varchar2 THEN
		open csr_get_date_details(p_assignment_id,p_effective_date);
		hr_utility.trace('DATE1');
		fetch csr_get_date_details into date_details_rec;
		l_commencing_date := fnd_date.canonical_to_date(date_details_rec.commencing_date);
		close csr_get_date_details;
	ELSE
		l_commencing_date := fnd_date.canonical_to_date(p_segment21);
	END IF;

	IF p_segment23 = hr_api.g_varchar2 THEN
		open csr_get_date_details(p_assignment_id,p_effective_date);
		fetch csr_get_date_details into date_details_rec;
		l_date_ending := fnd_date.canonical_to_date(date_details_rec.date_ending);
		close csr_get_date_details;
	ELSE
		l_date_ending := fnd_date.canonical_to_date(p_segment23);
	END IF;

	IF p_segment28 IS NULL THEN
		l_ind_working_hrs := NULL;
	ELSIF p_segment28 <>  hr_api.g_varchar2 then
		l_ind_working_hrs:=round(FND_NUMBER.CANONICAL_TO_NUMBER(p_segment28),2);
	ELSE
		l_ind_working_hrs := hr_api.g_number;
	END if;

	IF p_segment29 IS NULL THEN
		l_percentage := NULL;
	ELSIF p_segment29 <> hr_api.g_varchar2 THEN
		l_percentage := FND_NUMBER.CANONICAL_TO_NUMBER(p_segment29);
	ELSE
		l_percentage := hr_api.g_number;
	END IF;

	IF p_segment20 IS NULL THEN
		l_ind_perc := NULL;
	ELSIF p_segment20 <> hr_api.g_varchar2 THEN
		l_ind_perc := FND_NUMBER.CANONICAL_TO_NUMBER(p_segment20);
	ELSE
		l_ind_perc := hr_api.g_number;
	END IF;


	other_validations(p_assignment_id
		,p_effective_date,l_commencing_date ,l_date_ending
		,p_segment2		,p_segment3
		,l_ind_working_hrs	,l_ind_perc
		,l_percentage		,l_frequency,p_normal_hours);

	glo_payroll_id := NULL;
	--
  END IF;
  --
  hr_utility.trace('Leaving extra_assignment_checks');
  --
END extra_assignment_checks1;

END hr_nl_extra_asg_rules;

/
