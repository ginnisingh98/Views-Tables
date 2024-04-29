--------------------------------------------------------
--  DDL for Package Body PER_RI_CRP_DEFAULT_SETTINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CRP_DEFAULT_SETTINGS" AS
/* $Header: perricrpd.pkb 120.9 2008/05/12 14:08:26 viviswan noship $ */

Procedure create_hook;

PROCEDURE write_log(p_retcode			 IN NUMBER,
		    p_message_token1		 IN VARCHAR2,
		    p_message_token2		 IN VARCHAR2)
IS

BEGIN
	   FND_MESSAGE.SET_NAME('PER','PER_RI_WB_CRP_DEFAULTS');
	   FND_MESSAGE.SET_TOKEN('OBJECT',p_message_token1);
	   FND_MESSAGE.SET_TOKEN('BG',p_message_token2);
	   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
END write_log;

function get_dflt_first_end_date (p_basic_period_type  in varchar2,
				  p_periods_per_period in number,
				  p_session_date       in date ) return date is
 l_day_of_month   number(2) := to_number(to_char(p_session_date,'DD')) ;
 l_return_value   date      := null ;
 begin


   if ( p_basic_period_type = 'W' ) then
      -- First period end date should be start_date + 6
      -- If FPED is start_date + 7, the start_date is not included
      -- in the payroll process.
      -- In forms, this value for Weekly payroll is entered by user.
      l_return_value := p_session_date + 6 ;

   elsif ( p_basic_period_type = 'SM' ) then

      if ( l_day_of_month = 1 ) then

	l_return_value :=  trunc(p_session_date,'month') + 14 ;

      elsif ( l_day_of_month between 2 and 15 ) then

	l_return_value := last_day(p_session_date) ;

      else

        l_return_value := trunc(add_months(p_session_date,1),'month') + 14  ;

      end if;

   elsif ( p_basic_period_type = 'CM' ) then

      if ( l_day_of_month = 1 ) then

         l_return_value := last_day(add_months(p_session_date,p_periods_per_period - 1 )) ;

      else

         l_return_value := last_day(add_months(p_session_date,p_periods_per_period)) ;
     end if;

  end if;

  return ( l_return_value ) ;

 end get_dflt_first_end_date ;


PROCEDURE create_el_api		  (p_element_name 	   	 IN VARCHAR2,
		  	      	   p_bg_id		 	 IN NUMBER,
		  	           p_std_link_flag		 IN VARCHAR2,
		  	           p_legislation_code       	 IN VARCHAR2,
			           p_retcode 		 	 OUT nocopy NUMBER,
			           p_errbuff	 	 	 OUT nocopy VARCHAR2)

IS

  	 -- IN variables
   	 l_element_type_id    		  PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
	 l_effective_date     		  DATE;
	 l_costable_type              	  PAY_ELEMENT_LINKS_F.COSTABLE_TYPE%TYPE := 'N';
	 l_verify_element_link	 	  NUMBER;

	 -- OUT variables
	 l_element_link_id   		  PAY_ELEMENT_LINKS_F.ELEMENT_LINK_ID%TYPE;
	 l_comment_id 			  PAY_ELEMENT_LINKS_F.COMMENT_ID%TYPE;
	 l_object_version_number 	  PAY_ELEMENT_LINKS_F.OBJECT_VERSION_NUMBER%TYPE;
	 l_effective_start_date		  DATE;
	 l_effective_end_date   	  DATE;


	 -- Declare  a cursor to capture the element type and effective start date
	 CURSOR csr_element IS
		SELECT element_type_id,effective_start_date
		FROM   PAY_ELEMENT_TYPES_F
		WHERE  ELEMENT_NAME     = p_element_name
		AND    LEGISLATION_CODE = p_legislation_code;

BEGIN

	 p_retcode :=0;/* Setting initial value*/

     	 OPEN  csr_element;
  	 FETCH csr_element INTO l_element_type_id,l_effective_date;
	 CLOSE csr_element;

	 SELECT COUNT(*) INTO l_verify_element_link
	 FROM   PAY_ELEMENT_LINKS_F
	 WHERE  element_type_id     = l_element_type_id
	 AND    business_group_id   = p_bg_id
	 AND    organization_id     is null
	 AND    people_group_id     is null
	 AND    job_id              is null
	 AND    position_id         is null
	 AND    grade_id            is null
	 AND    location_id         is null
	 AND    employment_category is null
	 AND    payroll_id	    is null
 	 AND    pay_basis_id        is null;  /* CHECKS MADE TO ENSURE THAT IT IS AN OPEN ELEMENT LINK*/


	 IF (l_verify_element_link <>0) THEN
	 	 	p_retcode  := 1;
	 	 	p_errbuff  := 'Warning : CRP Default Program may not function properly as Element Links under the name ' || p_element_name || ' already exists(continuing creation of other data) for business group ID = ';
	 	 	write_log(1,p_errbuff,p_bg_id);

	 ELSE

	 PAY_ELEMENT_LINK_API.CREATE_ELEMENT_LINK(P_VALIDATE            	  => false,
	 					  P_EFFECTIVE_DATE 		  => l_effective_date,
						  P_ELEMENT_TYPE_ID 		  => l_element_type_id,
						  P_BUSINESS_GROUP_ID 		  => p_bg_id,
						  P_COSTABLE_TYPE		  => l_costable_type,
						  P_PAYROLL_ID 			  => null,
						  P_JOB_ID 			  => null,
						  P_POSITION_ID 		  => null,
						  P_PEOPLE_GROUP_ID		  => null,
						  P_COST_ALLOCATION_KEYFLEX_ID    => null,
						  P_ORGANIZATION_ID 		  => null,
						  P_LOCATION_ID 		  => null,
						  P_GRADE_ID 			  => null,
						  P_BALANCING_KEYFLEX_ID 	  => null,
						  P_ELEMENT_SET_ID 		  => null,
						  P_PAY_BASIS_ID 		  => null,
						  P_LINK_TO_ALL_PAYROLLS_FLAG 	  => 'N',
						  P_STANDARD_LINK_FLAG 		  => p_std_link_flag,
						  P_TRANSFER_TO_GL_FLAG 	  => 'N',
						  P_COMMENTS 			  => null,
						  P_EMPLOYMENT_CATEGORY 	  => null,
						  P_QUALIFYING_AGE 		  => null,
						  P_QUALIFYING_LENGTH_OF_SERVICE  => null,
						  P_QUALIFYING_UNITS 		  => null,
						  P_ATTRIBUTE_CATEGORY 		  => null,
						  P_ATTRIBUTE1 			  => null,
						  P_ATTRIBUTE2 			  => null,
						  P_ATTRIBUTE3 			  => null,
						  P_ATTRIBUTE4 			  => null,
						  P_ATTRIBUTE5 			  => null,
						  P_ATTRIBUTE6 			  => null,
						  P_ATTRIBUTE7 			  => null,
						  P_ATTRIBUTE8 			  => null,
						  P_ATTRIBUTE9 			  => null,
						  P_ATTRIBUTE10 		  => null,
						  P_ATTRIBUTE11 		  => null,
						  P_ATTRIBUTE12 		  => null,
						  P_ATTRIBUTE13 		  => null,
						  P_ATTRIBUTE14 		  => null,
						  P_ATTRIBUTE15 		  => null,
						  P_ATTRIBUTE16 		  => null,
						  P_ATTRIBUTE17 		  => null,
						  P_ATTRIBUTE18 		  => null,
						  P_ATTRIBUTE19 		  => null,
						  P_ATTRIBUTE20 		  => null,
						  P_COST_SEGMENT1 		  => null,
						  P_COST_SEGMENT2 		  => null,
						  P_COST_SEGMENT3 		  => null,
						  P_COST_SEGMENT4 		  => null,
						  P_COST_SEGMENT5 		  => null,
						  P_COST_SEGMENT6 		  => null,
						  P_COST_SEGMENT7 		  => null,
						  P_COST_SEGMENT8 		  => null,
						  P_COST_SEGMENT9 		  => null,
						  P_COST_SEGMENT10 		  => null,
						  P_COST_SEGMENT11 		  => null,
						  P_COST_SEGMENT12 		  => null,
						  P_COST_SEGMENT13 		  => null,
						  P_COST_SEGMENT14 		  => null,
						  P_COST_SEGMENT15 		  => null,
						  P_COST_SEGMENT16 		  => null,
						  P_COST_SEGMENT17 		  => null,
						  P_COST_SEGMENT18 		  => null,
						  P_COST_SEGMENT19 		  => null,
						  P_COST_SEGMENT20 		  => null,
						  P_COST_SEGMENT21 		  => null,
						  P_COST_SEGMENT22 		  => null,
						  P_COST_SEGMENT23 		  => null,
						  P_COST_SEGMENT24 		  => null,
						  P_COST_SEGMENT25 		  => null,
						  P_COST_SEGMENT26 		  => null,
						  P_COST_SEGMENT27 		  => null,
						  P_COST_SEGMENT28 		  => null,
						  P_COST_SEGMENT29 		  => null,
						  P_COST_SEGMENT30 		  => null,
						  P_BALANCE_SEGMENT1 		  => null,
						  P_BALANCE_SEGMENT2 		  => null,
						  P_BALANCE_SEGMENT3 		  => null,
						  P_BALANCE_SEGMENT4 		  => null,
						  P_BALANCE_SEGMENT5 		  => null,
						  P_BALANCE_SEGMENT6 		  => null,
						  P_BALANCE_SEGMENT7 		  => null,
						  P_BALANCE_SEGMENT8 		  => null,
						  P_BALANCE_SEGMENT9 		  => null,
						  P_BALANCE_SEGMENT10 		  => null,
						  P_BALANCE_SEGMENT11 		  => null,
						  P_BALANCE_SEGMENT12 		  => null,
						  P_BALANCE_SEGMENT13 		  => null,
						  P_BALANCE_SEGMENT14 		  => null,
						  P_BALANCE_SEGMENT15 		  => null,
						  P_BALANCE_SEGMENT16 		  => null,
						  P_BALANCE_SEGMENT17 		  => null,
						  P_BALANCE_SEGMENT18 		  => null,
						  P_BALANCE_SEGMENT19 		  => null,
						  P_BALANCE_SEGMENT20 		  => null,
						  P_BALANCE_SEGMENT21 		  => null,
						  P_BALANCE_SEGMENT22 		  => null,
						  P_BALANCE_SEGMENT23 		  => null,
						  P_BALANCE_SEGMENT24 		  => null,
						  P_BALANCE_SEGMENT25 		  => null,
						  P_BALANCE_SEGMENT26 		  => null,
						  P_BALANCE_SEGMENT27 		  => null,
						  P_BALANCE_SEGMENT28 		  => null,
						  P_BALANCE_SEGMENT29 		  => null,
						  P_BALANCE_SEGMENT30 		  => null,
						  P_COST_CONCAT_SEGMENTS 	  => null,
						  P_BALANCE_CONCAT_SEGMENTS	  => null,
						  P_ELEMENT_LINK_ID 		  => l_element_link_id,
						  P_COMMENT_ID 			  => l_comment_id,
						  P_OBJECT_VERSION_NUMBER 	  => l_object_version_number,
						  P_EFFECTIVE_START_DATE 	  => l_effective_start_date,
						  P_EFFECTIVE_END_DATE	 	  => l_effective_end_date );

	p_errbuff  := 'Element Links ' || p_element_name || ' has been created successfully for business group ID = ';
	write_log(0,p_errbuff,p_bg_id);

	END IF;



	EXCEPTION
	WHEN OTHERS THEN
 	p_retcode := 2;
 	p_errbuff := 'CRP Default data has not been created and all data has been rolled back because and error occurred while trying to create Element Link for ' || p_element_name || SQLERRM || SQLCODE;
 	write_log(2,p_errbuff,p_bg_id);


END create_el_api;


PROCEDURE create_salary_basis_api(p_name 			 IN VARCHAR2,
		  	      	  p_pay_basis_name 		 IN VARCHAR2,
                             	  p_bg_id	 	 	 IN NUMBER,
		  	     	  p_input_value_name 		 IN VARCHAR2,
			     	  p_element_name 		 IN VARCHAR2,
			     	  p_rate_name			 IN VARCHAR2,
			     	  p_pay_annualization_factor  	 IN NUMBER,
			     	  p_grade_annualization_factor   IN NUMBER,
			     	  p_legislation_code		 IN VARCHAR2,
			     	  p_retcode 			 OUT nocopy VARCHAR2,
			     	  p_errbuff	 		 OUT nocopy VARCHAR2)

IS
  	-- IN variables
  	l_input_value_id	       PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE;
        l_name			       PER_PAY_BASES.NAME%TYPE		 	   := p_name;
        l_pay_basis_name	       PER_PAY_BASES.PAY_BASIS%TYPE  		   := p_pay_basis_name;
        l_rate_id		       PAY_RATES.RATE_ID%TYPE;
	l_pay_annualization_factor     PER_PAY_BASES.PAY_ANNUALIZATION_FACTOR%TYPE := p_pay_annualization_factor;
	l_grade_annualization_factor   PER_PAY_BASES.GRADE_ANNUALIZATION_FACTOR%TYPE := p_grade_annualization_factor;
	l_verify_salary_basis 	       NUMBER;

	-- OUT Variables
	l_pay_basis_id  	       PER_PAY_BASES.PAY_BASIS_ID%TYPE			:= null;
	l_object_version_number        PAY_ELEMENT_LINKS_F.OBJECT_VERSION_NUMBER%TYPE	:= null;


	 -- Declare a cursor to capture input value id
	CURSOR csr_input_value_id IS
  	 SELECT i.input_value_id
	 FROM   PAY_INPUT_VALUES_F i,PAY_ELEMENT_TYPES_F e
	 WHERE  i.element_type_id  = e.element_type_id
	 AND    i.name             = p_input_value_name
	 AND    e.element_name     = p_element_name
	 AND    e.legislation_code = p_legislation_code; -- CHANGE THE LEGISLATION CODE ACCORDING TO REQUIREMENT

	-- Declare a cursor to capture rate basis id
	CURSOR csr_rate_id IS
   	 SELECT rate_id
	 FROM   PAY_RATES
	 WHERE  name = p_rate_name
	 and business_group_id = p_bg_id;

BEGIN
	p_retcode :=0;/* Setting initial value*/
    	OPEN  csr_input_value_id;
 	FETCH csr_input_value_id INTO l_input_value_id;
 	CLOSE csr_input_value_id;

 	OPEN  csr_rate_id;
	FETCH csr_rate_id INTO l_rate_id;
	CLOSE csr_rate_id;


	SELECT COUNT(*) INTO l_verify_salary_basis
	FROM   PER_PAY_BASES
	WHERE  name = p_name
        AND    business_group_id      = p_bg_id;

	IF (l_verify_salary_basis <>0) THEN
	 	p_retcode  := 1;
	 	p_errbuff  := 'Warning : CRP Default Program may not function properly as  Salary Basis under the name ' || p_name || ' already exists(continuing creation of other data) for business group ID = ';
	 	write_log(1,p_errbuff,p_bg_id);

	ELSE

	 -- Call the API to insert the Salary Basis

	HR_SALARY_BASIS_API.CREATE_SALARY_BASIS(P_VALIDATE	  	   	  => false,
						P_BUSINESS_GROUP_ID		  => p_bg_id,
					 	P_INPUT_VALUE_ID		  => l_input_value_id,
						P_RATE_ID			  => l_rate_id,
						P_NAME				  => l_name,
						P_PAY_BASIS			  => l_pay_basis_name,
						P_RATE_BASIS			  => null,
						P_PAY_ANNUALIZATION_FACTOR	  => l_pay_annualization_factor,
						P_GRADE_ANNUALIZATION_FACTOR  	  => l_grade_annualization_factor,
						P_ATTRIBUTE_CATEGORY		  => null,
						P_ATTRIBUTE1			  => null,
						P_ATTRIBUTE2			  => null,
						P_ATTRIBUTE3			  => null,
						P_ATTRIBUTE4			  => null,
						P_ATTRIBUTE5			  => null,
						P_ATTRIBUTE6			  => null,
						P_ATTRIBUTE7			  => null,
						P_ATTRIBUTE8			  => null,
						P_ATTRIBUTE9			  => null,
						P_ATTRIBUTE10			  => null,
						P_ATTRIBUTE11			  => null,
						P_ATTRIBUTE12			  => null,
						P_ATTRIBUTE13			  => null,
						P_ATTRIBUTE14			  => null,
						P_ATTRIBUTE15			  => null,
						P_ATTRIBUTE16			  => null,
						P_ATTRIBUTE17			  => null,
						P_ATTRIBUTE18			  => null,
						P_ATTRIBUTE19			  => null,
						P_ATTRIBUTE20			  => null,
						P_LAST_UPDATE_DATE		  => null,
						P_LAST_UPDATED_BY		  => null,
						P_LAST_UPDATE_LOGIN		  => null,
						P_CREATED_BY			  => null,
						P_CREATION_DATE			  => null,
						P_INFORMATION_CATEGORY		  => null,
						P_INFORMATION1			  => null,
						P_INFORMATION2			  => null,
						P_INFORMATION3			  => null,
						P_INFORMATION4			  => null,
						P_INFORMATION5			  => null,
						P_INFORMATION6			  => null,
						P_INFORMATION7			  => null,
						P_INFORMATION8			  => null,
						P_INFORMATION9			  => null,
						P_INFORMATION10			  => null,
						P_INFORMATION11			  => null,
						P_INFORMATION12			  => null,
						P_INFORMATION13			  => null,
						P_INFORMATION14		  	  => null,
						P_INFORMATION15		 	  => null,
						P_INFORMATION16		  	  => null,
						P_INFORMATION17		   	  => null,
						P_INFORMATION18		  	  => null,
						P_INFORMATION19		   	  => null,
						P_INFORMATION20		  	  => null,
						P_PAY_BASIS_ID			  => l_pay_basis_id,
						P_OBJECT_VERSION_NUMBER 	  => l_object_version_number);

	p_errbuff  := 'Salary Basis ' || p_name || ' has been created successfully for business group ID = ';
	write_log(0,p_errbuff,p_bg_id);


	END IF;

	EXCEPTION
	WHEN OTHERS THEN
 	p_retcode  := 2;
 	p_errbuff  := 'CRP Default data has not been created and all data has been rolled back because an error occurred while trying to create Salary Basis under the name ' || p_name;
 	write_log(2,p_errbuff,p_bg_id);


END create_salary_basis_api;



PROCEDURE create_payroll_api    (p_payroll_name			 IN VARCHAR2,
				 p_bg_id			 IN NUMBER,
			  	 p_effective_date		 IN DATE,
			  	 p_period_type			 IN VARCHAR2,
			  	 p_first_period_end_date	 IN DATE,
			  	 p_number_of_years		 IN NUMBER,
			  	 p_consolidation_set_name	 IN VARCHAR2,
                                 p_default_payment_method_id     IN NUMBER,
                                 p_payroll_id                    OUT nocopy NUMBER,
                   				 p_leg_code                      IN VARCHAR2,
			  	 p_retcode			 OUT nocopy NUMBER,
			  	 p_errbuff	 	 	 OUT nocopy VARCHAR2)

IS

	-- IN Variables
	l_leg_code              VARCHAR2(2) := p_leg_code;
	l_payroll_name 			PAY_PAYROLLS_F.PAYROLL_NAME%TYPE 	  := p_payroll_name;
	l_effective_date		DATE 				     	  := p_effective_date;
	l_period_type			PAY_PAYROLLS_F.PAYROLL_TYPE%TYPE 	  := p_period_type;
	l_first_period_end_date		PAY_PAYROLLS_F.FIRST_PERIOD_END_DATE%TYPE := p_first_period_end_date;
	l_number_of_years		PAY_PAYROLLS_F.NUMBER_OF_YEARS%TYPE	  := p_number_of_years;
	l_consolidation_set_id          PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_ID%TYPE;
        l_def_payment_method_id         PAY_PAYROLLS_F.DEFAULT_PAYMENT_METHOD_ID%type;
	l_verify_payroll  	        NUMBER;


	-- OUT Variables
        l_org_pay_method_usage_id	NUMBER;
        l_prl_object_version_number	PAY_ELEMENT_LINKS_F.OBJECT_VERSION_NUMBER%TYPE;
        l_opm_object_version_number	PAY_ELEMENT_LINKS_F.OBJECT_VERSION_NUMBER%TYPE;
        l_prl_effective_start_date	DATE;
        l_prl_effective_end_date	DATE;
        l_opm_effective_start_date	DATE;
        l_opm_effective_end_date	DATE;
        l_comment_id			NUMBER;


	-- Declare a Cursor to capture the consolidation set
	CURSOR csr_consolidation_set_id IS
		SELECT c.consolidation_set_id
		FROM   PAY_CONSOLIDATION_SETS c,PER_BUSINESS_GROUPS b
		WHERE  b.business_group_id      = p_bg_id
		AND    b.business_group_id      = c.business_group_id
		AND    c.consolidation_set_name = p_consolidation_set_name;

BEGIN

	p_retcode :=0;/* Setting initial value*/
	--hr_utility.trace_on(null,'TTT');

	OPEN  csr_consolidation_set_id;
	FETCH csr_consolidation_set_id INTO l_consolidation_set_id;
	CLOSE csr_consolidation_set_id;

	SELECT COUNT(*) INTO l_verify_payroll
	FROM   PAY_PAYROLLS_F
	WHERE  payroll_name           = p_payroll_name
	AND    business_group_id      = p_bg_id;

	--hr_utility.trace(' BG ID .....'        || p_bg_id);
	--hr_utility.trace(' Payroll Name '      || p_payroll_name);
	--hr_utility.trace(' l_verify Payroll ..'|| l_verify_payroll);

	IF (l_verify_payroll <>0 ) THEN
	 	p_retcode  := 1;
	 	p_errbuff  := 'Warning : CRP Default Program may not function properly as Payroll under the name ' || p_payroll_name || ' already exists(continuing creation of other data) for business group ID = ';
        	write_log(1,p_errbuff,p_bg_id);

                -- Get the id of the existing payroll with the same name
                SELECT distinct payroll_id into p_payroll_id
                FROM   PAY_PAYROLLS_F
                WHERE  payroll_name      = p_payroll_name
                AND    business_group_id = p_bg_id;
	ELSE

--       hr_utility.trace_on(null,'PRAM');
--       hr_utility.trace('l_payroll_name='||l_payroll_name);

       IF l_leg_code = 'US' Then
        PAY_PAYROLL_API.CREATE_PAYROLL(P_VALIDATE			=> null,
				       P_EFFECTIVE_DATE			=> l_effective_date,
				       P_PAYROLL_NAME			=> l_payroll_name,
				       P_PAYROLL_TYPE			=> null,
				       P_PERIOD_TYPE			=> l_period_type,
				       P_FIRST_PERIOD_END_DATE		=> l_first_period_end_date,
				       P_NUMBER_OF_YEARS		=> l_number_of_years,
				       P_PAY_DATE_OFFSET		=> 0,
				       P_DIRECT_DEPOSIT_DATE_OFFSET	=> 0,
				       P_PAY_ADVICE_DATE_OFFSET		=> 0,
				       P_CUT_OFF_DATE_OFFSET		=> 0,
				       P_MIDPOINT_OFFSET		=> null,
				       P_DEFAULT_PAYMENT_METHOD_ID	=> p_default_payment_method_id,
				       P_CONSOLIDATION_SET_ID		=> l_consolidation_set_id,
				       P_COST_ALLOCATION_KEYFLEX_ID	=> null,
				       P_SUSPENSE_ACCOUNT_KEYFLEX_ID	=> null,
				       P_NEGATIVE_PAY_ALLOWED_FLAG	=> 'N',
				       P_GL_SET_OF_BOOKS_ID		=> null,
				       P_SOFT_CODING_KEYFLEX_ID		=> null,
				       P_COMMENTS			=> null,
				       P_ATTRIBUTE_CATEGORY		=> null,
				       P_ATTRIBUTE1			=> null,
				       P_ATTRIBUTE2			=> null,
				       P_ATTRIBUTE3			=> null,
				       P_ATTRIBUTE4			=> null,
				       P_ATTRIBUTE5			=> null,
				       P_ATTRIBUTE6			=> null,
				       P_ATTRIBUTE7			=> null,
				       P_ATTRIBUTE8			=> null,
				       P_ATTRIBUTE9			=> null,
				       P_ATTRIBUTE10			=> null,
				       P_ATTRIBUTE11			=> null,
				       P_ATTRIBUTE12			=> null,
				       P_ATTRIBUTE13			=> null,
				       P_ATTRIBUTE14			=> null,
				       P_ATTRIBUTE15			=> null,
				       P_ATTRIBUTE16			=> null,
				       P_ATTRIBUTE17			=> null,
				       P_ATTRIBUTE18			=> null,
				       P_ATTRIBUTE19			=> null,
				       P_ATTRIBUTE20			=> null,
				       p_prl_information3       => 'N',  -- 'N','NO','No'
				       p_prl_information6       => 'L', --'Pre notification All',
				       P_ARREARS_FLAG			=> null,
				       P_PAYROLL_ID			=> p_payroll_id,
				       P_ORG_PAY_METHOD_USAGE_ID	=> l_org_pay_method_usage_id,
				       P_PRL_OBJECT_VERSION_NUMBER	=> l_prl_object_version_number,
				       P_OPM_OBJECT_VERSION_NUMBER	=> l_opm_object_version_number,
				       P_PRL_EFFECTIVE_START_DATE	=> l_prl_effective_start_date,
				       P_PRL_EFFECTIVE_END_DATE		=> l_prl_effective_end_date,
				       P_OPM_EFFECTIVE_START_DATE	=> l_opm_effective_start_date,
				       P_OPM_EFFECTIVE_END_DATE		=> l_opm_effective_end_date,
				       P_COMMENT_ID 			=> l_comment_id);

       ELSIF l_leg_code = 'GB' Then

               PAY_PAYROLL_API.CREATE_PAYROLL(P_VALIDATE			=> null,
				       P_EFFECTIVE_DATE			=> l_effective_date,
				       P_PAYROLL_NAME			=> l_payroll_name,
				       P_PAYROLL_TYPE			=> null,
				       P_PERIOD_TYPE			=> l_period_type,
				       P_FIRST_PERIOD_END_DATE		=> l_first_period_end_date,
				       P_NUMBER_OF_YEARS		=> l_number_of_years,
				       P_PAY_DATE_OFFSET		=> 0,
				       P_DIRECT_DEPOSIT_DATE_OFFSET	=> 0,
				       P_PAY_ADVICE_DATE_OFFSET		=> 0,
				       P_CUT_OFF_DATE_OFFSET		=> 0,
				       P_MIDPOINT_OFFSET		=> null,
				       P_DEFAULT_PAYMENT_METHOD_ID	=> p_default_payment_method_id,
				       P_CONSOLIDATION_SET_ID		=> l_consolidation_set_id,
				       P_COST_ALLOCATION_KEYFLEX_ID	=> null,
				       P_SUSPENSE_ACCOUNT_KEYFLEX_ID	=> null,
				       P_NEGATIVE_PAY_ALLOWED_FLAG	=> 'N',
				       P_GL_SET_OF_BOOKS_ID		=> null,
				       P_SOFT_CODING_KEYFLEX_ID		=> null,
				       P_COMMENTS			=> null,
				       P_ATTRIBUTE_CATEGORY		=> null,
				       P_ATTRIBUTE1			=> null,
				       P_ATTRIBUTE2			=> null,
				       P_ATTRIBUTE3			=> null,
				       P_ATTRIBUTE4			=> null,
				       P_ATTRIBUTE5			=> null,
				       P_ATTRIBUTE6			=> null,
				       P_ATTRIBUTE7			=> null,
				       P_ATTRIBUTE8			=> null,
				       P_ATTRIBUTE9			=> null,
				       P_ATTRIBUTE10			=> null,
				       P_ATTRIBUTE11			=> null,
				       P_ATTRIBUTE12			=> null,
				       P_ATTRIBUTE13			=> null,
				       P_ATTRIBUTE14			=> null,
				       P_ATTRIBUTE15			=> null,
				       P_ATTRIBUTE16			=> null,
				       P_ATTRIBUTE17			=> null,
				       P_ATTRIBUTE18			=> null,
				       P_ATTRIBUTE19			=> null,
				       P_ATTRIBUTE20			=> null,
				       P_ARREARS_FLAG			=> null,
				       P_PAYROLL_ID			=> p_payroll_id,
				       P_ORG_PAY_METHOD_USAGE_ID	=> l_org_pay_method_usage_id,
				       P_PRL_OBJECT_VERSION_NUMBER	=> l_prl_object_version_number,
				       P_OPM_OBJECT_VERSION_NUMBER	=> l_opm_object_version_number,
				       P_PRL_EFFECTIVE_START_DATE	=> l_prl_effective_start_date,
				       P_PRL_EFFECTIVE_END_DATE		=> l_prl_effective_end_date,
				       P_OPM_EFFECTIVE_START_DATE	=> l_opm_effective_start_date,
				       P_OPM_EFFECTIVE_END_DATE		=> l_opm_effective_end_date,
				       P_COMMENT_ID 			=> l_comment_id);
       END IF;

	p_errbuff  := 'Payroll ' || p_payroll_name || ' has been created successfully for business group ID = ';
	write_log(0,p_errbuff,p_bg_id);

  END IF;

	EXCEPTION
	WHEN OTHERS THEN
	p_retcode  := 2;
	p_errbuff  := 'CRP Default data has not been created and all data has been rolled back because an error occurred while trying to create Payroll under the name ' || p_payroll_name || SQLERRM || SQLCODE;
 	write_log(2,p_errbuff,p_bg_id);


END create_payroll_api;



PROCEDURE create_payment_methods_api	(p_payment_method_name		 IN VARCHAR2,
					 p_bg_id			 IN NUMBER,
		 	 		 p_effective_date		 IN DATE,
				  	 p_payment_type_name		 IN VARCHAR2,
				  	 p_territory_code		 IN VARCHAR2,
				  	 p_seg1				 IN VARCHAR2,
				  	 p_seg2 			 IN VARCHAR2,
			  	 	 p_seg3				 IN NUMBER,
			  		 p_seg4				 IN NUMBER,
			  		 p_seg5				 IN VARCHAR2,
			 	 	 p_seg6 			 IN VARCHAR2,
				  	 p_pmeth_info1			 IN VARCHAR2,
				  	 p_pmeth_info2			 IN VARCHAR2,
                                         --bugfix 4219436. payment method id is needed to create an opmu
                                         p_org_payment_method_id         OUT nocopy NUMBER,
			  	 	 p_retcode			 OUT nocopy NUMBER,
			  	 	 p_errbuff	 	         OUT nocopy VARCHAR2)

IS

	-- In Variables
	l_effective_date		DATE 				     	  		:= p_effective_date;
	l_payment_method_name	 	PAY_ORG_PAYMENT_METHODS_F.ORG_PAYMENT_METHOD_NAME%TYPE	:= p_payment_method_name;
	l_payment_type_id	 	PAY_ORG_PAYMENT_METHODS_F.PAYMENT_TYPE_ID%TYPE;
	l_currency_code 	 	FND_CURRENCIES.CURRENCY_CODE%TYPE;
	l_verify_payment_method         NUMBER;


	-- OUT Variables
	l_effective_start_date		DATE;
 	l_effective_end_date		DATE;
	l_object_version_number  	PAY_ELEMENT_LINKS_F.OBJECT_VERSION_NUMBER%TYPE;
	l_asset_code_combination_id	NUMBER;
	l_comment_id			NUMBER;
	l_external_account_id		NUMBER := null;


	-- Declare a cursor to capture the payment type id
	CURSOR csr_payment_type_id IS
		SELECT payment_type_id
		FROM   PAY_PAYMENT_TYPES
		WHERE  payment_type_name = p_payment_type_name
		AND    territory_code    = p_territory_code;

	-- Declare a cursor to capture the currency code
	CURSOR csr_currency_code IS
		SELECT currency_code
		FROM   FND_CURRENCIES
		WHERE  issuing_territory_code = p_territory_code;



BEGIN
	p_retcode :=0;/* Setting initial value*/

	OPEN  csr_payment_type_id;
	FETCH csr_payment_type_id INTO l_payment_type_id;
	CLOSE csr_payment_type_id;

	OPEN  csr_currency_code;
	FETCH csr_currency_code INTO l_currency_code;
	CLOSE csr_currency_code;


	SELECT COUNT(*) INTO l_verify_payment_method
	FROM   PAY_ORG_PAYMENT_METHODS_F
	WHERE  org_payment_method_name = p_payment_method_name
	AND    business_group_id       = p_bg_id;

	IF (l_verify_payment_method <> 0) THEN
	 	p_retcode  := 1;
	 	p_errbuff  := 'Warning : CRP Default Program may not function properly as Payment Method under the name ' || p_payment_method_name || ' already exists(continuing creation of other data) for business group ID = ';
	 	write_log(1,p_errbuff,p_bg_id);

                SELECT distinct org_payment_method_id into p_org_payment_method_id
	        FROM   PAY_ORG_PAYMENT_METHODS_F
                WHERE  org_payment_method_name = p_payment_method_name
	        AND    business_group_id       = p_bg_id;

	ELSE

	PAY_ORG_PAYMENT_METHOD_API.CREATE_ORG_PAYMENT_METHOD(P_VALIDATE				=> false,
							     P_EFFECTIVE_DATE			=> l_effective_date,
							     P_LANGUAGE_CODE			=> HR_API.USERENV_LANG,
							     P_BUSINESS_GROUP_ID		=> p_bg_id,
							     P_ORG_PAYMENT_METHOD_NAME		=> l_payment_method_name,
							     P_PAYMENT_TYPE_ID			=> l_payment_type_id,
							     P_CURRENCY_CODE			=> l_currency_code,
							     P_ATTRIBUTE_CATEGORY		=> null,
							     P_ATTRIBUTE1			=> null,
							     P_ATTRIBUTE2			=> null,
							     P_ATTRIBUTE3			=> null,
							     P_ATTRIBUTE4			=> null,
							     P_ATTRIBUTE5			=> null,
							     P_ATTRIBUTE6			=> null,
							     P_ATTRIBUTE7			=> null,
							     P_ATTRIBUTE8			=> null,
							     P_ATTRIBUTE9			=> null,
							     P_ATTRIBUTE10			=> null,
							     P_ATTRIBUTE11			=> null,
							     P_ATTRIBUTE12			=> null,
							     P_ATTRIBUTE13			=> null,
							     P_ATTRIBUTE14			=> null,
							     P_ATTRIBUTE15			=> null,
							     P_ATTRIBUTE16			=> null,
							     P_ATTRIBUTE17			=> null,
							     P_ATTRIBUTE18			=> null,
							     P_ATTRIBUTE19			=> null,
							     P_ATTRIBUTE20			=> null,
							     P_PMETH_INFORMATION1		=> p_pmeth_info1,
							     P_PMETH_INFORMATION2		=> p_pmeth_info2,
							     P_PMETH_INFORMATION3		=> null,
							     P_PMETH_INFORMATION4		=> null,
							     P_PMETH_INFORMATION5		=> null,
							     P_PMETH_INFORMATION6		=> null,
							     P_PMETH_INFORMATION7		=> null,
							     P_PMETH_INFORMATION8		=> null,
							     P_PMETH_INFORMATION9		=> null,
							     P_PMETH_INFORMATION10		=> null,
							     P_PMETH_INFORMATION11		=> null,
							     P_PMETH_INFORMATION12		=> null,
							     P_PMETH_INFORMATION13		=> null,
							     P_PMETH_INFORMATION14		=> null,
							     P_PMETH_INFORMATION15		=> null,
							     P_PMETH_INFORMATION16		=> null,
							     P_PMETH_INFORMATION17		=> null,
							     P_PMETH_INFORMATION18		=> null,
							     P_PMETH_INFORMATION19		=> null,
							     P_PMETH_INFORMATION20		=> null,
							     P_COMMENTS				=> null,
							     P_SEGMENT1				=> p_seg1,
							     P_SEGMENT2				=> p_seg2,
							     P_SEGMENT3				=> p_seg3,
							     P_SEGMENT4				=> p_seg4,
							     P_SEGMENT5				=> p_seg5,
							     P_SEGMENT6				=> p_seg6,
							     P_SEGMENT7				=> null,
							     P_SEGMENT8				=> null,
							     P_SEGMENT9				=> null,
							     P_SEGMENT10			=> null,
							     P_SEGMENT11			=> null,
							     P_SEGMENT12			=> null,
							     P_SEGMENT13			=> null,
							     P_SEGMENT14			=> null,
							     P_SEGMENT15			=> null,
							     P_SEGMENT16			=> null,
							     P_SEGMENT17			=> null,
							     P_SEGMENT18			=> null,
							     P_SEGMENT19			=> null,
							     P_SEGMENT20			=> null,
							     P_SEGMENT21			=> null,
							     P_SEGMENT22			=> null,
							     P_SEGMENT23			=> null,
							     P_SEGMENT24			=> null,
							     P_SEGMENT25			=> null,
							     P_SEGMENT26			=> null,
							     P_SEGMENT27			=> null,
							     P_SEGMENT28			=> null,
							     P_SEGMENT29			=> null,
							     P_SEGMENT30			=> null,
							     P_CONCAT_SEGMENTS			=> null,
							     P_GL_SEGMENT1			=> null,
							     P_GL_SEGMENT2			=> null,
							     P_GL_SEGMENT3			=> null,
							     P_GL_SEGMENT4			=> null,
							     P_GL_SEGMENT5			=> null,
							     P_GL_SEGMENT6			=> null,
							     P_GL_SEGMENT7			=> null,
							     P_GL_SEGMENT8			=> null,
							     P_GL_SEGMENT9			=> null,
							     P_GL_SEGMENT10			=> null,
							     P_GL_SEGMENT11			=> null,
							     P_GL_SEGMENT12			=> null,
							     P_GL_SEGMENT13			=> null,
							     P_GL_SEGMENT14			=> null,
							     P_GL_SEGMENT15			=> null,
							     P_GL_SEGMENT16			=> null,
							     P_GL_SEGMENT17			=> null,
							     P_GL_SEGMENT18			=> null,
							     P_GL_SEGMENT19			=> null,
							     P_GL_SEGMENT20			=> null,
							     P_GL_SEGMENT21			=> null,
							     P_GL_SEGMENT22			=> null,
							     P_GL_SEGMENT23			=> null,
							     P_GL_SEGMENT24			=> null,
							     P_GL_SEGMENT25			=> null,
							     P_GL_SEGMENT26			=> null,
							     P_GL_SEGMENT27			=> null,
							     P_GL_SEGMENT28			=> null,
							     P_GL_SEGMENT29			=> null,
							     P_GL_SEGMENT30			=> null,
							     P_GL_CONCAT_SEGMENTS		=> null,
							     P_SETS_OF_BOOK_ID			=> null,
							     P_THIRD_PARTY_PAYMENT		=> 'N',
							     P_ORG_PAYMENT_METHOD_ID		=> p_org_payment_method_id,
							     P_EFFECTIVE_START_DATE		=> l_effective_start_date,
							     P_EFFECTIVE_END_DATE		=> l_effective_end_date,
							     P_OBJECT_VERSION_NUMBER		=> l_object_version_number,
							     P_ASSET_CODE_COMBINATION_ID	=> l_asset_code_combination_id,
							     P_COMMENT_ID			=> l_comment_id,
							     P_EXTERNAL_ACCOUNT_ID 		=> l_external_account_id);

	p_errbuff  := 'Payment Method ' || p_payment_method_name || ' has been created successfully for business group ID = ';
	write_log(0,p_errbuff,p_bg_id);


	END IF;


	EXCEPTION
	WHEN OTHERS THEN
 	p_retcode  := 2;
 	p_errbuff  := 'CRP Default data has not been created and all data has been rolled back because an error occurred while trying to create Payment Method '|| p_payment_method_name || SQLERRM || SQLCODE;
 	write_log(2,p_errbuff,p_bg_id);




END create_payment_methods_api;

-- @desc   : Procedure to attach a valid payment method to a payroll
-- @action : creates an org pay method usage [OPMU]
-- @misc   : part of bugfix 4219436
PROCEDURE attach_valid_pay_method_api (p_payroll_id                IN NUMBER
                                      ,p_org_payment_method_id     IN NUMBER
                                      ,p_bg_id	 	  	   IN NUMBER --needed only for write_log
                                      ,p_effective_start_date      IN DATE
                                      ,p_retcode                   OUT nocopy NUMBER
                                      ,p_errbuff                   OUT nocopy VARCHAR2)
IS
     --variables
     l_org_pay_method_usage_id    NUMBER;
     l_effective_end_date         DATE;
     l_rowid                      VARCHAR2(20);
     l_reccount                   NUMBER;
BEGIN
     p_retcode := 0;

     SELECT count(*) into l_reccount
     FROM   PAY_ORG_PAY_METHOD_USAGES_F
     WHERE  payroll_id            = p_payroll_id
     AND    org_payment_method_id = p_org_payment_method_id;

     IF (l_reccount <> 0) THEN
	 	p_retcode  := 1;
	 	p_errbuff  := 'Warning : CRP Default Program may not function properly as payment method usage was not created since it already exists';
	 	write_log(1,p_errbuff,p_bg_id);
     ELSE
          IF (p_payroll_id is null or p_org_payment_method_id is null or p_effective_start_date is null) THEN
	 	p_retcode  := 1;
	 	p_errbuff  := 'Warning : CRP Default Program may not function properly as payment method was not attached to the payroll';
	 	write_log(1,p_errbuff,p_bg_id);
          ELSE
                -- This procedure has been used in the 'Define Payroll' form(PAYWSDPG.fmb) to
                -- attach a 'valid payment method' to a payroll.
                -- From pyopu01t.pkb v115.4
                PAY_ORG_PAY_METH_USAGES_F_PKG.Insert_Row(X_Rowid                   => l_rowid
                                             ,X_Org_Pay_Method_Usage_Id => l_org_pay_method_usage_id
                                             ,X_Effective_Start_Date    => p_effective_start_date
                                             ,X_Effective_End_Date      => l_effective_end_date
                                             ,X_Payroll_Id              => p_payroll_id
                                             ,X_Org_Payment_Method_Id   => p_org_payment_method_id);

                 p_errbuff := 'Payment Method with Id ' || to_char(p_org_payment_method_id) || ' has been attached to the Payroll = ' || to_char(p_payroll_id);
                 write_log(0, p_errbuff,p_bg_id);
           END IF;
      END IF;

      EXCEPTION
      WHEN OTHERS THEN
      p_retcode  := 2;
      p_errbuff  := 'CRP Default data has not been created and all data has been rolled back.An error occured while creating a OPMU' || SQLERRM || SQLCODE;
      write_log(2,p_errbuff,p_bg_id);

END attach_valid_pay_method_api;


PROCEDURE create_org_info_api	 (p_effec_date                 	   IN DATE,
				  p_bg_id			   IN NUMBER,
 				  p_org_id		           IN NUMBER,
 				  p_org_info_type	           IN VARCHAR2,
  				  p_org_info1			   IN VARCHAR2,
 	 			  p_org_info2			   IN VARCHAR2,
	  			  p_org_info3		           IN VARCHAR2,
  			  	  p_org_info4			   IN VARCHAR2,
			 	  p_org_info10			   IN VARCHAR2,
 				  p_retcode			   OUT nocopy NUMBER,
 				  p_errbuff	 	 	   OUT nocopy VARCHAR2)

 IS

 	-- variables

 	l_verify_org_info		NUMBER;

 	-- OUT Variables
 	l_org_information_id		HR_ORGANIZATION_INFORMATION.ORG_INFORMATION_ID%TYPE;
 	l_object_version_number  	PAY_ELEMENT_LINKS_F.OBJECT_VERSION_NUMBER%TYPE;




 BEGIN
 	p_retcode :=0;/* Setting initial value*/

 	SELECT COUNT(*) INTO l_verify_org_info
 	FROM   HR_ORGANIZATION_INFORMATION
 	WHERE  organization_id       = p_org_id
	AND    org_information_context = p_org_info_type;


	IF (l_verify_org_info <> 0) THEN
		 	p_retcode  := 1;
		 	p_errbuff  := 'Warning : CRP Default Program may not function properly as ' || p_org_info_type || ' already exists(continuing creation of other data) for business group ID = ';
		 	write_log(1,p_errbuff,p_bg_id);

	ELSE

 	HR_ORGANIZATION_API.CREATE_ORG_INFORMATION(P_VALIDATE			=> false,
 						   P_EFFECTIVE_DATE		=> p_effec_date,
 						   P_ORGANIZATION_ID		=> p_org_id,
 						   P_ORG_INFO_TYPE_CODE		=> p_org_info_type,
 						   P_ORG_INFORMATION1		=> p_org_info1,
 						   P_ORG_INFORMATION2		=> p_org_info2,
 						   P_ORG_INFORMATION3		=> p_org_info3,
 						   P_ORG_INFORMATION4		=> p_org_info4,
 						   P_ORG_INFORMATION5		=> null,
 						   P_ORG_INFORMATION6		=> null,
 						   P_ORG_INFORMATION7		=> null,
 						   P_ORG_INFORMATION8		=> null,
 						   P_ORG_INFORMATION9		=> null,
 						   P_ORG_INFORMATION10		=> p_org_info10,
 						   P_ORG_INFORMATION11		=> null,
 						   P_ORG_INFORMATION12		=> null,
 						   P_ORG_INFORMATION13		=> null,
 						   P_ORG_INFORMATION14		=> null,
 						   P_ORG_INFORMATION15		=> null,
 						   P_ORG_INFORMATION16		=> null,
 						   P_ORG_INFORMATION17		=> null,
 						   P_ORG_INFORMATION18		=> null,
 						   P_ORG_INFORMATION19		=> null,
 						   P_ORG_INFORMATION20		=> null,
 						   P_ATTRIBUTE_CATEGORY		=> null,
 						   P_ATTRIBUTE1			=> null,
 						   P_ATTRIBUTE2			=> null,
 						   P_ATTRIBUTE3			=> null,
 						   P_ATTRIBUTE4			=> null,
 						   P_ATTRIBUTE5			=> null,
 						   P_ATTRIBUTE6			=> null,
 						   P_ATTRIBUTE7			=> null,
 						   P_ATTRIBUTE8			=> null,
 						   P_ATTRIBUTE9			=> null,
 						   P_ATTRIBUTE10		=> null,
 						   P_ATTRIBUTE11		=> null,
 						   P_ATTRIBUTE12		=> null,
 						   P_ATTRIBUTE13		=> null,
 						   P_ATTRIBUTE14		=> null,
 						   P_ATTRIBUTE15		=> null,
 						   P_ATTRIBUTE16		=> null,
 						   P_ATTRIBUTE17		=> null,
 						   P_ATTRIBUTE18		=> null,
 						   P_ATTRIBUTE19		=> null,
 						   P_ATTRIBUTE20		=> null,
 						   P_ORG_INFORMATION_ID		=> l_org_information_id,
 						   P_OBJECT_VERSION_NUMBER 	=> l_object_version_number);

  	p_errbuff  := 'Organization Information ' || p_org_info_type || ' has been created successfully for business group ID = ';
	write_log(0,p_errbuff,p_bg_id);

 	END IF;

	EXCEPTION
	WHEN OTHERS THEN
 	p_retcode  := 1;
 	p_errbuff  := 'CRP Default data has not been created and all data has been rolled back because an error occurred while trying to create for ' || p_org_info_type || SQLERRM || SQLCODE;
 	write_log(2,p_errbuff,p_bg_id);


END create_org_info_api;


PROCEDURE populate(p_errbuf		OUT NOCOPY VARCHAR2,
          	   p_retcode		OUT NOCOPY NUMBER,
          	   p_business_group_id  IN NUMBER,
                   p_short_code		IN VARCHAR2)

IS
  	 -- variables
 	 l_bg_info			VARCHAR2(200)				   := null;
	 l_retcode 			NUMBER					   := null;
	 l_errbuff			VARCHAR2(200)				   := null;
	 l_bg_id			NUMBER					   := null;
	 l_bg_start_date 	 	DATE					   := null;
	 l_bg_name			PER_BUSINESS_GROUPS.NAME%TYPE		   := null;
	 l_org_id			NUMBER					   := null;
	 l_element_name			PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE      := null;
	 l_leg_code			VARCHAR2(2)				   := null;
	 l_short_code       VARCHAR2(9)  					   := null;
	 --bugfix 4219436 vars
	 l_crp_check_payment_method_id  NUMBER				:= null;
	 l_crp_nacha_payment_method_id  NUMBER				:= null;
	 l_crp_sm_payroll_id            NUMBER              		:= null;
	 l_crp_w_payroll_id             NUMBER              		:= null;
	 l_crp_m_payroll_id             NUMBER              		:= null;
	 l_crp_bacs_payment_method_id   NUMBER          		:= null;
	 l_crp_cheque_payment_method_id NUMBER             		:= null;
         l_crp_run                      NUMBER                          :=0;

	-- Declare a cursor to get a list of US Business groups remove
	-- the last AND clause to apply to all US  and UK BG's, during
	-- actual implementation
	CURSOR csr_business_group_info(p_bg_id NUMBER) IS
	 	SELECT business_group_id,date_from,name,legislation_code
	 	FROM   PER_BUSINESS_GROUPS
	 	WHERE  business_group_id is not null
		and    business_group_id = p_bg_id;

	-- Declare cursor to capture the Organization ID from Business Group ID and Name
	CURSOR csr_bg_org_id(p_bg_id NUMBER, p_bg_name VARCHAR2) IS
	 	SELECT organization_id
	 	FROM   HR_ORGANIZATION_UNITS
	 	WHERE  business_group_id = p_bg_id
	 	AND    name              = p_bg_name;

	-- Decalare a cursor to fetch the element name
	CURSOR csr_element_name(p_bg_id NUMBER) IS
		SELECT element_name
		FROM   PAY_ELEMENT_TYPES_F
		WHERE  business_group_id  = p_bg_id
		AND    indirect_only_flag = 'N'
		AND    legislation_code is not null;

      -- Declare a cursor to detect if the CRP default is already run
      -- for the current BG
      CURSOR csr_business_group(p_bg_id NUMBER) IS
            SELECT count(*) as crp_run
            FROM   per_ri_requests prr,
                   fnd_concurrent_requests fcr
            WHERE  business_group_id = p_bg_id
            AND    SETUP_TASK_CODE = 'GENERATE_DEFAULT_SETTINGS'
            AND    prr.request_id = fcr.request_id
            and    status_code = 'C';

BEGIN

	OPEN csr_business_group(p_business_group_id);
		FETCH csr_business_group INTO l_crp_run;
	CLOSE csr_business_group;

          -- If the program has been run for this business group donot run again.
         IF l_crp_run > 0 THEN

      	  l_bg_info  := 'Business Group id: ' || p_business_group_id;
    	  write_log(0,l_bg_info,' ');

	    write_log(0,' ',' ');
	    write_log(0,'The Default Settings for this business group has already been run. You cannot do so again.',' ');
            write_log(0,' ',' ');
          return;
         END IF;

	IF (p_short_code = '' OR p_short_code is null)  THEN
		l_short_code := 'CRP ';
	ELSE
		l_short_code := p_short_code || ' ';
	END IF;

	p_retcode := 0;
	write_log(0,' ',' ');
	write_log(0,'NOTE : In case the program returns with an ERROR status,the following data that get created will be rolled back completely',' ');
	write_log(0,' ',' ');

	OPEN csr_business_group_info(p_business_group_id);
		FETCH csr_business_group_info INTO l_bg_id,l_bg_start_date,l_bg_name,l_leg_code;
	CLOSE csr_business_group_info;

	OPEN csr_bg_org_id(l_bg_id,l_bg_name);
		FETCH csr_bg_org_id into l_org_id;
	CLOSE csr_bg_org_id;

	l_bg_info  := 'Business Group id: ' || l_bg_id || '      Business Group name: ' || l_bg_name || '      Short Code: '|| l_short_code ;
	write_log(0,l_bg_info,' ');

	---
	-- HARDCODING VALUES FOR US BUSINESS GROUP STARTS HERE
	---
	if l_leg_code = 'US' THEN

	  -- Call The procedure to create element links
	  create_el_api (p_element_name 	   => 'Regular Salary',
	 	    	 p_bg_id	 	   => l_bg_id,
	 	    	 p_std_link_flag	   => null,
	 	   	 p_legislation_code 	   => 'US',
	 	   	 p_retcode 		   => l_retcode,
		   	 p_errbuff		   => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	p_retcode := l_retcode;
	  	IF l_retcode = 2 THEN
	  		rollback;
	  		return;
	  	END IF;
	  END IF;


	  -- Call The procedure to create element links
	  create_el_api (p_element_name 	   => 'Regular Wages',
	 	 	 p_bg_id	 	   => l_bg_id,
	 	   	 p_std_link_flag	   => null,
	 	  	 p_legislation_code 	   => 'US',
	 	   	 p_retcode 		   => l_retcode,
		   	 p_errbuff		   => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;

	  -- Call The procedure to create element links
	  create_el_api (p_element_name 	   => 'Workers Compensation',
	   	 	 p_bg_id	 	   => l_bg_id,
	   	   	 p_std_link_flag	   => null,
	   	  	 p_legislation_code 	   => 'US',
	   	   	 p_retcode 		   => l_retcode,
		   	 p_errbuff		   => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;

	  -- Call The procedure to create element links
	  create_el_api (p_element_name 	   => 'VERTEX',
	   	 	 p_bg_id	 	   => l_bg_id,
	   	   	 p_std_link_flag	   => null,
	   	  	 p_legislation_code 	   => 'US',
	   	   	 p_retcode 		   => l_retcode,
		   	 p_errbuff		   => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;


	  -- Open the cursor for all elements with indirect only flag set to N and create element links for the same
	  OPEN csr_element_name(l_bg_id);

	  LOOP -- For every element with indirect only flag = 'N'
	 	 FETCH csr_element_name INTO l_element_name;
	 	 EXIT WHEN csr_element_name%NOTFOUND;

	 	  -- Call The procedure to create element links
		  create_el_api (p_element_name 	   => l_element_name,
		 	   	p_bg_id	 	   	   => l_bg_id,
		 	   	p_std_link_flag	   	   => null,
		 	   	p_legislation_code 	   => 'US',
		 	   	p_retcode 		   => l_retcode,
		   	 	p_errbuff		   => l_errbuff);

		 IF l_retcode = 2 OR l_retcode = 1 THEN
		 	  	p_retcode := l_retcode;
		 	  	IF l_retcode = 2 THEN
		 	      		rollback;
		 	  		return;
		 	  	END IF;
	  	 END IF;

	  END LOOP;
	  CLOSE csr_element_name;

          -- bugfix 4219436.
	  -- order of creation: payment_method -> payroll -> opmu[attaching payment method to payroll]

          -- Calls to procedure to create payment methods
	  -- Payment methods are to be created before payrolls as the default payment methods are attached
	  -- to a payroll during the payroll creation.
	  create_payment_methods_api (p_payment_method_name		 => l_short_code || 'Check',
	  	  	  	      p_bg_id	 	  	 	 => l_bg_id,
	  	  		      p_effective_date 	                 => l_bg_start_date,
	  	  		      p_payment_type_name		 => 'Check',
	  	  		      p_territory_code			 => 'US',
	  	  	              p_seg1	  	                 => l_short_code || 'Test Account',
	  	  		      p_seg2	 			 => 'S',
	  	  		      p_seg3				 => '123',
	  	  		      p_seg4				 => '000000123',
	  	  		      p_seg5				 => 'Citibank',
	  	  		      p_seg6	 			 => 'New York',
	  	  		      p_pmeth_info1			 => null,
	  	  		      p_pmeth_info2			 => null,
				      p_org_payment_method_id            => l_crp_check_payment_method_id,
	  	  		      p_retcode				 => l_retcode,
	  			      p_errbuff				 => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;

	  create_payment_methods_api   (p_payment_method_name		 => l_short_code || 'NACHA',
	   				p_bg_id	 	  		 => l_bg_id,
	   		 	 	p_effective_date		 => l_bg_start_date,
	   			  	p_payment_type_name		 => 'NACHA',
	   			  	p_territory_code		 => 'US',
	  			  	p_seg1				 => l_short_code || 'Test Account', -- Account name
					p_seg2 			 	 => 'S',		-- Account Type (savings/current etc)
					p_seg3				 => '123',		-- Number
					p_seg4				 => '000000123',
					p_seg5				 => 'Citibank',		-- Bank name
			  	 	p_seg6 				 => 'New York',		-- City
			  	 	p_pmeth_info1			 => null,
			  	 	p_pmeth_info2			 => null,
				        p_org_payment_method_id          => l_crp_nacha_payment_method_id,
	  	  	 	 	p_retcode			 => l_retcode,
					p_errbuff			 => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;

	  create_payroll_api 	(p_payroll_name		 	 => l_short_code || 'Semi-monthly Payroll',
	  	   		 p_bg_id	 	  	 => l_bg_id,
	  	  		 p_effective_date		 => l_bg_start_date,
	  	  		 p_period_type			 => 'Semi-Month',
	  	  		 p_first_period_end_date	 => get_dflt_first_end_date('SM',1,l_bg_start_date),
	  	  		 p_number_of_years		 => 10,
	  	  		 p_consolidation_set_name	 => l_bg_name,
				 p_default_payment_method_id     => l_crp_check_payment_method_id,
				 p_payroll_id                    => l_crp_sm_payroll_id,
				 p_leg_code          => l_leg_code,
	  	 	 	 p_retcode			 => l_retcode,
			 	 p_errbuff			 => l_errbuff);

          IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;


	 create_payroll_api 	(p_payroll_name		 	 => l_short_code || 'Weekly Payroll',
	 	 	  	 p_bg_id	 	  	 => l_bg_id,
	  	  		 p_effective_date		 => l_bg_start_date,
	 	 	  	 p_period_type			 => 'Week',
	  	  		 p_first_period_end_date	 => get_dflt_first_end_date('W',1,l_bg_start_date),
	 	 	  	 p_number_of_years		 => 10,
	 	 	  	 p_consolidation_set_name	 => l_bg_name,
				 p_default_payment_method_id     => l_crp_check_payment_method_id,
				 p_payroll_id                    => l_crp_w_payroll_id,
				 p_leg_code          => l_leg_code,
	 	 	 	 p_retcode			 => l_retcode,
				 p_errbuff			 => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;

	 --@@ bugfix 4219436
	 --attach valid payment methods to the payrolls
	 attach_valid_pay_method_api(p_payroll_id                => l_crp_w_payroll_id
	                             ,p_org_payment_method_id    => l_crp_nacha_payment_method_id
                                     ,p_bg_id	 	  	 => l_bg_id
                                     ,p_effective_start_date     => l_bg_start_date
                                     ,p_retcode                  => l_retcode
				     ,p_errbuff                  => l_errbuff);

	 IF l_retcode = 2 OR l_retcode = 1 THEN
	                p_retcode := l_retcode;
			IF l_retcode = 2 THEN
			          rollback;
				  return;
			END IF;
	 END IF;

         attach_valid_pay_method_api(p_payroll_id                => l_crp_sm_payroll_id
	                             ,p_org_payment_method_id    => l_crp_nacha_payment_method_id
                                     ,p_bg_id	 	  	 => l_bg_id
                                     ,p_effective_start_date     => l_bg_start_date
                                     ,p_retcode                  => l_retcode
				     ,p_errbuff                  => l_errbuff);

	 IF l_retcode = 2 OR l_retcode = 1 THEN
	                p_retcode := l_retcode;
			IF l_retcode = 2 THEN
			          rollback;
				  return;
			END IF;
	 END IF;
	 -- bugfix 4219436 @@

	 create_salary_basis_api(p_name				=> l_short_code || 'Monthly Salary',
	 	  		 p_pay_basis_name 		=> 'MONTHLY',
	 	  		 p_bg_id			=> l_bg_id,
	 	  		 p_input_value_name   		=> 'Monthly Salary',
	 	  		 p_element_name 		=> 'Regular Salary',
	 	  		 p_rate_name			=> null,
	 	  		 p_pay_annualization_factor     => 12,
	 	  		 p_grade_annualization_factor   => null,
	 	  		 p_legislation_code		=> 'US',
	 	  		 p_retcode			=> l_retcode,
	 	  		 p_errbuff			=> l_errbuff);


	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  p_retcode := l_retcode;
	  	  IF l_retcode = 2 THEN
	  	  	rollback;
	  	  	return;
	   	  END IF;
	  END IF;

	  create_salary_basis_api(p_name			=> l_short_code || 'Hourly Salary',
	 	  	  	 p_pay_basis_name 		=> 'HOURLY',
	 	  	  	 p_bg_id			=> l_bg_id,
	 	  	  	 p_input_value_name   		=> 'Rate',
	 	  	  	 p_element_name 		=> 'Regular Wages',
	 	  	  	 p_rate_name			=> null,
	 	  	  	 p_pay_annualization_factor     => 2000,
	 	  	  	 p_grade_annualization_factor   => null,
	 	  	  	 p_legislation_code		=> 'US',
	 	  	  	 p_retcode			=> l_retcode,
	 		  	 p_errbuff			=> l_errbuff);


	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	 p_retcode := l_retcode;
	  	 IF l_retcode = 2 THEN
	   	 	rollback;
	   	 	return;
	   	 END IF;
	  END IF;

	  create_org_info_api    (p_effec_date                 	  => l_bg_start_date,
	  			 p_bg_id			  => l_bg_id,
	  			 p_org_id		          => l_org_id,
	  			 p_org_info_type	          => 'Work Day Information',
	   			 p_org_info1			  => '9:00',  --start-time/
	   			 p_org_info2			  => '17:00', --end time/
	   			 p_org_info3		          => '40',    --working hours
	   			 p_org_info4			  => 'W',     --frequency
	 			 p_org_info10			  => null,
 			 	 p_retcode			  => l_retcode,
				 p_errbuff			  => l_errbuff);

	 IF l_retcode = 2 OR l_retcode = 1 THEN
	 	  	p_retcode := l_retcode;
	 	  	IF l_retcode = 2 THEN
	 	      		rollback;
	 	  		return;
	 	  	END IF;
	  END IF;

	 END IF;

	---
	-- HARDCODING VALUES FOR UK BUSINESS GROUP STARTS HERE
	---
	IF l_leg_code = 'GB' THEN

	 create_el_api  (p_element_name 	  	 => 'PAYE',
	 	 	 p_bg_id	 	  	 => l_bg_id,
	 		 p_std_link_flag		 => null,
		 	 p_legislation_code 		 => 'GB',
			 p_retcode 			 => l_retcode,
			 p_errbuff			 => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	 	  	p_retcode := l_retcode;
	 	  	IF l_retcode = 2 THEN
	 	      		rollback;
	 	  		return;
	 	  	END IF;
	  END IF;

	  create_el_api  (p_element_name 	  	 => 'NI',
	 	 	 p_bg_id	 	  	 => l_bg_id,
	 	 	 p_std_link_flag		 => null,
	 		 p_legislation_code 		 => 'GB',
	 		 p_retcode 			 => l_retcode,
			 p_errbuff			 => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	 	  	p_retcode := l_retcode;
	 	  	IF l_retcode = 2 THEN
	 	      		rollback;
	 	  		return;
	 	  	END IF;
	  END IF;


      OPEN csr_element_name(l_bg_id);

	   LOOP -- For every element with indirect only flag = 'N'
	 	 FETCH csr_element_name INTO l_element_name;
	  	 EXIT WHEN csr_element_name%NOTFOUND;

	 	 -- Call The procedure to create element links
	 	 create_el_api(p_element_name 	  	 => l_element_name,
	  	  	       p_bg_id	 	  	 => l_bg_id,
	  	  	       p_std_link_flag		 => null,
	  	  	       p_legislation_code 	 => 'GB',
	  	  	       p_retcode 		 => l_retcode,
			       p_errbuff		 => l_errbuff);

	   	 IF l_retcode = 2 OR l_retcode = 1 THEN
		 	  	p_retcode := l_retcode;
		 	  	IF l_retcode = 2 THEN
		 	      		rollback;
		 	  		return;
		 	  	END IF;
	  	 END IF;
	  	 END LOOP;
	  CLOSE csr_element_name;

	  create_payment_methods_api   (p_payment_method_name	 => l_short_code || 'Cheque',
	  				p_bg_id	 	  	 => l_bg_id,
	  		 	 	p_effective_date	 => l_bg_start_date,
	  			  	p_payment_type_name	 => 'Cheque',
	  			  	p_territory_code	 => 'GB',
	  			  	p_seg1			 => '80', -- Bank name --> In this case Bank of Scotland
					p_seg2 			 => null,  --- Not applicable
					p_seg3			 => '000001',   --- Sort Code
					p_seg4			 => '000000100', --- A/c number
					p_seg5			 => 'Test Account',  --- A/c Name
			  	 	p_seg6 			 => '0', -- Account type 0 stands for standard account
			  	 	p_pmeth_info1		 => null,  -- BACS User Number
					p_pmeth_info2            => null, -- BACS Limit
					p_org_payment_method_id  => l_crp_cheque_payment_method_id,
	 	  	 	 	p_retcode		 => l_retcode,
					p_errbuff		 => l_errbuff);


	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;

	  create_payment_methods_api   (p_payment_method_name	 => l_short_code || 'BACS',
	   				p_bg_id	 	  	 => l_bg_id,
	   		 	 	p_effective_date	 => l_bg_start_date,
	   			  	p_payment_type_name	 => 'BACS Tape',
	   			  	p_territory_code 	 => 'GB',
					p_seg1			 => '80', -- Bank name --> In this case Bank of Scotland
					p_seg2 			 => null,  --- Not applicable
					p_seg3			 => '000123',   --- Sort Code
					p_seg4			 => '000000100', --- A/c number
					p_seg5			 => 'Test Account',  --- A/c Name
			  	 	p_seg6 			 => '0', -- Account type 0 stands for standard account
			  	 	p_pmeth_info1		 => '10',  -- BACS User Number
					p_pmeth_info2            => '1000', -- BACS Limit
					p_org_payment_method_id  => l_crp_bacs_payment_method_id,
					p_retcode		 => l_retcode,
					p_errbuff		 => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	 	  	p_retcode := l_retcode;
	 	  	IF l_retcode = 2 THEN
	 	      		rollback;
	 	  		return;
	 	  	END IF;
	  END IF;

	  -- Call the procedure to create Payroll
	  create_payroll_api(p_payroll_name		 => l_short_code || 'Monthly Payroll',
		  	     p_bg_id	 	  	 => l_bg_id,
	  		     p_effective_date		 => l_bg_start_date,
	  		     p_period_type		 => 'Calendar Month',
	  		     p_first_period_end_date	 => get_dflt_first_end_date('CM',1,l_bg_start_date),
	  		     p_number_of_years		 => 10,
	  		     p_consolidation_set_name	 => l_bg_name,
       	             p_default_payment_method_id => l_crp_cheque_payment_method_id, --null,
			     p_payroll_id                => l_crp_m_payroll_id,
   				 p_leg_code          => l_leg_code,
	 	  	     p_retcode			 => l_retcode,
			     p_errbuff			 => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;


	  -- Call the procedure to create Payroll
	  create_payroll_api    (p_payroll_name		 	 => l_short_code || 'Weekly Payroll',
	 	  		 p_bg_id	 	  	 => l_bg_id,
	 	  		 p_effective_date		 => l_bg_start_date,
	 	  		 p_period_type			 => 'Week',
	 	  		 p_first_period_end_date	 => get_dflt_first_end_date('W',1,l_bg_start_date),
	 	  		 p_number_of_years		 => 10,
	 	  		 p_consolidation_set_name	 => l_bg_name,
				 p_default_payment_method_id     =>l_crp_cheque_payment_method_id,--null,
				 p_payroll_id                    => l_crp_w_payroll_id,
				 p_leg_code          => l_leg_code,
	 	 	  	 p_retcode			 => l_retcode,
				 p_errbuff			 => l_errbuff);

	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;


	 --@@ bugfix 4219436
	 --attach valid payment methods to the payrolls
	 attach_valid_pay_method_api(p_payroll_id                => l_crp_w_payroll_id
	                             ,p_org_payment_method_id    => l_crp_bacs_payment_method_id
                                     ,p_bg_id	 	  	 => l_bg_id
                                     ,p_effective_start_date     => l_bg_start_date
                                     ,p_retcode                  => l_retcode
				     ,p_errbuff                  => l_errbuff);

	 IF l_retcode = 2 OR l_retcode = 1 THEN
	                p_retcode := l_retcode;
			IF l_retcode = 2 THEN
			          rollback;
				  return;
			END IF;
	 END IF;

         attach_valid_pay_method_api(p_payroll_id                => l_crp_m_payroll_id
	                             ,p_org_payment_method_id    => l_crp_bacs_payment_method_id
                                     ,p_bg_id	 	  	 => l_bg_id
                                     ,p_effective_start_date     => l_bg_start_date
                                     ,p_retcode                  => l_retcode
				     ,p_errbuff                  => l_errbuff);

	 IF l_retcode = 2 OR l_retcode = 1 THEN
	                p_retcode := l_retcode;
			IF l_retcode = 2 THEN
			          rollback;
				  return;
			END IF;
	 END IF;
	 -- bugfix 4219436 @@

	  -- Creating org info
	  create_org_info_api(p_effec_date          	  => l_bg_start_date,
	  		      p_bg_id			  => l_bg_id,
	  		      p_org_id		      	  => l_org_id,
	   		      p_org_info_type	  	  => 'Tax Details References',
	   		      p_org_info1		  => '123/London',  --start-time/tax district
	   		      p_org_info2		  => 'London',  --end time/
	   		      p_org_info3		  => 'London',  --working hours
	   		      p_org_info4		  => 'London',  --frequency
	 		      p_org_info10		  => 'UK',      --reporting country
 			      p_retcode			  => l_retcode,
			      p_errbuff			  => l_errbuff);

 	  IF l_retcode = 2 OR l_retcode = 1 THEN
	  	  	p_retcode := l_retcode;
	  	  	IF l_retcode = 2 THEN
	  	      		rollback;
	  	  		return;
	  	  	END IF;
	  END IF;

	END IF;


	commit;

	create_hook();

END populate;

Procedure create_hook As

Cursor csr_api_hook (c_module_name      varchar2
                    ,c_api_module_type  varchar2
                    ,c_api_hook_type    varchar2 ) Is
   Select ahm.api_module_id
        , ahk.api_hook_id
   From hr_api_hooks ahk
       ,hr_api_modules ahm
   Where ahm.module_name     = c_module_name
     and ahm.api_module_type = c_api_module_type
     and ahk.api_hook_type   = c_api_hook_type
     and ahk.api_module_id   = ahm.api_module_id;


Cursor csr_api_hook_call(c_hook_id Number) Is
    Select hc.api_hook_call_id
    From  hr_api_hook_calls hc
    Where hc.api_hook_id   = c_hook_id
      and hc.legislation_code Is Null
      and hc.call_package   = 'PER_RI_CREATE_CRP_EMPLOYEE'
      and hc.call_procedure = 'SET_USER_ACCT_DETAILS'
      and application_id = 800;


Cursor csr_hook_report  Is
   Select text
     From hr_api_user_hook_reports
   Where session_id = userenv('SESSIONID')
   Order By line;

l_api_hook_id           Number;
l_api_module_id         Number;
l_api_hook_call_id      Number;
l_object_version_number Number;
l_hook_report           csr_api_hook_call%RowType;


 Begin

   Open csr_api_hook('CREATE_USER_ACCT','BP','BP');
   Fetch csr_api_hook Into l_api_module_id,l_api_hook_id;
   Close csr_api_hook;

   Open csr_api_hook_call(l_api_hook_id);
   Fetch csr_api_hook_call Into l_api_hook_call_id;

   If csr_api_hook_call%NotFound Then

   /*  hr_api_hook_call_api.create_api_hook_call
                                  (p_validate                   => false
                                  ,p_effective_date             => Sysdate
                                  ,p_api_hook_id                => l_api_hook_id
                                  ,p_api_hook_call_type         => 'PP'
                                  ,p_sequence                   => 2000
                                  ,p_enabled_flag               => 'Y'
                                  ,p_call_package               => 'PER_RI_CREATE_CRP_EMPLOYEE'
                                  ,p_call_procedure             => 'SET_USER_ACCT_DETAILS'
                                  ,p_api_hook_call_id           => l_api_hook_call_id
                                  ,p_object_version_number      => l_object_version_number
                                  );*/
       hr_app_api_hook_call_internal.CREATE_APP_API_HOOK_CALL
			       (
				 P_VALIDATE                     => false
				,P_EFFECTIVE_DATE               => Sysdate
				,P_API_HOOK_ID                  => l_api_hook_id
				,P_API_HOOK_CALL_TYPE           => 'PP'
				,P_SEQUENCE                     => 1499
				,P_APPLICATION_ID               => 800
				,P_APP_INSTALL_STATUS           => 'I_OR_S'
				,P_ENABLED_FLAG                 => 'Y'
				,P_CALL_PACKAGE                 =>  'PER_RI_CREATE_CRP_EMPLOYEE'
				,P_CALL_PROCEDURE               => 'SET_USER_ACCT_DETAILS'
				,P_API_HOOK_CALL_ID             =>  l_api_hook_call_id
				,P_OBJECT_VERSION_NUMBER        =>  l_object_version_number
			       );

   End If;

   Close csr_api_hook_call;

   hr_api_user_hooks_utility.create_hooks_add_report(l_api_module_id);

   For l_hook_report In csr_hook_report Loop

   fnd_file.put_line(fnd_file.log,l_hook_report.text);

   End Loop;

   hr_api_user_hooks_utility.clear_hook_report;

 End create_hook ;


End per_ri_crp_default_settings;

/
